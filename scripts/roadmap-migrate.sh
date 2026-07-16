#!/usr/bin/env bash
# scripts/roadmap-migrate.sh — one-shot lossless migrator: .lsa/roadmap.md → .lsa/roadmap.yaml.
#
# Reads the former markdown roadmap and emits the YAML ledger (F1, F1b, F2):
#   - every `## Feature Backlog` row  → one `items:` entry (slug/title/priority/
#     status[/status_detail]/notes) — the full Notes cell preserved verbatim in a
#     `|` block scalar, no truncation;
#   - every `## Recently merged` row   → one `shipped_history:` entry (verbatim);
#   - the 7 remaining `## ` sections   → `appendix:` entries, each section's full
#     content preserved verbatim under a preserved appendix key.
#
# Pure awk/bash — no yq, no python, no external installs (Pro-safe). One-shot:
# after it runs and roadmap.yaml is verified, .lsa/roadmap.md is deleted (F3).
# Repo-internal — NOT shipped in any plugin; no version bump or CHANGELOG entry.
#
# Usage: bash scripts/roadmap-migrate.sh [SRC] [DST]   (defaults: .lsa/roadmap.md .lsa/roadmap.yaml)
# Exit 0 = roadmap.yaml written. Exit 1 = source missing / parse produced no items.

set -uo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

SRC="${1:-.lsa/roadmap.md}"
DST="${2:-.lsa/roadmap.yaml}"

if [[ ! -f "${SRC}" ]]; then
  echo "roadmap-migrate: NOT-FOUND — no ${SRC}" >&2
  exit 1
fi

awk '
function trim(s){ gsub(/^[[:space:]]+|[[:space:]]+$/,"",s); return s }
# kebab slug from a title, capped to the first 8 word-parts, uniqued.
function slugify(s,   t,parts,n,i,out){
  t=tolower(s)
  gsub(/[^a-z0-9]+/,"-",t)
  gsub(/^-+|-+$/,"",t)
  n=split(t,parts,"-")
  out=""
  for(i=1;i<=n && i<=8;i++){ if(parts[i]!=""){ out=(out==""?parts[i]:out"-"parts[i]) } }
  if(out==""){ out="item" }
  if(out in seen){ seen[out]++; out=out"-"seen[out] } else { seen[out]=1 }
  return out
}
# normalize a raw Status cell to the F4 enum by its leading token.
function status_enum(s,   l){
  l=tolower(s)
  if(l ~ /^backlog/)          return "backlog"
  if(l ~ /^not started/)      return "not_started"
  if(l ~ /^in progress/)      return "in_progress"
  if(l ~ /^in-progress/)      return "in_progress"
  if(l ~ /^started/)          return "in_progress"
  if(l ~ /^branch open/)      return "in_progress"
  if(l ~ /^shipped/)          return "shipped"
  if(l ~ /^deferred/)         return "deferred"
  return "backlog"
}
# strip markdown emphasis from a priority cell (**Must** -> Must).
function prio(s){ gsub(/[*]/,"",s); return trim(s) }
# emit a value as a YAML "|" block scalar at content indent = pad.
# text is a single logical line (a table cell); empty -> "".
function block1(key, keypad, text, pad){
  if(text==""){ printf "%s%s: \"\"\n", keypad, key; return }
  printf "%s%s: |\n", keypad, key
  printf "%s%s\n", pad, text
}

BEGIN{ sec=0; print "version: 1"; print "items:" }

# --- section state machine -------------------------------------------------
/^##[[:space:]]+Feature Backlog[[:space:]]*$/ { mode="backlog"; next }
/^##[[:space:]]+Recently merged[[:space:]]*$/ { mode="merged"; printf "\nshipped_history:\n"; next }
# the first ## after Recently merged opens the verbatim appendix tail.
/^##[[:space:]]/ && mode=="merged" { mode="appendix"; printf "\nappendix:\n" }

# --- backlog + merged table rows -------------------------------------------
mode=="backlog" && /^\|/ {
  if($0 ~ /^\|[[:space:]]*-+/) next
  if($0 ~ /\|[[:space:]]*Feature[[:space:]]*\|/) next
  n=split($0,c,"|")
  title=trim(c[2]); priority=prio(c[3]); rawstatus=trim(c[4])
  notes=""
  for(i=5;i<=n-1;i++){ notes=(notes==""?c[i]:notes"|"c[i]) }
  notes=trim(notes)
  slug=slugify(title)
  printf "  - slug: %s\n", slug
  block1("title","    ",title,"      ")
  printf "    priority: %s\n", priority
  printf "    status: %s\n", status_enum(rawstatus)
  if(rawstatus != status_enum(rawstatus)) block1("status_detail","    ",rawstatus,"      ")
  block1("notes","    ",notes,"      ")
  items++
  next
}
mode=="merged" && /^\|/ {
  if($0 ~ /^\|[[:space:]]*-+/) next
  if($0 ~ /\|[[:space:]]*Release[[:space:]]*\|/) next
  n=split($0,c,"|")
  release=trim(c[2]); date=trim(c[3])
  hl=""
  for(i=4;i<=n-1;i++){ hl=(hl==""?c[i]:hl"|"c[i]) }
  hl=trim(hl)
  printf "  -\n"
  block1("release","    ",release,"      ")
  block1("date","    ",date,"      ")
  block1("highlights","    ",hl,"      ")
  next
}

# --- appendix: verbatim tail, split into one entry per ## section ----------
mode=="appendix" {
  if($0 ~ /^##[[:space:]]/){
    sec++
    printf "  - section: appendix-%d\n", sec
    printf "    content: |\n"
  }
  # add 6 spaces to every non-empty line (block content indent); keep blanks empty.
  if($0 ~ /[^[:space:]]/) printf "      %s\n", $0; else print ""
  next
}

END{ if(items+0==0) exit 2 }
' "${SRC}" > "${DST}.tmp"
rc=$?
if [[ "${rc}" -ne 0 ]]; then
  echo "roadmap-migrate: PARSE-FAILED (rc=${rc}) — no items extracted from ${SRC}" >&2
  rm -f "${DST}.tmp"
  exit 1
fi

mv "${DST}.tmp" "${DST}"
echo "roadmap-migrate: wrote ${DST}"
exit 0
