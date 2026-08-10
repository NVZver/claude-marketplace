#!/usr/bin/env bash
# scripts/tests/no-optarg-hang-test.sh — option-parsing hang guard.
#
# Guards a defect class that appeared twice in this repo: an option-parsing loop
# written as
#
#     while [[ $# -gt 0 ]]; do
#       case "$1" in
#         --opt) val="${2:-}"; shift 2 ;;
#
# spins forever when --opt is passed with no value. `shift 2` with only one
# argument remaining is a NO-OP that returns non-zero — it does not shift, so $1
# never advances and the loop never terminates. The `${2:-}` default hides it:
# the variable gets a value, so nothing looks wrong.
#
# Found in scripts/roadmap-query.sh (--limit, --fields) and scripts/pitch-query.sh
# (--width). A hang is worse than a crash here: these run inside agent turns, so
# the failure mode is a wedged session with no error, not a fallback.
#
# Every option-taking script must instead REJECT a value-less flag and exit
# non-zero. This test asserts that by running each flag with no value under a
# hard alarm and failing on timeout.
#
# Pure bash/perl — Pro-safe, no deps (perl alarm, since macOS has no `timeout`).
# Exit 0 = no script hangs. Exit 1 = at least one hangs or accepts a bad value.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

TIMEOUT_SECS=5

# run_bounded <secs> <cmd...> — 142 = alarm fired (hang)
run_bounded() { perl -e 'alarm shift; exec @ARGV' "$@" >/dev/null 2>&1; }

echo "=== option parsing: a value-less flag must exit, never hang ==="

# assert_no_hang <label> <script> <args...>
assert_no_hang() {
  local label="$1"; shift
  local script="$1"; shift
  if [[ ! -f "${script}" ]]; then
    pass_line "${label} — ${script} absent, skipped"
    return
  fi
  run_bounded "${TIMEOUT_SECS}" bash "${script}" "$@"
  local rc=$?
  if [[ ${rc} -eq 142 ]]; then
    fail_line "${label} — HANG (no exit within ${TIMEOUT_SECS}s): infinite option loop"
  elif [[ ${rc} -eq 0 ]]; then
    fail_line "${label} — exited 0 on a value-less flag; should reject it"
  else
    pass_line "${label} — rejected with exit ${rc}"
  fi
}

assert_no_hang "roadmap-query --limit (no value)"  scripts/roadmap-query.sh backlog --limit
assert_no_hang "roadmap-query --fields (no value)" scripts/roadmap-query.sh backlog --fields
assert_no_hang "pitch-query --width (no value)"    scripts/pitch-query.sh outline --width

echo
echo "=== a non-numeric value where a number is required must be rejected ==="
assert_no_hang "roadmap-query --limit abc" scripts/roadmap-query.sh backlog --limit abc
assert_no_hang "pitch-query --width abc"   scripts/pitch-query.sh outline --width abc

echo
echo "=== happy paths still work (guard must not over-reject) ==="
if bash scripts/roadmap-query.sh backlog --limit 2 >/dev/null 2>&1; then
  pass_line "roadmap-query backlog --limit 2 still succeeds"
else
  fail_line "roadmap-query backlog --limit 2 regressed"
fi

first_pitch="$(ls .lsa/pitches/*.md 2>/dev/null | head -1)"
if [[ -n "${first_pitch}" ]]; then
  slug="$(basename "${first_pitch}" .md)"
  if bash scripts/pitch-query.sh outline --width 40 "${slug}" >/dev/null 2>&1; then
    pass_line "pitch-query outline --width 40 still succeeds"
  else
    fail_line "pitch-query outline --width 40 regressed"
  fi
else
  pass_line "no pitches on disk — pitch happy-path check skipped"
fi

echo
if [[ ${fail} -eq 0 ]]; then
  echo "no-optarg-hang: PASS — no option loop hangs"
  exit 0
fi
echo "no-optarg-hang: FAIL" >&2
exit 1
