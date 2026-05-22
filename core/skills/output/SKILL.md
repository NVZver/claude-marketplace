---
name: output
description: Apply to every human-facing output — agent responses, skill bodies, plan files, READMEs, commit messages, PR descriptions, comments. Enforces five golden rules — structured, minimal, formatted, sourced, concrete (cites ground-rules Rule 1).
---

> **Trace.** On load, print first: `=============== [core/skills/output/SKILL.md] [core] ===============`

> **Canonical source.** This file is the single source-of-truth for output discipline across the NVZver marketplace. Other plugins MAY cite it and MAY add component-specific formats that satisfy these five rules. They MUST NOT restate the rule count or rule names outside this file (citation by markdown link only). They MUST NOT override or relax any rule. Re-grounded summaries that restate the rules in prose are permitted only when they cite this file by link at the top — see `helper/knowledge/output-discipline.md` for the canonical adherent example. Enforced by `core/tests/repo-anchored.md` probe D2.

# Output Discipline

Five golden rules. Component-specific formats (per-skill) are free choices WITHIN these rules.

## 1. Structured
Output has a shape: headings, sections, tables, lists, blocks. No stream-of-consciousness prose.

## 2. Minimal
No fluff, no overexplanation, no padding. Every line earns its place.

- **1–1.5 screen budget.** Default response budget is ~30–50 lines of rendered markdown per turn. Above the fold: verdict + the single decision the human owns next. Below the fold: supporting tables, worked examples, alternatives.
- **Split into turns.** If a response needs both (a) a decision and (b) supporting detail that takes the response over budget, split: deliver the decision in this turn, deliver the detail in the next turn only if the human asks.
- **Pull, don't push.** Surface what the human needs to act on next. Do not pre-emptively render every option, every artifact, every consideration in one shot — that forces scroll-and-skim and buries the decision.

## 3. Formatted
Markdown affordances match content: tables, lists, code blocks, headings.

## 4. Sourced
Every factual claim carries source + exact quote per [`core/ground-rules`](../ground-rules/SKILL.md) Rule 1.

**File-load trace.** Every NVZver-marketplace instructional file carries a one-line trace directive at its top. On load, the agent prints that line verbatim — `=============== [<file>] [<plugin>] ===============` — before the response body. One line per loaded file, in load order. Gives the human a step-by-step path of which marketplace files shaped the turn.

## 5. Concrete (decision prompts) — *prompt voice*
Questions and options name the real-world subject — not spec IDs, not project jargon. Pickers surface only choices that change the outcome.

- **Subject-first.** Resolve identifiers (`F3`, `AC2`, `OQ5`) to the real-world subject in the prompt. IDs stay in spec files for traceability.
  - ✗ *"Approve F3 in requirements.md §Functional Requirements?"*
  - ✓ *"Add password reset endpoint?"*
- **No project jargon.** Strip terms a first-time user can't decode (`contract-trigger`, `Hard Confirm`, `diagonal coverage`). Reserve jargon for skill bodies, not user-facing prompts.
- **Must-decide only.** Surface as picker questions only choices that meaningfully change the outcome. Bundle consistency checks; defer nice-to-decide to non-blocking summary lines.
- **One decision per question.** Don't bundle "approve A and B and C?" — split into separate questions.

---

Substrate selection — see `vision/VISION.md` §2 principle 9 (*"Substrate-native first"*).

Verdict labels — see [`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md).
