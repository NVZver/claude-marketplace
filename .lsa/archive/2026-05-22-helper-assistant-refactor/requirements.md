# Feature: Refactor Helper from command-router to assistant

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #1.

## Summary

Reshape the Helper agent (`helper/agents/helper.md`) from a multiple-choice dispatcher ("present picker → user picks → fire slash command") into a goal-understanding assistant whose default reply is a direct cited answer in Helper's own voice. The picker becomes the *outcome* of help (an optional closing offer), not the substance (a mandatory front-door gate). Symptom: user 2026-05-22 — *"Helper does not try to help, just tries to run a command without any reasoning behind. It should take care of the user, communicate with them, understand their goal and try to assist."* (source: `.lsa/roadmap.md:107`). Verbal name: **Helper-as-phone-tree**.

The current shape forces a picker even when the user has already asked a direct question — both invocation paths funnel into the same dispatch logic:

- The `/help` slash command body (`helper/commands/help.md:18-22`) opens a 3-option starter-topic picker when called without an argument; with an argument it dispatches to `Skill(helper)` but the agent body has no rule preventing a closing picker on every turn.
- The agent body (`helper/agents/helper.md:36`) makes the closing picker mandatory: *"Close with a next-step picker (skip if Step 4 handed off). `AskUserQuestion` with 2–3 narrow options"* — Step 5 is unconditional, not "when a real fork remains".
- Output discipline (`helper/knowledge/output-discipline.md:20`) codifies the picker as default: *"Closing picker. Every response (except `Skill()` handoff) closes with `AskUserQuestion`"*.

Per project memory `feedback_helper_must_assist.md` ("Helper must assist, not dispatch") and `feedback_askuserquestion_overuse.md` ("answer first, ask only at real forks"). This refactor delivers row #1 alone; rows #2 (`.lsa/features/2026-05-22-helper-onboarding-fast-path/`) and #3 (`.lsa/features/2026-05-22-askuserquestion-audit/`) are independent and ride on this foundation but do not block it (see `design.md` §"Boundary with rows #2 and #3").

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | Helper's default first-turn reply to any question (signal b/c) **leads with a direct cited answer** — not with an `AskUserQuestion` picker. The answer carries `file:line` (or URL) citations per claim and stays within the 1.5-screen budget. | Must |
| F2 | The closing `AskUserQuestion` picker becomes **optional and conditional** — emitted only when a genuine fork remains *after* the answer (the user might pick a follow-up that the agent cannot infer). When no real fork remains, Helper ends the turn cleanly (no picker, no filler closing). | Must |
| F3 | The `/help` slash command, when called **without** an argument, **prompts inline for the user's question in Helper's voice** (free-form), rather than opening a starter-topic picker. (The current 3-option picker at `helper/commands/help.md:18-22` is the canonical "phone-tree" symptom.) The starter-topic list remains in knowledge as *example questions Helper can answer*, not as a mandatory fork. | Must |
| F4 | Helper's first step on any invocation is an **explicit goal-understanding pass**: identify what the user is trying to accomplish (install / learn-concept / find-skill / start-a-skill / debug), state that understanding back in one short sentence, then answer. The goal-understanding sentence is part of the answer body, not a separate picker turn. | Must |
| F5 | When Helper detects workflow intent that maps to a skill (`"I want to add X"` → `lsa-specify`, `"bug in X"` → `lsa-discover`), the handoff confirmation remains an `AskUserQuestion` (preserved from `helper/agents/helper.md:35` Step 4) — this is a genuine fork (destructive: starts a multi-step flow). The handoff is the *outcome* of help, after the cited answer has been given. | Must |
| F6 | When Helper truly cannot answer (no source found, no skill matches, ambiguity it cannot resolve from context), it follows the existing cannot-verify fallback (`helper/agents/helper.md:50`) — `"I cannot verify this."` + named sources + `AskUserQuestion` for next steps. This is the **only** scenario where the first thing the user sees is a picker. | Must |
| F7 | The Steps reshape in `helper/agents/helper.md` makes the new ordering executable: Step 1 (cooldown + goal-understanding) → Step 2 (read sources) → Step 3 (compose answer) → Step 4 (offer skill handoff IF intent maps) → Step 5 (close cleanly OR optional follow-up picker IF genuine fork remains). Each step has an observable result per `core/skills/actor-template/SKILL.md`. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | **Per-plugin SemVer + CHANGELOG.** `helper/CHANGELOG.md` gains an entry; `helper/.claude-plugin/plugin.json` bumps minor (v0.2.1 → v0.3.0 — minor because user-visible default-flow change, not a bug fix). Per `.lsa/main.spec.md:32` NFR3. *Note: v0.3.0 carries both row #1 (this) and row #2 (onboarding fast-path) per user decision 2026-05-23.* |
| NF2 | **Living READMEs.** `helper/README.md` reflects the new default flow ("answer-first, picker optional"); the v0.2.1 phrasing at `helper/README.md:8` (*"`AskUserQuestion` for every decision"*) is corrected to *"`AskUserQuestion` for every genuine fork"*. Repo `README.md` unchanged (no top-level surface delta). Per `CLAUDE.md` §"Discipline (sourced)" *"READMEs are living documents"*. |
| NF3 | **Fact-grounding preserved.** Every Helper claim still carries `file:line` (in-repo) or URL (external) citation per `core/ground-rules` Rule 1 and `.lsa/main.spec.md:30` NFR1. The refactor adds nothing that bypasses grounding. |
| NF4 | **Knowledge vs Actor separation preserved.** `helper/agents/helper.md` stays an Actor (Goal/Input/Steps/Output/Constraints). The "answer-first" rule lives in the agent body (how-to-act). The *examples* of starter-topic phrasings move to `helper/knowledge/output-discipline.md` (what-is-true reference). Per `.lsa/main.spec.md:34` NFR5. |
| NF5 | **Substrate-native preserved.** `AskUserQuestion` is still the substrate for any decision that is offered. The change is *whether to offer* a decision, not *how to render it*. Per `.lsa/VISION.md:66` Principle 9 and `core/CLAUDE.md:19-20` checkpoint 1. |
| NF6 | **Behavior-trace from spec to skill body.** Every change in `helper/agents/helper.md` and `helper/knowledge/output-discipline.md` traces to an AC below. Per `.lsa/main.spec.md:31` NFR2 (spec-grounding). |
| NF7 | **No-regression on Helper v0.2.0 capabilities.** All 8 ACs in `.lsa/features/2026-05-21-helper-agent/requirements.md` (AC1–AC8) still hold after the refactor — except the implicit "picker every turn" interpretation of AC8 / output-discipline (which this refactor explicitly revises). |

