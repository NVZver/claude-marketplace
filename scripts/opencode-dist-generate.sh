#!/usr/bin/env bash
# scripts/opencode-dist-generate.sh — regenerate dist/opencode/ from core, manager,
# and lsa source (SpecForge → OpenCode port).
#
# Companion to dist/cursor/ (hand-maintained, no generator). This script is the
# generator for the OpenCode equivalent: it drives Claude Code (`claude -p`,
# non-interactive) to re-translate each source skill/agent into OpenCode's
# command/agent format, using the same rules the original port used.
#
# Why Claude Code and not the local LM Studio model: tried it first (see repo
# history / CHANGELOG) — the local model didn't reliably read the real source
# file before writing, and produced malformed output missing YAML frontmatter
# entirely. This translation step needs judgment (condense knowledge files,
# rewrite tool references, decide permission scopes) that the local model
# doesn't hold up on unsupervised. This is the one piece of the OpenCode port
# that isn't local-first — it's an occasional regen task, not routine coding.
#
# Excludes vector/RAG search infrastructure entirely (lsa/skills/bootstrap-rag,
# lsa/docker/, lsa/scripts/*rag*, lsa/hooks/*) — deliberate, not an oversight.
#
# Output lands in dist/opencode/{commands,agents}/ — nothing outside this repo
# is touched. Run scripts/opencode-dist-deploy.sh separately to install it.
#
# Requires: claude CLI, authenticated. Review the diff in dist/opencode/ before
# deploying — even Claude Code should be checked, not blind-trusted.
#
# Exit 0 = every file generated. Exit 1 = at least one translation failed.

set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${repo_root}" ]] || repo_root="$(pwd)"
cd "${repo_root}" || exit 1

MODEL="${OPENCODE_DIST_MODEL:-sonnet}"
DIST="dist/opencode"
fail=0

if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; OFF=$'\033[0m'; else GREEN=""; RED=""; OFF=""; fi
pass_line() { printf '  %sOK%s    %s\n' "${GREEN}" "${OFF}" "$1"; }
fail_line() { printf '  %sFAIL%s  %s\n' "${RED}" "${OFF}" "$1"; fail=1; }

mkdir -p "${DIST}/commands" "${DIST}/agents"

read -r -d '' RULES <<'EOF' || true
Translation rules (apply all):
- A `Skill` tool call to another skill -> rewrite as "run `/other-command-name`".
- Dispatching a subagent via the `Agent` tool -> rewrite as "delegate to the `@agent-name` subagent".
- `AskUserQuestion` tool -> "ask the user directly in chat and wait for their reply".
- Claude-Code-only mechanisms with no OpenCode equivalent (hooks, ToolSearch,
  deferred tools, TaskOutput, ScheduleWakeup, CronCreate, EnterPlanMode/ExitPlanMode)
  -> drop, or note briefly as unavailable. Do not invent a fake OpenCode equivalent.
  OpenCode's Tab-key Plan/Build toggle is a loose analog to plan mode if a
  substitute is genuinely needed — don't overstate the equivalence.
- Any reference to RAG/vector search/rag-query.sh/rag-index.sh/bootstrap-rag ->
  replace with "(vector/RAG search not available in this port — use direct file
  reads and grep instead)". Never leave a dangling reference to a script that
  isn't part of this port.
- Keep `${specs_root}`, `.lsa/`, `.lsa.yaml` path conventions as-is (project
  file conventions, not Claude-Code-specific).
- Citations to `core:ground-rules` / `core:output` may stay as short references
  — that content is already live globally via this machine's
  ~/.config/opencode/opencode.json `instructions` array citing core/CLAUDE.md.
  Do not re-embed their full text.
- If the source skill leans on a `manager/knowledge/*.md` or `lsa/knowledge/*.md`
  file, fold the load-bearing content in — OpenCode commands are self-contained
  prompts, not a doc browser, so don't just link to a knowledge file.
- Extract the actionable Goal/Steps/Output shape; drop pure Claude-Code plumbing.
  Keep the result reasonably tight, not a line-for-line transcript.
EOF

read -r -d '' COMMAND_SCHEMA <<'EOF' || true
Target: an OpenCode custom command (~/.config/opencode/commands/<name>.md).
Write YAML frontmatter with a `description` key (required, one line). Body is
the prompt template that runs when the command is invoked; it may reference
$ARGUMENTS, $1, $2 for positional args if the source skill takes input.
EOF

read -r -d '' AGENT_SCHEMA <<'EOF' || true
Target: an OpenCode subagent (~/.config/opencode/agents/<name>.md).
Write YAML frontmatter with: `description` (required), `mode: subagent`, and a
`permission` object. Permission keys: read, edit, glob, grep, list, bash, task,
webfetch, websearch, todowrite — each value "allow", "ask", or "deny". Derive
the permission block from the source agent's Claude Code `tools:` list: an
agent limited to Read/Grep/Glob -> read/glob/grep allow, edit/bash deny; an
agent with Write/Edit/Bash -> those allow or ask depending on how autonomous
the source agent's role is. Body is the agent's system prompt.
EOF

translate() {
  local src="$1" dest="$2" schema="$3"
  if [[ ! -f "${src}" ]]; then
    fail_line "${src} (source missing)"
    return
  fi
  local prompt
  prompt="Read the file at ${repo_root}/${src}. Translate it into the target
below, then write the result to ${repo_root}/${dest} (overwrite if it exists).

${schema}

${RULES}

Write only the translated file — no commentary in your final reply beyond a
one-line confirmation."
  if claude -p "${prompt}" \
      --model "${MODEL}" \
      --permission-mode acceptEdits \
      --allowedTools "Read Write" \
      --add-dir "${repo_root}" \
      >/tmp/opencode-dist-gen.log 2>&1; then
    if [[ -f "${dest}" ]]; then
      pass_line "${dest}"
    else
      fail_line "${dest} (claude ran but no file appeared — see /tmp/opencode-dist-gen.log)"
    fi
  else
    fail_line "${dest} (claude -p failed — see /tmp/opencode-dist-gen.log)"
  fi
}

echo "=== generating dist/opencode/ (model: ${MODEL}) ==="

echo "-- core --"
for name in flow-selector actor-template reuse-first doctor; do
  translate "core/skills/${name}/SKILL.md" "${DIST}/commands/core-${name}.md" "${COMMAND_SCHEMA}"
done

echo "-- manager --"
for name in shape next decompose check implement; do
  translate "manager/skills/${name}/SKILL.md" "${DIST}/commands/manager-${name}.md" "${COMMAND_SCHEMA}"
done
translate "manager/agents/product-manager.md" "${DIST}/agents/manager-product-manager.md" "${AGENT_SCHEMA}"
translate "manager/agents/project-manager.md" "${DIST}/agents/manager-project-manager.md" "${AGENT_SCHEMA}"

echo "-- lsa (bootstrap-rag excluded — vector search out of scope) --"
for name in discover specify verify delegate reconcile init revise-constitution; do
  translate "lsa/skills/${name}/SKILL.md" "${DIST}/commands/lsa-${name}.md" "${COMMAND_SCHEMA}"
done
translate "lsa/agents/orchestrator.md" "${DIST}/agents/lsa-orchestrator.md" "${AGENT_SCHEMA}"

echo
if [[ "${fail}" -eq 0 ]]; then
  echo "${GREEN}All files generated into ${DIST}/${OFF}. Review the diff, then run scripts/opencode-dist-deploy.sh."
else
  echo "${RED}One or more files failed to generate.${OFF} See /tmp/opencode-dist-gen.log for the last failure's output."
fi
exit "${fail}"
