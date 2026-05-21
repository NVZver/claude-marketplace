---
name: output
description: Apply to every human-facing output — agent responses, skill bodies, plan files, READMEs, commit messages, PR descriptions, comments. Enforces four golden rules — structured shape, minimal length, correct markdown formatting, every factual claim sourced + quoted (cites ground-rules Rule 1). Each component picks its own format within these constraints.
---

# Output Discipline

Four golden rules. Every output is bound by them. Component-specific formats (`tier-selector` confirm prompts, `lsa-verify` reports, etc.) are free choices WITHIN these rules — they may not violate any of the four.

## 1. Structured

Output has a shape: headings, sections, tables, lists, blocks. No stream-of-consciousness prose. The reader's eye finds key information without reading top-to-bottom.

## 2. Minimal

No fluff, no overexplanation, no padding. Every line earns its place. Length is earned by the task, not assumed.

## 3. Formatted

Markdown affordances match content: tables for tabular data, lists for enumerations, code blocks for code, headings for sections. Don't over-decorate or under-render.

## 4. Sourced

Every factual claim carries source + exact quote per [`core/ground-rules`](../ground-rules/SKILL.md) Rule 1. This rule enforces visibility (the source is scannable, not buried); ground-rules enforces existence (a claim without a source is not a claim).

---

**Each component picks its own format.** When the substrate provides a native primitive for an output context (`AskUserQuestion` for decisions in Claude Code, `TaskCreate`/`TaskUpdate` for task tracking, native pickers for selection), use it (per `vision/VISION.md` §2 principle 9 — *"Substrate-native first"*). The text-rendered alternative is the fallback when no native primitive exists.

For verdict-line conventions (`PROPOSED` / `READY` / `PASS` / `FAIL` / etc.) when a component's format uses them: see [`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md).
