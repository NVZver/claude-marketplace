#!/usr/bin/env bash
# scripts/tests/test-build-index.sh — real-flow tests for scripts/build-index.sh.
#
# Covers the three project-index flows
# (.lsa/features/pro-tier-token-affordability/project-index/flow-*.feature) as
# executable checks, not unit assertions on internal functions:
#
#   Flow 1 (generate)  — deterministic byte-identical output; spine files carry
#                        their verbatim H1; historical trees collapse to counts +
#                        slug lists; the file announces itself as generated.
#   Flow 2 (discover)  — the generated map carries the scoping pointers a read
#                        protocol consults (plugin→README rows, spine by H1,
#                        feature slugs); a source file with no H1 degrades, never
#                        crashes.
#   Flow 3 (freshness) — adding a tracked file changes the output (the property
#                        the lint C13 regenerate-and-diff gate relies on); the
#                        budget stays bounded because trees collapse; the live
#                        repo's C13/C14 gates report fresh + within budget.
#
# Each flow runs in an isolated throwaway git repo (git init + git add; no commit
# needed — build-index.sh reads the index via `git ls-files`). Bash 3.2-safe.
#
# Exit 0 = all flows pass. Exit 1 = a flow failed.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BUILD="${REPO_ROOT}/scripts/build-index.sh"

pass=0
fail=0
TMPDIRS=()
cleanup() { for d in "${TMPDIRS[@]:-}"; do [[ -n "${d}" ]] && rm -rf "${d}"; done; }
trap cleanup EXIT

