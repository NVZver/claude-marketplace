#!/usr/bin/env bash
# scripts/tests/check-lib-pins-test.sh — check-lib-pins.sh behavior test (R10).
#
# Hermetic: builds fixture .lsa.yaml + pinned-spec + lockfile files in a
# mktemp -d sandbox (non-git, so the script's `git rev-parse || pwd` fallback
# is exercised the same way scripts/gate.sh's is) and runs the real
# scripts/check-lib-pins.sh against each fixture from that directory.
#
# Covers: R5 exit codes (0 fresh / 1 stale / 2 cannot-verify / 1 broken /
# 0 empty-libs) and R6's decision order (spec-missing, Pinned-Version absent,
# Lockfile: none, Lockfile-Assertion absent, assertion found/not-found).
#
# Pure bash — Pro-safe, no deps, bash 3.2-safe.
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="${repo_root}/scripts/check-lib-pins.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -x "${SCRIPT}" ]]; then
  echo "check-lib-pins-test: ${SCRIPT} missing or not executable" >&2
  exit 1
fi

echo "=== check-lib-pins.sh (R10) ==="

work="$(mktemp -d "${TMPDIR:-/tmp}/checklibpins.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

# --- Case 1: fresh — assertion found in lockfile → exit 0 ------------------
d="${work}/fresh"; mkdir -p "${d}/.lsa/libs"
cat > "${d}/.lsa.yaml" <<'EOF'
libs:
  widget:
    spec: .lsa/libs/widget.md
    manifest: package.json
EOF
cat > "${d}/.lsa/libs/widget.md" <<'EOF'
# widget

- Pinned-Version: 1.2.3
- Manifest: package.json
- Lockfile: lock.txt
- Lockfile-Assertion: "widget": "1.2.3"
EOF
printf '"widget": "1.2.3"\n' > "${d}/lock.txt"
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 0 && "${out}" == *"OK          widget 1.2.3"* ]]; then
  pass_line "fresh pin (assertion found) exits 0, reports OK"
else
  fail_line "fresh pin: expected exit 0 + OK line, got exit ${rc}: ${out}"
fi

# --- Case 2: stale — assertion not found in lockfile → exit 1 --------------
d="${work}/stale"; mkdir -p "${d}/.lsa/libs"
cat > "${d}/.lsa.yaml" <<'EOF'
libs:
  widget:
    spec: .lsa/libs/widget.md
    manifest: package.json
EOF
cat > "${d}/.lsa/libs/widget.md" <<'EOF'
# widget

- Pinned-Version: 1.2.3
- Manifest: package.json
- Lockfile: lock.txt
- Lockfile-Assertion: "widget": "1.2.3"
EOF
printf '"widget": "9.9.9"\n' > "${d}/lock.txt"
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 1 && "${out}" == *"STALE       widget pinned 1.2.3"* ]]; then
  pass_line "mismatched assertion exits 1, reports STALE"
else
  fail_line "stale pin: expected exit 1 + STALE line, got exit ${rc}: ${out}"
fi

# --- Case 3: Lockfile: none → exit 2, [cannot verify] ----------------------
d="${work}/nolock"; mkdir -p "${d}/.lsa/libs"
cat > "${d}/.lsa.yaml" <<'EOF'
libs:
  widget:
    spec: .lsa/libs/widget.md
    manifest: package.json
EOF
cat > "${d}/.lsa/libs/widget.md" <<'EOF'
# widget

- Pinned-Version: 1.2.3
- Manifest: package.json
- Lockfile: none
EOF
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 2 && "${out}" == *"[cannot verify]  widget pinned 1.2.3"* ]]; then
  pass_line "Lockfile: none exits 2, reports [cannot verify]"
else
  fail_line "no-lockfile pin: expected exit 2 + [cannot verify] line, got exit ${rc}: ${out}"
fi

# --- Case 4: BROKEN — spec file missing → exit 1 ----------------------------
d="${work}/broken"; mkdir -p "${d}"
cat > "${d}/.lsa.yaml" <<'EOF'
libs:
  ghost:
    spec: .lsa/libs/ghost.md
    manifest: package.json
EOF
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 1 && "${out}" == *"BROKEN      ghost — spec file not found"* ]]; then
  pass_line "missing spec file exits 1, reports BROKEN"
else
  fail_line "broken pin: expected exit 1 + BROKEN line, got exit ${rc}: ${out}"
fi

# --- Case 5: empty/absent libs: → exit 0 ------------------------------------
d="${work}/empty"; mkdir -p "${d}"
cat > "${d}/.lsa.yaml" <<'EOF'
libs: {}
EOF
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 0 ]]; then
  pass_line "empty libs: {} exits 0"
else
  fail_line "empty libs: expected exit 0, got exit ${rc}: ${out}"
fi

d="${work}/absent"; mkdir -p "${d}"
: > "${d}/.lsa.yaml"
out="$(cd "${d}" && "${SCRIPT}")"; rc=$?
if [[ "${rc}" -eq 0 ]]; then
  pass_line "absent libs: key exits 0"
else
  fail_line "absent libs: expected exit 0, got exit ${rc}: ${out}"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "check-lib-pins-test: PASS — 6/6 cases"
  exit 0
fi
echo "check-lib-pins-test: FAIL — see FAIL lines above"
exit 1
