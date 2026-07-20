#!/usr/bin/env bash
# scripts/tests/metrics-emit-guard-test.sh — falsification test for lint.sh's C17.
#
# The deliverable per reconcile-emit-guard R7 is NOT "C17 exists" — it is
# "deleting the reconcile metrics-emit step is PROVEN to turn the gate red".
# `lsa` 0.16.0 removed the `.lsa/metrics.md` writer as refactor collateral and
# nothing caught it (restore-tracked-metrics-harvest pitch, rabbit hole 2); a
# check that only ever asserts the baseline PASS would repeat that blind spot.
# So this test runs a NEGATIVE CONTROL: it mutates the real, tracked
# lsa/skills/reconcile/SKILL.md to strip both C17 markers, asserts the gate
# actually goes red, then restores the file and asserts the gate is green
# again — byte-for-byte identical to before the test.
#
# Safety: the file is backed up to a temp path and a `trap … EXIT` restores it
# unconditionally, so a Ctrl-C or crash mid-test cannot leave the repo dirty.
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# Exit 0 = every case passed. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

LINT="scripts/lint.sh"
TARGET="lsa/skills/reconcile/SKILL.md"

if [[ ! -f "${LINT}" ]]; then
  echo "metrics-emit-guard-test: ${LINT} missing" >&2
  exit 1
fi
if [[ ! -f "${TARGET}" ]]; then
  echo "metrics-emit-guard-test: ${TARGET} missing" >&2
  exit 1
fi

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

echo "=== metrics-emit-guard (C17 falsification) ==="

# --- backup + unconditional restore -----------------------------------------
# Two copies: `backup` is consumed (removed) by restore(); `reference` is kept
# around for the final byte-for-byte check below, so the check does not depend
# on git HEAD (the working tree may already carry unrelated, uncommitted
# changes to TARGET at test time — comparing against HEAD would be wrong).
backup="$(mktemp "${TMPDIR:-/tmp}/reconcile-skill.XXXXXX")"
reference="$(mktemp "${TMPDIR:-/tmp}/reconcile-skill-ref.XXXXXX")"
cp "${TARGET}" "${backup}"
cp "${TARGET}" "${reference}"
cleanup() { rm -f "${backup}" "${reference}"; }
restore() { cp "${backup}" "${TARGET}"; }
trap 'restore; cleanup' EXIT

# --- 1. baseline: C17 PASS on the intact repo -------------------------------
baseline_out="$(bash "${LINT}" 2>&1)"
if printf '%s\n' "${baseline_out}" | grep -qE 'PASS.*C17'; then
  pass_line "baseline: C17 PASS line present on intact ${TARGET}"
else
  fail_line "baseline: no C17 PASS line found — got:"
  printf '%s\n' "${baseline_out}" | grep -i C17 | sed 's/^/        /'
fi

# --- 2. NEGATIVE CONTROL: strip both markers, gate must go red -------------
grep -v -e 'scripts/metrics-harvest\.sh' -e '\.lsa/metrics\.md' "${backup}" > "${TARGET}"

mutated_out="$(bash "${LINT}" 2>&1)"
mutated_rc=$?

if printf '%s\n' "${mutated_out}" | grep -qE 'FAIL.*C17'; then
  pass_line "negative control: C17 FAIL line present after stripping both markers"
else
  fail_line "negative control: expected a C17 FAIL line — got:"
  printf '%s\n' "${mutated_out}" | grep -i C17 | sed 's/^/        /'
fi

if printf '%s\n' "${mutated_out}" | grep -qF 'metrics writer dropped again — see lsa 0.16.0'; then
  pass_line "negative control: FAIL text names the regression (lsa 0.16.0)"
else
  fail_line "negative control: FAIL text did not name the lsa 0.16.0 regression"
fi

if [[ "${mutated_rc}" -ne 0 ]]; then
  pass_line "negative control: scripts/lint.sh exits non-zero (${mutated_rc}) on the mutated repo"
else
  fail_line "negative control: scripts/lint.sh exited 0 on the mutated repo — C17 does not gate"
fi

# --- 3. restore + confirm the gate is green again ---------------------------
restore

restored_out="$(bash "${LINT}" 2>&1)"
if printf '%s\n' "${restored_out}" | grep -qE 'PASS.*C17' && ! printf '%s\n' "${restored_out}" | grep -qE 'FAIL.*C17'; then
  pass_line "restoration: C17 PASS lines return, no C17 FAIL remains"
else
  fail_line "restoration: C17 did not return to all-PASS after restore — got:"
  printf '%s\n' "${restored_out}" | grep -i C17 | sed 's/^/        /'
fi

# Byte-for-byte check against `reference` (captured before any mutation), not
# git HEAD — the working tree may already carry unrelated, uncommitted
# changes to TARGET, which would make a git-diff-based check give a false
# negative here.
if cmp -s "${reference}" "${TARGET}"; then
  pass_line "restoration: ${TARGET} is byte-for-byte identical to before the test"
else
  fail_line "restoration: ${TARGET} differs from its pre-test content — repo left dirty"
fi

trap - EXIT
cleanup

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "metrics-emit-guard: all cases pass."
  exit 0
fi
echo "metrics-emit-guard: FAILURES above."
exit 1
