---
name: prompt-create
description: Create a new prompt following ground rules
allowed-tools: Read, Write, Grep, Glob, AskUserQuestion
---

> **Trace.** On load, print first: `=============== [prompt-engineer/commands/prompt-create.md] [prompt-engineer] ===============`


# Prompt Create

Goal: Create a new prompt file with all required sections filled.

Input: $ARGUMENTS (name of the new prompt)

Constraints:
- Do NOT leave placeholder text in the final file
- Do NOT skip any required section

## Steps

1. If component type not in input → ask: "(A) Agent, (B) Command"
2. If name not in input → ask for name (kebab-case)
3. Read knowledge files: [`../knowledge/actor-ground-rules.md`](../knowledge/actor-ground-rules.md), [`../knowledge/separation-of-concerns.md`](../knowledge/separation-of-concerns.md) → actor format template and classification rules loaded
4. Ask user for:
   - Goal (one sentence)
   - Input description
   - 1-3 constraints
5. Determine file path:
   - Agent → `.claude/agents/{name}.md`
   - Command → `.claude/commands/{name}.md`
6. Generate file using actor format template from [knowledge/actor-ground-rules.md](../knowledge/actor-ground-rules.md):
   - Agent: frontmatter (name, description with examples, tools) + body (Role, Goal, Input, Constraints, Steps, Output, Example Output)
   - Command: frontmatter (name, description, allowed-tools) + body (Goal, Input, Constraints, Steps, Output, Example Output)
7. Show the full generated content per the [`../../core/skills/output/SKILL.md`](../../core/skills/output/SKILL.md) Rule 7 *Delivery test* (turn-final message, or carried in the approval gate's `preview`) → take approval via `AskUserQuestion` → **then** write the file and confirm the path — show → approve → write per Rule 7 *Authorization boundary*; on reject, write nothing
8. Run prompt-review logic on new file → verify compliance

## Output

Format — approve path: file path + compliance status, 2 lines. Reject path: one line stating nothing was written.

## Example Output

Created: `.claude/commands/lint-config.md`
Review: 0 issues found.

(reject path: `Rejected — nothing written.`)
