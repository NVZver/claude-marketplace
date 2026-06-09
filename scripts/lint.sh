#!/usr/bin/env bash
# scripts/lint.sh — repo-internal invariant lint for the NVZver claude-marketplace.
#
# Enforces the repo's "write each fact once, cite everywhere else" rule
# mechanically. These checks are the executable form of grep recipes already
# documented (in prose) at:
#   - core/tests/repo-anchored.md            §"D2" (output-discipline drift)
#   - prompt-engineer/tests/repo-anchored.md §"A2" (actor ground-rules single def)
# This script is the source of truth for the *executable* checks.
#
# Repo-internal only — NOT shipped in any plugin (the checks reference this
# repo's own files by path). Lives outside every plugin's artifact_paths in
# .lsa.yaml, so it triggers no plugin version bump or CHANGELOG entry.
#
# Exit 0 = all invariants hold. Exit 1 = at least one violation.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

CANON="core/skills/output/SKILL.md"
fail=0

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

echo "=== marketplace invariant lint ==="

# ---------------------------------------------------------------------------
# C1 — output-discipline rule COUNT is stated only in the canonical file.
# A literal "(N golden rules)" anywhere else goes stale when the count changes.
# ---------------------------------------------------------------------------
hits="$(grep -rEn '\([0-9]+ golden rules\)' --include='*.md' \
  --exclude-dir=archive --exclude-dir=plans --exclude-dir=.git \
  --exclude=CHANGELOG.md . 2>/dev/null \
  | grep -v "^\./${CANON}:" || true)"
if [[ -z "${hits}" ]]; then
  pass_line "C1 rule-count stated only in ${CANON}"
else
  fail_line "C1 rule-count restated outside ${CANON}:"
  printf '%s\n' "${hits}" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C2 — output-discipline rule NAME LIST is stated only in the canonical file.
# A hit is allowed when the line also cites the canonical file (a re-grounding)
# or carries the full canonical enumeration (…, concrete). The test doc that
# describes this recipe is exempt — it is allowed to name what it catches.
# ---------------------------------------------------------------------------
raw="$(grep -rEn 'structured, ?minimal, ?formatted, ?sourced' --include='*.md' \
  --exclude-dir=archive --exclude-dir=plans --exclude-dir=.git \
  --exclude=CHANGELOG.md . 2>/dev/null || true)"
viol="$(printf '%s\n' "${raw}" \
  | grep -v '^$' \
  | grep -v "^\./${CANON}:" \
  | grep -v '^\./core/tests/repo-anchored\.md:' \
  | grep -vE 'skills/output/SKILL\.md' \
  | grep -vE 'structured, ?minimal, ?formatted, ?sourced, ?concrete' \
  || true)"
if [[ -z "${viol}" ]]; then
  pass_line "C2 rule-name list stated only in ${CANON} (or cited)"
else
  fail_line "C2 rule-name list restated outside ${CANON}:"
  printf '%s\n' "${viol}" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
# C3 — the prompt-engineer actor ground-rules list is defined once, in a
# knowledge file. A copy under agents/ or commands/ is a Knowledge-in-Actor
# boundary violation (the repo's highest-severity defect).
# ---------------------------------------------------------------------------
needle='Declare: Goal, Input, Steps, Output'
leak="$(grep -rn "${needle}" prompt-engineer/agents prompt-engineer/commands 2>/dev/null || true)"
canon_hit="$(grep -rn "${needle}" prompt-engineer/knowledge 2>/dev/null || true)"
if [[ -n "${leak}" ]]; then
  fail_line "C3 actor ground-rules list leaked into an Actor body:"
  printf '%s\n' "${leak}" | sed 's/^/        /'
elif [[ -z "${canon_hit}" ]]; then
  fail_line "C3 actor ground-rules list missing from prompt-engineer/knowledge (moved/renamed?)"
else
  pass_line "C3 actor ground-rules list defined once in prompt-engineer/knowledge"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "All invariants hold."
  exit 0
fi
echo "Invariant violations found — see FAIL lines above."
exit 1
