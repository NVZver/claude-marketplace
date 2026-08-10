#!/usr/bin/env bash
# scripts/pitch-query.sh — bounded pitch outlines (zero model tokens).
#
# The manager:next Mode 1 fan-out offload: Step 2 previously read every candidate
# item's linked pitch file in full to sequence the backlog. Pitches run ~4-13 KB
# each, so N candidates cost N full reads to answer a question that only needs
# "what problem, how big" per candidate.
#
# This prints a capped outline per pitch — title, first line of ## Problem, first
# line of ## Appetite — so the ledger slice + outlines are enough to sequence.
# The full body is read only for the item actually picked.
#
# specs_root is read from .lsa.yaml (default .lsa/); pitches are
# ${specs_root}/pitches/<slug>.md. Pure awk — no yq, no python, Pro-safe.
#
# Subcommands:
#   outline <slug>...        outline for each named slug (missing slug → stderr note)
#   outline --all            outline for every pitch in ${specs_root}/pitches/
#
# Options:
#   --width N                per-field character cap (default 160)
#
# Exit 0 = at least one outline printed. Exit 1 = no pitches dir / no slug
# resolved — the caller falls through to its model-side read.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

CFG=".lsa.yaml"
specs_root=".lsa/"
if [[ -f "${CFG}" ]]; then
  v="$(awk '/^specs_root:[[:space:]]*/ { sub(/^specs_root:[[:space:]]*/,""); gsub(/[[:space:]]+$/,""); print; exit }' "${CFG}")"
  [[ -n "${v}" ]] && specs_root="${v}"
fi
PITCHES="${specs_root%/}/pitches"

usage() { echo "usage: pitch-query.sh outline <slug>... | outline --all [--width N]" >&2; exit 1; }

[[ $# -ge 1 ]] || usage
sub="$1"; shift
[[ "${sub}" == "outline" ]] || usage

width=160
slugs=""
all=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)   all=1; shift ;;
    --width)
      # `shift 2` with only one arg left is a no-op that returns non-zero —
      # the loop would spin forever. Demand the value explicitly.
      [[ $# -ge 2 ]] || { echo "pitch-query: --width needs a value" >&2; exit 1; }
      width="$2"
      [[ "${width}" =~ ^[0-9]+$ ]] && [[ "${width}" -gt 0 ]] || {
        echo "pitch-query: --width must be a positive integer, got '${width}'" >&2; exit 1; }
      shift 2 ;;
    -*)      usage ;;
    *)       slugs="${slugs} $1"; shift ;;
  esac
done

if [[ ! -d "${PITCHES}" ]]; then
  echo "pitch-query: NOT-FOUND — no ${PITCHES}" >&2
  exit 1
fi

if [[ ${all} -eq 1 ]]; then
  slugs=""
  for f in "${PITCHES}"/*.md; do
    [[ -e "${f}" ]] || continue
    b="$(basename "${f}" .md)"
    slugs="${slugs} ${b}"
  done
fi

[[ -n "${slugs// /}" ]] || { echo "pitch-query: NONE — no slug given and --all matched nothing" >&2; exit 1; }

# outline_one <file> <width> — title + first line of Problem + first line of Appetite
outline_one() {
  awk -v path="$1" -v w="$2" '
    function clip(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/,"",s)
      if (length(s) > w) s = substr(s,1,w-1) "…"
      return s
    }
    # first ATX H1 is the pitch title
    !title && /^# / { t=$0; sub(/^# /,"",t); title=clip(t); tline=FNR; next }
    /^## Problem/  { sec="problem";  next }
    /^## Appetite/ { sec="appetite"; next }
    /^## /         { sec=""; next }
    sec=="problem"  && !problem  && NF { problem=clip($0);  sec=""; next }
    sec=="appetite" && !appetite && NF { appetite=clip($0); sec=""; next }
    END {
      if (!title) exit 1
      printf "%s:%d — %s\n", path, tline, title
      if (problem)  printf "  problem:  %s\n", problem
      if (appetite) printf "  appetite: %s\n", appetite
      # A thin outline must announce itself. Silently emitting a title-only
      # outline would hand the caller less than it asked for with no signal,
      # and the caller cannot distinguish "small pitch" from "unparsed pitch".
      if (!problem && !appetite)
        printf "  INCOMPLETE: no ## Problem or ## Appetite section — outline cannot rank this candidate; read the body if it matters\n"
      else if (!problem)
        printf "  INCOMPLETE: no ## Problem section\n"
      else if (!appetite)
        printf "  INCOMPLETE: no ## Appetite section\n"
    }
  ' "$1"
}

found=0
for s in ${slugs}; do
  f="${PITCHES}/${s}.md"
  if [[ ! -f "${f}" ]]; then
    echo "pitch-query: no pitch for slug '${s}' (${f})" >&2
    continue
  fi
  if outline_one "${f}" "${width}"; then
    found=$((found + 1))
  else
    echo "pitch-query: '${s}' has no H1 title — skipped" >&2
  fi
done

[[ ${found} -gt 0 ]] || exit 1
exit 0
