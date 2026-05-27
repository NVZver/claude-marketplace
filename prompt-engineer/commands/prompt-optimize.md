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

1. Run prompt-review logic on target → issues table
2. If no issues found → report "No issues found." and stop
3. Present issues table to user → confirm scope of fixes
4. For each file with issues, apply fixes by severity:
   a. HIGH: add missing sections using Prompt Format Template from [`../agents/prompt-engineer.md`](../agents/prompt-engineer.md) → file contains all required sections
   b. MEDIUM: rewrite vague steps with arrow-notation results, add output format spec, remove assumption language → each step has observable result. Consolidate duplicate content into one source with cross-references. Replace hardcoded formats with references to the knowledge file that defines them. Remove rules that formalize natural LLM behavior. Replace arbitrary thresholds with state-based detection. Merge constraints that can combine without losing meaning. Remove Goal text that restates the frontmatter description.
   c. LOW: delete adverbs, replace hedging with direct statements, convert passive to active voice, remove filler phrases → no wording violations remain. Add paradigm citations where adapted frameworks lack provenance. Trim example bloat to one per pattern. Remove low-density padding.
5. Re-run review on modified files → verify fixes resolved issues
6. If new issues found → repeat steps 4-5 until no new issues remain or the same issue recurs
7. Compile changes → output table

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
