#!/usr/bin/env bash
# scripts/tests/no-wholefile-ledger-read.sh — F9 enforcement test.
#
# Asserts that no roadmap read-consumer whole-file-reads the .lsa/roadmap.yaml
# ledger on its HAPPY PATH — each obtains its slice through a query script
# (scripts/roadmap-row.sh or scripts/roadmap-query.sh). This is the enforceable
# core of the context win in the yaml-ledger-selective-load pitch: a whole-file
# read of the ledger reloads the entire roadmap into the model context, exactly
# what the cutover removes.
#
# Two assertions per consumer:
#   (a) POSITIVE — its happy-path step names the query/extractor script it calls;
#   (b) NEGATIVE — it carries no unqualified "Read the ledger" directive (any
#       ledger `Read` must be marked as the non-zero-exit fallback, per F8).
#
# Pure bash/grep — Pro-safe, no deps. Repo-internal — not shipped.
# Exit 0 = all assertions hold. Exit 1 = at least one consumer whole-file-reads
# the ledger on the happy path (or lost its query-script wiring).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

echo "=== F9: no happy-path whole-file read of the roadmap ledger ==="

NEXT="manager/skills/next/SKILL.md"
PM="manager/agents/project-manager.md"
IMPL="manager/skills/implement/SKILL.md"
CHECK="manager/skills/check/SKILL.md"

# (a) POSITIVE — each consumer names the query/extractor script on its happy path.
must_contain() {  # file  needle  label
  if grep -qF "$2" "$1" 2>/dev/null; then
    pass_line "$3"
  else
    fail_line "$3 — expected '$2' in $1, not found"
  fi
}
must_contain "${NEXT}" "scripts/roadmap-row.sh"        "manager:next Step 0 calls roadmap-row.sh"
must_contain "${PM}"   "scripts/roadmap-row.sh"        "project-manager Mode 0 calls roadmap-row.sh"
must_contain "${PM}"   "roadmap-query.sh backlog"      "project-manager Mode 1 calls roadmap-query.sh backlog"
must_contain "${PM}"   "roadmap-query.sh hygiene"      "project-manager hygiene calls roadmap-query.sh hygiene"
must_contain "${IMPL}" "roadmap-query.sh backlog"      "manager:implement 1a preview calls roadmap-query.sh backlog"

# (b) NEGATIVE — no consumer carries an UNQUALIFIED whole-file read of the ledger.
# A ledger `Read` is allowed only when the same line marks it as fallback
# (fall through / fallback / non-zero / only if / absent). An unmarked
# "`Read` `${specs_root}/roadmap.yaml`" is a happy-path whole-file read → FAIL.
for f in "${NEXT}" "${PM}" "${IMPL}" "${CHECK}"; do
  bad="$(grep -nE '(`Read`|whole-file[- ]read).*roadmap\.yaml' "${f}" 2>/dev/null \
    | grep -viE 'fall[- ]?through|fall through|fallback|non-zero|only if|absent|never whole-file|do not whole-file' \
    || true)"
  if [[ -z "${bad}" ]]; then
    pass_line "${f}: no unqualified whole-file ledger read"
  else
    fail_line "${f}: unqualified whole-file ledger read on the happy path:"
    printf '%s\n' "${bad}" | sed 's/^/        /'
  fi
done

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "F9 holds — every consumer slices the ledger via a query script; no happy-path whole-file read."
  exit 0
fi
echo "F9 VIOLATED — see FAIL lines above."
exit 1
