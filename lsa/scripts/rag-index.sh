#!/usr/bin/env bash
# lsa/scripts/rag-index.sh — plugin-shipped, portable copy of
# scripts/rag-index.sh (rag-plugin-plug-and-play, relocate-and-run-in-place
# epic). Thin host-side wrapper: builds/updates the local RAG index for a
# given scope by shelling out to `docker run` against the image built from
# this plugin's own Dockerfile at lsa/docker/.
#
# Usage: lsa/scripts/rag-index.sh [<scope>]
#   <scope>   path, relative to the TARGET repo root, to index. Default: "."
#             (whole repo). A directory or a single file.
#
# Mounts the TARGET repo read-only at /repo and its local index volume
# (.lsa/.rag-index/, gitignored — see .gitignore) read-write at /index. The
# target repo is resolved independently of wherever this plugin's own
# Dockerfile/rag_cli.py physically live (R4) — see the `plugin_root` vs.
# `repo_root` split below.
#
# Structural chunking (Markdown H2/H3, bash function/block, fixed-window
# fallback), local CPU-only embedding, and the vector store all run inside
# the container (lsa/docker/rag_cli.py) — this script does none of that
# itself, per this repo's "deterministic work is scripted" convention
# applied to the *invocation*, not a reimplementation of the container's
# logic.
#
# Relocation note (R3, R4 — .lsa/features/rag-plugin-plug-and-play/
# relocate-and-run-in-place/requirements.md): the root-level
# scripts/rag-index.sh resolves a single `repo_root` (via `git rev-parse
# --show-toplevel`) and uses it BOTH as the Docker build context AND as the
# target repo to index — correct only because that script always ships
# alongside the repo it indexes. This plugin-shipped copy splits the two:
#   - `plugin_root` — where THIS script's own Dockerfile/rag_cli.py live.
#     Prefers `$CLAUDE_PLUGIN_ROOT` (set by Claude Code when this script
#     runs as an installed plugin — see lsa/skills/init/SKILL.md's
#     established dual-mode precedent), falling back to a path derived from
#     this script's own location (`${BASH_SOURCE[0]}`-relative) when
#     `$CLAUDE_PLUGIN_ROOT` is unset/empty (e.g. a marketplace checkout run
#     directly). Never derived from the target repo.
#   - `repo_root` — the TARGET repo being indexed. Same resolution as
#     before this epic (`git rev-parse --show-toplevel` from CWD, falling
#     back to `pwd`), fully independent of `plugin_root`. Still used for
#     `INDEX_DIR`, the `-v "${repo_root}:/repo:ro"` mount, and the
#     gitignore-list computation.
#
# Exit codes (R1, R2, R5 — .lsa/features/rag-context-engine-and-repo-indexing/
# index-query-pipeline/requirements.md):
#   0 — index built/updated (including "nothing changed, every chunk skipped")
#   2 — Docker daemon unreachable — a distinct, LOUD infrastructure fault,
#       reported by name, never conflated with an ordinary retrieval miss
#       (a miss is a query-side concept — see lsa/scripts/rag-query.sh)
#   1 — any other failure (image build failed, docker run crashed, ...)

set -uo pipefail
export LC_ALL=C

# plugin_root: where THIS script's own Dockerfile/rag_cli.py live. Prefer
# $CLAUDE_PLUGIN_ROOT (installed-plugin mode); otherwise derive it from this
# script's own path — lsa/scripts/rag-index.sh's parent's parent is lsa/,
# the plugin root (lsa/skills/init/SKILL.md:41 dual-mode precedent).
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  plugin_root="${CLAUDE_PLUGIN_ROOT}"
else
  plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# repo_root: the TARGET repo being indexed — unchanged resolution from
# before this epic, fully independent of plugin_root.
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

# Distinct tag from the root-level scripts/rag-index.sh's "rag-index:local"
# (R5: single shared tag, reused across every target repo — no
# target-repo-specific tag). Kept distinct from the root-level tag so the
# two build contexts (repo-root Dockerfile vs. lsa/docker/Dockerfile) never
# fight over the same image name/label when both are present, e.g. inside
# this very repo before dogfood-migration (epic 4) cuts over.
IMAGE_NAME="rag-index-plugin:local"
INDEX_DIR="${repo_root}/.lsa/.rag-index"
SCOPE="${1:-.}"

# Shared bounded docker_daemon_reachable() — was four near-identical
# copies across this repo (rag-index.sh, rag-query.sh,
# check-rag-index-fresh.sh, rag-bootstrap-check.sh); extracted during a PR
# review pass. Sourced via plugin_root (already resolved above), not a
# fresh ${BASH_SOURCE[0]} lookup — same self-location, no new resolution.
source "${plugin_root}/scripts/lib/docker-reachable.sh"

if ! command -v docker >/dev/null 2>&1; then
  printf 'FAULT: Docker daemon unreachable — the "docker" CLI is not on PATH.\n' >&2
  exit 2
fi

if ! docker_daemon_reachable; then
  printf 'FAULT: Docker daemon unreachable — is Docker running? (`docker info` failed or timed out)\n' >&2
  exit 2
fi

mkdir -p "${INDEX_DIR}"

