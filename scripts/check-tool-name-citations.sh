#!/usr/bin/env bash
# check-tool-name-citations.sh
#
# Scans first-slice (core, lsa, manager) skill/agent instruction prose for
# backtick-wrapped Claude-Code tool names mentioned WITHOUT the compliant
# "(<ToolName> in Claude Code)" / "in Claude Code, ..." citation pattern.
#
# Scope: core/skills/**/SKILL.md, lsa/skills/**/SKILL.md, lsa/agents/*.md,
#        manager/skills/**/SKILL.md, manager/agents/*.md
# core/CLAUDE.md is explicitly OUT of scope (not a skill/agent file).
#
# Frontmatter (text between the first two "---" lines, including the
# `tools:` declaration) is excluded from the scan — only body prose is
# checked.
#
# A match is flagged unless "Claude Code" appears within a few words of the
# tool-name mention, on the same line (either order: "`Tool` in Claude Code"
# or "in Claude Code: ... `Tool`" style enumerations).
#
# Exit 0 = zero unconditioned matches. Exit 1 = one or more found (printed).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TOOL_NAMES=(
  Read Write Edit Grep Glob Bash Agent Skill AskUserQuestion WebFetch
  WebSearch NotebookEdit TaskOutput ScheduleWakeup CronCreate
  EnterPlanMode ExitPlanMode SendMessage
)

# Build the alternation for grep -E, e.g. Read|Write|Edit|...
TOOL_ALT=$(IFS='|'; echo "${TOOL_NAMES[*]}")

FILES=$(
  {
    find core/skills -name 'SKILL.md' 2>/dev/null
    find lsa/skills -name 'SKILL.md' 2>/dev/null
    find lsa/agents -maxdepth 1 -name '*.md' 2>/dev/null
    find manager/skills -name 'SKILL.md' 2>/dev/null
    find manager/agents -maxdepth 1 -name '*.md' 2>/dev/null
  } | sort -u
)

found=0
total_checked=0

for f in $FILES; do
  total_checked=$((total_checked + 1))

  # Strip frontmatter: text between the first two '---' lines.
  # Use awk to emit only body lines (after the second '---'), preserving
  # original line numbers via a running counter.
  body_with_lineno=$(awk '
    BEGIN { dashcount = 0; inbody = 0 }
    {
      if ($0 == "---" && dashcount < 2) {
        dashcount++
        if (dashcount == 2) { inbody = 1 }
        next
      }
      if (inbody) { print NR ":" $0 }
    }
  ' "$f")

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    lineno="${line%%:*}"
    content="${line#*:}"

    # Find every backtick-wrapped occurrence of a tool name on this line.
    matches=$(grep -oE "\`(${TOOL_ALT})\`" <<<"$content" || true)
    [ -z "$matches" ] && continue

    # Does "Claude Code" appear anywhere on this line? If so, treat every
    # tool-name mention on the line as covered by the citation pattern
    # (handles both "`Tool` in Claude Code" and "In Claude Code: `Tool`,
    # `Tool2`..." enumeration styles).
    if grep -q "Claude Code" <<<"$content"; then
      continue
    fi

    while IFS= read -r m; do
      [ -z "$m" ] && continue
      found=$((found + 1))
      echo "UNCONDITIONED: ${f}:${lineno}: ${m} — ${content}"
    done <<<"$matches"
  done <<<"$body_with_lineno"
done

echo
echo "Scanned ${total_checked} files."
if [ "$found" -eq 0 ]; then
  echo "PASS — zero unconditioned tool-name matches."
  exit 0
else
  echo "FAIL — ${found} unconditioned tool-name match(es) found."
  exit 1
fi
