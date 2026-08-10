#!/usr/bin/env bash
# scripts/tests/roadmap-query-hygiene-test.sh — hygiene hint-class behavior test (R7).
#
# Hermetic: builds a throwaway git repo in a scratch dir with a fixture
# roadmap.yaml, feature branches, a pitch file and a feature dir, then runs the
# real scripts/roadmap-query.sh hygiene against it.
#
# A hermetic fixture is REQUIRED, not a convenience: the live tree has no merged
# branch whose name matches a roadmap slug, so class 4 emits nothing on real data
# and a green live run would prove nothing (grounding.md §Feasibility).
#
# Covers: class 4 fires (merged branch + non-shipped status) · class 4 silent
# (status shipped) · class 5 fires (zero artifacts) · class 5 silent (pitch file
# exists) · classes 1–3 regression (stale in_progress still hinted).
#
# Pure bash/git — Pro-safe, no deps, bash 3.2-safe (no mapfile/assoc arrays).
# Exit 0 = all cases pass. Exit 1 = a case failed (named in the FAIL line).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
SCRIPT="${repo_root}/scripts/roadmap-query.sh"

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

if [[ ! -f "${SCRIPT}" ]]; then
  echo "roadmap-query-hygiene-test: ${SCRIPT} missing" >&2
  exit 1
fi

echo "=== roadmap-query.sh hygiene — classes 4 and 5 (R7) ==="

# --- hermetic scratch repo --------------------------------------------------
work="$(mktemp -d "${TMPDIR:-/tmp}/rqhygiene.XXXXXX")"
cleanup() { rm -rf "${work}"; }
trap cleanup EXIT

cd "${work}"
git init -q
git symbolic-ref HEAD refs/heads/main       # default branch = main (no origin/HEAD here)
git config user.email "t@t.t"
git config user.name "t"

mkdir -p .lsa/pitches .lsa/features

# Fixture ledger. Field shape matches items_tsv's parser:
#   "  - slug: " / "    priority: " / "    status: " / "    title: |" / "    notes: |"
#
#   alpha   in_progress + feature/alpha MERGED   → class 4 fires
#   beta    shipped     + feature/beta  MERGED   → class 4 silent
#   gamma   backlog, no branch/dir/pitch         → class 5 fires
#   delta   backlog, has pitches/delta.md        → class 5 silent
#   epsilon in_progress, no branch (has feat dir)→ class 3 regression fires
cat > .lsa/roadmap.yaml <<'YAML'
version: 1
items:
  - slug: alpha
    title: |
      Alpha item
    priority: must
    status: in_progress
    notes: |
      Pitch: .lsa/pitches/alpha.md
  - slug: beta
    title: |
      Beta item
    priority: must
    status: shipped
    notes: |
      Pitch: .lsa/pitches/beta.md
  - slug: gamma
    title: |
      Gamma item
    priority: should
    status: backlog
    notes: |
      Pitch: .lsa/pitches/gamma.md
  - slug: delta
    title: |
      Delta item
    priority: should
    status: backlog
    notes: |
      Pitch: .lsa/pitches/delta.md
  - slug: epsilon
    title: |
      Epsilon item
    priority: could
    status: in_progress
    notes: |
      Pitch: .lsa/pitches/epsilon.md
YAML

# Artifacts: a pitch for delta (class-5 silencer) and a feature dir containing
# "epsilon" (class-5 silencer for the class-3 regression item, so its only hint
# is the stale-in-progress one).
echo "delta pitch" > .lsa/pitches/delta.md
mkdir -p .lsa/features/2026-01-01-epsilon-scope

git add -A
git commit -q -m init

# feature/alpha and feature/beta: real commits, then merged into main.
for b in alpha beta; do
  git checkout -q -b "feature/${b}"
  echo "${b}" > "${b}.txt"
  git add -A
  git commit -q -m "${b}"
  git checkout -q main
  git merge -q --no-ff -m "merge ${b}" "feature/${b}"
