---
name: output
description: Apply to every human-facing output — agent responses, skill bodies, plan files, READMEs, commit messages, PR descriptions, comments. Enforces seven golden rules — structured, minimal, formatted, sourced, concrete, what-and-why preamble, show-changes-inline (cites ground-rules Rule 1).
---

> **Trace.** On load, print first: `=============== [core/skills/output/SKILL.md] [core] ===============`

> **Canonical source.** This file is the single source-of-truth for output discipline across the NVZver marketplace. Other plugins MAY cite it and MAY add component-specific formats that satisfy these seven rules. They MUST NOT restate the rule count or rule names outside this file (citation by markdown link only). They MUST NOT override or relax any rule. Re-grounded summaries that restate the rules in prose are permitted only when they cite this file by link at the top — see `helper/knowledge/output-discipline.md` for the canonical adherent example. Enforced by `core/tests/repo-anchored.md` probe D2.

# Output Discipline

Seven golden rules. Component-specific formats (per-skill) are free choices WITHIN these rules.

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
- **Must-decide only — Genuine-fork test.** Surface as picker questions only choices that meaningfully change the outcome. Before opening a picker, the agent answers: *is there a real fork I cannot resolve from in-scope sources?* A fork is real when **at least one** holds: (a) **destructive** — the next action edits a file, deletes a row, calls an external service, or starts a multi-turn skill flow; (b) **two named designs in scope and neither overrides the other** — the agent has identified ≥2 reasonable continuations from in-scope sources (`vision/VISION.md:63` Principle 6) and no source ranks one above the other; (c) **a fact required by the next step is absent from working context and cannot be derived** — spec, repo, and prior turns do not supply it; (d) **per-row triage** — N items each need an independent decision (batched into one multi-question picker). If none apply, deliver the cited answer directly and offer at most ONE closing picker for the user to override. Substrate selection (which primitive) is governed by `vision/VISION.md:66` Principle 9.
- **One decision per question.** Don't bundle "approve A and B and C?" — split into separate questions.

## 6. What-and-why preamble — verdicts carry a one-sentence frame
Every emission of a verdict label from
[`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md) §"Verdicts"
is preceded in the same paragraph by a one-sentence preamble naming
(a) the action in plain English in the user's frame, and (b) the concrete
consequence if the human does not act. Canonical format:
`<context sentence>. <VERDICT> verdict + <details>.` A bare verdict line
fails this rule.

## 7. Show changes inline — write, show, comment

Every write, edit, or mark performed by an agent is **echoed back inline** before any commentary. The order is **write → show → comment** — never *"I added X to file Y; here's why it matters."* without quoting X first.

This rule generalizes the 8-element drift block already in use by [`lsa-reconcile`](../../../lsa/skills/lsa-reconcile/SKILL.md), which the user endorsed as the gold standard: *"Good! Love it!"* (2026-05-22).

### Single-change template

For one edit to one file, the response contains, in order:

1. **What changed** — one phrase naming the action (added / edited / replaced / appended / marked).
2. **Where** — the file path with the precise line range, as `path:line` or `path:line-range`.
3. **Previous content** (if the change replaces existing content) — quoted verbatim in a fenced code block, with the source line range above it.
4. **New content** — quoted verbatim in a fenced code block, with the destination line range above it.
5. **Reason** — one sentence in the human's frame: *why* this change happened (the user's request, the spec line, the discovered drift). No agent-vocabulary verbs without a one-clause gloss.
6. **Source** — a `file:line` (or URL) for the authority that justified the change. Inherits Rule 4 (Sourced).
7. **Type tag** — one of `add` / `edit` / `replace` / `append` / `mark`, so the human can skim a sequence of changes by type.

Combined, the seven elements line up with the eight-element drift block at [`lsa-reconcile`](../../../lsa/skills/lsa-reconcile/SKILL.md) (the eighth — *bundle-explanation* — collapses into element 5 here when the change is not part of a multi-module batch).

### Batch template — compressed inspection table

When a single turn produces more than ~5 file changes or more than ~10 lines of new content, full single-change blocks blow the 1–1.5-screen budget (Rule 2). Replace them with a **compressed inspection table**:

| # | file:line | type | summary (≤8 words) | pointer |
|---|-----------|------|--------------------|---------|
| 1 | `lsa/skills/lsa-sync/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 2 | `lsa/skills/lsa-sync/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |

After the table: one cluster of follow-up `file:line` pointers the human can open. **Never** *"see the files for the rest."* The table itself *is* the quote-back.

### What this rule forbids

- *"I added X to file Y"* without the verbatim X.
- *"Marked OQ5 as resolved"* without the new line content.
- *"Observable result: file is edited"* / *"diff shown"* without naming whether the diff is full-quote or compressed-table.
- *"go check the file"* / *"see file for details"* in any form.

### Worked examples

**Example 1 — single-file edit (a typo fix).**

> *Edited `core/skills/output/SKILL.md:32` — single line.*
>
> *Previous (line 32):*
> ```markdown
> ## 5. Concrete (decision prompts) — *prompt voce*
> ```
>
> *New (line 32):*
> ```markdown
> ## 5. Concrete (decision prompts) — *prompt voice*
> ```
>
> *Reason: fixing the typo flagged in the 2026-05-22 review pass.*
> *Source: user 2026-05-22.*
> *Type: `edit`.*

**Example 2 — multi-file batch write (this feature's own implementation).**

| # | file:line | type | summary | pointer |
|---|-----------|------|---------|---------|
| 1 | `core/skills/output/SKILL.md:42-90` | add | Rule 7 *Show changes inline* | new section |
| 2 | `core/CLAUDE.md:18` | edit | Operational checkpoint #4 cites Rule 7 | inline |
| 3 | `lsa/skills/lsa-sync/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 4 | `lsa/skills/lsa-sync/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |
| 5 | `lsa/skills/lsa-specify/SKILL.md:99` | edit | Observable result names quoted-section format | step 4 |

*Reason: lands the `core/output` Rule 7 + LSA sweep per `vision/specs/features/2026-05-22-show-changes-inline/tasks.md` step 1-2. Source: `vision/specs/roadmap.md:128-132`. Type: `batch` (`add` + `edit` mix).*

**Example 3 — state mark.**

> *Marked **OQ5** as resolved in `vision/specs/features/2026-05-22-show-changes-inline/design.md:118`.*
>
> *Previous (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `vision/specs/archive/`?
> ```
>
> *New (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `vision/specs/archive/`? **Resolved 2026-05-23: no — per archive-files-don't-rewrite rule (`vision/specs/roadmap.md:48`).**
> ```
>
> *Reason: human picked `[b] no backfill` at User Verification 3. Source: this session 2026-05-23. Type: `mark`.*

### Inheritance & inheritance gaps

- **Inherits Rule 2 (Minimal).** The batch template is the explicit escape valve when full single-change blocks would blow the budget.
- **Inherits Rule 4 (Sourced).** Every change carries a `file:line` source per element 6.
- **Inherits Rule 5 (Concrete).** The reason (element 5) names the subject in the human's frame, not the spec ID.
- **Composes with Rule 3 (Formatted).** Single-change blocks use fenced code; batch blocks use markdown tables. Match the affordance to the content.

---

Substrate selection — see `vision/VISION.md` §2 principle 9 (*"Substrate-native first"*).

Verdict labels — see [`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md).
