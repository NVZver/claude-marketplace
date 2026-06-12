---
name: output
description: Apply to every human-facing output — agent responses, skill bodies, plan files, READMEs, commit messages, PR descriptions, comments. One HARD rule — fact-grounding / sourced (Rule 4, cites ground-rules Rule 1) plus its file-load trace and citation format. Six GUIDANCE outcomes to aim for when they serve the answer — structured, minimal, formatted, concrete, what-and-why preamble, show-changes-inline.
---

> **Trace.** On load, print first: `=============== [core/skills/output/SKILL.md] [core] ===============`

> **Canonical source.** This file is the single source-of-truth for output discipline across the NVZver marketplace. Other plugins MAY cite it and MAY add component-specific formats. They MUST NOT restate the rule count or rule names outside this file (citation by markdown link only). They MUST NOT override or relax the **hard** rule (Rule 4, Sourced — and its file-load trace + citation format). The **guidance** rules (1-3, 5-7) MAY be applied as outcomes; a plugin MAY cite a specific guidance rule as load-bearing for its own output where the shape genuinely matters, but MUST NOT re-promote a guidance rule to a marketplace-wide hard requirement. Re-grounded summaries that restate the rules in prose are permitted only when they cite this file by link at the top — see `helper/knowledge/output-discipline.md` for the canonical adherent example. Enforced by `core/tests/repo-anchored.md` probe D2.

# Output Discipline

Seven rules, two postures. **One is hard, six are guidance.**

