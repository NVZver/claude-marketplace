# Test Suites: Refactor Helper from command-router to assistant

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #1.

Verification approach is **manual probe in a fresh Claude Code session** (no automated harness — Helper response shape is a UX assertion, not a code unit). Probes follow `vision/specs/standards/testing.md` V1 → V2 → V3 progression. Each probe maps to one or more ACs in `requirements.md`.

## Journey 1: Direct question through `/help`

**Goal:** confirm Helper leads with a cited answer, not a picker, on a direct factual question.
**Covers:** AC1, AC3 (goal-restatement), AC7 (no-regression on v0.2.0 AC1).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1a | Direct factual question | In a fresh session, type `/help what is the Standard flow?`. |
| 1b | Workflow-intent question | In a fresh session, type `/help I want to add password reset`. (Handoff branch; see Journey 4.) |

**Expected outcome (1a):**
- First rendered element of the response is **prose**, not an `AskUserQuestion` picker.
- The response opens with a goal-restatement sentence in Helper's voice (e.g., *"You want to know what Standard means and when to use it."*).
- The body contains a cited definition of the Standard flow with `file:line` references (expect citations to `vision/VISION.md:121-125` and/or `core/skills/flow-selector/SKILL.md`).
- The response stays ≤1.5 screens (≤~50 rendered lines).
- The response **ends cleanly** — no closing `AskUserQuestion` picker. (AC4: the answer fully resolves the question; no genuine fork remains.)

## Journey 2: Bare `/help` (no argument)

**Goal:** confirm bare `/help` prompts inline, not via a 3-option picker.
**Covers:** AC2, F3.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 2a | Bare invocation | In a fresh session, type `/help` alone. |

**Expected outcome (2a):**
- Helper responds with a **prose one-sentence invitation** to state the question (e.g., *"What would you like help with? Install, a concept, picking a skill, and starting a flow are all common — go ahead."*).
- No `AskUserQuestion` 3-option picker (Install / Pick a skill / Explain a concept) appears as the substance of the turn.
- The prompt is short (≤3 lines).
- **Failure mode** if AC2 fails: bare `/help` opens a picker → fails Journey 2a regardless of how good the picker options are.

## Journey 3: Goal-restatement is present

**Goal:** confirm every Helper response opens with a one-sentence goal restatement.
**Covers:** AC3, F4.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 3a | Concept question | Type `/help what's lsa-verify?`. |
| 3b | Install question | Type `/help how do I install the marketplace?`. |
| 3c | Pick-a-skill question | Type `/help which skill specs out a new feature?`. |
| 3d | One-word question (edge case) | Type `/help lsa-sync?`. |

**Expected outcome:**
- 3a–3c: response opens with an explicit goal-restatement sentence ("You want to know X" / "You want to install Y" / "You want to find the skill that does Z").
- 3d: response may collapse the restatement into a half-sentence prefix ("`lsa-sync` is — ...") per Decision 2 in `design.md`. Test passes if some form of goal-acknowledgement appears before the substantive answer.

## Journey 4: Skill handoff preserves the confirmation picker

**Goal:** confirm flow-start handoff still uses `AskUserQuestion` — a genuine fork is not collapsed.
**Covers:** AC5, F5, AC7 (no-regression on v0.2.0 AC3).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 4a | New-feature intent | Type `/help I want to add password reset`. |
| 4b | Bug-fix intent | Type `/help the date formatter is broken`. |
| 4c | User says No | At the `AskUserQuestion` confirmation in 4a, pick `No`. |

**Expected outcome:**
- 4a: response opens with a cited answer (one paragraph describing what `lsa-specify` does, citing `lsa/skills/lsa-specify/SKILL.md`), **then** an `AskUserQuestion` *"Start `lsa-specify` for password reset? — Yes / No"*. The cited answer comes **first**.
- 4b: same shape; cited paragraph on `lsa-discover` + Standard flow, then `AskUserQuestion` *"Start `lsa-discover` for the date-formatter bug? — Yes / No"*.
- 4c (No path): Helper falls through cleanly — no extra picker, no "anything else?" filler. (AC4: no genuine fork remains.)

## Journey 5: Cannot-verify fallback unchanged

**Goal:** confirm the cannot-verify branch still produces a picker for next steps.
**Covers:** AC6, F6, AC7 (no-regression on v0.2.0 AC5).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 5a | Subject not in repo / plugins / context7 | Type `/help what is the gluten-free batch processor?` (fictional subject). |

**Expected outcome:**
- Response body is exactly `"I cannot verify this."` + a list of sources checked (e.g., *"checked `vision/`, `core/`, `lsa/`, installed-plugin caches, `context7`"*).
- An `AskUserQuestion` opens with next-step options (e.g., *"Try a different question? / Search externally? / Done"*).
- This is the **only** journey where the user's first sight is a picker.

## Journey 6: Closing picker — only when fork remains

