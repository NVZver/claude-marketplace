# Changelog

All notable changes to the `helper` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.4.3] – 2026-06-02

Re-ground the output-discipline adherent to the new `core/output` posture.

### Changed

- **`knowledge/output-discipline.md`** — heading "The seven golden rules" → "Output rules (`core/output`) — one hard, six guidance"; the ≤1.5-screen budget note no longer re-promotes the guidance Rule 2 to "hard" (Helper holds it firm as its own convention, but flags it as guidance at the marketplace layer). Tracks the `core` v0.11.0 hard-vs-guidance split.

## [0.4.2] – 2026-06-02

Show-changes / actions-inline cite for Helper.

### Changed

- **`helper/agents/helper.md`** — Step 4 and a new Constraints bullet require handoff actions and surfaced facts to be named with their concrete effect inline before the verdict, per `core/output` Rule 7; never a bare "done" / "handed off". Clarifies that Helper is read-only (no file-write obligation — it has no Write/Edit tool, per `friction-signals.md:48`).

## [0.4.1] – 2026-06-02

Fast-path catalog back-cite + roadmap-navigation routing.

### Changed

- **`knowledge/onboarding-fast-path.md`** — added a back-cite to the new `core/knowledge/fast-path-source-of-truth.md` (Helper's catalog is the first shipped instance of that pattern), plus a "what's next" negative example that routes roadmap-navigation questions to `lsa:next` rather than a deep read. Resolves the fast-path pitch's Open Question #1: the catalog had no missing navigation-class onboarding row — "what's next" is a deliberately separate fast-path owned by `lsa:next` / `management:roadmap`. Catalog stays at 8 rows; no agent-behavior change.

## [0.4.0] – 2026-05-28

Onboarding fast-path catalog expansion + heading-anchor citation migration. Stage 1 / Epic 2 of the `readme-and-knowledge-base` pitch (see [`.lsa/pitches/readme-and-knowledge-base.md`](../.lsa/pitches/readme-and-knowledge-base.md)).

### Added

- **`knowledge/onboarding-fast-path.md`** — two new catalog rows: row 7 *what is `management`* and row 8 *what is `prompt-engineer`*. Catalog grows from v1's 6 rows to v2's 8 rows; *what-is* coverage now spans all five shipped plugins. Fast-path resolves these subjects in seconds instead of falling through to deep-read.

### Changed

- **`knowledge/onboarding-fast-path.md`** — citation format migrated from `file:line-range` (e.g., `README.md:73-83`) to `file#heading-anchor` (e.g., `README.md#install`). Heading anchors survive line shifts; line-range citations broke silently every time the target file was edited. The new repo-root [`knowledge/index.md`](../knowledge/index.md) becomes the single source of truth for heading names — any rename in `README.md` must update both files in the same commit.
- **`knowledge/onboarding-fast-path.md`** — canonical-subjects list expanded from {`marketplace`, `core`, `lsa`, `helper`} to {`marketplace`, `core`, `lsa`, `helper`, `management`, `prompt-engineer`}, reflecting the five shipped plugins.
- **`.claude-plugin/plugin.json`** and **`agents/helper.md`** (description frontmatter + Step 1.5 / Step 2 body) — citation wording tightened to match the migration: "`file:line` (or URL) citations" → "file citations (line range, heading anchor, or URL)"; Step 1.5 now correctly describes the catalog as mapping to heading-anchor excerpts (was `file:line`).

### Fixed

- **`knowledge/onboarding-fast-path.md`** — stale path references corrected: `lsa/ARCHITECTURE.md §4.10` → `§3` (the `.lsa.yaml` config section is §3); `lsa/skills/lsa-verify/SKILL.md` → `lsa/skills/verify/SKILL.md` and `lsa/skills/lsa-specify/SKILL.md` → `lsa/skills/discover/SKILL.md` (renames from `lsa` v0.8.0 prefix drop + `specify`-into-`discover` merge).
- **`knowledge/onboarding-fast-path.md`** — `./knowledge-scope.md:13` line-anchored citation replaced with bare-path citation (line number was stale).
- **Dead-spec link sweep (plugin-wide).** Cleared all broken references left by the `vision/ → .lsa/` migration (`d1ba7a7`), completing what v0.3.2 began: moved-spec links repointed `.lsa/features/` → `.lsa/archive/` for `2026-05-22-helper-assistant-refactor` and `-onboarding-fast-path` (`README.md`, `CHANGELOG.md`); the **deleted** `2026-05-21-helper-agent` spec (no archive — absorbed into [`../.lsa/modules/helper/spec.md`](../.lsa/modules/helper/spec.md)) delinked across `README.md`, `agents/helper.md`, `VERIFICATION.md`, `knowledge/knowledge-scope.md`, `knowledge/friction-signals.md`, and the historical `CHANGELOG.md` entries — home references now point to the module spec, deep AC/OQ/Journey citations delinked to plain text.

## [0.3.2] – 2026-05-27

Prompt audit remediation — cross-reference fixes and knowledge deduplication.

### Fixed

- **`agents/helper.md`**, **`knowledge/friction-signals.md`**, **`knowledge/knowledge-scope.md`** — removed 4 dead links to deleted `vision/specs/features/2026-05-21-helper-agent/` spec (replaced with descriptive text).
- **`knowledge/onboarding-fast-path.md`** — fixed spec path `features/` → `archive/` for `2026-05-22-helper-onboarding-fast-path`.
- **`knowledge/output-discipline.md`** — fixed spec path `features/` → `archive/` for `2026-05-22-helper-assistant-refactor`.
- **`README.md`**, **`VERIFICATION.md`** — fixed dead spec links (same pattern).

### Changed

- **`agents/helper.md`** — removed restated knowledge from Steps (cooldown logic, onboarding matching, genuine-fork test) and Constraints (5 duplicated rules → 1 convention reference). Steps now cite knowledge files by path. Removed duplicate "Inherits core/output" from frontmatter description.

### Added

- **`agents/helper.md`** — Example Output section (previously missing, flagged HIGH by audit rule A10).

## [0.3.1] – 2026-05-24

### Changed

- **Agent body Step 5 citation upgraded** ([`./agents/helper.md`](./agents/helper.md)) — *"genuine-fork test"* now cites [`core/skills/output/SKILL.md`](../core/skills/output/SKILL.md) Rule 5 (*Concrete — Genuine-fork test*) as the canonical source; the local [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md) § *Genuine fork — operating definition* is referenced as a re-grounded summary. Step 5 wording itself unchanged. Per [`.lsa/features/2026-05-22-askuserquestion-audit/`](../.lsa/features/2026-05-22-askuserquestion-audit/) Epic C — closes the helper-side call-site audit.

## [0.3.0] – 2026-05-24

Two bundled changes: (1) **Answer-first refactor** — Helper from command-router to assistant; default reply becomes a direct cited answer in Helper's voice opening with a one-sentence goal restatement, the closing `AskUserQuestion` becomes conditional on a "genuine fork" remaining after the answer, and bare `/help` no longer opens a 3-option starter-topic picker (Helper prompts inline instead). Targets the *"Helper-as-phone-tree"* symptom per [`.lsa/roadmap.md:104-108`](../.lsa/roadmap.md). Spec at [`.lsa/features/2026-05-22-helper-assistant-refactor/`](../.lsa/archive/2026-05-22-helper-assistant-refactor/). (2) **Onboarding fast-path** — Helper short-circuits to README excerpts for *install / start / what-is-X / how-do-I-run* patterns. Latency target ≤5s wall-clock for catalog-matched questions vs. ~3min deep-research baseline (user-reported, 2026-05-22). New Knowledge file [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md) holds the 6-row catalog; new Step 1.5 in [`./agents/helper.md`](./agents/helper.md) wires it into the agent. Spec at [`.lsa/features/2026-05-22-helper-onboarding-fast-path/`](../.lsa/archive/2026-05-22-helper-onboarding-fast-path/). Bundled per user decision 2026-05-23. Standard flow.

### Changed

- **Agent body Steps 1, 3, 5 reshaped** ([`./agents/helper.md`](./agents/helper.md)). Step 1 gains a goal-restatement sub-step ("You want to: [install / learn X / find a skill / start a flow / fix Y]"). Step 3 prefixes the answer with the Step 1 sentence (or collapses to a half-sentence prefix for one-word factual questions). Step 5 becomes conditional: clean end when the answer fully resolves the question; `AskUserQuestion` only when a genuine fork remains (destructive action, two architecturally equivalent options, missing input the agent cannot infer, or per-row triage at scale). Steps 2 and 4 unchanged. Each Step preserves its observable-result line per [`core/skills/actor-template/SKILL.md`](../core/skills/actor-template/SKILL.md).
- **Agent description frontmatter** ([`./agents/helper.md`](./agents/helper.md)) — tail clause *"`AskUserQuestion` for every decision"* replaced with *"`AskUserQuestion` only for genuine forks"*.
- **Bare `/help` no-argument behavior** ([`./commands/help.md`](./commands/help.md)). Removed the 3-option `AskUserQuestion` starter-topic picker (install / pick a skill / explain a concept). The command now dispatches `Skill(helper)` with an empty argument; Helper's Step 1 emits a one-sentence inline prompt in Helper's voice inviting the user to state their question. The starter-topic phrasings migrated to [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md) § *Starter-topic examples* as illustrative examples — not a runtime fork.
- **Command description frontmatter** ([`./commands/help.md`](./commands/help.md)) — *"opens a 3-option starter-topic picker"* replaced with *"dispatches to Helper; if no argument, Helper prompts inline for the question"*.
- **Output discipline closing-picker rule** ([`./knowledge/output-discipline.md`](./knowledge/output-discipline.md)) — *"Every response (except `Skill()` handoff) closes with `AskUserQuestion`"* replaced with *"Close with `AskUserQuestion` only when a genuine fork remains after the answer ... Otherwise end cleanly."*
- **`helper/README.md:8` default-flow phrasing** — *"`AskUserQuestion` for every decision"* replaced with *"`AskUserQuestion` for every **genuine fork** — destructive actions, real choices, missing inputs"*. Per [`CLAUDE.md`](../CLAUDE.md) §*"Discipline (sourced)"* (*"READMEs are living documents"*).
- **Constraints bullet added to [`./agents/helper.md`](./agents/helper.md)** — *"Fast-path-first for onboarding subjects."* References [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md) §`Fall-through rules`. Inserted at the end of the Constraints block; the prior 9 Constraints bullets (substrate-native, cannot-ground fallback, no-persona, cooldown, signal-(a) precondition, etc.) preserved unchanged.

### Added

- **"Genuine fork — operating definition" section** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). Four concrete tests: destructive/irreversible action, two architecturally equivalent options, missing required input the agent cannot infer, per-row triage at scale. Cites `.lsa/VISION.md:57` (Ownership over automation) and project memory `feedback_askuserquestion_overuse.md`.
- **"Goal-restatement opening" rule** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). Every response opens with a one-sentence goal restatement; for one-word factual questions a half-sentence prefix suffices. Per `requirements.md` F4 / AC3.
- **"Starter-topic examples" section** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md). The install / pick-a-skill / explain-a-concept phrasings migrated from `helper/commands/help.md` as illustrative content, not a runtime picker.
- **"What violates discipline" bullet** in [`./knowledge/output-discipline.md`](./knowledge/output-discipline.md): *"A response that opens with `AskUserQuestion` instead of a cited answer (except cannot-verify per `helper/agents/helper.md` Step 3)."*
- **v0.3.0 row** in the status table of [`./README.md`](./README.md).
- **New Knowledge file [`./knowledge/onboarding-fast-path.md`](./knowledge/onboarding-fast-path.md)** — 6-row catalog mapping onboarding triggers (install / start with LSA / what-is + {marketplace, core, lsa, helper}) to README excerpts with `file:line-range` citations, plus matching rules, negative examples, and fall-through rules. Catalog is data — adding a new onboarding pattern does not require editing [`./agents/helper.md`](./agents/helper.md). Per [`.lsa/features/2026-05-22-helper-onboarding-fast-path/requirements.md`](../.lsa/archive/2026-05-22-helper-onboarding-fast-path/requirements.md) F6 / NF5 (Knowledge vs Actor separation).
- **New Step 1.5 in [`./agents/helper.md`](./agents/helper.md)** — *Onboarding fast-path*. Inserted between existing Step 1 (cooldown check) and Step 2 (scope-order read). Insertion-style: existing Steps 2 / 3 / 4 / 5 keep their numbers and bodies; the *"skip to Step 5"* note at line 34 stays valid. On catalog match, Step 1.5 reads the cited excerpt and proceeds directly to Step 5; on no match, falls through to Step 2 unchanged. No `Grep`, no `Glob`, no `context7` in Step 1.5.