done

# Sanity: both branches must actually report as merged, or the fixture is broken.
mergedlist="$(git branch --merged main --format='%(refname:short)' | tr '\n' ' ')"
case " ${mergedlist} " in
  *" feature/alpha "*) : ;;
  *) fail_line "fixture: feature/alpha is not merged into main (got '${mergedlist}')" ;;
esac

out="$(bash "${SCRIPT}" hygiene </dev/null 2>&1)"; rc=$?

if [[ "${rc}" -eq 0 ]]; then
  pass_line "exit 0 when the ledger loads (R4)"
else
  fail_line "expected exit 0, got ${rc} — output: ${out}"
fi

# --- class 4 fires: alpha (in_progress) with feature/alpha merged ------------
if printf '%s\n' "${out}" | grep -q 'alpha .* HINT: branch feature/alpha is merged into main but status is in_progress'; then
  pass_line "class 4 fires: alpha — merged feature/alpha, status in_progress"
else
  fail_line "class 4 fires: expected a merged-not-shipped hint for alpha — output: ${out}"
fi

# --- class 4 silent: beta (shipped) with feature/beta merged ----------------
if printf '%s\n' "${out}" | grep -q 'beta .* HINT: branch feature/beta is merged'; then
  fail_line "class 4 silent: beta is shipped but a merged-not-shipped hint was emitted — output: ${out}"
else
  pass_line "class 4 silent: beta — merged feature/beta, status shipped, no hint"
fi

# --- class 5 fires: gamma has no branch, no feature dir, no pitch -----------
if printf '%s\n' "${out}" | grep -q 'gamma .* HINT: no feature/gamma branch'; then
  pass_line "class 5 fires: gamma — zero artifacts, classify deferred/active"
else
  fail_line "class 5 fires: expected a no-artifacts hint for gamma — output: ${out}"
fi

# --- class 5 silent: delta has .lsa/pitches/delta.md ------------------------
if printf '%s\n' "${out}" | grep -q 'delta .* HINT: no feature/delta branch'; then
  fail_line "class 5 silent: delta has a pitch file but a no-artifacts hint was emitted — output: ${out}"
else
  pass_line "class 5 silent: delta — pitches/delta.md exists, no hint"
fi

# --- class 5 is an existence proxy, not a recency check (R3) ----------------
if printf '%s\n' "${out}" | grep -q 'not a recency check'; then
  pass_line "class 5 hint states the artifact-existence-proxy boundary (R3)"
else
  fail_line "class 5 hint is missing the 'not a recency check' boundary note (R3) — output: ${out}"
fi

# --- classes 1–3 regression: epsilon in_progress, no feature/epsilon branch --
if printf '%s\n' "${out}" | grep -q 'epsilon .* HINT: status in_progress but no feature/epsilon branch'; then
  pass_line "class 3 regression: epsilon — stale in_progress hint still printed (R4)"
else
  fail_line "class 3 regression: expected the stale-in-progress hint for epsilon — output: ${out}"
fi

# --- R4: the clean-ledger line still prints on zero hits --------------------
cat > .lsa/roadmap.yaml <<'YAML'
version: 1
items:
  - slug: beta
    title: |
      Beta item
    priority: must
    status: shipped
    notes: |
      Pitch: .lsa/pitches/beta.md
YAML
clean="$(bash "${SCRIPT}" hygiene </dev/null 2>&1)"; rcc=$?
if [[ "${rcc}" -eq 0 ]] && printf '%s\n' "${clean}" | grep -qF 'no deterministic mismatches found'; then
  pass_line "zero hits: 'no deterministic mismatches found' still printed (R4)"
else
  fail_line "zero hits: expected the clean line at exit 0 (got exit ${rcc}) — output: ${clean}"
fi

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "roadmap-query.sh hygiene: all cases pass."
  exit 0
fi
echo "roadmap-query.sh hygiene: FAILURES above."
exit 1