**Goal:** confirm the closing picker is conditional, not mandatory.
**Covers:** AC4, F2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 6a | Fully-resolved question | Type `/help what is the Standard flow?` (same as 1a). |
| 6b | Two-valid-skill question | Type `/help should I use lsa-specify or lsa-discover for a small refactor?`. |
| 6c | Question implying a follow-up flow | Type `/help how do I install LSA?`. |

**Expected outcome:**
- 6a: clean end, no closing picker (per Journey 1).
- 6b: response describes both skills with citations, **then** opens `AskUserQuestion` *"Which sounds closer to your task? — refactor (`lsa-discover` / Standard flow) / new feature (`lsa-specify` / Extended flow)"*. The picker is offered because a real choice remains.
- 6c: response shows install steps (one-paragraph quote of `README.md` "Default plugins" block); the *follow-up* ("now try `/help <topic>` to learn a skill") could be a soft offer. Acceptable to end cleanly OR offer a single follow-up via `AskUserQuestion` — both pass AC4 as long as a mandatory phone-tree picker is absent.

## Journey 7: Auto-engage paths unchanged (signal a + b)

**Goal:** confirm signal-(a) and signal-(b) auto-engages still work, with answer-first applied.
**Covers:** AC7 (no-regression on v0.2.0 AC2), F1, F4.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 7a | Signal (b) — free-form mid-flow | Mid-session (no skill active), type `what is `lsa-verify`?` (no `/help` prefix). |
| 7b | Signal (a) — consecutive User Verification reject | Start `lsa-specify` for a feature; at any User Verification, pick `[c] reject`; on re-presentation pick `[c] reject` again. |
| 7c | Cooldown probe | After declining Helper's auto-engage in 7a or 7b with `No`, re-trigger the same signal-type immediately. |

**Expected outcome:**
- 7a: Helper auto-engages without `/help`. Response opens with goal-restatement + cited answer (e.g., citing `lsa/skills/lsa-verify/SKILL.md`). No mandatory closing picker (per AC4).
- 7b: Helper auto-engages with `AskUserQuestion` *"Want me to explain what this User Verification is checking? — Yes / No"* (this is a genuine fork — re-explain or not — and was the established shape per `helper/agents/helper.md:34` Step 3). On Yes, re-grounded explanation cites `lsa/skills/lsa-specify/SKILL.md`.
- 7c: Helper does NOT re-engage on the same signal-type until a different signal fires or `/help` is invoked. Cooldown preserved per `helper/knowledge/friction-signals.md:18-25`.

## Journey 8: Jargon re-grounding + length budget preserved

**Goal:** confirm v0.2.0 NFRs around jargon and length still hold.
**Covers:** AC7 (no-regression on v0.2.0 AC7 + AC8), NF3, NF4.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 8a | Jargon first-use | Type `/help when do I use Extended?`. |
| 8b | Long-answer budget | Type `/help walk me through everything LSA does`. |

**Expected outcome:**
- 8a: first use of *Extended* in the response carries a 3–5 word inline gloss (e.g., *"Extended — full-LSA flow for a new feature"*). Acronyms (`LSA`, `EARS`, `MCP`) get a gloss every turn.
- 8b: response stays ≤1.5 screens; if more is needed, Helper splits across turns ending with `AskUserQuestion` for *"show more"* / pivot. (Long-answer case IS a genuine fork — the user might want to drill into one skill.)

## Journey 9: README / CHANGELOG / version updated

**Goal:** confirm the user-facing surface reflects the new behavior.
**Covers:** AC8, NF1, NF2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 9a | README reflects answer-first | Open `helper/README.md`; search for phrasing about `AskUserQuestion`. |
| 9b | CHANGELOG entry | Open `helper/CHANGELOG.md`; check for a v0.3.0 entry. |
| 9c | Version bump | Open `helper/.claude-plugin/plugin.json`; check `version` field. |

**Expected outcome:**
- 9a: the line at `helper/README.md:8` (currently *"`AskUserQuestion` for every decision"*) is updated to *"every genuine fork"* (or equivalent). Status table has a v0.3.0 row describing the refactor.
- 9b: a `## [0.3.0] — 2026-05-23` block exists with Keep a Changelog format, citing the roadmap row.
- 9c: `version` is `0.3.0`.

## Open Questions

1. **Should Journey 6c require a clean end or allow an optional follow-up picker?** Spec is permissive ("either passes AC4"). Tightening this might be useful after dogfooding; for now keep flexible.
2. **Journey 7b: should the "re-explain Yes/No" picker also be re-examined?** It's a Yes/No picker offered automatically on signal (a). Arguably the re-explanation could be unconditional ("user already said the Verification is opaque twice — just re-explain"). This is a Helper-side simplification candidate but is out of scope for this refactor; flag for row #3 (`AskUserQuestion` audit).
3. **Automated lint for "no opening `AskUserQuestion`"?** Could be added later as part of the self-eval harness (`vision/specs/roadmap.md:28`). Currently manual probe only.
4. **Should there be a Journey 10 for context7 / external-library questions?** v0.2.0 AC4 covers this (`vision/specs/features/2026-05-21-helper-agent/requirements.md:80-83`); this refactor doesn't change the external-library path. Covered transitively by AC7 (no-regression).
