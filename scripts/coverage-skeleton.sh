#!/usr/bin/env bash
# scripts/coverage-skeleton.sh — deterministic coverage-table skeleton for reconcile.
#
# lsa:reconcile Step 4 builds a requirement↔hunk coverage table. Its two axes are
# pure enumeration — every requirement ID from requirements.md, every changed file
# from git diff — deterministic work the model should cite, not recompute at
# inference time (.lsa/VISION.md §2 principle 10). This script emits that skeleton:
# a coverage-table with one empty row per requirement ID plus a Candidate-hunks
# checklist of every changed file. The model fills ONLY the semantic mapping
# (which hunk satisfies which requirement) and reads off orphans / uncovered.
#
# ENUMERATION ONLY. It never maps a hunk to a requirement — semantic judgment stays
# with reconcile (principle 10's enumeration/judgment split; the doc-lint gate's
# no-fragile-matching discipline: a script never guesses semantics).
#
# Handles both R- and F-keyed specs (both exist in-repo). The spec's own files under
# <feature-dir> are excluded — they are never implementing hunks.
#
# Repo-internal — NOT shipped in any plugin; lives outside every plugin's
# artifact_paths, so it triggers no plugin version bump or CHANGELOG entry.
# Pure grep + git, bash 3.2-safe, zero model calls, Pro-safe.
#
# Usage: coverage-skeleton.sh <feature-dir> [git-diff-args…]   (git-diff-args default: HEAD)
# Exit 0 = skeleton emitted. Non-zero + one-line diagnostic on bad input
# (missing dir / missing requirements.md).

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

feature_dir="${1:-}"
if [[ -z "${feature_dir}" ]]; then
  echo "coverage-skeleton: usage: coverage-skeleton.sh <feature-dir> [git-diff-args…]" >&2
  exit 1
fi
shift

feature_dir="${feature_dir%/}"           # normalize trailing slash
req_file="${feature_dir}/requirements.md"

if [[ ! -d "${feature_dir}" ]]; then
  echo "coverage-skeleton: no such feature dir: ${feature_dir}" >&2
  exit 1
fi
if [[ ! -f "${req_file}" ]]; then
  echo "coverage-skeleton: no requirements.md in ${feature_dir}" >&2
  exit 1
fi

# Default the git-diff-args to HEAD when none are passed.
if [[ $# -eq 0 ]]; then
  set -- HEAD
fi

# R1: every requirement ID (^- R1. / ^- F1. …) in document order.
ids="$(grep -oE '^- [RF][0-9]+\.' "${req_file}" | grep -oE '[RF][0-9]+' || true)"

# R2: changed files — tracked diff PLUS untracked new files (reconcile grades an
# epic before its commit, so the epic's own new files are still untracked). Merge
# both lists, dedupe + sort, and exclude <feature-dir> itself (spec files are never
# hunks).
changed="$( { git diff --name-only "$@" 2>/dev/null; \
              git ls-files --others --exclude-standard 2>/dev/null; } \
  | sort -u \
  | awk -v d="${feature_dir}" '
      $0 == d               { next }      # the dir path itself
      index($0, d "/") == 1 { next }      # anything under the dir
      NF                     { print }    # skip blank lines
    ' || true)"

# R3: the coverage-table skeleton — one empty row per requirement ID.
echo "| Req | Implementing hunks/files | Proving runs | Verdict |"
echo "|---|---|---|---|"
printf '%s\n' "${ids}" | while IFS= read -r id; do
  [[ -n "${id}" ]] || continue
  printf '| %s |  |  |  |\n' "${id}"
done

# R4: the deterministic changed-file enumeration as a checklist below the table.
echo
echo "## Candidate hunks"
echo
if [[ -n "${changed}" ]]; then
  printf '%s\n' "${changed}" | while IFS= read -r f; do
    [[ -n "${f}" ]] || continue
    printf -- '- [ ] %s\n' "${f}"
  done
else
  echo "_(no changed files)_"
fi

exit 0
