#!/usr/bin/env bash
# lsa/scripts/rag-query.sh — plugin-shipped, portable copy of
# scripts/rag-query.sh (rag-plugin-plug-and-play, relocate-and-run-in-place
# epic). Thin host-side wrapper: queries the local RAG index built by
# lsa/scripts/rag-index.sh, returning top-ranked chunks with
# "path:start-end" citations by shelling out to `docker run` against the
# image built from this plugin's own Dockerfile at lsa/docker/.
#
# Usage: lsa/scripts/rag-query.sh [--sha <sha>] [--path <prefix>] "<query text>"
#
# Mounts the TARGET repo's local index volume (.lsa/.rag-index/, gitignored)
# at /index. The target repo is resolved independently of wherever this
# plugin's own Dockerfile/rag_cli.py physically live — see the
# `plugin_root` vs. `repo_root` split below (same split as rag-index.sh).
#
# stdout on success is a single JSON object: {"results": [...]}. A miss —
# no chunk is a good match — is reported as {"results": []} on exit 0, NEVER
# as a non-zero exit or an error message (R4: a miss is not a guess, and
# must be distinguishable from an error).
#
# --path <prefix> (R1-R5 — .lsa/features/rag-context-engine-and-repo-
# indexing/path-scoped-query-fix/requirements.md): passed straight through
# as the container's `query --path <prefix>` argument, which applies it as a
# real LanceDB pre-filter (`.where(..., prefilter=True)`) on the vector
# search itself — evaluated before the ANN top-K, not a host-side filter on
# an already-limited result list (see lsa/docker/rag_cli.py cmd_query).
# Independent of --sha; both may be given together (--sha's post-filter then
# runs on the already path-scoped results). A --path with no matching
# content reports the same {"results": []} / exit-0 miss contract as an
# ordinary miss (R5).
#
# --sha <sha> (R1, R2 — .lsa/features/rag-context-engine-and-repo-indexing/
# reconcile-wiring/requirements.md): after the normal query above returns,
# filter its candidate results to only paths UNCHANGED between <sha> and HEAD
# (`git diff --quiet <sha> HEAD -- <path>`), per path — a host-side filter
# layered on top of the existing query, no index/schema change. A path that
# changed, or a <sha> that does not resolve to a real commit at all (every
# path then fails the same `git diff` check), is discarded; if that leaves
# zero results, this reports the exact same {"results": []} / exit-0 miss
# contract as an ordinary miss (R2) — never a new error shape. The `git diff`
# check runs against the TARGET repo (`repo_root`), never the plugin's own
# location. Requires `jq` on PATH (only when --sha is given); Docker-
# unreachable (exit 2) is checked before sha-filtering ever runs, so that
# fault is reported exactly as today.
#
# Relocation note (R3, R4 — .lsa/features/rag-plugin-plug-and-play/
# relocate-and-run-in-place/requirements.md): same plugin_root/repo_root
# split as lsa/scripts/rag-index.sh — see that script's header for the full
# rationale. `plugin_root` locates this script's own Dockerfile/rag_cli.py
# (build context + SOURCE_HASH only); `repo_root` is the TARGET repo, used
# for `INDEX_DIR` and the `--sha` git-diff checks, resolved exactly as
# before this epic (`git rev-parse --show-toplevel` from CWD).
#
# Exit codes (R3, R4, R5 — .lsa/features/rag-context-engine-and-repo-indexing/
# index-query-pipeline/requirements.md):
#   0 — query executed, including an empty ("miss") result (a --sha filter
#       that discards everything is reported through this same miss shape)
#   2 — Docker daemon unreachable — a distinct, LOUD infrastructure fault,
#       reported by name, never conflated with the ordinary miss above
#   1 — any other failure (bad usage, image build failed, docker run crashed,
#       --sha given without `jq` on PATH)

set -uo pipefail
export LC_ALL=C

# plugin_root: where THIS script's own Dockerfile/rag_cli.py live. Prefer
# $CLAUDE_PLUGIN_ROOT (installed-plugin mode); otherwise derive it from this
# script's own path — lsa/scripts/rag-query.sh's parent's parent is lsa/,
# the plugin root (lsa/skills/init/SKILL.md:41 dual-mode precedent).
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  plugin_root="${CLAUDE_PLUGIN_ROOT}"
else
  plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# repo_root: the TARGET repo being queried — unchanged resolution from
# before this epic, fully independent of plugin_root.
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

# Distinct tag from the root-level scripts/rag-query.sh's "rag-index:local"
# — must match lsa/scripts/rag-index.sh's IMAGE_NAME exactly, since both
# scripts share one built image (R5: single shared tag per plugin-shipped
# location, reused across every target repo).
IMAGE_NAME="rag-index-plugin:local"
INDEX_DIR="${repo_root}/.lsa/.rag-index"

SHA=""
QUERY_PATH=""
QUERY_TEXT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sha)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        printf 'Usage: lsa/scripts/rag-query.sh [--sha <sha>] [--path <prefix>] "<query text>"\n' >&2
        exit 1
      fi
      SHA="$2"
      shift 2
      ;;
    --path)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        printf 'Usage: lsa/scripts/rag-query.sh [--sha <sha>] [--path <prefix>] "<query text>"\n' >&2
        exit 1
      fi
      QUERY_PATH="$2"
      shift 2
      ;;
    *)
      QUERY_TEXT="$1"
      shift
      ;;
  esac
