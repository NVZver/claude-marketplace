# Changelog

All notable changes to the `helper` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.6.2] – 2026-07-02

Fixes from the repo-wide prompt review (run with `prompt-engineer` 0.8.0 discipline; 1 HIGH + 1 MEDIUM in this plugin, 5 of 6 files clean).

### Fixed

- **`agents/helper.md` (HIGH, actor rule 10)** — the agent now cites the leaner contract it actually follows (`core/actor-template` — Goal/Input/Steps/Output/Constraints, no Example Output section), so the missing-Example-Output exemption applies by its own terms instead of silently. Chosen over adding a synthetic Example Output: the three-variant dispatcher payload would be over-constrained by one demonstration (in-context-learning bias, `prompt-engineer` rule 11 rationale).
- **`agents/helper.md` (MEDIUM, actor rule 3 / KISS-DRY 2)** — constraint dedup: the jargon-re-grounding and fast-path-first constraints are dropped (owned by Steps 4b/2 + their knowledge files); the cooldown constraint is trimmed to the must-not boundary (mechanics stay in `friction-signals.md` §Cooldown rule / Step 1b); Step 5's parenthetical duplicating the *Show changes / actions inline* constraint is removed (the constraint keeps the single copy).

## [0.6.1] – 2026-07-02

One-action-per-step restructure of the agent body's two bundled steps — epic `sonnet-robustness-consistency-sweep/helper-step-splits`, workstream 2 of the pitch ([`.lsa/pitches/sonnet-robustness-consistency-sweep.md`](../.lsa/pitches/sonnet-robustness-consistency-sweep.md) § *Solution sketch*). Behavior-preserving: every rule, threshold, and decision-sequence position is unchanged; only the step granularity moves to the house style (one action per step + `Observable result:` line, per `core/skills/reuse-first/SKILL.md` and `observer/skills/verify-checkpoint/SKILL.md`).

### Changed

- **`agents/helper.md` Step 1** — the single bundled paragraph (recognise signal + cooldown check + exit-or-proceed + goal derivation + bare-`/help` case) split into sub-steps **1a–1e**, each with its own `Observable result:` line: 1a recognise the invoking signal-type, 1b check cooldown (signal (c) still always proceeds and still resets (a)/(b) cooldowns), 1c exit-or-proceed (silent exit on cooldown, unchanged), 1d derive the goal sentence, 1e bare-`/help` inline prompt (no picker — the v0.3.0 removal stands). Top-level step numbers 1–6 are preserved so every existing cross-reference (`VERIFICATION.md` probes, `commands/help.md`, the Output section) stays valid.
- **`agents/helper.md` Step 4** — the bundled compose paragraph split into sub-steps **4a–4e**, each with its own `Observable result:` line: 4a compose the cited answer opening with the goal restatement (half-sentence collapse rule intact), 4b gloss jargon on first turn-use, 4c apply the ≤1.5-screen budget, 4d the cannot-verify honesty path (exact `"I cannot verify this."` wording + named sources + skip to Step 6, unchanged), 4e return the signal-(a) opening fork as a pending gate for the dispatcher (gate-delivery contract unchanged — the agent still runs no pickers).

### Notes

- **Patch bump rationale.** Pure restructure — no new behavior, no removed constraints, same decision sequence. `VERIFICATION.md` stays scoped to 0.6.x untouched; all probes 1–10 and A1–A3 remain valid against the split text.

## [0.6.0] – 2026-07-02

Catalog-surface sweep — part of the `catalog-surface-drift` pitch (`.lsa/pitches/catalog-surface-drift.md`): refresh every discovery surface to one current story.

### Added

