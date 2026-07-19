#!/usr/bin/env bash
# scripts/tests/metrics-harvest-test.sh — metrics-harvest.sh behavior test
# (harvest-script requirements R1-R7, R9).
#
# Hermetic: builds a throwaway git repo in a scratch dir, copies the REAL
# scripts/coverage-skeleton.sh + scripts/check-citations.sh into it (the
# scripts metrics-harvest.sh shells out to via repo-relative paths), and runs
# the REAL scripts/metrics-harvest.sh against fixture conformance.md files.
# Also runs directly against the real repo's historical
# .lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md to prove
# the non-canonical-orphan-line UNPARSEABLE path (R11 item 3) and that the
# file is left byte-for-byte unchanged.
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# The test does NOT modify any tracked repo file.
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
SCRIPT="${repo_root}/scripts/metrics-harvest.sh"
COVSKEL="${repo_root}/scripts/coverage-skeleton.sh"
CITECHECK="${repo_root}/scripts/check-citations.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -x "${SCRIPT}" ]]; then
  echo "metrics-harvest-test: ${SCRIPT} missing or not executable" >&2
  exit 1
fi

echo "=== metrics-harvest.sh ==="

# --- R11 item 3: the real repo file, prose orphan heading, run from repo root
real_conformance="${repo_root}/.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md"
before_sum="$(shasum -a 256 "${real_conformance}" 2>/dev/null || true)"
out_real="$(cd "${repo_root}" && bash "${SCRIPT}" .lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md)"; rc_real=$?
after_sum="$(shasum -a 256 "${real_conformance}" 2>/dev/null || true)"

if [[ "${rc_real}" -eq 0 ]] \
   && printf '%s' "${out_real}" | grep -qE '^only-required-changes: UNPARSEABLE \(non-canonical orphan-hunk line\)$' \
   && printf '%s' "${out_real}" | grep -qE '^accuracy-to-task: [0-9]+/[0-9]+$' \
   && printf '%s' "${out_real}" | grep -qE '^citation-resolve-rate: .*\(PROXY — resolve-rate, not quote integrity\)$'; then
  pass_line "real historical file: non-canonical orphan line → UNPARSEABLE, other two lines still print, exit 0"
else
  fail_line "real historical file: got (exit ${rc_real}):
${out_real}"
fi

if [[ "${before_sum}" == "${after_sum}" && -n "${before_sum}" ]]; then
  pass_line "real historical file left byte-for-byte unchanged"
else
  fail_line "real historical file was modified by the harvest run"
fi

# --- R6: zero arguments -------------------------------------------------
err="$(bash "${SCRIPT}" 2>&1 1>/dev/null)"; rc0=$?
if [[ "${rc0}" -ne 0 ]] \
   && printf '%s' "${err}" | grep -qF 'metrics-harvest: usage: metrics-harvest.sh <conformance.md> [git-diff-args…]'; then
  pass_line "zero args: non-zero exit (${rc0}) + literal usage diagnostic on stderr"
else
  fail_line "zero args: expected non-zero exit + usage diagnostic, got exit ${rc0}, err '${err}'"
fi

# --- R7: non-existent path -----------------------------------------------
err="$(bash "${SCRIPT}" does/not/exist/conformance.md 2>&1 1>/dev/null)"; rcm=$?
if [[ "${rcm}" -ne 0 ]] \
   && printf '%s' "${err}" | grep -qF 'metrics-harvest: no such file: does/not/exist/conformance.md'; then
  pass_line "missing file: non-zero exit (${rcm}) + literal diagnostic on stderr"
else
  fail_line "missing file: expected non-zero exit + diagnostic, got exit ${rcm}, err '${err}'"
fi

# --- hermetic scratch repo, real coverage-skeleton.sh + check-citations.sh --
work="$(mktemp -d "${TMPDIR:-/tmp}/metricsharvest.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

cd "${work}"
git init -q
git config user.email "t@t.t"
git config user.name "t"

mkdir -p scripts
cp "${COVSKEL}" scripts/coverage-skeleton.sh
cp "${CITECHECK}" scripts/check-citations.sh
chmod +x scripts/coverage-skeleton.sh scripts/check-citations.sh

FD=".lsa/features/test-fixture"
mkdir -p "${FD}"
printf '%s\n' \
  '# Demo requirements' '' \
  '- F1. thing one' '- F2. thing two' '- F3. thing three' '- F4. thing four' \
  > "${FD}/requirements.md"

git add -A
git commit -q -m "baseline: scripts + requirements.md"

# --- fixture 1: canonical happy path (Orphan hunks: none.) ------------------
mkdir -p src
for f in h1 h2 h3 h4; do echo "x" > "src/${f}.sh"; done
cat > "${FD}/conformance.md" <<'EOF'
# Conformance — test-fixture

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | src/h1.sh | 3/3 | ✅ |
| F2 | src/h2.sh | 3/3 | ✅ |
| F3 | src/h3.sh | 3/3 | ✅ |
| F4 | src/h4.sh | 3/3 | ❌ |

Orphan hunks: none.
EOF
git add -A

out1="$(bash "${SCRIPT}" "${FD}/conformance.md")"; rc1=$?