## Inputs & Outputs

- **Input.**
  - User invocation through one of the three signal paths in `helper/knowledge/friction-signals.md:11-15` — (a) consecutive `lsa-specify` User Verification rejects, (b) free-form `?` / `what is X?` mid-flow, (c) explicit `/help <question>` or `/help` alone.
  - Ambient state: this repo + installed plugins (per `helper/knowledge/knowledge-scope.md:9-15`) + (optional) `context7` MCP.
  - Prior conversation transcript (for cooldown derivation per `helper/knowledge/friction-signals.md:46-52`).
- **Output.**
  - **Default**: a cited answer in Helper's voice, opening with a one-sentence goal restatement, ≤1.5 screens, ending cleanly (no closing picker unless a genuine fork remains).
  - **Skill-handoff branch**: cited answer first, then `AskUserQuestion` to confirm a flow start (e.g., `"Start lsa-specify for password reset? — Yes / No"`), then `Skill(...)` on Yes.
  - **Cannot-verify branch**: `"I cannot verify this."` + named sources + `AskUserQuestion` for next steps. (Only branch where the user's first sight is a picker.)
- **Side effects.** None outside the conversation. Preserved from v0.2.0 (`.lsa/features/2026-05-21-helper-agent/requirements.md:40`).

## Constraints

- **NFR1 fact-grounding** (`.lsa/main.spec.md:30`) — every claim cites `file:line` or URL.
- **NFR2 spec-grounding** (`.lsa/main.spec.md:31`) — every change in agent body traces to an AC here.
- **NFR3 per-plugin SemVer + CHANGELOG** (`.lsa/main.spec.md:32`) — `helper` bumps in same commit as user-visible change.
- **NFR5 Knowledge vs Actor separation** (`.lsa/main.spec.md:34`) — agent body holds Steps; jargon glosses + topic examples live in `helper/knowledge/`.
- **Vision Principle 9 — substrate-native first** (`.lsa/VISION.md:66`) — `AskUserQuestion` is preserved as the picker primitive *when a picker is appropriate*.
- **Vision §2 sub-principle 2a — journey-shaped ACs** (`.lsa/VISION.md:59`) — every AC below is user-observable.
- **Vision §2 sub-principle 1a — Ownership over automation** (`.lsa/VISION.md:57`) — the refactor surfaces *the answer* and lets the user choose what to do next; it does not silently decide what skill to fire.
- **Memory: `feedback_helper_must_assist`** — Helper is currently a command router; the refactor's purpose is exactly to fix this.
- **Memory: `feedback_askuserquestion_overuse`** — answer first, ask only at real forks. This refactor codifies the rule into Steps.
- **Memory: `feedback_askuserquestion_mandatory`** — `AskUserQuestion` remains the only acceptable picker primitive (no text `[a]/[b]/[c]` blocks). The refactor does not relax this — it changes *when* to use a picker, not *how*.
- **Memory: `feedback_output_length`** — ≤1.5 screens; split across turns. Preserved.

## Out of Scope

- **No retrofit of `lsa/` skills.** This refactor touches `helper/` only. The LSA-wide `AskUserQuestion` audit is row #3 (`.lsa/features/2026-05-22-askuserquestion-audit/`) — independent.
- **No fast-path classifier for onboarding questions.** Row #2 (`.lsa/features/2026-05-22-helper-onboarding-fast-path/`) introduces a README-quote short-circuit; that's a separate latency optimization. This refactor makes the *default flow* answer-first; row #2 makes a *subset of common questions* faster.
- **No friction-signal change.** Signals (a) / (b) / (c) and the cooldown rule (`helper/knowledge/friction-signals.md`) are unchanged.
- **No new tools.** The agent's `tools:` line at `helper/agents/helper.md:4` is preserved (`Read, Grep, Glob, AskUserQuestion, Skill, mcp__plugin_context7_context7__*`).
- **No persona theater.** The "no greeting / no avatar" constraint at `helper/agents/helper.md:51` stays — answer-first does NOT mean chatty-first.
- **No conversation-state persistence.** Preserved from v0.2.0 (`.lsa/features/2026-05-21-helper-agent/requirements.md:40`).
- **No deprecation of the `/help` command.** The slash command remains the explicit pull path; only its no-argument behavior changes (F3).

## Acceptance Criteria

Journey-shaped per `.lsa/VISION.md` §2 sub-principle 2a; EARS form per `.lsa/VISION.md:204` (Ubiquitous / Event / State / Optional / Unwanted).

- [ ] **AC1 — Direct question gets a direct answer first.**
  *Journey:* user types `/help what is the Standard flow?` in a fresh session.
  *Behavior:* **When** `/help` is invoked with a question argument, **the system shall** respond with a goal-restatement sentence (one line) followed by a `file:line`-cited definition of the Standard flow, in ≤1.5 screens. The response **shall not** open with an `AskUserQuestion` picker.

- [ ] **AC2 — Bare `/help` asks the user's question inline, not via a starter picker.**
  *Journey:* user types `/help` alone (no argument).
  *Behavior:* **When** `/help` is invoked with no argument, **the system shall** respond in Helper's voice with a one-sentence prompt inviting the user to state their question (e.g., *"What would you like help with? — install, a concept, picking a skill, or starting a flow are all common."*). The response **shall not** open with an `AskUserQuestion` 3-option picker as the substantive content of the turn.

- [ ] **AC3 — Goal-understanding sentence opens the reply.**
  *Journey:* any Helper response to a substantive question (signal b or c).
  *Behavior:* **When** Helper composes a reply to a user question, **the system shall** open the response with one sentence restating what the user is trying to accomplish (e.g., *"You want to know what the Standard flow is and when to use it."*). This sentence carries no citation (it's a restatement, not a claim) and counts toward the 1.5-screen budget.

- [ ] **AC4 — Closing picker only when a real fork remains.**
  *Journey:* Helper has answered a question whose follow-up is obvious from context (e.g., user asked "what is X" and the answer covers it).
  *Behavior:* **When** the answer fully resolves the user's question and no genuine follow-up fork exists, **the system shall** end the turn after the answer body — no closing `AskUserQuestion`, no filler ("Anything else?"). **When** a genuine fork remains (e.g., the answer surfaced two valid skills and the user has to pick which one applies), **the system shall** close with an `AskUserQuestion` offering the actual options.

- [ ] **AC5 — Skill handoff stays a confirmed picker (genuine fork preserved).**
  *Journey:* user types `"I want to add password reset"` to Helper.
  *Behavior:* **When** Helper detects workflow intent that maps to a skill, **the system shall** first respond with a cited one-paragraph answer (e.g., describing what `lsa-specify` does, citing `lsa/skills/lsa-specify/SKILL.md`), **then** confirm via `AskUserQuestion` (*"Start lsa-specify for password reset? — Yes / No"*), **then** on Yes invoke `Skill(lsa-specify)`. The picker is *not* skipped — a flow start is a destructive fork.

- [ ] **AC6 — Cannot-verify fallback unchanged.**
  *Journey:* user asks Helper about a subject that does not exist in repo, installed plugins, or `context7`.
  *Behavior:* **If** no grounded source is found after a bounded read (per `helper/knowledge/knowledge-scope.md:25-33`), **then the system shall** respond `"I cannot verify this."` + name the sources checked + open an `AskUserQuestion` for next steps. This is the **only** branch where the first thing the user sees is a picker. Preserves AC5 from the v0.2.0 spec at `.lsa/features/2026-05-21-helper-agent/requirements.md:84`.

- [ ] **AC7 — No-regression on v0.2.0 capabilities.**
  *Journey:* run each of AC1–AC8 from `.lsa/features/2026-05-21-helper-agent/requirements.md:67-98` against the refactored Helper.
  *Behavior:* **The system shall** still satisfy v0.2.0 AC1 (citations), AC2 (auto-engage at User Verification reject), AC3 (workflow handoff via `Skill()`), AC4 (`context7` for external libraries), AC5 (cannot-verify), AC6 (substrate-native `AskUserQuestion`), AC7 (jargon re-grounding), AC8 (≤1.5 screens) — modulo this feature's intentional revision of "picker every turn".

- [ ] **AC8 — README reflects the new default.**
  *Journey:* a new user installs `helper@NVZver` and reads `helper/README.md` to learn how Helper behaves.
  *Behavior:* **The system shall** show in `helper/README.md` that Helper's default reply is a cited answer, and that pickers appear only on genuine forks or cannot-verify. The current line at `helper/README.md:8` (*"`AskUserQuestion` for every decision"*) is updated to *"every genuine fork"* (or equivalent). Per `CLAUDE.md` §"Discipline (sourced)" *"READMEs are living documents"*.

## Open Questions

1. **Path mismatch in roadmap row.** The roadmap row says `helper/skills/helper/SKILL.md` (`.lsa/roadmap.md:108`), but the actual file is `helper/agents/helper.md` (`helper` is an agent plugin, not a skill plugin — confirmed via `ls helper/` and `helper/.claude-plugin/plugin.json`). All citations in this spec use the actual path. Assumption: roadmap row authored by analogy to LSA's `*/SKILL.md` files; no path change intended. *If* the implementer disagrees, raise before tasks.md execution.
2. **"Genuine fork" test phrasing.** The rule is "ask only when the agent cannot resolve from context". Concrete tests need to be enumerated in `helper/knowledge/output-discipline.md` (e.g., destructive action? two architecturally equivalent options? missing required input?). Draft list in `design.md` §"Genuine fork — operating definition".
3. **What does "bare `/help`" say exactly?** F3 / AC2 leave the prompt phrasing soft (*"What would you like help with?"* is illustrative). Final wording is a `helper/commands/help.md` edit and can be tuned during implementation; the AC tests *that* an inline prompt appears, not the exact words.
4. **Should the goal-restatement sentence be conditional?** For one-word factual questions (*"what's `lsa-verify`?"*), an explicit "You want to know what `lsa-verify` is" sentence is mild filler. Possible refinement: goal-restatement only when the question is ambiguous or carries intent (workflow / install / pick-a-skill). Leaving F4 / AC3 as written; this is an implementation-time tuning question, not a spec change.
