#!/usr/bin/env bash
# scripts/roadmap-row.sh — deterministic highest-priority-backlog-row extractor (YAML ledger).
#
# The manager:next Step 0 fast-path offload (pitch pro-tier-token-affordability
# WS3): instead of an agent whole-file-reading the roadmap model-side to find the
# next actionable item, this prints the highest-priority `backlog` /
# `not_started` item of the `.lsa/roadmap.yaml` ledger with its `path:line`
# citation — the exact artifact manager:next quotes.
#
# Ordering is Must > Should > Could > unset, then file order within a priority.
# File order alone is NOT the answer: it can surface a Could while a Must sits
# lower in the ledger, which makes the fast path product-wrong, not just cheap.
#
# specs_root is read from .lsa.yaml (default .lsa/); the ledger is
# ${specs_root}/roadmap.yaml. Zero model calls, pure awk, Pro-safe (no yq, no
# python). Repo-internal — NOT shipped in any plugin; no version bump / CHANGELOG.
#
# Exit 0 = a row was printed. Exit 1 = no ledger / no items / no backlog item —
# the caller falls through to its model-side path (F8 fallback contract).

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
  echo "roadmap-row: NOT-FOUND — no ${ROADMAP}" >&2
  exit 1
fi

# Walk items:; print the highest-priority backlog / not_started item as
# "path:line — slug | title | priority | status", citing the slug's line.
# Ties within a priority resolve to the first in file order.
row="$(awk -v roadmap="${ROADMAP}" '
  function rank(p) {
    if (p=="Must")   return 1
    if (p=="Should") return 2
    if (p=="Could")  return 3
    return 4                                             # unset / unrecognised sorts last
  }
  /^items:[[:space:]]*$/            { ins=1; next }
  ins && /^[^[:space:]#]/           { ins=0 }            # left the items: block
  !ins                              { next }
  /^  - slug: / {
    slug=$0; sub(/^  - slug: /,"",slug); sline=FNR
    title=""; prio=""; wt=0; next
  }
  /^    title: \|[[:space:]]*$/     { wt=1; next }
  wt==1                             { t=$0; sub(/^      /,"",t); title=t; wt=0; next }
  /^    priority: /                 { prio=$0; sub(/^    priority: /,"",prio); next }
  /^    status: / {
    st=$0; sub(/^    status: /,"",st)
    if (st=="backlog" || st=="not_started") {
      r=rank(prio)
      # strict < keeps the first row seen at a rank: file order is the tie-break
      if (best==0 || r<best) {
        best=r
        brow=sprintf("%s:%d — %s | %s | %s | %s", roadmap, sline, slug, title, prio, st)
      }
    }
    next
  }
  END { if (best==0) exit 1; print brow }
' "${ROADMAP}")"

if [[ -z "${row}" ]]; then
  echo "roadmap-row: NONE — no backlog/not_started item in ${ROADMAP}" >&2
  exit 1
fi

printf '%s\n' "${row}"
exit 0
