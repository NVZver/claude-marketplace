#!/usr/bin/env bash
# scripts/check-rag-index-fresh.sh — R7 gate check ("rag-index-fresh" in
# .lsa.yaml's gate: block): is the local RAG index usable right now?
#
# Three outcomes only, never a silent green — same contract as
# scripts/check-lib-pins.sh, which this script is styled after:
#   0 = OK              — Docker daemon reachable AND the index is
#                          structurally present
#   1 = STALE/BROKEN    — daemon reachable but no index is present
#   2 = [cannot verify] — Docker daemon unreachable; nothing about the index
#       can be asserted from here, so this is reported as unknown, never
#       treated as a pass. Distinguishes "can't tell" from "index missing" —
#       the same daemon-down-is-not-a-miss distinction R5 requires of
#       scripts/rag-index.sh and scripts/rag-query.sh
#       (.lsa/pitches/rag-context-engine-and-repo-indexing.md rabbit hole 2).
#
# Repo-internal — NOT shipped in any plugin; lives outside every plugin's
# artifact_paths, so it triggers no plugin version bump or CHANGELOG entry.
#
# Usage: check-rag-index-fresh.sh   (no arguments)

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

INDEX_DIR="${repo_root}/.lsa/.rag-index"

# `docker info` can hang indefinitely (rather than fail fast) when the
# daemon/socket is gone but the CLI context still resolves — observed with
# Docker Desktop on macOS once the app is fully quit. Bound the check to ~5s
# so an unreachable daemon reads as [cannot verify] promptly, never as a
# silent hang mistaken for the gate being unresponsive.
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

if ! command -v docker >/dev/null 2>&1 || ! docker_daemon_reachable; then
  printf '  [cannot verify]  rag-index-fresh — Docker daemon unreachable\n'
  exit 2
fi

if [[ -d "${INDEX_DIR}/lancedb" ]] \
  && find "${INDEX_DIR}/lancedb" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
  printf '  OK               rag-index-fresh — daemon reachable, index present at %s\n' "${INDEX_DIR}"
  exit 0
fi

printf '  BROKEN           rag-index-fresh — daemon reachable but no index found at %s\n' "${INDEX_DIR}"
exit 1
