#!/usr/bin/env bash
# lsa/scripts/tests/test-project-map.sh — real-flow tests for project-map build/check.
#
# Covers: idempotent YAML build, depth-3 truncation, check PASS/FAIL, not-a-git-repo.
# bash 3.2 / macOS portable. Avoids subshells so pass/fail counters stick.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LSA_SCRIPTS="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD="${LSA_SCRIPTS}/project-map-build.sh"
CHECK="${LSA_SCRIPTS}/project-map-check.sh"
REPO_ROOT="$(cd "${LSA_SCRIPTS}/../.." && pwd)"

pass=0
fail=0
TMPDIRS=()

cleanup() {
  local d
  for d in "${TMPDIRS[@]+"${TMPDIRS[@]}"}"; do
    rm -rf "${d}" 2>/dev/null || true
  done
}
trap cleanup EXIT

ok() { printf '  PASS  %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '  FAIL  %s\n' "$1"; fail=$((fail + 1)); }

new_repo() {
  local d
  d="$(mktemp -d)"
  TMPDIRS+=("${d}")
  (
    cd "${d}"
    git init -q
    git config user.email "test@example.com"
    git config user.name "test"
    mkdir -p a/b/c/d core/skills/demo
    printf 'root\n' > README.md
    printf 'x\n' > a/b/c/d/deep.txt
    printf 'skill\n' > core/skills/demo/SKILL.md
    printf 'mid\n' > a/b/mid.txt
    git add -A
    git commit -q -m "seed"
  )
  printf '%s\n' "${d}"
}

echo "=== project-map build/check real-flow tests ==="

echo "Flow 1 — deterministic generation"
r1="$(new_repo)"
cd "${r1}"
bash "${BUILD}" >/dev/null
cp project-map.yaml /tmp/pm-a-$$.yaml
bash "${BUILD}" >/dev/null
if diff -q /tmp/pm-a-$$.yaml project-map.yaml >/dev/null; then
  ok "two builds are byte-identical"
else
  bad "two builds differ"
fi
rm -f /tmp/pm-a-$$.yaml
if grep -q 'version: 1' project-map.yaml && grep -q 'depth: 3' project-map.yaml; then
  ok "header has version + depth"
else
  bad "missing version/depth header"
fi
if grep -q 'project-map.yaml' project-map.yaml; then
  bad "map must not list itself"
else
  ok "map does not list itself"
fi

echo "Flow 2 — depth ≤ 3"
r2="$(new_repo)"
cd "${r2}"
bash "${BUILD}" >/dev/null
if grep -q 'deep.txt' project-map.yaml; then
  bad "depth-4 file deep.txt must not appear"
else
  ok "depth-4 file deep.txt absent"
fi
if awk '
  /^  a:/ { ina=1; next }
  ina && /^  [^ ]/ { ina=0 }
  ina && /^    b:/ { inb=1; next }
  inb && /^    [^ ]/ { inb=0 }
  inb && /c: dir/ { found=1 }
  END { exit !found }
' project-map.yaml; then
  ok "depth-3 parent of deeper path is dir"
else
  bad "expected a.b.c: dir for truncated path"
  cat project-map.yaml >&2
fi
if grep -q 'mid.txt: file' project-map.yaml; then
  ok "depth-3 file mid.txt listed as file"
else
  bad "mid.txt missing as file"
fi
if grep -q 'README.md: file' project-map.yaml; then
  ok "root README.md listed"
else
  bad "root README.md missing"
fi
if grep -q 'SKILL.md' project-map.yaml; then
  bad "SKILL.md at depth 4 must not appear"
else
  ok "depth-4 SKILL.md absent"
fi

echo "Flow 3 — project-map-check.sh"
r3="$(new_repo)"
cd "${r3}"
bash "${BUILD}" >/dev/null
git add project-map.yaml
git commit -q -m "add map"
if bash "${CHECK}" >/dev/null 2>&1; then
  ok "check PASS when map is committed and fresh"
else
  bad "check should PASS on fresh committed map"
  bash "${CHECK}" 2>&1 || true
fi
printf 'new\n' > new-root.txt
git add new-root.txt
git commit -q -m "add file"
if bash "${CHECK}" >/dev/null 2>&1; then
  bad "check should FAIL when tree changed without map commit"
else
  ok "check FAIL when rebuild dirties project-map.yaml"
fi

echo "Flow 4 — not a git work tree"
nd="$(mktemp -d)"
TMPDIRS+=("${nd}")
cd "${nd}"
if bash "${BUILD}" >/dev/null 2>&1; then
  bad "build should fail outside git"
else
  ok "build exits non-zero outside git"
fi

echo "Flow 5 — live marketplace map"
cd "${REPO_ROOT}"
bash "${BUILD}" >/dev/null
if [[ -f project-map.yaml ]] && grep -q '^tree:' project-map.yaml; then
  ok "live: project-map.yaml exists with tree:"
else
  bad "live: project-map.yaml missing or malformed"
fi

echo ""
echo "=== ${pass} passed, ${fail} failed ==="
[[ "${fail}" -eq 0 ]]
