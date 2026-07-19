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
# hygiene emits five deterministic hint classes:
#   (1) missing-pitch       actionable item with no pitch/detail/archive reference
#   (2) backlog-but-branch  actionable item that already has a feature/<slug> branch
#   (3) stale-in-progress   in_progress with no matching feature/<slug> branch
#   (4) merged-not-shipped  feature/<slug> merged into the default branch, status != shipped
#   (5) no-artifacts        actionable item with NO branch, NO features/*<slug>* dir,
#                           and NO pitches/<slug>.md
#
# SCOPE NOTE — class 5 is NOT a recency check. True staleness ("no recent
# activity") is OUT OF SCOPE: the roadmap item schema carries no date/updated
# field (items are slug · title · priority · status · status_detail · notes), so
# time-based staleness is not deterministically derivable here. Class 5 is an
# artifact-EXISTENCE proxy only — it says "nothing was ever created for this
# slug", never "this slug went quiet". The deferred-vs-active call stays the
# human's; every class is a hint, never an auto-fix.
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

    # Default branch for the merged-into test: origin/HEAD when the remote head is
    # known, else "main". Prefer the local ref; fall back to origin/<default> when
    # only the remote-tracking ref exists.
    default_branch="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
    default_branch="${default_branch#origin/}"
    [[ -n "${default_branch}" ]] || default_branch="main"
    merge_base_ref="${default_branch}"
    if ! git rev-parse --verify --quiet "${merge_base_ref}" >/dev/null 2>&1; then
      if git rev-parse --verify --quiet "origin/${default_branch}" >/dev/null 2>&1; then
        merge_base_ref="origin/${default_branch}"
      fi
    fi
    merged="$(git branch --merged "${merge_base_ref}" --format='%(refname:short)' 2>/dev/null | grep '^feature/' | tr '\n' ' ' || true)"

    # Spec-artifact inventories for class 5 (basenames, space-joined like branches).
    featdirs=""
    if [[ -d "${specs_root%/}/features" ]]; then
      for d in "${specs_root%/}/features"/*/; do
        [[ -d "${d}" ]] || continue
        b="${d%/}"; b="${b##*/}"
        featdirs="${featdirs}${b} "
      done
    fi
    pitchfiles=""
    if [[ -d "${specs_root%/}/pitches" ]]; then
      for f in "${specs_root%/}/pitches"/*.md; do
        [[ -f "${f}" ]] || continue
        pitchfiles="${pitchfiles}${f##*/} "
      done
    fi

    items_tsv | awk -F'\t' -v roadmap="${ROADMAP}" -v branches="${branches}" \
                      -v merged="${merged}" -v defbranch="${default_branch}" \
                      -v featdirs="${featdirs}" -v pitchfiles="${pitchfiles}" \
                      -v sroot="${specs_root%/}/" '
      BEGIN{ nb=split(branches,B," "); nm=split(merged,M," ")
             nfd=split(featdirs,FD," "); np=split(pitchfiles,P," ") }
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
        # (4) merged-not-shipped: feature/<slug> is merged into the default branch
        #     yet the item is not marked shipped.
        merged_branch=""
        for(i=1;i<=nm;i++){ if(M[i]=="feature/" slug) merged_branch=M[i] }
        if(merged_branch!="" && status!="shipped"){
          printf "%s:%d — %s — HINT: branch %s is merged into %s but status is %s (→ shipped?)\n", \
                 roadmap, line, slug, merged_branch, defbranch, status
          hits++
        }
        # (5) no-artifacts: an actionable item with no branch, no features/*<slug>*
        #     dir and no pitches/<slug>.md. Artifact-EXISTENCE proxy, NOT recency —
        #     the item schema has no date field (see the SCOPE NOTE in the header).
        if(status=="backlog"||status=="not_started"||status=="in_progress"){
          has_artifact=has_branch
          for(i=1;i<=nfd;i++){ if(!has_artifact && index(FD[i], slug)>0) has_artifact=1 }
          for(i=1;i<=np;i++){ if(!has_artifact && P[i]==slug ".md") has_artifact=1 }
          if(!has_artifact){
            printf "%s:%d — %s — HINT: no feature/%s branch, no %sfeatures/*%s* dir, no %spitches/%s.md — classify as deferred or active (artifact-existence proxy, not a recency check)\n", \
                   roadmap, line, slug, slug, sroot, slug, sroot, slug
            hits++
          }
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
