#!/usr/bin/env bash
# scripts/tests/resolve-refs-test.sh — resolve-refs.sh behavior test (R8).
#
# Hermetic: builds a throwaway git repo in a scratch dir, runs the real
# scripts/resolve-refs.sh against it, and asserts the per-symbol resolution
# contract. Covers R2 (path-exists / path-new), R3 (path:line in-range /
# out-of-range / missing-path), R4 (identifier-hit / identifier-new), and R1
# (empty-input non-zero exit).
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
SCRIPT="${repo_root}/scripts/resolve-refs.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -x "${SCRIPT}" ]]; then
  echo "resolve-refs-test: ${SCRIPT} missing or not executable" >&2
  exit 1
fi

echo "=== resolve-refs.sh (R8) ==="

# --- hermetic scratch repo --------------------------------------------------
work="$(mktemp -d "${TMPDIR:-/tmp}/resolverefs.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

cd "${work}"
git init -q
git config user.email "t@t.t"
git config user.name "t"

mkdir -p src
# A tracked file with a known identifier and a known line count (3 lines).
printf '%s\n' 'line one' 'uniqueIdentToken here' 'line three' > src/present.txt
git add -A
git commit -q -m init

# --- R2: path-exists --------------------------------------------------------
out="$(bash "${SCRIPT}" src/present.txt </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'src/present.txt → exists @ src/present.txt'; then
  pass_line "path-exists: src/present.txt → exists @ src/present.txt"
else
  fail_line "path-exists: got '${out}' (exit ${rc})"
fi

# --- R2: path-new -----------------------------------------------------------
out="$(bash "${SCRIPT}" src/absent.txt </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'src/absent.txt → new'; then
  pass_line "path-new: src/absent.txt → new"
else
  fail_line "path-new: got '${out}' (exit ${rc})"
fi

# --- R3: path:line in-range -------------------------------------------------
out="$(bash "${SCRIPT}" src/present.txt:2 </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'src/present.txt:2 → exists @ src/present.txt:2'; then
  pass_line "path:line in-range: src/present.txt:2 → exists @ src/present.txt:2"
else
  fail_line "path:line in-range: got '${out}' (exit ${rc})"
fi

# --- R3: path:line out-of-range (file has 3 lines) --------------------------
out="$(bash "${SCRIPT}" src/present.txt:99 </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'src/present.txt:99 → OUT-OF-RANGE'; then
  pass_line "path:line out-of-range: src/present.txt:99 → OUT-OF-RANGE"
else
  fail_line "path:line out-of-range: got '${out}' (exit ${rc})"
fi

# --- R3: path:line missing-path ---------------------------------------------
out="$(bash "${SCRIPT}" src/absent.txt:5 </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'src/absent.txt:5 → MISSING'; then
  pass_line "path:line missing-path: src/absent.txt:5 → MISSING"
else
  fail_line "path:line missing-path: got '${out}' (exit ${rc})"
fi

# --- R4: identifier-hit -----------------------------------------------------
out="$(bash "${SCRIPT}" uniqueIdentToken </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'uniqueIdentToken → exists @ src/present.txt:2'; then
  pass_line "identifier-hit: uniqueIdentToken → exists @ src/present.txt:2"
else
  fail_line "identifier-hit: got '${out}' (exit ${rc})"
fi

# --- R4: identifier-new (no tracked hit) ------------------------------------
out="$(bash "${SCRIPT}" noSuchIdentifierAnywhere </dev/null)"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'noSuchIdentifierAnywhere → new'; then
  pass_line "identifier-new: noSuchIdentifierAnywhere → new"
else
  fail_line "identifier-new: got '${out}' (exit ${rc})"
fi

# --- R4: identifier hit via stdin (pipe) ------------------------------------
out="$(printf 'uniqueIdentToken\n' | bash "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 0 ]] && printf '%s' "${out}" | grep -qF 'uniqueIdentToken → exists @ src/present.txt:2'; then
  pass_line "stdin-piped: uniqueIdentToken resolved from stdin"
else
  fail_line "stdin-piped: got '${out}' (exit ${rc})"
fi

# --- R1: args take precedence — stdin NOT read when arguments are given -----
# Piped stdin content must be ignored entirely: only the arg is resolved.
out="$(printf 'IGNORED\n' | bash "${SCRIPT}" src/present.txt)"; rc=$?
if [[ "${rc}" -eq 0 ]] \
   && printf '%s' "${out}" | grep -qF 'src/present.txt → exists @ src/present.txt' \
   && ! printf '%s' "${out}" | grep -qF 'IGNORED'; then
  pass_line "args-precedence: stdin ignored when args present (no IGNORED line)"
else
  fail_line "args-precedence: stdin leaked into output — got '${out}' (exit ${rc})"
fi

# --- R1: arg-only invocation never blocks on a stdin pipe that stays open ----
# The agent-harness case: stdin is an open pipe with no EOF. Run with stdin on a
# FIFO no one ever writes to or closes; the script must finish anyway. Poll up to
# ~5s, then kill and fail — a hang here is the defect this case exists to catch.
fifo="${work}/never_eof.fifo"
rm -f "${fifo}"
if mkfifo "${fifo}" 2>/dev/null; then
  # Hold the FIFO open for writing (never writes, never closes) via a background
  # sleep, so the reader side blocks rather than seeing immediate EOF.
  sleep 30 > "${fifo}" &
  holder=$!
  bash "${SCRIPT}" src/present.txt < "${fifo}" > "${work}/nb.out" 2>&1 &
  runner=$!
  waited=0
  while kill -0 "${runner}" 2>/dev/null && [[ "${waited}" -lt 50 ]]; do
    sleep 0.1
    waited=$((waited + 1))
  done
  if kill -0 "${runner}" 2>/dev/null; then
    kill -9 "${runner}" 2>/dev/null
    wait "${runner}" 2>/dev/null
    fail_line "no-block: arg-only invocation HUNG on a never-EOF stdin pipe"
  else
    wait "${runner}"; rcn=$?
    if [[ "${rcn}" -eq 0 ]] && grep -qF 'src/present.txt → exists @ src/present.txt' "${work}/nb.out"; then
      pass_line "no-block: arg-only invocation completed on a never-EOF stdin pipe"
    else
      fail_line "no-block: completed but wrong result (exit ${rcn}): $(cat "${work}/nb.out")"
    fi
  fi
  kill -9 "${holder}" 2>/dev/null
  wait "${holder}" 2>/dev/null
  rm -f "${fifo}"
else
  fail_line "no-block: could not create FIFO for the never-EOF stdin case"
fi

# --- R1: empty-input non-zero exit ------------------------------------------
err="$(bash "${SCRIPT}" </dev/null 2>&1 1>/dev/null)"; rcb=$?
if [[ "${rcb}" -ne 0 && -n "${err}" ]]; then
  pass_line "empty-input: non-zero exit (${rcb}) with usage diagnostic"
else
  fail_line "empty-input: expected non-zero exit + diagnostic (got exit ${rcb}, err '${err}')"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "resolve-refs.sh: all cases pass."
  exit 0
fi
echo "resolve-refs.sh: FAILURES above."
exit 1
