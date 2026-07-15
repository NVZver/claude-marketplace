#!/usr/bin/env bash
# scripts/build-index.sh — deterministic, token-budgeted project index.
#
# Emits .lsa/PROJECT-index.md: a structural map of the repo's tracked markdown
# surface, STRUCTURALLY ONLY (no prose paraphrase, no model calls; same tracked
# input -> byte-identical output). It is the aider-repo-map analogue for a
# markdown-only repo: headings ARE the descriptions.
#
# What it maps:
#   1. the five plugins, each as skill/knowledge/agent/command counts -> README,
#   2. the repo-root docs,
#   3. the .lsa/ live spine (VISION / roadmap / main.spec / modules / standards)
#      listed by verbatim H1, and
#   4. the .lsa/ per-feature spec trees (features / pitches / archive / ...) —
#      point-in-time records — collapsed to counts + slug lists.
#
# The index is the scoping map the LSA read protocol consults before walking the
# tree (lsa/knowledge/conventions.md §"Read protocol"; lsa/skills/discover Step 1).
# Hard budget: <= 1000 tokens (chars/4 proxy), enforced by scripts/lint.sh C14.
# Freshness is enforced by scripts/lint.sh C13 (regenerate-and-diff) — never
# hand-edit; rerun this script after any tracked-markdown change.
#
# Repo-internal only — NOT shipped in any plugin. Lives outside every plugin's
# artifact_paths in .lsa.yaml, so it triggers no plugin version bump or CHANGELOG.
#
# Exit 0 = index written. Exit 1 = not inside a git work tree.

set -euo pipefail
export LC_ALL=C

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  echo "ERROR: not inside a git work tree — cannot enumerate tracked files." >&2
  exit 1
fi
cd "${repo_root}" || exit 1

OUT=".lsa/PROJECT-index.md"

# Verbatim first H1 of a file (empty string if none — F7 graceful degrade).
h1() { grep -m1 -E '^# ' "$1" 2>/dev/null | sed -E 's/^#[[:space:]]+//' || true; }
# Comma-join stdin lines: "a\nb" -> "a, b".
join_csv() { paste -sd, - | sed 's/,/, /g'; }
count() { git ls-files "$@" 2>/dev/null | grep -c . || true; }

total_md="$(count '*.md')"

{
  printf '> **Trace.** On load, print first: `=============== [.lsa/PROJECT-index.md] [marketplace] ===============`\n'
  printf '<!-- GENERATED — DO NOT EDIT. Structural map of the tracked markdown surface built by scripts/build-index.sh; regenerate with: bash scripts/build-index.sh -->\n\n'

  printf '# Project index — claude-marketplace\n\n'
  printf 'Script-generated map of the tracked markdown surface (`git ls-files '"'"'*.md'"'"'`, %s files). Consult this to locate where a topic lives **before** walking the tree; headings are the descriptions. Regenerate: `bash scripts/build-index.sh`.\n\n' "${total_md}"

  printf '## Plugins (counts → per-plugin README)\n'
  for p in $(git ls-files '*/.claude-plugin/plugin.json' | awk -F/ '{print $1}' | sort); do
    parts=""
    s="$(count "${p}/skills/*/SKILL.md")";  [[ "${s}" -gt 0 ]] && parts="${parts}${s} skills, "
    k="$(count "${p}/knowledge/*.md")";     [[ "${k}" -gt 0 ]] && parts="${parts}${k} knowledge, "
    a="$(count "${p}/agents/*.md")";        [[ "${a}" -gt 0 ]] && parts="${parts}${a} agents, "
    c="$(count "${p}/commands/*.md")";      [[ "${c}" -gt 0 ]] && parts="${parts}${c} commands, "
    printf -- '- `%s/` — %s → `%s/README.md`\n' "${p}" "${parts%, }" "${p}"
  done
  printf '\n'

  printf '## Root docs\n'
  printf -- '- %s\n\n' "$(git ls-files '*.md' | awk -F/ 'NF==1' | join_csv)"

  printf '## `.lsa/` spine (live — read directly)\n'
  for f in VISION roadmap main.spec; do
    printf -- '- `.lsa/%s.md` — %s\n' "${f}" "$(h1 ".lsa/${f}.md")"
  done
  printf -- '- generated: `.lsa/VISION-digest.md` (constitution digest), `.lsa/PROJECT-index.md` (this file)\n'
  printf -- '- other top-level: %s\n' "$(git ls-files '.lsa/*.md' | awk -F/ 'NF==2{print $2}' \
    | grep -vE '^(VISION|VISION-digest|roadmap|main\.spec|PROJECT-index)\.md$' | join_csv)"
  printf -- '- `modules/`: %s (each `spec.md`)\n' "$(git ls-files '.lsa/modules/*' | awk -F/ '{print $3}' | sort -u | join_csv)"
  printf -- '- `standards/`: %s\n\n' "$(git ls-files '.lsa/standards/*.md' | awk -F/ '{print $3}' | join_csv)"

  printf '## `.lsa/` specs (per-feature, point-in-time — glob to read)\n'
  feat="$(git ls-files '.lsa/features/*' | awk -F/ '{print $3}' | sort -u)"
  printf -- '- `features/` (%s): %s\n' "$(printf '%s\n' "${feat}" | grep -c .)" "$(printf '%s\n' "${feat}" | join_csv)"
  pit="$(git ls-files '.lsa/pitches/*.md' | awk -F/ '{print $3}' | sed 's/\.md$//' | sort)"
  printf -- '- `pitches/` (%s): %s\n' "$(printf '%s\n' "${pit}" | grep -c .)" "$(printf '%s\n' "${pit}" | join_csv)"
  printf -- '- `archive/` (%s files) · `plans/` (%s) · `research/` (%s) · `observations/` (%s)\n' \
    "$(count '.lsa/archive/*')" "$(count '.lsa/plans/*')" "$(count '.lsa/research/*')" "$(count '.lsa/observations/*')"
} > "${OUT}"

chars="$(wc -c < "${OUT}" | tr -d ' ')"
echo "OK: wrote ${OUT} (${chars} chars, ~$((chars / 4)) tokens of 1000 budget) mapping ${total_md} tracked .md files"