done

if [[ -z "${QUERY_TEXT}" ]]; then
  printf 'Usage: lsa/scripts/rag-query.sh [--sha <sha>] [--path <prefix>] "<query text>"\n' >&2
  exit 1
fi

# Shared bounded docker_daemon_reachable() — was four near-identical
# copies across this repo; extracted during a PR review pass. Sourced via
# plugin_root (already resolved above), not a fresh ${BASH_SOURCE[0]}
# lookup.
source "${plugin_root}/scripts/lib/docker-reachable.sh"

if ! command -v docker >/dev/null 2>&1; then
  printf 'FAULT: Docker daemon unreachable — the "docker" CLI is not on PATH.\n' >&2
  exit 2
fi

if ! docker_daemon_reachable; then
  printf 'FAULT: Docker daemon unreachable — is Docker running? (`docker info` failed or timed out)\n' >&2
  exit 2
fi

# Stale-image detection (R1-R3 — .lsa/features/rag-context-engine-and-repo-
# indexing/index-freshness/requirements.md): the image existing is not the
# same as the image being current — see lsa/scripts/rag-index.sh for the
# full rationale, including a second real incident that ruled out an
# unconditional `--no-cache` (it re-downloads pip packages and the
# embedding model on every source edit and failed outright under network
# pressure). Two-tier: try a plain cached build first (Docker's own
# COPY-layer invalidation reliably reuses the expensive pip/model layers
# here); only fall back to `--no-cache` if the resulting label still
# doesn't match.
#
# Both the hash inputs and the build context below read from `plugin_root`
# — NOT `repo_root` — the R3/R4 split this epic exists to make.
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

mkdir -p "${INDEX_DIR}"

# --path <prefix>, when given, is passed straight through as the container's
# `query --path <prefix>` argument (R1, R3 — path-scoped-query-fix). Built as
# an array and expanded with the "${arr[@]+"${arr[@]}"}" idiom below — under
# `set -u`, bash 3.2 (macOS's /usr/bin/env bash) treats a plain "${arr[@]}"
# on a zero-element array as an unbound-variable error.
path_args=()
if [[ -n "${QUERY_PATH}" ]]; then
  path_args=(--path "${QUERY_PATH}")
fi

# No --sha: unchanged from before this epic apart from the optional --path
# pass-through above (R2: with no --path, path_args is empty and the command
# is byte-for-byte identical to before this epic).
if [[ -z "${SHA}" ]]; then
  # Plain command + rc=$? immediately after, not `if ! cmd; then rc=$?` —
  # bash's `!` negation overwrites the visible exit status before a nested
  # rc=$? can capture the real code (same bug this script's own --sha path
  # below never had, since it never used `!` in the first place).
  docker run --rm \
    -v "${INDEX_DIR}:/index:ro" \
    "${IMAGE_NAME}" query "${QUERY_TEXT}" --index-dir /index "${path_args[@]+"${path_args[@]}"}"
  rc=$?
  if [[ "${rc}" -ne 0 ]]; then
    if ! docker_daemon_reachable; then
      printf 'FAULT: Docker daemon unreachable — was reachable at start, is not now.\n' >&2
      exit 2
    fi
    printf 'ERROR: rag-query.sh failed (exit %s)\n' "${rc}" >&2
    exit 1
  fi
  exit 0
fi

# --sha <sha>: same query (now also path-scoped if --path was given), captured
# so the results can be filtered before they're emitted (R1, R2).
docker_output="$(docker run --rm \
  -v "${INDEX_DIR}:/index:ro" \
  "${IMAGE_NAME}" query "${QUERY_TEXT}" --index-dir /index "${path_args[@]+"${path_args[@]}"}")"
rc=$?
if [[ "${rc}" -ne 0 ]]; then
  if ! docker_daemon_reachable; then
    printf 'FAULT: Docker daemon unreachable — was reachable at start, is not now.\n' >&2
    exit 2
  fi
  printf 'ERROR: rag-query.sh failed (exit %s)\n' "${rc}" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  printf 'ERROR: rag-query.sh --sha requires "jq" on PATH (not found)\n' >&2
  exit 1
fi

# Per path (R1): keep only if unchanged between <sha> and HEAD, checked
# against the TARGET repo (repo_root, via `cd` above), never the plugin's
# own location. A path that changed, AND a <sha> that fails to resolve at
# all (every path's `git diff` then errors the same way), both fall out of
# this one loop as "not kept" — no separate sha-validity branch needed (R2).
keep_indices=()
idx=0
while IFS= read -r path; do
  if git diff --quiet "${SHA}" HEAD -- "${path}" 2>/dev/null; then
    keep_indices+=("${idx}")
  fi
  idx=$((idx + 1))
done < <(printf '%s' "${docker_output}" | jq -r '.results[].path')

if [[ ${#keep_indices[@]} -eq 0 ]]; then
  # Same miss contract as an ordinary empty result (R2) — not a new shape.
  printf '{"results": []}\n'
  exit 0
fi

idx_csv="$(printf '%s,' "${keep_indices[@]}")"
idx_csv="[${idx_csv%,}]"
printf '%s' "${docker_output}" | jq -c --argjson idx "${idx_csv}" '{results: [ .results[$idx[]] ]}'
exit 0
