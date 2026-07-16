#!/usr/bin/env bash
# scripts/roadmap-row.sh — deterministic first-backlog-row extractor (YAML ledger).
#
# The manager:next Step 0 fast-path offload (pitch pro-tier-token-affordability
# WS3): instead of an agent whole-file-reading the roadmap model-side to find the
# first actionable item, this prints the first `backlog` / `not_started` item of
# the `.lsa/roadmap.yaml` ledger with its `path:line` citation — the exact
# artifact manager:next quotes.
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

# Walk items:; print the first whose status is backlog / not_started as
# "path:line — slug | title | priority | status", citing the slug's line.
row="$(awk -v roadmap="${ROADMAP}" '
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
      printf "%s:%d — %s | %s | %s | %s\n", roadmap, sline, slug, title, prio, st
      found=1; exit
    }
    next
  }
  END { if (!found) exit 1 }
' "${ROADMAP}")"

if [[ -z "${row}" ]]; then
  echo "roadmap-row: NONE — no backlog/not_started item in ${ROADMAP}" >&2
  exit 1
fi

printf '%s\n' "${row}"
exit 0
