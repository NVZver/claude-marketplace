# Changelog

All notable changes to the `helper` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.3.0] – 2026-05-24

Answer-first refactor — Helper from command-router to assistant. Default reply becomes a direct cited answer in Helper's voice opening with a one-sentence goal restatement; the closing `AskUserQuestion` becomes conditional on a "genuine fork" remaining after the answer. Bare `/help` no longer opens a 3-option starter-topic picker — Helper prompts inline for the question instead. Targets the *"Helper-as-phone-tree"* symptom per [`vision/specs/roadmap.md:104-108`](../vision/specs/roadmap.md). Spec at [`vision/specs/features/2026-05-22-helper-assistant-refactor/`](../vision/specs/features/2026-05-22-helper-assistant-refactor/). Standard flow.

### Changed

- **Agent body Steps 1, 3, 5 reshaped** ([`./agents/helper.md`](./agents/helper.md)). Step 1 gains a goal-restatement sub-step ("You want to: [install / learn X / find a skill / start a flow / fix Y]"). Step 3 prefixes the answer with the Step 1 sentence (or collapses to a half-sentence prefix for one-word factual questions). Step 5 becomes conditional: clean end when the answer fully resolves the question; `AskUserQuestion` only when a genuine fork remains (destructive action, two architecturally equivalent options, missing input the agent cannot infer, or per-row triage at scale). Steps 2 and 4 unchanged. Each Step preserves its observable-result line per [`core/skills/actor-template/SKILL.md`](../core/skills/actor-template/SKILL.md).
- **Agent description frontmatter** ([`./agents/helper.md`](./agents/helper.md)) — tail clause *"`AskUserQuestion` for every decision"* replaced with *"`AskUserQuestion` only for genuine forks"*.
- **Bare `/help` no-argument behavior** ([`./commands/help.md`](./commands/help.md)). Removed the 3-option `AskUserQuestion` starter-topic picker (install / pick a skill / explain a concept). The command now dispatches `Skill(helper)` with an empty argument; Helper's Step 1 emits a one-sentence inline prompt in Helper's voice inviting the user to state their question. The starter-topic phrasings migrated to [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md) § *Starter-topic examples* as illustrative examples — not a runtime fork.
- **Command description frontmatter** ([`./commands/help.md`](./commands/help.md)) — *"opens a 3-option starter-topic picker"* replaced with *"dispatches to Helper; if no argument, Helper prompts inline for the question"*.
- **Output discipline closing-picker rule** ([`./knowledge/output-discipline.md`](./knowledge/output-discipline.md)) — *"Every response (except `Skill()` handoff) closes with `AskUserQuestion`"* replaced with *"Close with `AskUserQuestion` only when a genuine fork remains after the answer ... Otherwise end cleanly."*
- **`helper/README.md:8` default-flow phrasing** — *"`AskUserQuestion` for every decision"* replaced with *"`AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs"*. Per [`CLAUDE.md`](../CLAUDE.md) §*"Discipline (sourced)"* (*"READMEs are living documents"*).

### Added

- **"Genuine fork — operating definition" section** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). Four concrete tests: destructive/irreversible action, two architecturally equivalent options, missing required input the agent cannot infer, per-row triage at scale. Cites `vision/VISION.md:57` (Ownership over automation) and project memory `feedback_askuserquestion_overuse.md`.
- **"Goal-restatement opening" rule** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). Every response opens with a one-sentence goal restatement; for one-word factual questions a half-sentence prefix suffices. Per `requirements.md` F4 / AC3.
- **"Starter-topic examples" section** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). The install / pick-a-skill / explain-a-concept phrasings migrated from `helper/commands/help.md` as illustrative content, not a runtime picker.
- **"What violates discipline" bullet** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md): *"A response that opens with `AskUserQuestion` instead of a cited answer (except cannot-verify per `helper/agents/helper.md` Step 3)."*
- **v0.3.0 row** in the status table of [`./README.md`](./README.md).

### Notes

- **Minor bump rationale.** User-visible default-flow change (the picker stops being mandatory; bare `/help` shape changes). Underlying capabilities are unchanged — still cited, still ≤1.5 screens, still `AskUserQuestion` as the picker primitive *when a picker is appropriate*. Per [`vision/specs/main.spec.md:32`](../vision/specs/main.spec.md) NFR3.
- **Constraints block in `./agents/helper.md` (lines 46–58) unchanged.** Substrate-native, cannot-ground fallback, no-persona, cooldown, signal-(a) precondition — all preserved. Per `tasks.md` Task 1.4.
- **`core/output` confirmed untouched.** The "closing picker every turn" rule never lived in [`core/skills/output/SKILL.md`](../core/skills/output/SKILL.md); it was a Helper-specific extension at [`./knowledge/output-discipline.md:20`](./knowledge/output-discipline.md). `core/output` Rule 5 (*"Pickers surface only choices that change the outcome"*, `core/skills/output/SKILL.md:33`) is consistent with this refactor — no `core/` edit needed. Resolves OQ2 in [`vision/specs/features/2026-05-22-helper-assistant-refactor/design.md`](../vision/specs/features/2026-05-22-helper-assistant-refactor/design.md).

## [0.2.1] – 2026-05-22

File-load trace adoption. The Helper agent body, the `/help` command, and all 3 `helper/knowledge/*.md` files carry the new one-line trace directive at their top, per `core` v0.5.4 Rule 4 (Sourced) → *File-load trace*. On load, each file prints `=============== [<file>] [helper] ===============` verbatim. Replaces the v0.5.3 `[plugin:skill]` marker scheme. Per user request 2026-05-22. Quick flow.

