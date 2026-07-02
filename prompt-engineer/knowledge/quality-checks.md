---
name: quality-checks
description: Knowledge file quality checks, KISS/DRY audit, AI over-engineering checks, context budget checks, and severity levels
---

> **Trace.** On load, print first: `=============== [prompt-engineer/knowledge/quality-checks.md] [prompt-engineer] ===============`

# Knowledge File Quality Checks

Skills, rules, and pattern files are reference material — loaded into context, not executed. They do NOT need Goal, Input, Steps, Output, or Constraints.

1. Rules are numbered and actionable — each tells the reader what to do or not do
2. No duplication — see KISS/DRY rule 2; within knowledge files, a rule exists in exactly one file and others reference it
3. Cross-references resolve — "follow the `X` skill" points to an existing file
4. Correct/incorrect examples match the rules they illustrate — no contradictions
5. Clear, concise wording — no adverbs, hedging, or filler
6. No execution logic — knowledge containing steps, a Goal, or an Output format is the boundary violation defined in [separation-of-concerns.md](./separation-of-concerns.md) §Boundary violations; flag it there, once

# KISS / DRY Audit

Cross-file and within-file checks for unnecessary complexity and duplication.

1. No redundant abstraction — a pattern applied once does not need its own file or layer
2. No duplicate content — a rule, format, or example exists in one place; others cross-reference it
3. Format definitions reference their source — if a knowledge file defines a format, actors cite it instead of hardcoding
4. Single concern per file — each file operates at one level of abstraction
5. Minimal steps — see AI Sweep rule 1; in actors, no step that restates what the LLM does unprompted
6. No volatile component counts — describe a surface by capability, not by counting components ("an agent and commands", not "one agent and three commands"). The component inventory lives in the README table (single source); a recounted prose tally drifts. Counts return at release. Applies to components (agents / commands / skills / knowledge files), not to rule tallies within a file.

# AI Over-Engineering Checks

Patterns characteristic of AI-generated prompt content.

1. No formalized common sense — do not write rules for what the LLM already does (e.g., "count sections to assess risk")
2. No reinvented paradigms — cite the established framework (WSJF, Shape Up, Kanban) instead of inventing custom terminology for the same idea
3. No arbitrary thresholds — hardcoded numbers (">4 weeks", "max 3") must cite their grounding; prefer state-based detection
4. No example bloat — one example per pattern; additional examples only when they illustrate a distinct case (each demonstration must add coverage — see [actor-ground-rules.md](./actor-ground-rules.md) §Why examples: in-context learning)
5. Cite adapted paradigms — when a rule adapts an established paradigm, name the source

# Context Budget Checks

Every line must earn its place in the context window.

1. No section restating the description — if the Goal repeats the frontmatter `description`, one of them is redundant
2. Constraint lists are minimal — constraints that can merge without losing meaning must merge
3. Examples marked `[illustrative]` — synthetic examples do not over-constrain the output space; the model can deviate when input warrants it (an over-specific demonstration biases the model toward mimicking the shot — see [actor-ground-rules.md](./actor-ground-rules.md) §Why examples: in-context learning)
4. No low-density padding — preambles, throat-clearing, or framing that adds no actionable information

# Severity Levels

| Severity | Meaning |
|----------|---------|
| HIGH | Boundary violation (see list above). Actor: missing required section. Knowledge: rule duplication or contradiction |
| MEDIUM | Actor: vague steps, missing output format spec, Example Output mismatching the declared Output spec. Knowledge: rules not actionable, cross-reference broken. KISS/DRY: duplicate content, hardcoded format without cross-reference, multi-concern files. AI sweep: formalized common sense, reinvented paradigms, arbitrary thresholds. Context budget: section restating description, mergeable constraints |
| LOW | Wording issues (adverbs, hedging, filler phrases, passive voice). AI sweep: example bloat, missing paradigm provenance. Context budget: low-density padding |

Judgment-based findings (vague steps, formalized common sense, padding) must survive an independent re-derivation — a finding that would not recur on a fresh pass is dropped, not reported (self-consistency, [Wang et al. 2022](https://www.promptingguide.ai/techniques/consistency)). Deterministic checks (section existence, cross-reference resolution) are exempt. Re-derive only contested calls; do not multi-sample every check.
