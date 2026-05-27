---
name: prompt-optimize
description: Apply fixes for issues found by prompt-review
allowed-tools: Read, Write, Edit, Grep, Glob, Agent
---

> **Trace.** On load, print first: `=============== [prompt-engineer/commands/prompt-optimize.md] [prompt-engineer] ===============`


# Prompt Optimize

Goal: Fix ground rule violations in target prompts.

Input: $ARGUMENTS (file path, directory, or glob pattern). If empty or ambiguous, ask: "(A) specific file, (B) all prompts in a plugin directory, (C) all prompts in the repository"

Constraints:
- Do NOT change the functional intent of any prompt
- Do NOT add features or content beyond what ground rules require
- Do NOT proceed without reviewing first

## Steps

1. Read knowledge files: [`../knowledge/actor-ground-rules.md`](../knowledge/actor-ground-rules.md), [`../knowledge/quality-checks.md`](../knowledge/quality-checks.md), [`../knowledge/separation-of-concerns.md`](../knowledge/separation-of-concerns.md) → checklist loaded
2. Run prompt-review logic on target → issues table
3. If no issues found → report "No issues found." and stop
4. Present issues table to user → confirm scope of fixes
5. For each file with issues, apply fixes by severity:
   a. HIGH: add missing sections using actor format template from [knowledge/actor-ground-rules.md](../knowledge/actor-ground-rules.md) → file contains all required sections
   b. MEDIUM: apply fixes per [knowledge/quality-checks.md](../knowledge/quality-checks.md) and [knowledge/actor-ground-rules.md](../knowledge/actor-ground-rules.md) — rewrite vague steps with arrow-notation results, consolidate duplicates, replace hardcoded formats with knowledge references, merge constraints, remove restated descriptions
   c. LOW: delete adverbs, replace hedging with direct statements, convert passive to active voice, remove filler phrases, add paradigm citations, trim example bloat, remove low-density padding
6. Re-run review on modified files → verify fixes resolved issues
7. If new issues found → repeat steps 5-6 until no new issues remain or the same issue recurs
8. Compile changes → output table

## Output

Format: Summary line + markdown table.
Length: One line summary + one row per change.

## Example Output

Fixed 3 issues in 2 files.

| File | Change | Rule |
|------|--------|------|
| agents/deployer.md | Added Goal section | 1 |
| agents/deployer.md | Rewrote step 2: "analyze" → "read file and list functions" | 5 |
| commands/deploy.md | Added Example Output section | 10 |
