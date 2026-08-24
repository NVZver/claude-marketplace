#!/usr/bin/env bash
# lsa/scripts/check-rag-index-fresh.sh — R7 gate check ("rag-index-fresh" in
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
# Plugin-shipped (lsa/scripts/**/*.sh, dogfood-migration epic) — this
# header previously said "not shipped in any plugin," true only of the
# root-level version this file replaced; corrected during a PR review pass.
# A change here does need a plugin version bump + CHANGELOG entry.
#
# Usage: lsa/scripts/check-rag-index-fresh.sh   (no arguments)

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

INDEX_DIR="${repo_root}/.lsa/.rag-index"

# Shared bounded docker_daemon_reachable() — was four near-identical
# copies across this repo; extracted during a PR review pass. Sourced
# relative to this script's own location (this file has no other
# self-location logic to reuse, unlike rag-index.sh/rag-query.sh's
# plugin_root).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib/docker-reachable.sh"

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