ok()   { pass=$((pass + 1)); printf '  PASS  %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; [[ -n "${2:-}" ]] && printf '        %s\n' "$2"; }

# assert_contains <file> <fixed-string> <label>
assert_contains() {
  if grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3" "expected to find: $2"; fi
}
# assert_absent <file> <fixed-string> <label>
assert_absent() {
  if grep -qF -- "$2" "$1"; then bad "$3" "should NOT contain: $2"; else ok "$3"; fi
}

# new_repo — mints an isolated git repo with a realistic markdown surface and
# echoes its path. Mirrors the live layout: 1 plugin, root docs, .lsa/ spine,
# and one file in each historical tree.
new_repo() {
  local d
  d="$(mktemp -d)"
  TMPDIRS+=("${d}")
  (
    cd "${d}"
    git init -q
    mkdir -p core/.claude-plugin core/skills/demo core/knowledge \
             .lsa/modules/core .lsa/standards .lsa/features/myfeat .lsa/pitches .lsa/archive
    printf '{"name":"core","version":"1.0.0"}\n' > core/.claude-plugin/plugin.json
    printf '# core README\n'                     > core/README.md
    printf '# Demo skill\nbody\n'                 > core/skills/demo/SKILL.md
    printf '# Conventions\nrules\n'               > core/knowledge/conventions.md
    printf '# Marketplace root\n'                 > README.md
    printf '# Claude entry point\n'               > CLAUDE.md
    printf '# The Constitution\ntext\n'           > .lsa/VISION.md
    printf '# Roadmap\nrows\n'                    > .lsa/roadmap.md
    printf '# Module index\n'                     > .lsa/main.spec.md
    printf '# core module\n'                      > .lsa/modules/core/spec.md
    printf '# Code standard\n'                    > .lsa/standards/code.md
    printf '# myfeat requirements\n'              > .lsa/features/myfeat/requirements.md
    printf '# a pitch\n'                          > .lsa/pitches/mypitch.md
    printf '# archived thing\n'                   > .lsa/archive/old-decision.md
    git add -A
  )
  printf '%s\n' "${d}"
}

echo "=== build-index.sh real-flow tests ==="

# --------------------------------------------------------------------------
echo "Flow 1 — deterministic generation"
# --------------------------------------------------------------------------
R="$(new_repo)"
(
  cd "${R}"
  bash "${BUILD}" >/dev/null 2>&1
  cp .lsa/PROJECT-index.md /tmp/idx-a.$$
  bash "${BUILD}" >/dev/null 2>&1
  cp .lsa/PROJECT-index.md /tmp/idx-b.$$
)
if diff -q "/tmp/idx-a.$$" "/tmp/idx-b.$$" >/dev/null 2>&1; then
  ok "two builds are byte-identical (F1/AC1 — no model call, same input ⇒ same output)"
else
  bad "two builds are byte-identical (F1/AC1)" "$(diff "/tmp/idx-a.$$" "/tmp/idx-b.$$" | head -5)"
fi
IDX="${R}/.lsa/PROJECT-index.md"
assert_contains "${IDX}" '`.lsa/VISION.md` — The Constitution'  "spine file carries verbatim H1 (F4/AC1)"
assert_contains "${IDX}" '`.lsa/roadmap.md` — Roadmap'          "roadmap H1 is verbatim (F4/AC1)"
assert_contains "${IDX}" 'features/` (1): myfeat'               "features/ collapsed to count + slug (F4/AC1)"
assert_contains "${IDX}" 'pitches/` (1): mypitch'               "pitches/ collapsed to count + slug (F4/AC1)"
assert_absent   "${IDX}" 'requirements.md'                      "historical tree does NOT enumerate files (collapse, F4)"
assert_absent   "${IDX}" 'old-decision'                         "archive/ collapsed to a count, not slugs (F4)"
# Trace + generated banner (F2/F8/AC5)
if head -1 "${IDX}" | grep -qF 'PROJECT-index.md'; then ok "opens with the file-load trace directive (F8/AC5)"; else bad "opens with the trace directive (F8/AC5)"; fi
assert_contains "${IDX}" 'GENERATED — DO NOT EDIT'              "carries the GENERATED — DO NOT EDIT banner (F2/AC5)"
rm -f "/tmp/idx-a.$$" "/tmp/idx-b.$$"

# --------------------------------------------------------------------------
echo "Flow 2 — the map fits the discovery-scoping flow"
# --------------------------------------------------------------------------
assert_contains "${IDX}" '`core/` — '                          "plugin row present for scoping (F6)"
assert_contains "${IDX}" '`core/README.md`'                     "plugin row points to its README (F6)"
assert_contains "${IDX}" '`.lsa/` spine (live'                  "spine section present for direct reads (F6)"

# F7 — a spine file with NO H1 degrades gracefully (blank description, exit 0, no crash)
R2="$(new_repo)"
(
  cd "${R2}"
  printf 'no heading here\njust body\n' > .lsa/main.spec.md   # strip the H1
  git add -A
)
set +e
( cd "${R2}" && bash "${BUILD}" >/dev/null 2>&1 ); rc=$?
set -e 2>/dev/null || true
if [[ "${rc}" -eq 0 ]]; then ok "missing H1 does not crash the generator (F7 — exit 0)"; else bad "missing H1 degrades gracefully (F7)" "exit ${rc}"; fi
assert_contains "${R2}/.lsa/PROJECT-index.md" '`.lsa/main.spec.md` —' "file with no H1 still listed, blank description (F7)"

# --------------------------------------------------------------------------
echo "Flow 3 — freshness property + bounded budget"
# --------------------------------------------------------------------------
# Freshness: adding a tracked file changes the output — the exact drift the lint
# C13 regenerate-and-diff gate detects (F5/AC3).
R3="$(new_repo)"
(
  cd "${R3}"
  bash "${BUILD}" >/dev/null 2>&1
  cp .lsa/PROJECT-index.md /tmp/idx-before.$$
  mkdir -p .lsa/features/second-feature
  printf '# second feature\n' > .lsa/features/second-feature/requirements.md
  git add -A
  bash "${BUILD}" >/dev/null 2>&1
  cp .lsa/PROJECT-index.md /tmp/idx-after.$$
)
if diff -q "/tmp/idx-before.$$" "/tmp/idx-after.$$" >/dev/null 2>&1; then
  bad "adding a tracked file changes the index (F5/AC3 — staleness is detectable)" "index did not change"
else
  ok "adding a tracked file changes the index (F5/AC3 — staleness is detectable)"
fi
assert_contains "/tmp/idx-after.$$" 'second-feature'           "the new feature slug appears after regeneration (F5)"
rm -f "/tmp/idx-before.$$" "/tmp/idx-after.$$"

# Budget: many historical entries stay bounded because trees collapse (F3 design).
R4="$(new_repo)"
(
  cd "${R4}"
  i=0
  while [[ "${i}" -lt 60 ]]; do
    mkdir -p ".lsa/features/feat-${i}"
    printf '# feat %s\n' "${i}" > ".lsa/features/feat-${i}/requirements.md"
    printf '# pitch %s\n' "${i}" > ".lsa/pitches/pitch-${i}.md"
    i=$((i + 1))
  done
  git add -A
  bash "${BUILD}" >/dev/null 2>&1
)
idx_chars="$(wc -c < "${R4}/.lsa/PROJECT-index.md" | tr -d ' ')"
idx_tokens=$((idx_chars / 4))
# 60 features + 60 pitches = 180+ tracked files, but the index enumerates slugs
# only — it must stay well within the 1000-token cap enforced by lint C14.
if [[ "${idx_tokens}" -le 1000 ]]; then
  ok "180+ tracked files stay within the 1000-token cap (F3 — collapse keeps it bounded; ~${idx_tokens} tokens)"
else
  bad "budget stays bounded under a large tree (F3)" "~${idx_tokens} tokens > 1000"
fi

# Robustness: outside a git work tree the generator errors cleanly (exit 1), never
# writes a garbage index.
NOGIT="$(mktemp -d)"; TMPDIRS+=("${NOGIT}")
set +e
( cd "${NOGIT}" && bash "${BUILD}" >/dev/null 2>"${NOGIT}/err" ); rc=$?
set -e 2>/dev/null || true
if [[ "${rc}" -eq 1 ]] && grep -qF 'git work tree' "${NOGIT}/err"; then
  ok "outside a git work tree ⇒ clean exit 1 with a message (robustness)"
else
  bad "outside a git work tree ⇒ clean exit 1" "exit ${rc}"
fi

# --------------------------------------------------------------------------
echo "Flow 3 (live) — the committed index passes the real C13/C14 gates"
# --------------------------------------------------------------------------
lint_out="$(cd "${REPO_ROOT}" && bash scripts/lint.sh 2>&1)"
if printf '%s\n' "${lint_out}" | grep -qE 'PASS  C13 .*is fresh'; then
  ok "live: committed .lsa/PROJECT-index.md is fresh (C13 PASS)"
else
  bad "live C13 fresh" "$(printf '%s\n' "${lint_out}" | grep -E 'C13' | head -1)"
fi
if printf '%s\n' "${lint_out}" | grep -qE 'PASS  C14 .*within budget'; then
  ok "live: committed index within the token budget (C14 PASS)"
else
  bad "live C14 within budget" "$(printf '%s\n' "${lint_out}" | grep -E 'C14' | head -1)"
fi

# --------------------------------------------------------------------------
echo ""
echo "=== ${pass} passed, ${fail} failed ==="
[[ "${fail}" -eq 0 ]]
