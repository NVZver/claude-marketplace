#!/usr/bin/env bash
# scripts/rag-index.sh — thin host-side wrapper: builds/updates the local RAG
# index for a given scope by shelling out to `docker run` against the image
# built from the repo-root Dockerfile.
#
# Usage: scripts/rag-index.sh [<scope>]
#   <scope>   path, relative to the repo root, to index. Default: "." (whole
#             repo). A directory or a single file.
#
# Mounts the repo read-only at /repo and the local index volume
# (.lsa/.rag-index/, gitignored — see .gitignore) read-write at /index.
#
# Structural chunking (Markdown H2/H3, bash function/block, fixed-window
# fallback), local CPU-only embedding, and the vector store all run inside
# the container (docker/rag_cli.py) — this script does none of that itself,
# per this repo's "deterministic work is scripted" convention applied to the
# *invocation*, not a reimplementation of the container's logic.
#
# Exit codes (R1, R2, R5 — .lsa/features/rag-context-engine-and-repo-indexing/
# index-query-pipeline/requirements.md):
#   0 — index built/updated (including "nothing changed, every chunk skipped")
#   2 — Docker daemon unreachable — a distinct, LOUD infrastructure fault,
#       reported by name, never conflated with an ordinary retrieval miss
#       (a miss is a query-side concept — see scripts/rag-query.sh)
#   1 — any other failure (image build failed, docker run crashed, ...)

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

IMAGE_NAME="rag-index:local"
INDEX_DIR="${repo_root}/.lsa/.rag-index"
SCOPE="${1:-.}"

# `docker info` can hang indefinitely (rather than fail fast) when the
# daemon/socket is gone but the CLI context still resolves — observed with
# Docker Desktop on macOS once the app is fully quit. Bound the check to ~5s
# so an unreachable daemon is reported LOUDLY and promptly (R5), never as a
# silent hang mistaken for the tool being unresponsive.
docker_daemon_reachable() {
  local pid waited
  ( docker info >/dev/null 2>&1 ) &
  pid=$!
  waited=0
  while kill -0 "${pid}" 2>/dev/null; do
    sleep 0.5
    waited=$((waited + 1))
    if [[ "${waited}" -ge 10 ]]; then
      kill -9 "${pid}" 2>/dev/null
      wait "${pid}" 2>/dev/null
      return 1
    fi
  done
  wait "${pid}"
}

if ! command -v docker >/dev/null 2>&1; then
  printf 'FAULT: Docker daemon unreachable — the "docker" CLI is not on PATH.\n' >&2
  exit 2
fi

if ! docker_daemon_reachable; then
  printf 'FAULT: Docker daemon unreachable — is Docker running? (`docker info` failed or timed out)\n' >&2
  exit 2
fi

mkdir -p "${INDEX_DIR}"

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "Building ${IMAGE_NAME} from ${repo_root}/Dockerfile ..." >&2
  if ! docker build -q -t "${IMAGE_NAME}" "${repo_root}" >/dev/null; then
    printf 'ERROR: docker build failed for %s\n' "${IMAGE_NAME}" >&2
    exit 1
  fi
fi

if ! docker run --rm \
  -v "${repo_root}:/repo:ro" \
  -v "${INDEX_DIR}:/index" \
  "${IMAGE_NAME}" index --scope "${SCOPE}" --index-dir /index --repo-root /repo; then
  rc=$?
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