# Stale-image detection (R1-R3 — .lsa/features/rag-context-engine-and-repo-
# indexing/index-freshness/requirements.md): the image existing is not the
# same as the image being current. A real incident this session: an edit to
# docker/rag_cli.py was silently not reflected in query behavior because
# `docker build -q` (Docker's own layer-cache invalidation) failed to pick
# up the change, and an "image exists, skip build" check meant nothing
# forced a rebuild either. Fix: hash Dockerfile + rag_cli.py on the host and
# compare against a `source-hash` label baked into the image.
#
# REVISED after a second real incident: an unconditional `--no-cache`
# rebuild (this comment's first draft) throws away the expensive
# pip-install and embedding-model-download layers on EVERY source edit, not
# just the one that changed -- and failed outright under network pressure
# ("DeadlineExceeded: context deadline exceeded" during `pip install`,
# observed directly this session). Docker's normal COPY-layer cache
# invalidation is reliable in the common case here: only the final
# COPY-rag_cli.py + ENTRYPOINT layers depend on the file that actually
# changes, so a plain cached `docker build` correctly reuses the
# pip/model layers and only rebuilds the cheap tail. Two-tier fix: try the
# cheap cached build first; verify the resulting label actually matches;
# only pay `--no-cache`'s full-rebuild cost as a fallback if the cached
# path still didn't pick up the change (a real, rare anomaly, not the
# common case).
#
# Both the hash inputs and the build context below read from `plugin_root`
# (where THIS script's own Dockerfile/rag_cli.py live) — NOT `repo_root`
# (the target repo being indexed). This is the R3/R4 split this epic exists
# to make.
SOURCE_HASH="$(cat "${plugin_root}/docker/Dockerfile" "${plugin_root}/docker/rag_cli.py" | shasum -a 256 | cut -d' ' -f1)"
CURRENT_SOURCE_HASH="$(docker image inspect "${IMAGE_NAME}" --format '{{ index .Config.Labels "source-hash" }}' 2>/dev/null || true)"

if [[ -z "${CURRENT_SOURCE_HASH}" || "${CURRENT_SOURCE_HASH}" != "${SOURCE_HASH}" ]]; then
  echo "Building ${IMAGE_NAME} from ${plugin_root}/docker (source changed or image missing/stale) ..." >&2
  if ! docker build -q -t "${IMAGE_NAME}" --label "source-hash=${SOURCE_HASH}" "${plugin_root}/docker" >/dev/null; then
    printf 'ERROR: docker build failed for %s\n' "${IMAGE_NAME}" >&2
    exit 1
  fi
  REBUILT_HASH="$(docker image inspect "${IMAGE_NAME}" --format '{{ index .Config.Labels "source-hash" }}' 2>/dev/null || true)"
  if [[ "${REBUILT_HASH}" != "${SOURCE_HASH}" ]]; then
    echo "Cached build did not pick up the source change — retrying with --no-cache ..." >&2
    if ! docker build --no-cache -q -t "${IMAGE_NAME}" --label "source-hash=${SOURCE_HASH}" "${plugin_root}/docker" >/dev/null; then
      printf 'ERROR: docker build (--no-cache fallback) failed for %s\n' "${IMAGE_NAME}" >&2
      exit 1
    fi
  fi
fi

# Gitignore-aware exclusion (R4-R5 — same requirements.md): the indexer's own
# hardcoded SKIP_DIR_NAMES list (lsa/docker/rag_cli.py) is whack-a-mole —
# `dist/` and `.remember/` each had to be added by hand as they were found
# leaking into the index. The real fix respects .gitignore directly,
# computed here on the host (the container has no access to `git`) and
# handed to the container as a dynamic exclusion list, checked IN ADDITION
# to (not instead of) the hardcoded safety net.
#
# `git ls-files --others --ignored --exclude-standard --directory` returns a
# mix of whole-directory entries (trailing "/", e.g. "dist/") and individual-
# file entries (no trailing "/") — verified directly against this repo: a
# directory with its own nested .gitignore (`.remember/`, which ignores
# itself via "* .remember/") produces BOTH the directory entry AND per-file
# entries beneath it, not one clean collapsed entry. Both shapes are written
# through unmodified; lsa/docker/rag_cli.py's load_ignored_list does the
# prefix-vs-exact-match split.
#
# Passed into the container as a mounted file rather than a CLI argument
# (could be arbitrarily long) — written into INDEX_DIR, which is already
# mounted read-write at /index, so no new mount/no new Docker Desktop
# file-sharing path is introduced. INDEX_DIR's basename (.rag-index) is
# itself in SKIP_DIR_NAMES, so this scratch file can never leak into the
# index even if cleanup below is skipped (e.g. the process is killed).
IGNORED_LIST_HOST="${INDEX_DIR}/.ignored-list.txt"
cleanup_ignored_list() {
  rm -f "${IGNORED_LIST_HOST}" 2>/dev/null || true
}
trap cleanup_ignored_list EXIT
git -C "${repo_root}" ls-files --others --ignored --exclude-standard --directory -- "${SCOPE}" \
  >"${IGNORED_LIST_HOST}" 2>/dev/null || true

# Plain command + rc=$? immediately after (NOT `if ! cmd; then rc=$?`) —
# bash's `!` negation overwrites the visible exit status before a nested
# `rc=$?` can capture the real code, so a genuine docker run failure would
# otherwise print the self-contradictory "(exit 0)" (confirmed live,
# multiple times, on a first index attempt against a freshly created repo).
# This is the same pattern rag-query.sh's --sha path already used correctly.
docker run --rm \
  -v "${repo_root}:/repo:ro" \
  -v "${INDEX_DIR}:/index" \
  "${IMAGE_NAME}" index --scope "${SCOPE}" --index-dir /index --repo-root /repo \
    --ignored-list /index/.ignored-list.txt
rc=$?
if [[ "${rc}" -ne 0 ]]; then
  # A `docker run` that fails because the daemon vanished mid-command is still
  # a daemon fault, not an ordinary tool error — re-check and report as such.
  if ! docker_daemon_reachable; then
    printf 'FAULT: Docker daemon unreachable — was reachable at start, is not now.\n' >&2
    exit 2
  fi
  printf 'ERROR: rag-index.sh failed (exit %s)\n' "${rc}" >&2
  exit 1
fi

exit 0
