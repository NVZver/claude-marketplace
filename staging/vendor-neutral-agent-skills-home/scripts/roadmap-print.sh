#!/usr/bin/env bash
# scripts/roadmap-print.sh — human-readable roadmap view (F10).
#
# Pretty-prints the .lsa/roadmap.yaml ledger as a table to stdout. This is a
# VIEW, not a source-of-truth — it writes no file; the YAML ledger stays the sole
# SoT. Pure awk, Pro-safe (no yq, no python). Repo-internal — NOT shipped; no
# version bump / CHANGELOG entry.
#
# Usage: bash scripts/roadmap-print.sh [--all]   (--all also lists shipped items)
# Exit 0 = table printed. Exit 1 = no ledger.

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
ROADMAP="${specs_root%/}/roadmap.yaml"

if [[ ! -f "${ROADMAP}" ]]; then
  echo "roadmap-print: NOT-FOUND — no ${ROADMAP}" >&2
  exit 1
fi

show_all=0
[[ "${1:-}" == "--all" ]] && show_all=1

awk -v roadmap="${ROADMAP}" -v show_all="${show_all}" '
  function pad(s,n,   d){ d=n-length(s); if(d<0)d=0; return s sprintf("%*s",d,"") }
  function trunc(s,n){ return (length(s)>n) ? substr(s,1,n-1) "…" : s }
  function flush(){
    if(slug==""){ return }
    if(show_all!=1 && (status=="shipped")){ return }
    printf "  %s  %s  %s\n", pad(trunc(prio,6),6), pad(status,12), trunc(title,64)
    shown++
  }
  /^items:[[:space:]]*$/        { ins=1; next }
  ins && /^[^[:space:]#]/       { flush(); slug=""; ins=0 }
  !ins                          { next }
  /^  - slug: /                 { flush(); slug=$0; sub(/^  - slug: /,"",slug); prio="";status="";title=""; blk=""; next }
  /^    title: \|[[:space:]]*$/ { blk="title"; next }
  /^    priority: /             { prio=$0; sub(/^    priority: /,"",prio); blk=""; next }
  /^    status: /               { status=$0; sub(/^    status: /,"",status); blk=""; next }
  /^      / { if(blk=="title"){ t=$0; sub(/^      /,"",t); title=t } next }
  END{
    flush()
    print ""
    printf "%d item(s) shown from %s", shown, roadmap
    if(show_all!=1) printf " (shipped hidden; --all to include)"
    print ""
  }
  BEGIN{
    print "=== Roadmap — " roadmap " ==="
    printf "  %-6s  %-12s  %s\n", "PRIO", "STATUS", "TITLE"
    printf "  %-6s  %-12s  %s\n", "------", "------------", "-----"
  }
' "${ROADMAP}"
exit 0