if [[ "${rc1}" -eq 0 ]] \
   && printf '%s' "${out1}" | grep -qF 'feature: test-fixture' \
   && printf '%s' "${out1}" | grep -qE '^only-required-changes: ([0-9]+)/\1$' \
   && printf '%s' "${out1}" | grep -qF 'accuracy-to-task: 3/4' \
   && printf '%s' "${out1}" | grep -qE '^citation-resolve-rate: [0-9]+/[0-9]+  \(PROXY — resolve-rate, not quote integrity\)$'; then
  pass_line "canonical fixture: all three metrics M/N, accuracy-to-task 3/4, PROXY suffix present, exit 0"
else
  fail_line "canonical fixture: got (exit ${rc1}):
${out1}"
fi

# candidate hunks = 4 (h1..h4), orphans = 0 → only-required-changes must be 4/4
if printf '%s' "${out1}" | grep -qF 'only-required-changes: 4/4'; then
  pass_line "canonical fixture: only-required-changes is 4/4 (4 candidate hunks, 0 orphans)"
else
  fail_line "canonical fixture: expected only-required-changes: 4/4, got:
${out1}"
fi

git commit -q -m "fixture 1: h1..h4 + conformance.md"

# --- fixture 2: orphan subtraction (Orphan hunks: 3, 10 candidate hunks) ----
for i in 1 2 3 4 5 6 7 8 9 10; do echo "x" > "src/o${i}.sh"; done
cat > "${FD}/conformance.md" <<'EOF'
# Conformance — test-fixture (orphan case)

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | src/o1.sh | 3/3 | ✅ |
| F2 | src/o2.sh | 3/3 | ✅ |
| F3 | src/o3.sh | 3/3 | ✅ |
| F4 | src/o4.sh | 3/3 | ✅ |

Orphan hunks: 3
EOF
git add -A

out2="$(bash "${SCRIPT}" "${FD}/conformance.md")"; rc2=$?

if [[ "${rc2}" -eq 0 ]] && printf '%s' "${out2}" | grep -qF 'only-required-changes: 7/10'; then
  pass_line "orphan subtraction: Orphan hunks: 3 + 10 candidate hunks → only-required-changes: 7/10"
else
  fail_line "orphan subtraction: expected only-required-changes: 7/10, got (exit ${rc2}):
${out2}"
fi

if printf '%s' "${out2}" | grep -qF 'accuracy-to-task: 4/4'; then
  pass_line "orphan-fixture accuracy-to-task derivation: 4/4"
else
  fail_line "orphan-fixture accuracy-to-task: expected 4/4, got:
${out2}"
fi

# --- ambiguous orphan lines (multiple canonical matches) --------------------
cat > "${FD}/conformance.md" <<'EOF'
# Conformance — test-fixture (ambiguous orphan case)

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | src/o1.sh | 3/3 | ✅ |

Orphan hunks: none.
Orphan hunks: 2
EOF

out3="$(bash "${SCRIPT}" "${FD}/conformance.md")"; rc3=$?
if [[ "${rc3}" -eq 0 ]] \
   && printf '%s' "${out3}" | grep -qE '^only-required-changes: UNPARSEABLE'; then
  pass_line "ambiguous orphan lines: UNPARSEABLE, not averaged"
else
  fail_line "ambiguous orphan lines: expected UNPARSEABLE, got (exit ${rc3}):
${out3}"
fi

# --- R7: FAIL-line arithmetic (broken citations subtracted from checked) ---
# Swap in a fake check-citations.sh that emits a fixed FAIL summary line, so
# the FAIL-branch parsing (checked - broken) is exercised directly rather
# than relying on the real repo happening to have broken citations.
cp scripts/check-citations.sh scripts/check-citations.sh.bak
cat > scripts/check-citations.sh <<'FAKE'
#!/usr/bin/env bash
echo
echo "FAIL 2 broken citation(s) of 50 checked — see VIOLATION lines above."
exit 1
FAKE
chmod +x scripts/check-citations.sh

out4="$(bash "${SCRIPT}" "${FD}/conformance.md")"; rc4=$?
mv scripts/check-citations.sh.bak scripts/check-citations.sh

if [[ "${rc4}" -eq 0 ]] \
   && printf '%s' "${out4}" | grep -qF 'citation-resolve-rate: 48/50  (PROXY — resolve-rate, not quote integrity)'; then
  pass_line "FAIL-line arithmetic: FAIL 2 broken of 50 checked → citation-resolve-rate: 48/50, exit 0 (non-zero check-citations exit does not gate)"
else
  fail_line "FAIL-line arithmetic: expected citation-resolve-rate: 48/50, got (exit ${rc4}):
${out4}"
fi

# --- R2: string 'citation density' must appear nowhere in the script -------
if grep -qi 'citation density' "${SCRIPT}"; then
  fail_line "'citation density' string found in ${SCRIPT} (pitch rabbit hole 3)"
else
  pass_line "'citation density' string absent from the script"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "metrics-harvest.sh: all cases pass."
  exit 0
fi
echo "metrics-harvest.sh: FAILURES above."
exit 1
