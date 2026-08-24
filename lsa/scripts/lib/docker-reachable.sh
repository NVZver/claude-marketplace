# lsa/scripts/lib/docker-reachable.sh — shared bounded Docker daemon
# reachability check. Sourced (not executed) by lsa/scripts/rag-index.sh,
# lsa/scripts/rag-query.sh, lsa/scripts/check-rag-index-fresh.sh, and
# lsa/hooks/rag-bootstrap-check.sh — extracted from four near-identical
# copies of the same function found during a PR review pass.
#
# `docker info` can hang indefinitely (rather than fail fast) when the
# daemon/socket is gone but the CLI context still resolves — observed with
# Docker Desktop on macOS once the app is fully quit. Bounded background-
# poll-and-kill so an unreachable daemon is reported LOUDLY and promptly,
# never as a silent hang mistaken for the tool being unresponsive.
#
# Usage: docker_daemon_reachable [timeout_seconds, default 5]
#   Returns 0 if `docker info` succeeds within the timeout, 1 otherwise.
docker_daemon_reachable() {
  local timeout_s="${1:-5}"
  local pid waited max_iters rc
  max_iters=$(( timeout_s * 2 ))
  ( docker info >/dev/null 2>&1 ) &
  pid=$!
  waited=0
  while kill -0 "${pid}" 2>/dev/null; do
    sleep 0.5
    waited=$((waited + 1))
    if [[ "${waited}" -ge "${max_iters}" ]]; then
      kill -9 "${pid}" 2>/dev/null
      wait "${pid}" 2>/dev/null
      return 1
    fi
  done
  rc=0
  wait "${pid}" || rc=$?
  return "${rc}"
}
