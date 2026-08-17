#!/usr/bin/env bash
# scripts/rag-query.sh — thin host-side wrapper: queries the local RAG index
# built by scripts/rag-index.sh, returning top-ranked chunks with
# "path:start-end" citations by shelling out to `docker run`.
#
# Usage: scripts/rag-query.sh "<query text>"
#
# Mounts the local index volume (.lsa/.rag-index/, gitignored) at /index.
#
# stdout on success is a single JSON object: {"results": [...]}. A miss —
# no chunk is a good match — is reported as {"results": []} on exit 0, NEVER
# as a non-zero exit or an error message (R4: a miss is not a guess, and
# must be distinguishable from an error).
#
# Exit codes (R3, R4, R5 — .lsa/features/rag-context-engine-and-repo-indexing/
# index-query-pipeline/requirements.md):
#   0 — query executed, including an empty ("miss") result
#   2 — Docker daemon unreachable — a distinct, LOUD infrastructure fault,
#       reported by name, never conflated with the ordinary miss above
#   1 — any other failure (bad usage, image build failed, docker run crashed)

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

IMAGE_NAME="rag-index:local"
INDEX_DIR="${repo_root}/.lsa/.rag-index"

if [[ $# -lt 1 || -z "${1:-}" ]]; then
  printf 'Usage: scripts/rag-query.sh "<query text>"\n' >&2
  exit 1
fi
QUERY_TEXT="$1"

# `docker info` can hang indefinitely (rather than fail fast) when the
# daemon/socket is gone but the CLI context still resolves — observed with
# Docker Desktop on macOS once the app is fully quit. Bound the check to ~5s
# so an unreachable daemon is reported LOUDLY and promptly (R5), never as a
# silent hang mistaken for a slow retrieval.
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

if ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
  echo "Building ${IMAGE_NAME} from ${repo_root}/Dockerfile ..." >&2
  if ! docker build -q -t "${IMAGE_NAME}" "${repo_root}" >/dev/null; then
    printf 'ERROR: docker build failed for %s\n' "${IMAGE_NAME}" >&2
    exit 1
  fi
fi

mkdir -p "${INDEX_DIR}"

if ! docker run --rm \
  -v "${INDEX_DIR}:/index:ro" \
  "${IMAGE_NAME}" query "${QUERY_TEXT}" --index-dir /index; then
  rc=$?
  if ! docker_daemon_reachable; then
    printf 'FAULT: Docker daemon unreachable — was reachable at start, is not now.\n' >&2
    exit 2
  fi
  printf 'ERROR: rag-query.sh failed (exit %s)\n' "${rc}" >&2
  exit 1
fi

exit 0