### Notes

- **Minor bump rationale.** User-visible default-flow change (the picker stops being mandatory; bare `/help` shape changes). Underlying capabilities are unchanged — still cited, still ≤1.5 screens, still `AskUserQuestion` as the picker primitive *when a picker is appropriate*. Per [`.lsa/main.spec.md:32`](../.lsa/main.spec.md) NFR3.
- **Existing Constraints bullets preserved.** Feature 1 (assistant refactor) explicitly preserved all 9 prior Constraints bullets in `./agents/helper.md` — substrate-native, cannot-ground fallback, no-persona, cooldown, signal-(a) precondition, etc. Feature 2 (onboarding fast-path) adds one new bullet ("Fast-path-first for onboarding subjects") at the end of the block; the original 9 are byte-identical. Per feature-1 `tasks.md` Task 1.4 + feature-2 `tasks.md` Task 2.
- **`core/output` confirmed untouched.** The "closing picker every turn" rule never lived in [`core/skills/output/SKILL.md`](../core/skills/output/SKILL.md); it was a Helper-specific extension at [`./knowledge/output-discipline.md:20`](./knowledge/output-discipline.md). `core/output` Rule 5 (*"Pickers surface only choices that change the outcome"*, `core/skills/output/SKILL.md:33`) is consistent with this refactor — no `core/` edit needed. Resolves OQ2 in [`.lsa/features/2026-05-22-helper-assistant-refactor/design.md`](../.lsa/archive/2026-05-22-helper-assistant-refactor/design.md).
- **Fast-path latency target ≤5s wall-clock** per [`.lsa/features/2026-05-22-helper-onboarding-fast-path/requirements.md`](../.lsa/archive/2026-05-22-helper-onboarding-fast-path/requirements.md) NF1. Framed as a target, not a hard merge gate — LLM tool-loop floors are non-deterministic. Measured manually via Journey 1 probe; >5s with otherwise-correct response body is recorded but does not block merge. ≤3 `Read` calls (catalog + one or two READMEs), no `Grep` / `Glob` / `context7` in Step 1.5.
- **Surface-divergence correction.** Roadmap row #2 (`.lsa/roadmap.md:116`) named `helper/skills/helper/SKILL.md` as the classifier home; that path does not exist. The classifier ships at the real surface: Knowledge file `helper/knowledge/onboarding-fast-path.md` (catalog) + Step 1.5 in `helper/agents/helper.md` (invocation). Roadmap row amended in same PR.

