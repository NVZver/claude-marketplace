#!/usr/bin/env bash
# scripts/tests/roadmap-row-test.sh — priority-ordering behavior test.
#
# Hermetic: builds a throwaway git repo in a scratch dir with a fixture
# roadmap.yaml, then runs the real scripts/roadmap-row.sh against it.
#
# A hermetic fixture is REQUIRED, not a convenience: the live ledger's priority
# mix changes as work ships, so a green live run would prove nothing about the
# ordering contract.
#
# Guards the regression this script was written for: file order alone can return
# a Could while a Must sits lower in the ledger, which makes the manager:next
# fast path product-wrong, not just cheap.
#
# Covers: Must beats an earlier Could · Should beats Could when no Must ·
# file order is the tie-break within one priority · unset priority sorts last ·
# non-actionable statuses skipped · no backlog item exits 1 · no ledger exits 1.
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
SCRIPT="${repo_root}/scripts/roadmap-row.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -f "${SCRIPT}" ]]; then
  echo "roadmap-row-test: ${SCRIPT} missing" >&2
  exit 1
fi

echo "=== roadmap-row.sh — priority ordering (Must > Should > Could > unset) ==="

# --- hermetic scratch repo --------------------------------------------------
work="$(mktemp -d "${TMPDIR:-/tmp}/rmrow.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

cd "${work}"
git init -q
git symbolic-ref HEAD refs/heads/main
git config user.email "t@t.t"
git config user.name "t"
mkdir -p .lsa

# item <slug> <priority> <status>  — emits one ledger record on stdout
item() {
  printf '  - slug: %s\n' "$1"
  printf '    title: |\n      Title for %s\n' "$1"
  [[ -n "$2" ]] && printf '    priority: %s\n' "$2"
  printf '    status: %s\n' "$3"
  printf '    notes: |\n      note\n\n'
}

# ledger <body-producing-commands...> — writes .lsa/roadmap.yaml
ledger() { { printf 'items:\n'; "$@"; } > .lsa/roadmap.yaml; }

# expect_slug <case-name> <expected-slug>
expect_slug() {
  local name="$1" want="$2" out rc
  out="$(bash "${SCRIPT}" 2>/dev/null)"; rc=$?
  if [[ ${rc} -ne 0 ]]; then
    fail_line "${name} — expected slug '${want}', script exited ${rc}"
  elif printf '%s' "${out}" | grep -q -- "— ${want} |"; then
    pass_line "${name} → ${want}"
  else
    fail_line "${name} — expected '${want}', got: ${out}"
  fi
}

# expect_exit1 <case-name>
expect_exit1() {
  local name="$1" rc
  bash "${SCRIPT}" >/dev/null 2>&1; rc=$?
  if [[ ${rc} -eq 1 ]]; then pass_line "${name} → exit 1"
  else fail_line "${name} — expected exit 1, got ${rc}"; fi
}

# --- case 1: the regression. Could listed FIRST, Must lower in the file ------
body1() { item could-item Could backlog; item must-item Must backlog; }
ledger body1
expect_slug "Must beats an earlier Could" "must-item"

# --- case 2: Should beats Could when no Must exists --------------------------
body2() { item could-item Could backlog; item should-item Should backlog; }
ledger body2
expect_slug "Should beats an earlier Could" "should-item"

# --- case 3: file order is the tie-break within one priority ----------------
body3() { item must-first Must backlog; item must-second Must backlog; }
ledger body3
expect_slug "first-in-file wins within a priority" "must-first"

# --- case 4: unset priority sorts last --------------------------------------
body4() { item no-priority "" backlog; item could-item Could backlog; }
ledger body4
expect_slug "unset priority sorts below Could" "could-item"

# --- case 5: non-actionable statuses are skipped ----------------------------
body5() { item shipped-must Must shipped; item wip-must Must in_progress; item live-could Could backlog; }
ledger body5
expect_slug "shipped/in_progress skipped" "live-could"

# --- case 6: not_started counts as actionable -------------------------------
body6() { item could-item Could backlog; item must-ns Must not_started; }
ledger body6
expect_slug "not_started is actionable" "must-ns"

# --- case 7: no actionable item exits 1 -------------------------------------
body7() { item done-one Must shipped; }
ledger body7
expect_exit1 "no backlog/not_started item"

# --- case 8: no ledger exits 1 ----------------------------------------------
rm -f .lsa/roadmap.yaml
expect_exit1 "no ledger file"

echo
if [[ ${fail} -eq 0 ]]; then
  echo "roadmap-row-test: PASS — all cases"
  exit 0
fi
echo "roadmap-row-test: FAIL" >&2
exit 1