- **HARD — must hold on every human-facing output:** Rule 4 (Sourced), including its file-load trace directive and citation format. Fact-grounding is non-negotiable: every factual claim carries a source + verbatim quote (inherits [`core/ground-rules`](../ground-rules/SKILL.md) Rule 1).
- **GUIDANCE — outcomes to aim for, not a checklist every response must satisfy:** Rules 1, 2, 3, 5, 6, 7. Apply them when they serve the answer. A one-sentence factual reply does not need a verdict headline, a preamble, a table, and a decision block to be correct — it needs a source. Reach for a guidance rule when the situation calls for it (a real decision → Rule 5; an artifact write → Rule 7; a verdict emission → Rule 6); skip it when it would only pad the response. Some skills cite a specific guidance rule as load-bearing for their own output (e.g. `lsa:reconcile`'s drift block leans on Rule 7) — that is the rule working as designed.

The rule numbering below is preserved verbatim — other files cite these rules by number. Only the enforcement posture changed, not the content.

---

## HARD RULE

## 4. Sourced
Every factual claim carries source + exact quote per [`core/ground-rules`](../ground-rules/SKILL.md) Rule 1. **This rule is hard — it holds on every human-facing output, no exceptions.**

**File-load trace.** Every NVZver-marketplace instructional file carries a one-line trace directive at its top. On load, the agent prints that line verbatim — `=============== [<file>] [<plugin>] ===============` — before the response body. One line per loaded file, in load order. Gives the human a step-by-step path of which marketplace files shaped the turn. **Hard — print it.**

---

## GUIDANCE

These are outcomes to aim for, applied when they serve the answer — not a template every response must satisfy.

## 1. Structured
Output has a shape: headings, sections, tables, lists, blocks. No stream-of-consciousness prose.

## 2. Minimal
No fluff, no overexplanation, no padding. Every line earns its place.

- **1–1.5 screen budget.** Default response budget is ~30–50 lines of rendered markdown per turn. Above the fold: verdict + the single decision the human owns next. Below the fold: supporting tables, worked examples, alternatives.
- **Split into turns.** If a response needs both (a) a decision and (b) supporting detail that takes the response over budget, split: deliver the decision in this turn, deliver the detail in the next turn only if the human asks.
- **Pull, don't push.** Surface what the human needs to act on next. Do not pre-emptively render every option, every artifact, every consideration in one shot — that forces scroll-and-skim and buries the decision.

## 3. Formatted
Markdown affordances match content: tables, lists, code blocks, headings.

## 5. Concrete (decision prompts) — *prompt voice*
Questions and options name the real-world subject — not spec IDs, not project jargon. Pickers surface only choices that change the outcome.

- **Subject-first.** Resolve identifiers (`F3`, `AC2`, `OQ5`) to the real-world subject in the prompt. IDs stay in spec files for traceability.
  - ✗ *"Approve F3 in requirements.md §Functional Requirements?"*
  - ✓ *"Add password reset endpoint?"*
- **No project jargon.** Strip terms a first-time user can't decode (`contract-trigger`, `Hard Confirm`, `diagonal coverage`). Reserve jargon for skill bodies, not user-facing prompts.
- **Must-decide only — Genuine-fork test.** Surface as picker questions only choices that meaningfully change the outcome. Before opening a picker, the agent answers: *is there a real fork I cannot resolve from in-scope sources?* A fork is real when **at least one** holds: (a) **destructive** — the next action edits a file, deletes a row, calls an external service, or starts a multi-turn skill flow; (b) **two named designs in scope and neither overrides the other** — the agent has identified ≥2 reasonable continuations from in-scope sources (`.lsa/VISION.md:63` Principle 6) and no source ranks one above the other; (c) **a fact required by the next step is absent from working context and cannot be derived** — spec, repo, and prior turns do not supply it; (d) **per-row triage** — N items each need an independent decision (batched into one multi-question picker). If none apply, deliver the cited answer directly and offer at most ONE closing picker for the user to override. Substrate selection (which primitive) is governed by `.lsa/VISION.md:66` Principle 9.
- **One decision per question.** Don't bundle "approve A and B and C?" — split into separate questions.
- **Self-contained gates.** A picker may only ask about content the user has already received per the Rule 7 *Delivery test*, or that the picker itself carries (question text, option descriptions, option `preview`). Never open an approve/reject gate whose subject exists only in a subagent transcript or in same-turn pre-tool-call text. Dispatcher pattern: re-render the agent's proposal as the turn-final message, gate in the following turn — or embed the proposal in the gate's `preview`.

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

This rule generalizes the 8-element drift block already in use by [`reconcile`](../../../lsa/skills/reconcile/SKILL.md), which the user endorsed as the gold standard: *"Good! Love it!"* (2026-05-22).

### Authorization boundary — authorized changes vs proposals

Write → show → comment applies to **already-authorized** changes — work the user asked for or a spec mandates.

For **approval-gated artifacts** — anything whose existence depends on a pending human gate (pitches, specs, roadmap rows, generated prompt files) — the order inverts: **show → approve → write**. Deliver the full content first (Delivery test below), run the gate, write the file only on approve. Nothing lands on disk "as a draft" before its gate. On reject, nothing is written. Prior art: [`lsa:init`](../../../lsa/skills/init/SKILL.md) Step 3 (*"show, approve, write"*) and [`lsa:revise-constitution`](../../../lsa/skills/revise-constitution/SKILL.md) Steps 3–4.

### Delivery test — what counts as "shown"

Content counts as delivered ONLY via a channel the harness renders to the user:

- the **final text message of a turn** (no tool calls after it in that turn), or
- **inside an `AskUserQuestion` gate** (question text, option descriptions, or option `preview`).

NOT delivered: a subagent's transcript or final report (returned to the dispatcher, never rendered to the user); same-turn text emitted before a tool call (the harness may drop it); a file path (*"see the file"* — already forbidden below). A dispatcher that receives a proposal from an agent re-renders it itself before gating.

### Single-change template

For one edit to one file, the response contains, in order:

1. **What changed** — one phrase naming the action (added / edited / replaced / appended / marked).
2. **Where** — the file path with the precise line range, as `path:line` or `path:line-range`.
3. **Previous content** (if the change replaces existing content) — quoted verbatim in a fenced code block, with the source line range above it.
4. **New content** — quoted verbatim in a fenced code block, with the destination line range above it.
5. **Reason** — one sentence in the human's frame: *why* this change happened (the user's request, the spec line, the discovered drift). No agent-vocabulary verbs without a one-clause gloss.
6. **Source** — a `file:line` (or URL) for the authority that justified the change. Inherits Rule 4 (Sourced).
7. **Type tag** — one of `add` / `edit` / `replace` / `append` / `mark`, so the human can skim a sequence of changes by type.

Combined, the seven elements line up with the eight-element drift block at [`reconcile`](../../../lsa/skills/reconcile/SKILL.md) (the eighth — *bundle-explanation* — collapses into element 5 here when the change is not part of a multi-module batch).

### Batch template — compressed inspection table

When a single turn produces more than ~5 file changes or more than ~10 lines of new content, full single-change blocks blow the 1–1.5-screen budget (Rule 2). Replace them with a **compressed inspection table**:

| # | file:line | type | summary (≤8 words) | pointer |
|---|-----------|------|--------------------|---------|
| 1 | `lsa/skills/verify/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 2 | `lsa/skills/verify/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |

After the table: one cluster of follow-up `file:line` pointers the human can open. **Never** *"see the files for the rest."* The table itself *is* the quote-back.

### What this rule forbids

- *"I added X to file Y"* without the verbatim X.
- *"Marked OQ5 as resolved"* without the new line content.
- *"Observable result: file is edited"* / *"diff shown"* without naming whether the diff is full-quote or compressed-table.
- *"go check the file"* / *"see file for details"* in any form.
- Writing an approval-gated artifact before its gate (see *Authorization boundary* above).
- Treating content in a subagent transcript or same-turn pre-tool-call text as "shown" (see *Delivery test* above).

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
| 3 | `lsa/skills/verify/SKILL.md:67` | edit | Observable result names quoted-diff format | step 3 |
| 4 | `lsa/skills/verify/SKILL.md:74` | edit | Observable result names quoted-diff format | step 4 |
| 5 | `lsa/skills/specify/SKILL.md:99` | edit | Observable result names quoted-section format | step 4 |

*Reason: lands the `core/output` Rule 7 + LSA sweep per `.lsa/features/2026-05-22-show-changes-inline/tasks.md` step 1-2. Source: `.lsa/roadmap.md:128-132`. Type: `batch` (`add` + `edit` mix).*

**Example 3 — state mark.**

> *Marked **OQ5** as resolved in `.lsa/features/2026-05-22-show-changes-inline/design.md:118`.*
>
> *Previous (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `.lsa/archive/`?
> ```
>
> *New (line 118):*
> ```markdown
> - **OQ5** — Do we backfill archive specs under `.lsa/archive/`? **Resolved 2026-05-23: no — per archive-files-don't-rewrite rule (`.lsa/roadmap.md:48`).**
> ```
>
> *Reason: human picked `[b] no backfill` at User Verification 3. Source: this session 2026-05-23. Type: `mark`.*

### Inheritance & inheritance gaps

- **Inherits Rule 2 (Minimal).** The batch template is the explicit escape valve when full single-change blocks would blow the budget.
- **Inherits Rule 4 (Sourced).** Every change carries a `file:line` source per element 6.
- **Inherits Rule 5 (Concrete).** The reason (element 5) names the subject in the human's frame, not the spec ID.
- **Composes with Rule 3 (Formatted).** Single-change blocks use fenced code; batch blocks use markdown tables. Match the affordance to the content.

### How this gets enforced

This rule is held in three places — content here, scaffolding elsewhere:

1. **Per-skill cites.** Every skill / agent step that writes / edits / marks an artifact carries an explicit "quote the change inline before your verdict" instruction in the step body, plus an `Observable result:` that names the quoted-diff format. The gold-standard exemplar is the 8-element drift block at [`lsa:reconcile`](../../../lsa/skills/reconcile/SKILL.md) Step 4 — *"verbatim spec quote with path:line + verbatim artifact quote with path:line + proposed one-line spec update"* — which this rule generalizes.
2. **Author-time regression check (prompt sources).** [`prompt-engineer:prompt-review`](../../../prompt-engineer/commands/prompt-review.md) scans prompt SOURCE files (`**/SKILL.md`, `**/agents/*.md`) for a step that writes / edits / marks without an accompanying show-changes-inline directive. Catches a structural omission in the prompt before the skill ships. Warning-only initially (signal, not gate).
3. **PR-time regression check (runtime artifacts).** [`lsa:verify`](../../../lsa/skills/verify/SKILL.md) scans the feature's runtime outputs / PR diff for banned phrasings (*"go check the file"*, *"I added X to Y"*, *"marked X"*, *"updated Z"*) with no inline quote of the change. Catches the violation as a runtime symptom. Warning-only initially.

The two checks are complementary, not redundant: prompt-review catches violations in prompt **sources**; lsa:verify catches violations in runtime **artifacts**. A correctly-prompted skill can still mis-execute (caught only by lsa:verify); a structural prompt-source omission stays invisible until a feature ships (caught only by prompt-review). Neither alone suffices.

---

Substrate selection — see `.lsa/VISION.md` §2 principle 9 (*"Substrate-native first"*).

Verdict labels — see [`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md).
