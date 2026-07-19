#!/usr/bin/env bash
# scripts/metrics-harvest.sh — deterministic harvest of the three tracked
# metrics from one conformance.md.
#
# COMPUTES, NEVER JUDGES: every value is read verbatim off an existing script's
# output or the conformance file's canonical shape. Anything not in that shape
# is reported UNPARSEABLE, with a reason — never guessed, never regex-cleverness
# (mirrors scripts/coverage-skeleton.sh: "a script never guesses semantics").
#
# The third metric, citation-resolve-rate, is a PROXY: scripts/check-citations.sh
# confirms a citation still points at a real line, not that the quoted text is
# intact (scripts/check-citations.sh:12-13). It is a repo-wide rate, not a
# per-feature one — hence the literal PROXY suffix on every run.
#
# Repo-internal — NOT shipped in any plugin; lives outside every plugin's
# artifact_paths in .lsa.yaml, so it triggers no plugin version bump or
# CHANGELOG entry.
#
# Zero model calls, no network access. Writes nothing — stdout only; never
# appends to .lsa/metrics.md (that is epic 2's, reconcile-emit-guard's, job).
#
# Usage: metrics-harvest.sh <conformance.md> [git-diff-args…]
#   (git-diff-args passed through verbatim to coverage-skeleton.sh; default HEAD,
#   matching scripts/coverage-skeleton.sh:23)
#
# Exit 0 whenever the four output lines are printed — an UNPARSEABLE metric is
# informational, not a failure (mirrors scripts/resolve-refs.sh's new/MISSING
# handling). Non-zero exit only on the usage / missing-file errors below.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

conformance="${1:-}"
if [[ -z "${conformance}" ]]; then
  echo "metrics-harvest: usage: metrics-harvest.sh <conformance.md> [git-diff-args…]" >&2
  exit 1
fi
if [[ ! -f "${conformance}" ]]; then
  echo "metrics-harvest: no such file: ${conformance}" >&2
  exit 1
fi
shift

feature_dir="$(dirname "${conformance}")"
feature_dir="${feature_dir%/}"
feature_name="$(basename "${feature_dir}")"

# --- line 1: feature ----------------------------------------------------
echo "feature: ${feature_name}"

# --- line 2: only-required-changes = (N - orphans) / N -------------------
# R5: the canonical orphan-hunk line, anchored at start of line (no leading
# `**`/whitespace). Exactly one such line required; zero or more than one is
# ambiguous, never averaged.
orphan_re='^Orphan hunks: (none\.|[0-9]+)[[:space:]]*$'
orphan_hits="$(grep -cE "${orphan_re}" "${conformance}" 2>/dev/null || true)"
[[ -n "${orphan_hits}" ]] || orphan_hits=0

if [[ "${orphan_hits}" -ne 1 ]]; then
  metric2="UNPARSEABLE (non-canonical orphan-hunk line)"
else
  orphan_line="$(grep -E "${orphan_re}" "${conformance}" 2>/dev/null | head -n 1)"
  orphan_value="${orphan_line#Orphan hunks: }"
  orphan_value="$(printf '%s' "${orphan_value}" | sed -E 's/[[:space:]]+$//')"
  if [[ "${orphan_value}" == "none." ]]; then
    orphans=0
  else
    orphans="${orphan_value}"
  fi

  cov_output="$(bash scripts/coverage-skeleton.sh "${feature_dir}" "$@" 2>/dev/null)"
  cov_rc=$?
  if [[ "${cov_rc}" -ne 0 ]]; then
    metric2="UNPARSEABLE (coverage-skeleton failed)"
  else
    candidate_n="$(printf '%s\n' "${cov_output}" | grep -c '^- \[ \] ' || true)"
    [[ -n "${candidate_n}" ]] || candidate_n=0
    if [[ "${candidate_n}" -eq 0 ]]; then
      metric2="UNPARSEABLE (no candidate hunks)"
    else
      metric2="$((candidate_n - orphans))/${candidate_n}"
    fi
  fi
fi
echo "only-required-changes: ${metric2}"

# --- line 3: accuracy-to-task = passing coverage rows / total rows -------
# R6: a coverage row is a `|`-prefixed line whose first cell (trimmed,
# backticks stripped) matches ^[RF][0-9]+[a-z]?$. M = rows whose LAST
# non-empty cell contains ✅.
accuracy_counts="$(awk '
  /^\|/ {
    n = split($0, cells, "|")
    first = cells[2]
    gsub(/^[ \t]+|[ \t]+$/, "", first)
    gsub(/`/, "", first)
    if (first !~ /^[RF][0-9]+[a-z]?$/) next
    total++
    last_idx = n
    while (last_idx >= 2 && cells[last_idx] ~ /^[ \t]*$/) last_idx--
    last = cells[last_idx]
    if (index(last, "✅") > 0) pass++
  }
  END { printf "%d %d\n", total+0, pass+0 }
' "${conformance}")"
accuracy_n="${accuracy_counts%% *}"
accuracy_m="${accuracy_counts##* }"

if [[ "${accuracy_n}" -eq 0 ]]; then
  metric3="UNPARSEABLE (no coverage-table rows)"
else
  metric3="${accuracy_m}/${accuracy_n}"
fi
echo "accuracy-to-task: ${metric3}"

# --- line 4: citation-resolve-rate (PROXY) --------------------------------
# R7: derived from scripts/check-citations.sh's summary line, repo-wide.
cite_output="$(bash scripts/check-citations.sh 2>&1)"
esc="$(printf '\033')"
cite_clean="$(printf '%s\n' "${cite_output}" | sed -E "s/${esc}\[[0-9;]*m//g")"

ok_line="$(printf '%s\n' "${cite_clean}" | grep -E '^OK[[:space:]]+[0-9]+ citation\(s\) checked, all resolve\.$' | head -n 1 || true)"
fail_line="$(printf '%s\n' "${cite_clean}" | grep -E '^FAIL[[:space:]]+[0-9]+ broken citation\(s\) of [0-9]+ checked' | head -n 1 || true)"

if [[ -n "${ok_line}" ]]; then
  n="$(printf '%s' "${ok_line}" | grep -oE '[0-9]+' | head -n 1)"
  metric4="${n}/${n}"
elif [[ -n "${fail_line}" ]]; then
  v="$(printf '%s' "${fail_line}" | grep -oE '[0-9]+' | sed -n '1p')"
  n="$(printf '%s' "${fail_line}" | grep -oE '[0-9]+' | sed -n '2p')"
  metric4="$((n - v))/${n}"
else
  metric4="UNPARSEABLE (check-citations summary not found)"
fi
echo "citation-resolve-rate: ${metric4}  (PROXY — resolve-rate, not quote integrity)"

exit 0
