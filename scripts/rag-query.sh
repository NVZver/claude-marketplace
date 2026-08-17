#!/usr/bin/env bash
# scripts/rag-query.sh — thin host-side wrapper: queries the local RAG index
# built by scripts/rag-index.sh, returning top-ranked chunks with
# "path:start-end" citations by shelling out to `docker run`.
#
# Usage: scripts/rag-query.sh [--sha <sha>] "<query text>"
#
# Mounts the local index volume (.lsa/.rag-index/, gitignored) at /index.
#
# stdout on success is a single JSON object: {"results": [...]}. A miss —
# no chunk is a good match — is reported as {"results": []} on exit 0, NEVER
# as a non-zero exit or an error message (R4: a miss is not a guess, and
# must be distinguishable from an error).
#
# --sha <sha> (R1, R2 — .lsa/features/rag-context-engine-and-repo-indexing/
# reconcile-wiring/requirements.md): after the normal query above returns,
# filter its candidate results to only paths UNCHANGED between <sha> and HEAD
# (`git diff --quiet <sha> HEAD -- <path>`), per path — a host-side filter
# layered on top of the existing query, no index/schema change. A path that
# changed, or a <sha> that does not resolve to a real commit at all (every
# path then fails the same `git diff` check), is discarded; if that leaves
# zero results, this reports the exact same {"results": []} / exit-0 miss
# contract as an ordinary miss (R2) — never a new error shape. Requires `jq`
# on PATH (only when --sha is given); Docker-unreachable (exit 2) is checked
# before sha-filtering ever runs, so that fault is reported exactly as today.
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

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

IMAGE_NAME="rag-index:local"
INDEX_DIR="${repo_root}/.lsa/.rag-index"

SHA=""
QUERY_TEXT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sha)
      if [[ $# -lt 2 || -z "${2:-}" ]]; then
        printf 'Usage: scripts/rag-query.sh [--sha <sha>] "<query text>"\n' >&2
        exit 1
      fi
      SHA="$2"
      shift 2
      ;;
    *)
      QUERY_TEXT="$1"
      shift
      ;;
  esac
done

if [[ -z "${QUERY_TEXT}" ]]; then
  printf 'Usage: scripts/rag-query.sh [--sha <sha>] "<query text>"\n' >&2
  exit 1
fi

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

# No --sha: unchanged from before this epic — same command, stdout streamed
# straight through, byte-for-byte identical behavior.
if [[ -z "${SHA}" ]]; then
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
fi

# --sha <sha>: same query, captured so the results can be filtered before
# they're emitted (R1, R2).
docker_output="$(docker run --rm \
  -v "${INDEX_DIR}:/index:ro" \
  "${IMAGE_NAME}" query "${QUERY_TEXT}" --index-dir /index)"
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

# Per path (R1): keep only if unchanged between <sha> and HEAD. A path that
# changed, AND a <sha> that fails to resolve at all (every path's `git diff`
# then errors the same way), both fall out of this one loop as "not kept" —
# no separate sha-validity branch needed (R2).
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