## [0.2.1] – 2026-05-22

File-load trace adoption. The Helper agent body, the `/help` command, and all 3 `helper/knowledge/*.md` files carry the new one-line trace directive at their top, per `core` v0.5.4 Rule 4 (Sourced) → *File-load trace*. On load, each file prints `=============== [<file>] [helper] ===============` verbatim. Replaces the v0.5.3 `[plugin:skill]` marker scheme. Per user request 2026-05-22. Quick flow.

### Added
- **Trace directive in 5 files** — `helper/agents/helper.md`, `helper/commands/help.md`, `helper/knowledge/friction-signals.md`, `helper/knowledge/knowledge-scope.md`, `helper/knowledge/output-discipline.md`. Hardcoded path + plugin name in each.

### Notes
- **Patch bump rationale.** No Helper behavior change — same friction-signal detection, same cooldown rule, same response discipline. Only the on-load trace output is new.

## [0.2.0] – 2026-05-22

Friction-signal detection + cooldown. Helper now auto-engages on the three signals defined in step 4 of the original helper-agent spec (Epic 4), with per-signal-type cooldown to prevent nag.

### Added

- **Step 4 — Friction-signal detection + cooldown.** New knowledge file [`./knowledge/friction-signals.md`](./knowledge/friction-signals.md) defines the three signals — (a) two consecutive `[c] reject` at any `lsa-specify` User Verification within the same Verification sequence, (b) free-form `?` / `(what|why|how)\s+(is|are|does|do)` mid-flow with no skill active, (c) explicit `/help` — and the cooldown rule: per-signal-type, per-session, reset by a different signal-type or by explicit `/help`. Helper agent body ([`./agents/helper.md`](./agents/helper.md)) extended with a Step 1 that recognises the invoking signal and checks cooldown (silent exit if in cooldown — no `AskUserQuestion`, no preamble), and two new Constraints (cooldown rule + signal-(a) requires `lsa-specify` active per OQ4). Resolves OQ2 in the original helper-agent design. Acknowledges OQ4 — signal (a) cannot fire outside `lsa-specify`, signals (b) and (c) always work.
- **`helper/VERIFICATION.md`** — V1/V2/V3 probe definitions for the v0.2.0 release, covering install, description-match across all three signals, and the cooldown probe per Journey 2 of the original helper-agent test-suites.
- **`.lsa.yaml`** — added `modules.helper` block with artifact paths (`agents/`, `commands/`, `knowledge/`, manifest, README, VERIFICATION) so `lsa-verify` tracks the plugin per [`CONTRIBUTING.md`](../CONTRIBUTING.md) §*"Adding a Knowledge surface"*.