### Added
- **Trace directive in 5 files** — `helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/friction-signals.md`, `helper/knowledge/knowledge-scope.md`, `helper/knowledge/output-discipline.md`. Hardcoded path + plugin name in each.

### Notes
- **Patch bump rationale.** No Helper behavior change — same friction-signal detection, same cooldown rule, same response discipline. Only the on-load trace output is new.

## [0.2.0] – 2026-05-22

Friction-signal detection + cooldown. Helper now auto-engages on the three signals defined in step 4 of [`vision/specs/features/2026-05-21-helper-agent/tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md) (Epic 4), with per-signal-type cooldown to prevent nag.

### Added

- **Step 4 — Friction-signal detection + cooldown.** New knowledge file [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) defines the three signals — (a) two consecutive `[c] reject` at any `lsa-specify` User Verification within the same Verification sequence, (b) free-form `?` / `(what|why|how)\s+(is|are|does|do)` mid-flow with no skill active, (c) explicit `/help` — and the cooldown rule: per-signal-type, per-session, reset by a different signal-type or by explicit `/help`. Helper agent body ([`./agents/helper.md`](./agents/helper.md)) extended with a Step 1 that recognises the invoking signal and checks cooldown (silent exit if in cooldown — no `AskUserQuestion`, no preamble), and two new Constraints (cooldown rule + signal-(a) requires `lsa-specify` active per OQ4). Resolves OQ2 in [`vision/specs/features/2026-05-21-helper-agent/design.md`](../vision/specs/features/2026-05-21-helper-agent/design.md). Acknowledges OQ4 — signal (a) cannot fire outside `lsa-specify`, signals (b) and (c) always work.
- **`helper/VERIFICATION.md`** — V1/V2/V3 probe definitions for the v0.2.0 release, covering install, description-match across all three signals, and the cooldown probe per Journey 2 of [`vision/specs/features/2026-05-21-helper-agent/test-suites.md`](../vision/specs/features/2026-05-21-helper-agent/test-suites.md).
- **`.lsa.yaml`** — added `modules.helper` block with artifact paths (`agents/`, `commands/`, `knowledge/`, manifest, README, VERIFICATION) so `lsa-verify` tracks the plugin per [`CONTRIBUTING.md`](../CONTRIBUTING.md) §*"Adding a Knowledge surface"*.

## [0.1.0] – 2026-05-22

First cut. Friendly fact-grounded assistant for the NVZver marketplace — a `/help` slash command, a description-matched subagent body, and two knowledge files codifying scope + output discipline. Built in three sequential commits on `feature/2026-05-21-helper-agent-e3` per steps 1–3 of [`vision/specs/features/2026-05-21-helper-agent/tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md). Auto-engage on friction signals lands in v0.2.0.

### Added

- **Step 3 — `/help` slash command body** ([`./commands/help.md`](./commands/help.md)). Replaces the step-1 stub with a thin shell that always dispatches to `Skill(helper)`. With an argument (`/help <question>`), the argument is the user's question. Without an argument, opens an `AskUserQuestion` picker offering 3 starter topics (install / pick a skill / explain a concept), then dispatches with the picked topic as a seed question. Command body never answers questions itself — the Helper agent owns the full discipline.
- **Step 2 — Helper agent body** ([`./agents/helper.md`](./agents/helper.md)). Replaces the step-1 stub with the full Actor body (Goal / Input / Steps / Output / Constraints per [`core/actor-template`](../core/skills/actor-template/SKILL.md)). Reads sources in scope order, composes ≤1.5-screen cited responses, hands off to other skills under explicit `AskUserQuestion` confirmation (`lsa-specify` for new features, `lsa-discover` for bugs), says `"I cannot verify this."` rather than fabricating. Tools: `Read`, `Grep`, `Glob`, `AskUserQuestion`, `Skill`, `context7` MCP for external library docs. Deliberately omits `Agent` (no subagent spawn) per [`design.md`](../vision/specs/features/2026-05-21-helper-agent/design.md) OQ3 resolution.
- **Two knowledge files** ([`./knowledge/output-discipline.md`](./knowledge/output-discipline.md), [`./knowledge/knowledge-scope.md`](./knowledge/knowledge-scope.md)). Output-discipline summarises the five `core/output` golden rules + Helper-specific extensions (≤1.5-screen budget, jargon re-grounding, substrate-native decisions, closing picker). Knowledge-scope defines the 3-tier read order (repo → installed plugins → `context7`), when to skip scope levels, the cannot-verify trigger, and the bounded-read budget (3–5 files per round, max 2 rounds).
- Plugin scaffold per step 1 of [`vision/specs/features/2026-05-21-helper-agent/tasks.md`](../vision/specs/features/2026-05-21-helper-agent/tasks.md). Ships: `plugin.json` at v0.1.0, this CHANGELOG, [`./README.md`](./README.md), stub `helper/commands/help.md`, stub `helper/agents/helper.md`. Repo `.claude-plugin/marketplace.json` and root `README.md` updated in the same commit per `CLAUDE.md` *"READMEs are living documents"*. V1 probe ready: `/plugin install helper@NVZver` succeeds, `helper` appears in `/plugin list`. `/help` command body and friction-signal detection land in subsequent steps (3–4); the command stub still responds with a pointer back to the spec.
