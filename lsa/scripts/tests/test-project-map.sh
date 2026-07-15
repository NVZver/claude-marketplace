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
if grep -q 'version: 2' project-map.yaml && grep -q 'depth: 3' project-map.yaml; then
  ok "header has version + depth"
else
  bad "missing version/depth header"
fi
if grep -q 'project-map.yaml' project-map.yaml; then
  bad "map must not list itself"
else
  ok "map does not list itself"
fi

echo "Flow 2 — directories only, depth ≤ 3"
r2="$(new_repo)"
cd "${r2}"
bash "${BUILD}" >/dev/null
# No files anywhere: this is a directory map, not a file catalog.
if grep -qE 'deep\.txt|mid\.txt|SKILL\.md|README\.md' project-map.yaml; then
  bad "no filenames may appear in a dirs-only map"
  cat project-map.yaml >&2
else
  ok "no filenames listed (dirs-only)"
fi
# Depth-3 directory (a/b/c) is present as a key.
if grep -qE '^      c:' project-map.yaml; then
  ok "depth-3 directory a/b/c present"
else
  bad "expected depth-3 dir a/b/c"
  cat project-map.yaml >&2
fi
# Depth-4 directory (a/b/c/d) is truncated away.
if grep -qE '^\s+d:' project-map.yaml; then
  bad "depth-4 directory d must not appear"
else
  ok "depth-4 directory d truncated"
fi
# A dir that holds only files (nothing deeper) still appears as a leaf key.
if grep -qE '^      demo:' project-map.yaml; then
  ok "leaf directory core/skills/demo present"
else
  bad "expected leaf dir core/skills/demo"
  cat project-map.yaml >&2
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
# A dirs-only map changes when a *directory* appears — not on a root file add.
mkdir -p newpkg
printf 'new\n' > newpkg/thing.txt
git add newpkg/thing.txt
git commit -q -m "add dir"
if bash "${CHECK}" >/dev/null 2>&1; then
  bad "check should FAIL when a new directory is uncommitted in the map"
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
