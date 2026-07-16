#!/usr/bin/env bash
# scripts/roadmap-query.sh — on-demand roadmap ledger query (zero model tokens).
#
# Consumers load only the slice a question needs instead of whole-file-reading the
# ledger (pitch yaml-ledger-selective-load). Pure awk over .lsa/roadmap.yaml — no
# yq, no python, Pro-safe. Repo-internal — NOT shipped; no version bump / CHANGELOG.
#
# Subcommands:
#   backlog --limit N [--fields a,b,...]   ≤N backlog/not_started rows to stdout
#                                          (fields default: slug,title,priority,status)
#   get <slug>                             the one record verbatim, or exit 1 if absent
#   hygiene                                deterministic status/pitch mismatch hints
#
# Fallback contract (F8): any non-zero exit ⇒ the calling consumer falls through to
# a whole-file read of the ledger. Exit 1 = no ledger / bad args / get-miss.
#
# Exit 0 = a slice was emitted (backlog/hygiene always 0 when the ledger loads;
# get = 0 only when the slug exists). Exit 1 = fallthrough.

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

usage() { echo "usage: roadmap-query.sh backlog --limit N [--fields a,b] | get <slug> | hygiene" >&2; }

if [[ ! -f "${ROADMAP}" ]]; then
  echo "roadmap-query: NOT-FOUND — no ${ROADMAP}" >&2
  exit 1
fi

sub="${1:-}"; shift || true

# Emit one TSV record per item: slug \t line \t priority \t status \t status_detail \t title \t notes
items_tsv() {
  awk '
    function flush(){ if(slug!=""){ printf "%s\t%d\t%s\t%s\t%s\t%s\t%s\n", slug, sline, prio, status, sd, title, notes } }
    /^items:[[:space:]]*$/        { ins=1; next }
    ins && /^[^[:space:]#]/       { flush(); slug=""; ins=0 }
    !ins                          { next }
    /^  - slug: /                 { flush(); slug=$0; sub(/^  - slug: /,"",slug); sline=FNR; prio="";status="";sd="";title="";notes=""; blk=""; next }
    /^    title: \|[[:space:]]*$/ { blk="title"; next }
    /^    priority: /             { prio=$0; sub(/^    priority: /,"",prio); blk=""; next }
    /^    status: /               { status=$0; sub(/^    status: /,"",status); blk=""; next }
    /^    status_detail: \|[[:space:]]*$/ { blk="sd"; next }
    /^    notes: \|[[:space:]]*$/  { blk="notes"; next }
    /^    notes: ""[[:space:]]*$/  { notes=""; blk=""; next }
    /^      / {
      line=$0; sub(/^      /,"",line)
      if(blk=="title") title=line
      else if(blk=="sd") sd=line
      else if(blk=="notes") notes=line
      next
    }
    END{ flush() }
  ' "${ROADMAP}"
}

case "${sub}" in
  backlog)
    limit=""
    fields="slug,title,priority,status"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --limit) limit="${2:-}"; shift 2 ;;
        --fields) fields="${2:-}"; shift 2 ;;
        *) usage; exit 1 ;;
      esac
    done
    [[ "${limit}" =~ ^[0-9]+$ ]] || { echo "roadmap-query: backlog needs --limit N" >&2; exit 1; }
    items_tsv | awk -F'\t' -v lim="${limit}" -v fl="${fields}" -v roadmap="${ROADMAP}" '
      BEGIN{ nf=split(fl,F,",") }
      $4=="backlog" || $4=="not_started" {
        if(count>=lim) next
        # column map: 1 slug,2 line,3 priority,4 status,5 status_detail,6 title,7 notes
        out=""
        for(i=1;i<=nf;i++){
          f=F[i]; v=""
          if(f=="slug")v=$1; else if(f=="title")v=$6; else if(f=="priority")v=$3
          else if(f=="status")v=$4; else if(f=="status_detail")v=$5; else if(f=="notes")v=$7
          out=(out==""?v:out" | "v)
        }
        printf "%s:%d — %s\n", roadmap, $2, out
        count++
      }
      END{ if(count==0) exit 1 }
    '
    exit $?
    ;;

  get)
    slug="${1:-}"
    [[ -n "${slug}" ]] || { echo "roadmap-query: get needs <slug>" >&2; exit 1; }
    # Print the item's YAML block verbatim (from its "  - slug:" to the next
    # "  - " / top-level key), with a leading path:line citation.
    out="$(awk -v want="${slug}" -v roadmap="${ROADMAP}" '
      /^items:[[:space:]]*$/  { ins=1; next }
      ins && /^[^[:space:]#]/ { ins=0 }
      !ins                    { next }
      /^  - slug: / {
        s=$0; sub(/^  - slug: /,"",s)
        if(pr){ exit }                 # was printing the wanted block; next slug ends it
        if(s==want){ pr=1; printf "%s:%d\n", roadmap, FNR }
      }
      pr { print }
    ' "${ROADMAP}")"
    if [[ -z "${out}" ]]; then
      echo "roadmap-query: NONE — no item with slug '${slug}'" >&2
      exit 1
    fi
    printf '%s\n' "${out}"
    exit 0
    ;;

  hygiene)
    # feature/* branch names carry no spaces → pass them space-joined for awk split.
    branches="$(git branch --format='%(refname:short)' 2>/dev/null | grep '^feature/' | tr '\n' ' ' || true)"
    items_tsv | awk -F'\t' -v roadmap="${ROADMAP}" -v branches="${branches}" '
      BEGIN{ nb=split(branches,B," ") }
      {
        slug=$1; line=$2; status=$4; notes=$7
        has_branch=0
        for(i=1;i<=nb;i++){ if(B[i]=="feature/" slug) has_branch=1 }
        # (1) missing-pitch: an actionable item with no pitch / detail / archive / feature reference.
        if((status=="backlog"||status=="not_started") && notes !~ /[Pp]itch|Detail:|archive|Feature:/){
          printf "%s:%d — %s — HINT: no linked pitch/detail reference (status %s)\n", roadmap, line, slug, status
          hits++
        }
        # (2) backlog-but-branch: an actionable item that already has a feature/<slug> branch.
        if((status=="backlog"||status=="not_started") && has_branch){
          printf "%s:%d — %s — HINT: feature/%s branch exists but status is %s (→ in_progress?)\n", roadmap, line, slug, slug, status
          hits++
        }
        # (3) stale-in-progress: in_progress with no matching feature/<slug> branch.
        if(status=="in_progress" && !has_branch){
          printf "%s:%d — %s — HINT: status in_progress but no feature/%s branch\n", roadmap, line, slug, slug
          hits++
        }
      }
      END{ if(hits==0) print "roadmap-query hygiene: no deterministic mismatches found" }
    '
    exit 0
    ;;

  *)
    usage
    exit 1
    ;;
esac
