---
name: prompt-review
description: Scan prompts for ground rule, KISS/DRY, AI sweep, and context budget violations
allowed-tools: Read, Grep, Glob, Agent
---

> **Trace.** On load, print first: `=============== [prompt-engineer/commands/prompt-review.md] [prompt-engineer] ===============`


# Prompt Review

Goal: Scan target prompts and report ground rule violations.

Input: $ARGUMENTS (file path, directory, or glob pattern)

Constraints:
- Do NOT modify any files
- Do NOT report issues without citing the violated rule number

## Steps

1. Read knowledge files: [`../knowledge/actor-ground-rules.md`](../knowledge/actor-ground-rules.md), [`../knowledge/quality-checks.md`](../knowledge/quality-checks.md), [`../knowledge/separation-of-concerns.md`](../knowledge/separation-of-concerns.md) → checklist loaded
2. Resolve target:
   - File path → single file
   - Directory → find all `.md` files with prompt frontmatter (has `name:` or `description:` in YAML)
   - No target → ask: "(A) all agents, (B) all commands, (C) specific path"
3. For each file, check:
   a. Separation of concerns per knowledge/separation-of-concerns.md → boundary violations = HIGH
   b. Actor ground rules 1-4 per knowledge/actor-ground-rules.md: Goal, Input, Steps, Output, Constraints sections exist → missing = HIGH
   c. Role (rule 2): agents have Role, commands do not → violation = MEDIUM
   d. Steps (rule 5): each step has observable result → vague steps = MEDIUM
   e. Example Output (rule 10): section exists with synthetic example → missing = HIGH
   f. Output spec (rule 4): format and length defined → missing = MEDIUM
   g. Wording (rule 9): check for adverbs, hedging, filler, passive voice → each = LOW
   h. Assumptions (rule 7): check for unverified claims ("probably", "likely", "usually") → each = MEDIUM
   i. Apply KISS/DRY checks per knowledge/quality-checks.md → each = MEDIUM
   j. Apply AI Over-Engineering checks per knowledge/quality-checks.md → formalized common sense, reinvented paradigms, arbitrary thresholds = MEDIUM; example bloat, missing paradigm provenance = LOW
   k. Apply Context Budget checks per knowledge/quality-checks.md → restating/mergeable = MEDIUM, padding = LOW
   l. Show-changes-inline (author-time, `core/output` Rule 7) — WARNING-ONLY: in prompt SOURCE files (`**/SKILL.md`, `**/agents/*.md`), flag any step body that describes a write/edit/mark action (verbs: write/edit/append/replace/mark/update/create a file) WITHOUT an accompanying show-changes-inline directive (an instruction to quote the changed content inline, or a `file:line` cite of `core/output` Rule 7 / the `lsa:reconcile` 8-element block). This catches the omission in the prompt source before the skill ships — complementary to `lsa:verify`'s runtime-artifact scan (see [`../../core/skills/output/SKILL.md`](../../core/skills/output/SKILL.md) §"How this gets enforced"). Each hit = WARNING (signal, not gate), cited as `<file>:<line>` + the write-verb + "no show-changes directive". Steps that only read, dispatch, or present (no artifact write) are exempt.
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
| skills/sync/SKILL.md:42 | Step 4 writes config.json, no show-changes directive | WARNING | 3l |
