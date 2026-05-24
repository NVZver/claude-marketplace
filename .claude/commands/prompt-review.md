---
name: prompt-review
description: Report prompt quality issues against ground rules
allowed-tools: Read, Grep, Glob, Agent
---

# Prompt Review

Goal: Scan target prompts and report ground rule violations.

Input: $ARGUMENTS (file path, directory, or glob pattern)

Constraints:
- Do NOT modify any files
- Do NOT report issues without citing the violated rule number

## Steps

1. Read `.claude/agents/prompt-engineer.md` → extract Ground Rules 1-10 and Severity Levels
2. Resolve target:
   - File path → single file
   - Directory → find all `.md` files with prompt frontmatter (has `name:` or `description:` in YAML)
   - No target → ask: "(A) all agents, (B) all commands, (C) specific path"
3. For each file, check:
   a. Structure (rules 1-4): Goal, Input, Steps, Output, Constraints sections exist → missing = HIGH
   b. Role (rule 2): agents have Role, commands do not → violation = MEDIUM
   c. Steps (rule 5): each step has observable result → vague steps = MEDIUM
   d. Example Output (rule 10): section exists with synthetic example → missing = HIGH
   e. Output spec (rule 4): format and length defined → missing = MEDIUM
   f. Wording (rule 9): check for adverbs, hedging, filler, passive voice → list of wording violations, each = LOW
   g. Assumptions (rule 7): check for unverified claims ("probably", "likely", "usually") → list of assumption violations, each = MEDIUM
4. Compile all findings → output table

## Output

Format: Summary line + markdown table.
Length: One line summary + one row per issue.

## Example Output

Found 4 issues in 2 files.

| File | Issue | Severity | Rule |
|------|-------|----------|------|
| agents/deployer.md | Missing Goal section | HIGH | 1 |
| agents/deployer.md | Step 2 unverifiable: "analyze the code" | MEDIUM | 5 |
| agents/deployer.md | Adverb: "thoroughly" in step 1 | LOW | 9 |
| commands/deploy.md | No Example Output section | HIGH | 10 |
