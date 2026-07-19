#!/usr/bin/env bash
# scripts/tests/no-wholefile-pitch-read.sh — Mode 1 pitch fan-out enforcement test.
#
# Asserts that manager:next Mode 1 sequencing obtains pitch context through
# scripts/pitch-query.sh outline rather than reading candidate pitch bodies in
# full. Sibling of no-wholefile-ledger-read.sh: same shape, different corpus.
#
# Why enforce it: pitches run ~4-13 KB each. A 5-candidate sequencing pass that
# full-reads each candidate costs ~12.7k tok to answer "what problem, how big" —
# measured 25x the equivalent outline pass (~489 tok). The saving only holds
# while the wiring holds, so it is asserted, not assumed.
#
# Assertions:
#   (a) POSITIVE — Mode 1 Step 2 names the outline script it calls;
#   (b) NEGATIVE — it carries no unqualified "read its linked pitch file"
#       directive; any full pitch read must be qualified as post-pick or
#       named-and-justified;
#   (c) BEHAVIORAL — the script actually produces a bounded outline, and that
#       outline is materially smaller than the corresponding full read.
#
# Pure bash/grep — Pro-safe, no deps. Repo-internal — not shipped.
# Exit 0 = all assertions hold. Exit 1 = the fan-out guard regressed.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
fail=0
pass_line() { printf '  %sPASS%s  %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

echo "=== Mode 1: no happy-path whole-file read of candidate pitches ==="

PM="manager/agents/project-manager.md"
SCRIPT="scripts/pitch-query.sh"

# (a) POSITIVE — the sequencing step names the outline script.
if grep -qF "pitch-query.sh outline" "${PM}" 2>/dev/null; then
  pass_line "project-manager Mode 1 names pitch-query.sh outline"
else
  fail_line "project-manager Mode 1 lost its pitch-query.sh wiring"
fi

# (b) NEGATIVE — no unqualified full-pitch-read directive.
if grep -qE '^2\. \*\*Read pitches\.\*\*' "${PM}" 2>/dev/null; then
  fail_line "project-manager Step 2 restored the unqualified 'Read pitches' directive"
else
  pass_line "no unqualified 'Read pitches' directive in Mode 1"
fi

if grep -qF "Do not read a full pitch file during sequencing" "${PM}" 2>/dev/null; then
  pass_line "Mode 1 states the no-full-read rule explicitly"
else
  fail_line "Mode 1 lost the explicit no-full-read rule"
fi

# (c) BEHAVIORAL — the script bounds what it emits.
if [[ ! -x "${SCRIPT}" && ! -f "${SCRIPT}" ]]; then
  fail_line "${SCRIPT} missing"
else
  pitches_dir="$(awk '/^specs_root:[[:space:]]*/ { sub(/^specs_root:[[:space:]]*/,""); gsub(/[[:space:]]+$/,""); print; exit }' .lsa.yaml 2>/dev/null)"
  [[ -n "${pitches_dir}" ]] || pitches_dir=".lsa/"
  pitches_dir="${pitches_dir%/}/pitches"

  # pick the largest pitch — the worst case for an outline cap
  biggest="$(ls -S "${pitches_dir}"/*.md 2>/dev/null | head -1)"
  if [[ -z "${biggest}" ]]; then
    pass_line "no pitches on disk — behavioral check skipped"
  else
    slug="$(basename "${biggest}" .md)"
    out_b="$(bash "${SCRIPT}" outline "${slug}" 2>/dev/null | wc -c | tr -d ' ')"
    full_b="$(wc -c < "${biggest}" | tr -d ' ')"

    if [[ "${out_b}" -eq 0 ]]; then
      fail_line "outline produced nothing for '${slug}'"
    elif [[ "${out_b}" -lt $((full_b / 5)) ]]; then
      pass_line "outline bounds the largest pitch (${out_b} B vs ${full_b} B full)"
    else
      fail_line "outline not materially smaller for '${slug}' (${out_b} B vs ${full_b} B)"
    fi

    # a missing slug must fall through, not crash
    if bash "${SCRIPT}" outline __definitely-not-a-pitch__ >/dev/null 2>&1; then
      fail_line "missing slug should exit non-zero (fallback contract)"
    else
      pass_line "missing slug exits non-zero — caller falls through"
    fi

    # a thin outline must announce itself rather than degrade silently: the
    # caller cannot otherwise tell "small pitch" from "unparsed pitch".
    thin="$(mktemp -d "${TMPDIR:-/tmp}/pqthin.XXXXXX")"
    mkdir -p "${thin}/.lsa/pitches"
    printf '# A document with no pitch sections\n\nprose only\n' > "${thin}/.lsa/pitches/thin-doc.md"
    (
      cd "${thin}" && git init -q 2>/dev/null
      out="$(bash "${repo_root}/${SCRIPT}" outline thin-doc 2>/dev/null)"
      printf '%s' "${out}" | grep -q "INCOMPLETE"
    )
    if [[ $? -eq 0 ]]; then
      pass_line "section-less pitch emits an INCOMPLETE marker"
    else
      fail_line "section-less pitch degraded silently — no INCOMPLETE marker"
    fi
    rm -rf "${thin}"
  fi
fi

echo
if [[ ${fail} -eq 0 ]]; then
  echo "no-wholefile-pitch-read: PASS — all assertions"
  exit 0
fi
echo "no-wholefile-pitch-read: FAIL" >&2
exit 1
