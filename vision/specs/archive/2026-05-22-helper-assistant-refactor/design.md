# Design: Refactor Helper from command-router to assistant

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #1.

## Modules Affected

| Module | Change Type | Files |
|--------|-------------|-------|
| `helper` | revise behavior | `helper/agents/helper.md` (Steps reshape + Constraints update), `helper/commands/help.md` (no-arg behavior), `helper/knowledge/output-discipline.md` (rule revision + "genuine fork" definition), `helper/README.md` (default-flow phrasing), `helper/CHANGELOG.md` (v0.3.0 entry), `helper/.claude-plugin/plugin.json` (version bump) |
| `core` | none | — (does not change; the refactor lives entirely in `helper/`) |
| `lsa` | none | — (orthogonal; LSA-side AskUserQuestion audit is row #3) |
| `vision` | none | — (no constitution or main.spec change; refactor traces to existing principles) |

## Landing Surface — exact file:line pointers

### What changes in `helper/agents/helper.md`

| Region | Current behavior | Target behavior | Source AC |
|---|---|---|---|
| Steps 1–5 (`helper/agents/helper.md:32-36`) | Step 1 cooldown → Step 2 read → Step 3 compose → Step 4 confirm+handoff → **Step 5 mandatory closing picker** | Step 1 cooldown + goal-understanding → Step 2 read → Step 3 compose (answer-first) → Step 4 conditional skill handoff → **Step 5 conditional close (clean exit OR fork-only picker)** | F1, F2, F4, F7, AC1, AC3, AC4 |
| Step 5 line (`helper/agents/helper.md:36`) — *"Close with a next-step picker (skip if Step 4 handed off)"* | Picker every turn except handoff | Picker only when a genuine fork remains *after* the answer; otherwise clean exit | F2, AC4 |
| `description` frontmatter (`helper/agents/helper.md:3`) — *"`AskUserQuestion` for every decision"* | Carries the phone-tree default into auto-trigger matching | Replace tail clause with *"`AskUserQuestion` only for genuine forks"* | F1, NF5 |
| Constraint: substrate-native (`helper/agents/helper.md:52`) | OK as-is | Unchanged — `AskUserQuestion` is still the picker primitive *when a picker is appropriate* | F2, NF5 |

### What changes in `helper/commands/help.md`

| Region | Current behavior | Target behavior | Source AC |
|---|---|---|---|
| "If the user did NOT provide an argument" block (`helper/commands/help.md:16-24`) | Opens an `AskUserQuestion` 3-option picker (Install / Pick a skill / Explain a concept) → dispatches to `Skill(helper)` after pick | Dispatches to `Skill(helper)` with an empty / "general" argument; Helper agent's Step 1 responds with a one-sentence inline prompt asking the user to state their question. The starter examples move to `helper/knowledge/output-discipline.md` as *example questions Helper can answer*, not a runtime fork. | F3, AC2 |
| Constraint: "Never render text `[a]/[b]/[c]`" (`helper/commands/help.md:29`) | OK as-is | Unchanged | NF5 |
| Description frontmatter (`helper/commands/help.md:2`) — *"opens a 3-option starter-topic picker"* | Stale after F3 | Reword to *"dispatches to Helper; if no argument, Helper prompts inline for the question"* | F3, AC2 |

### What changes in `helper/knowledge/output-discipline.md`

| Region | Current behavior | Target behavior | Source AC |
|---|---|---|---|
| "Closing picker" extension (`helper/knowledge/output-discipline.md:20`) — *"Every response (except `Skill()` handoff) closes with `AskUserQuestion`"* | Mandatory picker per turn | Rewrite to *"Close with `AskUserQuestion` only when a genuine fork remains after the answer (per `genuine fork` test below). Otherwise end the turn cleanly."* | F2, AC4 |
| "Substrate-native decisions" (`helper/knowledge/output-discipline.md:19`) | OK | Unchanged | NF5 |
| New section *"Genuine fork — operating definition"* | Does not exist | Add 3–4 test bullets (destructive action? two architecturally equivalent options? missing required input the agent cannot infer? per-row triage at scale?) — cited from `vision/VISION.md:57` (Ownership) and project memory `feedback_askuserquestion_overuse.md`. | F2, AC4 |
| New section *"Starter-topic examples"* | Migrated from `helper/commands/help.md` | List the install / pick-a-skill / explain-a-concept phrasings as **examples of questions Helper can answer**, not as runtime options. | F3, AC2 |

### What changes in `helper/README.md`

| Region | Current behavior | Target behavior | Source AC |
|---|---|---|---|
| Line 8 — *"`AskUserQuestion` for every decision"* | Codifies phone-tree | Replace with *"`AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs"* | AC8 |
| Status table line for "v0.2.0 feature-complete" (`helper/README.md:12-21`) | Step 3 / Step 4 row text describes the picker-default | Add a v0.3.0 row that describes the answer-first refactor | NF1, NF2 |

### What changes in `helper/CHANGELOG.md` and `helper/.claude-plugin/plugin.json`

| File | Change |
|---|---|
| `helper/CHANGELOG.md` | Add a `## [0.3.0] — 2026-05-23` block under Keep a Changelog format. Highlights: *"Helper default flow refactored from picker-first to answer-first; closing pickers conditional on genuine forks; bare `/help` prompts inline instead of opening starter-topic picker."* Cite the row at `vision/specs/roadmap.md:104-108`. |
| `helper/.claude-plugin/plugin.json` | Bump `version` to `0.3.0`. Per `vision/specs/main.spec.md:32` NFR3. |

## Key Design Decisions

### Decision 1 — Where the "answer-first" rule lives: agent body Steps, not just a knowledge rule

**Options considered.**
- **A. Rewrite Step 5 in the agent body** to make the closing picker conditional; restate the rule in `helper/knowledge/output-discipline.md`.
- **B. Leave Step 5 as-is; soften the wording in `helper/knowledge/output-discipline.md`** only.
- **C. Add a new always-on rule to `core/CLAUDE.md`** ("answer first, ask only at forks") and let it apply marketplace-wide.

**Recommendation.** **A.** Steps in an Actor body are the load-bearing how-to-act per `core/skills/actor-template/SKILL.md`; soft knowledge rules (option B) get ignored when Steps say otherwise. Option C is tempting and might subsume row #3 of the backlog, but it's a Vision-level change touching all skills — too big for this row. The cross-marketplace audit is exactly what row #3 (`vision/specs/features/2026-05-22-askuserquestion-audit/`) covers; do not pre-empt it here.

**Rationale.** This refactor's *purpose* is the Helper-specific behavior change. Promoting the rule to `core/CLAUDE.md` only makes sense after row #3 has surveyed every Helper + LSA call site and confirmed the rule generalizes cleanly. Source: project memory `feedback_minimal_edits` (*"Match edit size to ask size"*) and roadmap row #3 framing at `vision/specs/roadmap.md:117-120`.

### Decision 2 — How the goal-understanding sentence is composed (F4 / AC3)

**Options considered.**
- **A. Mandatory one-sentence restatement** opening every Helper response (a generic *"You want to know X"* / *"You want to start X"* / *"You want to fix X"*).
- **B. Conditional restatement** — only when the question carries workflow intent or is ambiguous; skip for one-word factual questions.
- **C. Implicit goal-understanding** — Helper just answers correctly; no explicit restatement sentence.

**Recommendation.** **A**, but with operating guidance in `helper/knowledge/output-discipline.md` that for one-word factual questions (*"what's `lsa-verify`?"*), the restatement can collapse to a half-sentence prefix (*"`lsa-verify` is — …"*). This satisfies F4 ("explicit goal-understanding pass" → "state that understanding back") without padding short answers.

**Rationale.** Option A delivers the user feedback directly (*"understand their goal and try to assist"* — `vision/specs/roadmap.md:107`); option C makes the goal-understanding invisible and indistinguishable from the current Helper. Option B saves a line but adds branching the agent has to judge — more failure modes for marginal gain. Source: `vision/VISION.md:57` (Ownership: *"makes the human think"* implies the system surfaces its own thinking).

### Decision 3 — Bare `/help` behavior (F3 / AC2)

**Options considered.**
- **A. Inline prompt in Helper's voice** — "What would you like help with? Common things: install, a concept, picking a skill, starting a flow."
- **B. Keep the 3-option `AskUserQuestion` picker** but reduce options.
- **C. Auto-suggest based on conversation context** — if the user has been in `lsa-specify`, suggest "explain User Verification"; if they just installed, suggest "next steps after install".

**Recommendation.** **A**. Direct, in Helper's voice, in prose. Option C is interesting but introduces hidden state inference (context-snooping); option B preserves the phone-tree symptom that this entire feature targets.

**Rationale.** The roadmap row's defining characteristic (`vision/specs/roadmap.md:107`) is *"verbal-coined name in this session: Helper-as-phone-tree"* — bare `/help` opening a 3-button picker IS the phone tree. Option A removes it. Option C is a follow-up; if the inline prompt proves too cold, future work can layer context-aware suggestions on top, but that's a fresh row, not part of this refactor. Source: user quote at `vision/specs/roadmap.md:107`, project memory `feedback_askuserquestion_overuse.md`.

## Proposed Steps reshape — `helper/agents/helper.md`

Current Steps (`helper/agents/helper.md:32-36`) — five steps. Target Steps — five steps, two of which change:

| # | Current Step (verbatim shape) | Target Step | Δ |
|---|---|---|---|
| 1 | Recognise the invoking signal and check cooldown per `friction-signals.md`. Signal (c) always proceeds. Observable: proceed OR silent exit. | **Recognise signal + cooldown + state the user's goal in one sentence.** Cooldown logic unchanged; add a goal-restatement sub-step ("You want to: [install / learn X / find a skill / start a flow / fix Y]"). Observable: either silent-exit OR Step 2 with a goal sentence ready to prepend to the answer. | + goal-restatement |
| 2 | Read sources in scope order per `knowledge-scope.md`. Stop after one bounded round. Observable: small set of `file:line` citations OR cannot-verify outcome. | **Unchanged** | — |
| 3 | Compose the answer per `output-discipline.md`. Every claim cited; ≤1.5 screens; cannot-verify fallback if Step 2 returned no source. Signal (a) opens with the User Verification picker. Observable: structured + cited + concise response body. | **Compose the answer, leading with the Step 1 goal-restatement sentence.** Otherwise unchanged. Signal (a) — the User Verification re-explanation prompt — stays as the established exception (it IS a genuine fork: re-explain Yes / No). | + goal-sentence prefix |
| 4 | If user intent maps to a skill, confirm via `AskUserQuestion` and hand off via `Skill()`. Fall through on No / no-match. Observable: `Skill()` invocation OR fall through. | **Unchanged** — flow start IS a genuine fork (NF5, F5, AC5) | — |
| 5 | **Close with a next-step picker** (skip if Step 4 handed off). `AskUserQuestion` with 2–3 narrow options. Observable: closing picker appears. | **Close cleanly OR offer a follow-up picker IF a genuine fork remains.** Apply the "genuine fork" test from `output-discipline.md`. If the answer fully resolves the question, end the turn with no picker. If the answer surfaced two valid skills the user must pick between, or two architectures, or asks for a destructive next step — only then open `AskUserQuestion`. Observable: either clean end OR a fork-specific picker. | conditional |

## Interaction with rows #2 and #3 (boundary)

The roadmap predicts (`vision/specs/roadmap.md:108`): *"Rows #2 and #3 likely fall out as side effects."* This refactor partially fulfills #3 (Helper-side) but does NOT subsume either row.

| Row | What this refactor delivers | What still needs row N | Independent? |
|---|---|---|---|
| **#1 (this row)** — Helper from router to assistant | Answer-first default; conditional closing picker; bare `/help` prompts inline; goal-restatement sentence; agent body Steps reshape; `helper/` README + CHANGELOG + version bump | — | — |
| **#2** — Onboarding fast-path (`vision/specs/features/2026-05-22-helper-onboarding-fast-path/`) | Helper's *default flow* now answers first, so onboarding questions get a cited answer — but they still go through the full scope-1/2/3 read in `helper/knowledge/knowledge-scope.md:9-15`. **Latency is unchanged.** | A pattern classifier ("install / how-to-start / what-is-X") that short-circuits to a README excerpt in seconds, skipping context7 + deep grep. Lives in `helper/agents/helper.md` Step 2 (or a pre-Step). | **Yes** — ride on row #1 but does not block it. Can ship in either order; if row #2 ships first, the closing picker stays mandatory until row #1 lands. |
| **#3** — `AskUserQuestion` audit (Helper + LSA) (`vision/specs/features/2026-05-22-askuserquestion-audit/`) | Helper's mandatory closing picker is removed; the "genuine fork" test is defined in `helper/knowledge/output-discipline.md`. Helper-side audit is therefore *substantially complete*. | LSA-wide audit: every `AskUserQuestion` call in `lsa/skills/**/SKILL.md` measured against the "genuine fork" test. Likely affects `lsa-specify`'s User Verification prompts, `lsa-plan`'s epic-approval picker, `lsa-discover`'s 3-question probe. | **Partial overlap**. Row #3 should cite the "genuine fork" definition this refactor introduces, instead of re-inventing it. Sequencing: row #1 first, then row #3 cites it. |

**Concrete boundary statement.** Row #1 alone delivers: a refactored Helper. Row #2 alone delivers: faster Helper for a *subset* of questions. Row #3 alone delivers: an LSA-wide picker audit. None of the three subsumes another; ship them in any order, but row #3 benefits from row #1 landing first (so it has a definition to cite).

**Cross-row Steps-conflict note (`helper/agents/helper.md`).** Row #1 reshapes Steps 1, 3, 5 (changes Step semantics). Row #2 adds a new Step 1.5 between Step 1 and Step 2 (no overlap on Steps 1, 3, 5). Row #5 (`vision/specs/features/2026-05-22-show-changes-inline/`) only adds a Constraints bullet — no Step-block conflict. **Bundled-delivery decision (user 2026-05-23):** Helper #1 (this row) and #2 (onboarding fast-path) ship as a SINGLE v0.3.0 PR. The two changes are scope-compatible (additive Step 1.5 + Steps 1/3/5 reshape) and share the CHANGELOG entry.

## Cross-Module Contracts

- **Helper → `core/output`** (`core/skills/output/SKILL.md`): no contract change. Helper still inherits the 5 golden rules. The "Closing picker" rule in `helper/knowledge/output-discipline.md:20` was a Helper-specific *extension* of `core/output`, not a `core/output` rule itself — so this refactor does not touch `core`. Verify by re-reading `core/skills/output/SKILL.md` during implementation; if the rule is *also* stated in `core/output`, escalate to a `core` change (out of scope here).
- **Helper → `core/actor-template`** (`core/skills/actor-template/SKILL.md`): no contract change. Each Step still has an observable result; the Steps shape (Goal / Input / Steps / Output / Constraints) is preserved.
- **Helper → `lsa-specify`** (`lsa/skills/lsa-specify/SKILL.md`): no contract change. Signal (a) auto-engage at consecutive User Verification rejects is preserved (`helper/knowledge/friction-signals.md:13`). The Yes/No picker offered to re-explain a Verification IS a genuine fork (re-explain Yes → re-grounded explanation; No → silent exit), so it stays.
- **Marketplace** (`./.claude-plugin/marketplace.json`): no change. `helper` plugin version bump is internal to the plugin.

## Open Questions

1. **Should the "answer-first" rule be promoted to `core/CLAUDE.md`?** Currently kept in `helper/` per Decision 1, but if row #3 (LSA audit) reaches the same conclusion, the rule should generalize. Defer until row #3 has surveyed LSA.
2. **Does the `core/output` SKILL itself say anything about closing pickers?** Need to read `core/skills/output/SKILL.md` during implementation. If it does, this refactor must escalate to a `core` change — which expands scope. Hypothesis: it does not (the "closing picker every turn" rule lives only in `helper/knowledge/output-discipline.md:20`). Verify before starting implementation.

   **Resolution (2026-05-24 — implementation):** Confirmed. Read `core/skills/output/SKILL.md` in full at implementation start. The five golden rules (Structured / Minimal / Formatted / Sourced / Concrete) do NOT mandate a closing picker. Rule 5 ("Concrete") in fact states *"Pickers surface only choices that change the outcome"* (`core/skills/output/SKILL.md:33`) and *"Must-decide only. Surface as picker questions only choices that meaningfully change the outcome"* (`core/skills/output/SKILL.md:39`) — fully aligned with this refactor's "genuine fork" rule. The "closing picker every turn" rule lives only in `helper/knowledge/output-discipline.md:20` as a Helper-specific extension. Scope stays inside `helper/`; no `core/` edit needed.
3. **Is "genuine fork" the right name?** Alternatives considered: "real choice", "blocking decision", "must-decide gate" (from project memory `feedback_gate_prompts_concrete`). The memory pushes toward *concrete* prompt voice. *"Genuine fork"* is internal vocabulary; the user-facing prompts must still be subject-named (e.g., *"Start lsa-specify for password reset?"* — not *"Confirm genuine fork?"*). Implementation-time naming choice; spec-level concept is stable.
4. **Should the description frontmatter at `helper/agents/helper.md:3` be revised even though it affects auto-trigger matching?** The current description ends *"`AskUserQuestion` for every decision"*. Revising to *"`AskUserQuestion` only for genuine forks"* could change which user messages auto-trigger Helper (the description is matched against the live conversation per Claude Code's plugin agent activation). Likely safe — the matched phrases are *"free-form question"*, *"`/help`"*, *"`lsa-specify` User Verification"* — but worth a quick sanity check during implementation.
5. **v0.3.0 vs v0.2.2.** Picked v0.3.0 (minor) because the default flow user-visibly changes; arguable that the underlying capabilities are unchanged (still cited, still ≤1.5 screens, still `AskUserQuestion` for forks) and v0.2.2 (patch) suffices. Going with minor for clarity; the implementer may downgrade if the CHANGELOG entry comes out shorter than expected.