## [0.1.0] – 2026-05-22

First cut. Friendly fact-grounded assistant for the NVZver marketplace — a `/help` slash command, a description-matched subagent body, and two knowledge files codifying scope + output discipline. Built in three sequential commits on `feature/2026-05-21-helper-agent-e3` per steps 1–3 of the original helper-agent spec. Auto-engage on friction signals lands in v0.2.0.

### Added

- **Step 3 — `/help` slash command body** ([`./commands/help.md`](./commands/help.md)). Replaces the step-1 stub with a thin shell that always dispatches to `Skill(helper)`. With an argument (`/help <question>`), the argument is the user's question. Without an argument, opens an `AskUserQuestion` picker offering 3 starter topics (install / pick a skill / explain a concept), then dispatches with the picked topic as a seed question. Command body never answers questions itself — the Helper agent owns the full discipline.
- **Step 2 — Helper agent body** ([`./agents/helper.md`](./agents/helper.md)). Replaces the step-1 stub with the full Actor body (Goal / Input / Steps / Output / Constraints per [`core/actor-template`](../core/skills/actor-template/SKILL.md)). Reads sources in scope order, composes ≤1.5-screen cited responses, hands off to other skills under explicit `AskUserQuestion` confirmation (`lsa-specify` for new features, `lsa-discover` for bugs), says `"I cannot verify this."` rather than fabricating. Tools: `Read`, `Grep`, `Glob`, `AskUserQuestion`, `Skill`, `context7` MCP for external library docs. Deliberately omits `Agent` (no subagent spawn) per the original helper-agent design OQ3 resolution.
- **Two knowledge files** ([`./knowledge/output-discipline.md`](./knowledge/output-discipline.md), [`./knowledge/knowledge-scope.md`](./knowledge/knowledge-scope.md)). Output-discipline summarises the five `core/output` golden rules + Helper-specific extensions (≤1.5-screen budget, jargon re-grounding, substrate-native decisions, closing picker). Knowledge-scope defines the 3-tier read order (repo → installed plugins → `context7`), when to skip scope levels, the cannot-verify trigger, and the bounded-read budget (3–5 files per round, max 2 rounds).
- Plugin scaffold per step 1 of the original helper-agent spec. Ships: `plugin.json` at v0.1.0, this CHANGELOG, [`./README.md`](./README.md), stub `helper/commands/help.md`, stub `helper/agents/helper.md`. Repo `.claude-plugin/marketplace.json` and root `README.md` updated in the same commit per `CLAUDE.md` *"READMEs are living documents"*. V1 probe ready: `/plugin install helper@NVZver` succeeds, `helper` appears in `/plugin list`. `/help` command body and friction-signal detection land in subsequent steps (3–4); the command stub still responds with a pointer back to the spec.