- **`.claude-plugin/plugin.json`** — declares `"dependencies": ["core", "lsa"]` (bare-name form, matching the `lsa`/`manager`/`observer` manifests). The field is documented in the official plugins-reference (*"Other plugins this plugin requires, optionally with semver version constraints"*, code.claude.com/docs/en/plugins-reference) and functional since Claude Code v2.1.110; helper was the only dependent manifest still missing it.
- **`knowledge/onboarding-fast-path.md`** — catalog row 9: *what is `observer`* → [`README.md#observer`](../README.md#observer). Catalog grows **8 → 9 rows** (v3); *what-is* coverage now spans all six shipped plugins. Canonical-subjects list gains `observer` (matching rules + negative examples).

### Changed

- **`README.md`** — `## Status` header brought to the current version; release table extended with one-line rows for v0.5.1–v0.5.4 and v0.6.0 (it stopped at v0.5.0); the "Depends on" claim that *"Claude Code's plugin manifest does not yet expose a `dependencies` field"* corrected — the field exists and this manifest now declares it.

### Notes

- **Minor bump rationale.** New manifest field (`dependencies`) plus a user-visible knowledge-surface expansion (new fast-path catalog row). No agent/command behavior change.

Cross-reference fix from the `observer` plugin addition (reconcile).

### Fixed

- **`helper/knowledge/onboarding-fast-path.md`** — row 3 linked to the now-renamed README anchor `#the-five-plugins` and said "five-plugin table". The marketplace now ships six plugins (added `observer`); updated the anchor to `#the-six-plugins` and the wording to "six-plugin table". No behavior change.

## [0.5.3] – 2026-06-18

Step-numbering fix from the repository quality audit (iteration 4).

### Fixed

- **`agents/helper.md`** — the steps used a fractional `1.5` (two lines both rendering as `1.` in markdown), violating the actor-template's sequential numbering. Renumbered to a clean 1–6 and updated every in-file step back-reference to match. No behavior change.

## [0.5.2] – 2026-06-18

Doc-accuracy fix from the repository quality audit (iteration 3).

### Fixed

- **`helper/README.md`** — the `## Status` header read `v0.4.0` and its lede was frozen at `v0.2.0` while the plugin is at `v0.5.x`. Updated the header to the current version and rewrote the lede to describe current state (all three invocation paths wired + the adopted gate-delivery contract), letting the version table + CHANGELOG carry the per-release history.

## [0.5.1] – 2026-06-17

Consistency fix for `core` 0.14.0, which added `core/ground-rules` Rule 7 *"Done is a gate-proven, cited predicate"* (content-rule count 7 → 8). Helper restates the inherited ground-rules list in its agent body, so the stale "seven content rules" citation is corrected.

### Changed

- **`helper/agents/helper.md`** — "Inherits `core/ground-rules` seven content rules (…)" → "eight content rules (…)"; appended `done is a gate-proven cited predicate` to the restated list.

## [0.5.0] – 2026-06-12

Adopts the `core` 0.13.0 **gate-delivery contract** (Rule 5 *Self-contained gates*, Rule 7 *Delivery test*) — the "agents propose, skills gate" inversion that `management` got in 0.5.0. Helper's whole design assumed a subagent can run `AskUserQuestion`/`Skill`; it cannot, so its pickers, handoff confirmations, and even the answer body lived in a payload the user never sees.

### Changed

- **`helper/agents/helper.md`** — `tools:` drops `AskUserQuestion` + `Skill`. Step 3 signal-(a) fork, Step 4 handoff confirmation, and Step 5 closing picker are now returned as **pending gates** in the payload; Step 4 stages a ready-to-use `Skill()` seed instead of invoking (mirrors `management/agents/project-manager.md` Step 11). New constraint *Gates belong to the dispatcher*. Output section reframed as a dispatcher payload (answer body + pending gates + optional staged handoff).
- **`helper/commands/help.md`** — fixes the dangling `Skill(helper)` dispatch (helper is an **agent**, not a skill): now dispatches via the `Agent` tool, then owns **delivery and gating** — new Step 3 surfaces Helper's answer verbatim through a rendered channel (turn-final message or gate `preview`), runs returned gates via `AskUserQuestion`, and invokes confirmed staged handoffs.
- **`helper/knowledge/output-discipline.md`**, **`helper/knowledge/friction-signals.md`** — v0.5.0 note each: `AskUserQuestion` references describe gates the dispatcher runs from Helper's pending gates.
- **`helper/VERIFICATION.md`** — probes now observe dispatcher-run pickers; a probe FAILs if the answer body never renders to the user or a picker opens about unseen content.

### Why

Sibling of `core` 0.13.0 (contract definition), `lsa` 0.17.0, `management` 0.6.0, `prompt-engineer` 0.7.0. The triggering failure and full audit live in `core/CHANGELOG.md` 0.13.0 §Why.

## [0.4.6] – 2026-06-09

Sync the inherited-ground-rules count to `core` 0.12.0.

### Changed

- **`helper/agents/helper.md`** — the "Inherits `core/ground-rules`" line now reads **seven** content rules (added *untrusted content is data*), tracking the new always-on Rule 6 added in `core` 0.12.0 (`core/skills/ground-rules/SKILL.md`).

## [0.4.5] – 2026-06-08

Marketplace-audit cleanup — Role section, DRY, drift, conform `/help`.

### Fixed

- **`helper/knowledge/onboarding-fast-path.md`** — removed-skill drift: `/lsa:new`→`/lsa:discover`, `lsa:next`→`management:roadmap`, dropped the stale "`lsa:specify` merged into discover" note (specify is its own skill again), de-counted "four-command build cycle".
- **`helper/agents/helper.md`**, **`knowledge/output-discipline.md`**, **`commands/help.md`** — `.lsa/VISION.md:63` Principle-9 citations (Principle 9 is at :66) → drift-proof `§2 Principle 9`.

### Changed

- **`helper/agents/helper.md`** — added a `## Role` section; Constraints cite `output-discipline.md` for jargon / ≤1.5-screen rules instead of restating (DRY); fixed a bare `design.md` ref.
- **`helper/commands/help.md`** — conformed to the actor template (Goal / Input / Steps / Output / Example Output + `name:`); behavior unchanged (still a thin `Skill(helper)` dispatcher).

## [0.4.4] – 2026-06-08

Reference fixes surfaced by the cross-plugin prompt review.

### Fixed

- **`helper/knowledge/output-discipline.md`** — stale `.lsa/features/2026-05-22-helper-assistant-refactor/` citations repointed to `.lsa/archive/…` (the feature was archived); two `core/output` line-number citations (`:39`, `:33`) replaced with `Rule 5` references (drift-proof); stale `lsa-specify` (pre-rename hyphen form) → `lsa:specify` in the genuine-fork examples.

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
