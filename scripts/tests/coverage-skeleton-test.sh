#!/usr/bin/env bash
# scripts/tests/coverage-skeleton-test.sh — coverage-skeleton.sh behavior test (R8).
#
# Hermetic: builds a throwaway git repo in a scratch dir, runs the real
# scripts/coverage-skeleton.sh against it, and asserts the enumeration contract.
# Covers R1 (R- and F-ID extraction), R2 (changed-file enumeration + feature-dir
# exclusion), and R6 (bad-input non-zero exit with a diagnostic).
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
SCRIPT="${repo_root}/scripts/coverage-skeleton.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -x "${SCRIPT}" ]]; then
  echo "coverage-skeleton-test: ${SCRIPT} missing or not executable" >&2
  exit 1
fi

echo "=== coverage-skeleton.sh (R8) ==="

# --- hermetic scratch repo --------------------------------------------------
work="$(mktemp -d "${TMPDIR:-/tmp}/covskel.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

cd "${work}"
git init -q
git config user.email "t@t.t"
git config user.name "t"
git commit -q --allow-empty -m init

FD=".lsa/features/demo"
mkdir -p "${FD}" src

# R-keyed requirements + two changed files outside the feature dir, and a change
# to the spec's own requirements.md (must be excluded from candidate hunks).
printf '%s\n' \
  '# Demo requirements' \
  '' \
  '- R1. first requirement' \
  '- R2. second requirement' \
  '- R3. third requirement' \
  > "${FD}/requirements.md"
echo x > src/a.txt
echo y > src/b.txt
git add -A

out="$(bash "${SCRIPT}" "${FD}" HEAD)"; rc=$?

# R6 happy-path exit
if [[ "${rc}" -eq 0 ]]; then pass_line "exit 0 on valid input"; else fail_line "expected exit 0, got ${rc}"; fi

# R3 header
if printf '%s' "${out}" | grep -qF '| Req | Implementing hunks/files | Proving runs | Verdict |'; then
  pass_line "coverage-table header emitted"
else
  fail_line "coverage-table header missing"
fi

# R1 R-ID extraction (document order)
if printf '%s' "${out}" | grep -qE '^\| R1 \|' \
   && printf '%s' "${out}" | grep -qE '^\| R2 \|' \
   && printf '%s' "${out}" | grep -qE '^\| R3 \|'; then
  pass_line "R-ID extraction: R1,R2,R3 rows present"
else
  fail_line "R-ID extraction: expected R1,R2,R3 rows"
fi

# R4 + R2 changed-file enumeration
if printf '%s' "${out}" | grep -qF -- '- [ ] src/a.txt' \
   && printf '%s' "${out}" | grep -qF -- '- [ ] src/b.txt'; then
  pass_line "changed-file enumeration: src/a.txt, src/b.txt listed"
else
  fail_line "changed-file enumeration: expected src/a.txt and src/b.txt candidate hunks"
fi

# R2 feature-dir exclusion
if printf '%s' "${out}" | grep -qF -- "- [ ] ${FD}/requirements.md"; then
  fail_line "feature-dir exclusion: spec file leaked into candidate hunks"
else
  pass_line "feature-dir exclusion: spec requirements.md NOT a candidate hunk"
fi

# R2 untracked new files — an epic graded before its commit still has its own new
# files untracked; they MUST appear as candidate hunks.
echo z > src/untracked.txt      # created, never `git add`ed → untracked
outu="$(bash "${SCRIPT}" "${FD}" HEAD)"; rcu=$?
if [[ "${rcu}" -eq 0 ]] && printf '%s' "${outu}" | grep -qF -- '- [ ] src/untracked.txt'; then
  pass_line "untracked-file enumeration: src/untracked.txt listed as candidate hunk"
else
  fail_line "untracked-file enumeration: expected src/untracked.txt candidate hunk (exit ${rcu})"
fi

# …but a commit RANGE names a historical cycle. Whatever is untracked in the
# working tree today did not belong to it, and counting it inflates the
# candidate-hunk denominator of every metric derived from this skeleton.
outr="$(bash "${SCRIPT}" "${FD}" 'HEAD~1..HEAD')"; rcr=$?
if [[ "${rcr}" -eq 0 ]] && ! printf '%s' "${outr}" | grep -qF -- '- [ ] src/untracked.txt'; then
  pass_line "commit range excludes untracked files (historical cycle, not the working tree)"
else
  fail_line "commit range: src/untracked.txt must NOT be a candidate hunk for A..B (exit ${rcr})"
fi

# --- F-keyed spec -----------------------------------------------------------
printf '%s\n' \
  '# Demo requirements (F-keyed)' \
  '' \
  '- F1. first requirement' \
  '- F2. second requirement' \
  > "${FD}/requirements.md"

outf="$(bash "${SCRIPT}" "${FD}" HEAD)"; rcf=$?
if [[ "${rcf}" -eq 0 ]] \
   && printf '%s' "${outf}" | grep -qE '^\| F1 \|' \
   && printf '%s' "${outf}" | grep -qE '^\| F2 \|'; then
  pass_line "F-ID extraction: F1,F2 rows present"
else
  fail_line "F-ID extraction: expected F1,F2 rows (exit ${rcf})"
fi

# --- bad input --------------------------------------------------------------
err="$(bash "${SCRIPT}" "${FD}-does-not-exist" HEAD 2>&1 1>/dev/null)"; rcb=$?
if [[ "${rcb}" -ne 0 && -n "${err}" ]]; then
  pass_line "bad input: non-zero exit (${rcb}) with diagnostic"
else
  fail_line "bad input: expected non-zero exit + diagnostic (got exit ${rcb}, err '${err}')"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "coverage-skeleton.sh: all cases pass."
  exit 0
fi
echo "coverage-skeleton.sh: FAILURES above."
exit 1
