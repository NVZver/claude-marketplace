#!/usr/bin/env bash
# scripts/roadmap-row.sh — deterministic first-backlog-row extractor.
#
# The manager:next Step 0 fast-path offload (pitch pro-tier-token-affordability
# WS3): instead of an agent reading roadmap.md model-side to find the first
# actionable row, this prints the first `backlog` / `not started` row of the
# `## Feature Backlog` table with its `path:line` citation — the exact artifact
# manager:next quotes.
#
# specs_root is read from .lsa.yaml (default .lsa/); the roadmap is
# ${specs_root}/roadmap.md. Zero model calls, Pro-safe local bash. Repo-internal —
# NOT shipped in any plugin; no plugin version bump or CHANGELOG entry.
#
# Exit 0 = a row was printed. Exit 1 = no roadmap / no `## Feature Backlog`
# anchor / no backlog row — the caller falls through to its model-side path.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

CFG=".lsa.yaml"
specs_root=".lsa/"
if [[ -f "${CFG}" ]]; then
  v="$(awk '/^specs_root:[[:space:]]*/ { sub(/^specs_root:[[:space:]]*/,""); gsub(/[[:space:]]+$/,""); print; exit }' "${CFG}")"
  [[ -n "${v}" ]] && specs_root="${v}"
fi
ROADMAP="${specs_root%/}/roadmap.md"

if [[ ! -f "${ROADMAP}" ]]; then
  echo "roadmap-row: NOT-FOUND — no ${ROADMAP}" >&2
  exit 1
fi

# Walk the ## Feature Backlog table; print the first data row (not header, not
# separator) whose Status column (3rd markdown cell) is exactly backlog / not
# started (case-insensitive). Emit "path:line — <verbatim row>".
row="$(awk -v roadmap="${ROADMAP}" '
  /^##[[:space:]]+Feature Backlog[[:space:]]*$/ { intab=1; next }
  intab && /^##[[:space:]]/                     { exit }          # next section ends the table
  intab && /^\|/ {
    if ($0 ~ /^\|[[:space:]]*-+/)         next                    # separator row
    if ($0 ~ /\|[[:space:]]*Feature[[:space:]]*\|/) next          # header row
    n = split($0, c, "|")                                         # c[2]=Feature c[3]=Priority c[4]=Status
    status = c[4]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
    ls = tolower(status)
    if (ls == "backlog" || ls == "not started") {
      printf "%s:%d — %s\n", roadmap, FNR, $0
      exit
    }
  }
' "${ROADMAP}")"

if [[ -z "${row}" ]]; then
  echo "roadmap-row: NONE — no backlog/not-started row in ${ROADMAP} ## Feature Backlog" >&2
  exit 1
fi

printf '%s\n' "${row}"
exit 0
