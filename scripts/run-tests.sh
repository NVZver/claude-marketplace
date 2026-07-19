#!/usr/bin/env bash
# scripts/run-tests.sh — run every deterministic regression test in scripts/tests/.
#
# Written because the tests existed but nothing invoked them: .lsa.yaml `gate:`
# ran lint/citations/links/project-map only, so scripts/tests/*.sh was dead
# weight — a test that never runs proves nothing (core/ground-rules Rule 7:
# "Done is a gate-proven, cited predicate"). This is the missing runner.
#
# Each test is self-contained, hermetic where it needs fixtures, and exits 0 on
# pass / non-zero on fail. This runner reports one line per test and aggregates.
#
# Pure bash — Pro-safe, no deps. Repo-internal — not shipped.
# Exit 0 = every test passed. Exit 1 = at least one failed (named below).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi

TESTS_DIR="scripts/tests"
if [[ ! -d "${TESTS_DIR}" ]]; then
  echo "run-tests: NOT-FOUND — no ${TESTS_DIR}" >&2
  exit 1
fi

echo "=== deterministic regression tests (${TESTS_DIR}) ==="

fail=0
ran=0
failed_names=""

for t in "${TESTS_DIR}"/*.sh; do
  [[ -e "${t}" ]] || continue
  name="$(basename "${t}")"
  ran=$((ran + 1))
  if out="$(bash "${t}" 2>&1)"; then
    printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "${name}"
  else
    printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "${name}"
    printf '%s\n' "${out}" | sed 's/^/          /'
    fail=1
    failed_names="${failed_names} ${name}"
  fi
done

echo
if [[ ${ran} -eq 0 ]]; then
  echo "run-tests: NONE — no test scripts in ${TESTS_DIR}" >&2
  exit 1
fi

if [[ ${fail} -eq 0 ]]; then
  echo "run-tests: PASS — ${ran}/${ran} tests"
  exit 0
fi

echo "run-tests: FAIL —${failed_names}" >&2
exit 1
