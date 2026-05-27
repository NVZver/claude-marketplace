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
3. Read [`../agents/prompt-engineer.md`](../agents/prompt-engineer.md) → extract Prompt Format Template and Ground Rules
4. Ask user for:
   - Goal (one sentence)
   - Input description
   - 1-3 constraints
5. Determine file path:
   - Agent → `.claude/agents/{name}.md`
   - Command → `.claude/commands/{name}.md`
6. Generate file:
   - Agent: frontmatter (name, description with examples, tools) + body (Role, Goal, Input, Constraints, Steps, Output, Example Output)
   - Command: frontmatter (name, description, allowed-tools) + body (Goal, Input, Constraints, Steps, Output, Example Output)
7. Write file → confirm path
8. Run prompt-review logic on new file → verify compliance

## Output

Format: File path + compliance status.
Length: 2 lines.

## Example Output

Created: `.claude/commands/lint-config.md`
Review: 0 issues found.
