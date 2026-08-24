#!/usr/bin/env bash
# lsa/hooks/rag-bootstrap-check.sh — SessionStart hook: offer the
# lsa:bootstrap-rag skill when RAG search could be turned on for this repo
# but hasn't been yet (rag-plugin-plug-and-play, bootstrap-trigger epic,
# R1-R3).
#
# Independently-timed sibling of lsa/hooks/session-start-drift-check.sh
# (same array, second entry — see lsa/hooks/hooks.json). Follows that
# script's exact established shape: set -uo pipefail, trap 'exit 0' ERR,
# resolve repo_root via `git rev-parse --show-toplevel` falling back to
# $CLAUDE_PROJECT_DIR, silent no-op (exit 0, no output) on any missing
# prerequisite. Must NEVER block session start and must NEVER exit nonzero
# (R3).
#
# Offers the skill (one printed line) only when ALL of the following hold
# (R2):
#   - .lsa.yaml exists at the repo root (lsa:init has run)
#   - .lsa.yaml's gate: block has no rag-index-fresh entry yet (not already
#     bootstrapped) -- a plain `grep -q` is sufficient here: this is a fast
#     DETECTION signal, not the rigorous gate:-block parsing epic 2 needed
#     for actual runtime behavior
#   - docker is on PATH
#   - docker is reachable within a bounded ~3s check -- the shared
#     lsa/scripts/lib/docker-reachable.sh's docker_daemon_reachable(),
#     called here as `docker_daemon_reachable 3` (6 x 0.5s) instead of its
#     5s default, to fit comfortably inside this hook's 10s SessionStart
#     timeout budget.
#
# No-op (silent, exit 0) when:
#   - not in a git repo and $CLAUDE_PROJECT_DIR is unset/not a directory
#   - .lsa.yaml is absent
#   - .lsa.yaml already has a rag-index-fresh gate entry (already bootstrapped)
#   - docker is not on PATH
#   - docker is not reachable within the ~3s bound

set -uo pipefail
trap 'exit 0' ERR

# Resolve repo root. Fall back to ${CLAUDE_PROJECT_DIR} if not in a git repo.
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  repo_root="${CLAUDE_PROJECT_DIR:-}"
fi
if [[ -z "${repo_root}" || ! -d "${repo_root}" ]]; then
  exit 0
fi

cfg="${repo_root}/.lsa.yaml"
[[ -f "${cfg}" ]] || exit 0

# Already bootstrapped? Fast, tolerant detection signal only.
grep -q "rag-index-fresh" "${cfg}" 2>/dev/null && exit 0

command -v docker >/dev/null 2>&1 || exit 0

# Shared bounded docker_daemon_reachable() — was four near-identical
# copies across this repo; extracted during a PR review pass. Sourced
# relative to this script's own location (this hook has no plugin_root
# variable of its own to reuse, unlike rag-index.sh/rag-query.sh).
hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${hook_dir}/../scripts/lib/docker-reachable.sh"

docker_daemon_reachable 3 || exit 0

echo "RAG search isn't set up for this repo yet. Run the lsa:bootstrap-rag skill to set it up (Docker build + index + git-hook wiring, unattended)."
exit 0
