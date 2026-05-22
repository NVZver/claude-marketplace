# Changelog

All notable changes to the `core` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

## [0.5.5] — 2026-05-22

DRY pass on `core/output` golden-rules citation. Two sites stop restating the rule list inline and cite by section instead, per `CONTRIBUTING.md:146` (*"don't inline a table or rule that's already canonical elsewhere; cite by file + section instead"*). Also fixes a stale skill name in `output-vocabulary.md` left over from the v0.5.2 `tier-selector` → `flow-selector` rename. Per repo lint audit 2026-05-22 findings H2 (`core` site) + L2. Quick flow.

### Changed
- **`core/skills/flow-selector/SKILL.md:68`** — Constraint line `- Outputs follow [\`../output/SKILL.md\`](../output/SKILL.md) golden rules (structured, minimal, formatted, sourced).` → `- Outputs follow the five golden rules in [\`../output/SKILL.md\`](../output/SKILL.md).` The dropped 4-item enumeration silently omitted Rule 5 *"concrete"* — both DRY restatement and a count drift versus the canonical 5 at `core/skills/output/SKILL.md:3`.
- **`core/knowledge/output-vocabulary.md:5`** — fixed stale skill name `tier-selector confirms` → `flow-selector confirms` (renamed in `core` v0.5.2 per `vision/VISION.md:119`). Dropped redundant `Pure constants — Knowledge, not Actor.` self-tag — the H1 already declares `— Knowledge`.

### Notes
- **Patch bump rationale.** No behavior change — cite-form fix and a stale-name correction. Canonical rule list at `core/skills/output/SKILL.md` is unchanged.
- **Sibling release** — `lsa` v0.6.5 trims the same DRY pattern across 8 LSA skill bodies + `ARCHITECTURE.md`; `helper` v0.2.2 trims the helper agent's frontmatter.

## [0.5.4] — 2026-05-22

File-load trace patch. Replaces the v0.5.3 single-line `[plugin:skill]` marker — which did not give the human enough signal about which marketplace files actually shaped a turn — with a per-file trace directive hardcoded at the top of every marketplace instructional file. On load, the agent prints `=============== [<file>] [<plugin>] ===============` verbatim, one line per loaded file, in load order, before the response body. Per user request 2026-05-22 ("markers do not work … print the file name and current plugin using it"). Quick flow.

### Changed
- **`core/skills/output/SKILL.md` Rule 4 (Sourced).** *Output marker* sub-section replaced by *File-load trace*. The agent no longer prepends one `[plugin:skill]` label per response; instead, each loaded marketplace file prints its own one-line trace.
- **`core/CLAUDE.md` § Output discipline** — third operational checkpoint *Output marker (`[plugin:skill]`)* replaced by *File-load trace*. Same Rule 4 citation.
- **`core/README.md`** — `output` row description updated to reference v0.5.4 trace directive instead of the v0.5.3 marker.

### Added
- **Trace directive at the top of every marketplace instructional file** — all 4 `core/skills/*/SKILL.md`, `core/knowledge/output-vocabulary.md`. Sibling plugins (`lsa`, `helper`) and `vision/**` files apply the same directive — those bumps land in their own CHANGELOGs.

### Notes
- **Patch bump rationale.** Rule 4 still exists with the same intent (provenance for the human). Only the output form changes — one line per loaded file instead of one label per response. No new rule, no count change (stays 5 golden rules). The v0.5.3 marker did not survive a full session in practice; the trace lines do because each file enforces its own.
- **Directive placement.** For files with YAML frontmatter (`---` block), the directive lands right after the closing `---`. For files without frontmatter, it lands at the very top, before the H1.

## [0.5.3] — 2026-05-22

Output-marker patch. Adds a source-attribution marker (`[plugin:skill]`) to every substantive agent response so the human can see at-a-glance which marketplace skill is shaping the current turn vs. background model output. Per `vision/specs/roadmap.md` row *"Output marker — source-attribution prefix"* (user request 2026-05-22). Quick flow.

### Added
- `core/skills/output/SKILL.md` Rule 4 (Sourced) — new sub-section **Output marker**. Form: `[plugin:skill]`, never bare `[skill]` (e.g., `[core:output]`, `[lsa:lsa-specify]`). Placement: first line of the response, treated as a label. Pick: the most-specific *currently-active* skill — defaults to `[core:output]` when no explicit skill is invoked. Skip only for trivial one-line replies (Rule 2 wins).
- `core/CLAUDE.md` § Output discipline — third operational checkpoint **Output marker (`[plugin:skill]`)** under the existing pointer to `core/output`. Header bumped from *Two operational checkpoints* → *Three*. Cites Rule 4.

### Notes
- **No count bump.** Stays 5 golden rules — the marker rides inside Rule 4 (Sourced) as a sub-section because both concerns are forms of provenance (factual claims cite their factual source; agent responses disclose their skill source). Re-evaluate promotion to a separate Rule 6 if marker scope grows beyond a single `[plugin:skill]` label per turn.
- **Format decision.** `[plugin:skill]` always, never bare `[skill]` — selected by user via `AskUserQuestion` 2026-05-22. The alternative (`[skill]` for core, `[plugin:skill]` for plugins) was rejected for uniformity / lint-ability.

## [0.5.2] — 2026-05-22

Naming clarity patch — renames the `core/tier-selector` skill to `core/flow-selector` and replaces the `T1` / `T2` / `T3` tier labels with `Quick` / `Standard` / `Extended` across `core/CLAUDE.md`, `core/README.md`, `core/VERIFICATION.md`, the skill body, and the plugin description. Per `vision/specs/roadmap.md` row *"Rename `T1` / `T2` / `T3` → `Flow: Quick` / `Flow: Standard` / `Flow: Extended`"*. Bundle B (Naming clarity) of the 2026-05-22 fixing session.

### Changed
- **Skill rename: `core/skills/tier-selector/` → `core/skills/flow-selector/`.** Directory + frontmatter `name:` + slash-command slug (`/core:tier-selector` → `/core:flow-selector`). The skill body adopts the new vocabulary (Quick / Standard / Extended) and notes the rename at the top so existing-user lookups still resolve.
- **`core/CLAUDE.md` § Tier selection → § Flow selection.** Section heading + body language switch from `T1 / T2 / T3` → `Quick / Standard / Extended`. Each tier bullet annotates the prior name (e.g., *"Quick (was `T1`)"*) so historical references in plans, CHANGELOGs, and archive files remain interpretable.
- **`core/README.md`.** `tier-selector` row + invocation example + CLAUDE-merge note updated.
- **`core/VERIFICATION.md` Probe C** — heading + label switch; `T3` → `Extended` in the expected behavior.
- **`core/.claude-plugin/plugin.json` `description`** — `tier-selector (T1/T2/T3 chain-of-thought)` → `flow-selector (Quick/Standard/Extended chain-of-thought — renamed from tier-selector in v0.5.2)`.

### Notes
- **Breaking surface change, treated as patch.** Strictly per [SemVer §4](https://semver.org/#spec-item-4), renaming a slug is breaking. Pre-1.0 SemVer lets the maintainer's discretion shape the bump; for this personal marketplace with no external consumers, a patch is defensible. Future external consumers should pin to v0.5.1 if they rely on `/core:tier-selector` literally.
- **Historical entries left untouched.** `core/CHANGELOG.md` [0.4.1] / [0.3.0] / [0.2.0] still reference `tier-selector` and `T1 / T2 / T3` — they describe past state and the rename note in the new entries (and `core/CLAUDE.md` body) makes them traceable.
- **Sibling lsa patch** — `lsa` v0.6.2 in the same Bundle B PR sweeps the `T1/T2/T3` and `tier-selector` references throughout `lsa/` and also renames the lsa-specify "Gate N" → "User Verification N".

## [0.5.1] — 2026-05-22

Output-discipline enforcement patch. Elevates the two `core/output` rules that the user observed as routinely skipped in practice (substrate-native pickers and the response screen-budget) to always-on operational checkpoints in `core/CLAUDE.md`, and tightens `core/output` Rule 2 (Minimal) with concrete budget shape. Per `vision/specs/roadmap.md` row *"core/output discipline enforcement (AskUserQuestion + output length)"*.

### Added
- `core/CLAUDE.md` § Output discipline — two new always-on operational checkpoints under the existing pointer to `core/output`: (1) **Substrate-native pickers** — every decision-bearing prompt uses `AskUserQuestion` in Claude Code; never render `[a]/[b]/[c]` text blocks when the picker is available; (2) **1–1.5 screen budget per turn** — default ~30–50 rendered markdown lines, split decisions into separate turns, pull don't push.
- `core/skills/output/SKILL.md` Rule 2 (Minimal) — three concrete sub-bullets: 1–1.5 screen budget (verdict + single next decision above the fold), split into turns (separate decision from supporting detail), pull-don't-push (no pre-emptive option/artifact/consideration dump).

### Changed
- `core/skills/output/SKILL.md` Rule 5 heading — now reads *"Concrete (decision prompts) — prompt voice"* for memorability. The sub-bullets (subject-first, no project jargon, must-decide only, one decision per question) are unchanged.

### Notes
- **No new rules.** Both checkpoints derive from existing material — Substrate-native first is `vision/VISION.md` §2 principle 9 (already cited in `core/ground-rules` Rule 0); the screen budget is implicit in Rule 2's *"every line earns its place"*. This patch lifts both from "implicit" to "always-on" because the user observed them routinely skipped.
- **Sibling LSA patch.** `lsa` v0.6.1 ships in the same Bundle A PR — applies the prompt-voice scaffolding inside `lsa-specify` / `lsa-plan` / `lsa-init` gate prompts so the user-facing pickers stop using `Gate N` / `F<n>` / `epic decomposition` jargon.
- Sibling rename PRs (Gate N → User Verification; T1/T2/T3 → Flow) land in Bundle B.

## [0.5.0] — 2026-05-21

Adds **Rule 5 (Concrete)** to `core/output` — decision-prompt voice discipline. Surfaced during Help-agent-persona refinement (2026-05-21) when the user flagged LSA gates as unusable: *"I have no IDEA what it means…wording is too…i don't know, it just means nothing to me…I want concrete questions to make decisions with clear problem to solve. I do not give a fuck about minor things."* Per `vision/specs/roadmap.md` row *"LSA gate prompts must be concrete"* (Must priority).

### Added
- `core/skills/output/SKILL.md` **Rule 5 — Concrete (decision prompts)** with four sub-bullets: subject-first (resolve `F3`/`AC2`/`OQ5` to the real-world subject in prompts; IDs stay in files), no project jargon (`contract-trigger`, `Hard Confirm`, `diagonal coverage` stay in skill bodies, not prompts), must-decide only (bundle consistency checks; surface only outcome-changing choices), one decision per question.

### Changed
- `core/.claude-plugin/plugin.json` `description` — `output (4 format golden rules — structured, minimal, formatted, sourced)` → `output (5 format golden rules — structured, minimal, formatted, sourced, concrete)`.
- Live citations of "four golden rules" updated to "five golden rules" across `core/CLAUDE.md`, `core/skills/ground-rules/SKILL.md`, `core/tests/repo-anchored.md`, repo `README.md`, `vision/VISION.md`, `lsa/README.md`, `lsa/ARCHITECTURE.md`. Historical references (older CHANGELOG entries, archived plans) left as-is — they describe past state.

### Notes
- **Behavior change, not a refactor.** Existing `AskUserQuestion` calls across `lsa/skills/*/SKILL.md` do not yet conform to Rule 5 (they reference `F1` / `Hard Confirm` / etc.). The new rule will surface their non-conformance immediately. Follow-up sweep tracked in `vision/specs/roadmap.md` row *"LSA gate prompts must be concrete"*.
- Sibling LSA work is queued, not blocking: the "Gate N → User Verification" rename (`vision/specs/roadmap.md`) and "T1/T2/T3 → Flow: Quick/Standard/Extended" rename land together with the prompt-voice sweep.

## [0.4.1] — 2026-05-21

Credo rollout PR 2 — `core/tier-selector` adopts its component-specific output format that satisfies `core/output` golden rules. Patch bump: skill contract unchanged (still proposes tier + waits for human confirm); only the render format updates. Per [`vision/plans/2026-05-20-credo-rollout-plan.md`](../vision/plans/2026-05-20-credo-rollout-plan.md) Layer 2.

### Changed
- `core/skills/tier-selector/SKILL.md` Step 4 — confirm prompt describes data + decision options + outcomes inline; defers format to `core/output` (no embedded template). `AskUserQuestion` is the canonical decision primitive in Claude Code.
- `core/skills/tier-selector/SKILL.md` Constraints — adds one citation line: *"Outputs follow `core/output` golden rules."*
- `core/skills/tier-selector/SKILL.md` footer — updated to mention both `core/ground-rules` (content) and `core/output` (format) as the two always-on disciplines.

### Notes
- No behavior change. The boundary signals + tier-classification logic + wait-for-confirm gate are unchanged.
- Sibling LSA-skill refit ships as `lsa` v0.4.0 (PR 2) and Vision v0.6.

## [0.4.0] — 2026-05-21

Codifies the user-authored credo *"LSA doesn't automate your thinking — it makes you own it."* with a DRY/KISS/SRP-clean structure. Extends `ground-rules` 4 → 6 content rules; extracts output discipline to a new dedicated skill; lifts the verdict vocabulary to a new Knowledge surface. Per [`vision/plans/2026-05-20-credo-rollout-plan.md`](../vision/plans/2026-05-20-credo-rollout-plan.md) PR 1 (audit-C restructure). Corresponds to Vision v0.5 (`vision/VISION.md` changelog).

### Added
- **NEW skill `core/skills/output/SKILL.md`** — single source of truth for output discipline. Four golden rules: (1) Structured, (2) Minimal, (3) Formatted, (4) Sourced (cites `core/ground-rules` Rule 1). Every other skill / agent / artifact cites this; nothing restates it. Body ≤30 lines.
- **NEW Knowledge surface `core/knowledge/output-vocabulary.md`** — 10-row verdict label table (`PROPOSED` / `READY` / `PASS` / `PASS WITH WARNINGS` / `FAIL` / `BLOCKED` / `DRIFT` / `CLEAN` / `APPLIED` / `REJECTED`) lifted out of any Actor body (SRP). Components whose chosen format uses a verdict line cite this surface by section name.
- `core/skills/ground-rules/SKILL.md` Rule 0 — *Ownership over automation* (the human owns the thinking; surfaces facts, lays out options, demands a choice). Per `vision/VISION.md:60`.
- `core/skills/ground-rules/SKILL.md` Rule 5 — *No filler* (every sentence carries a fact, an owned opinion, or an action).
- `core/skills/ground-rules/SKILL.md` Rule 1 amendments — *Scope* (every artifact, no draft exception) + *Illustrative content* (placeholder references tagged `[illustrative]`).
- `core/skills/ground-rules/SKILL.md` footer — back-reference to `core/output` (makes the cross-link bidirectional alongside output's existing cite to ground-rules Rule 1).
- `core/VERIFICATION.md` — **Probe D (output)** — single composed probe testing all four golden rules together (NOT per-rule).
- `core/tests/repo-anchored.md` — A5 (Rule 0 Ownership) + A6 (Rule 5 No filler) + new Set D = D1 (output composed test against `core/.claude-plugin/plugin.json`).
- `.lsa.yaml` `modules.core.artifact_paths` — added `core/knowledge/**/*.md` to track the new Knowledge surface (matches the lsa-side pattern).

### Changed
- `core/skills/ground-rules/SKILL.md` frontmatter `description:` — *"four rules"* → *"six content rules"* (enumerated).
- `core/CLAUDE.md` — collapsed from a per-rule restatement to ~3 pointer lines (one per always-on skill: ground-rules + output + tier-selector). No rule enumeration. Audit-C C5 — eliminates the DRY violation introduced by an earlier draft.
- `core/README.md` — `ground-rules` row: *"6 content rules — see `core/CLAUDE.md`."* Added new `output` row: *"4 format golden rules — see `core/CLAUDE.md`."* `/core:output` added to the invocation list.
- `core/tests/repo-anchored.md` A3 — expected count updated 4 → 6 with the six headings listed.
- `core/.claude-plugin/plugin.json` `description` — rewritten to enumerate the four skills (ground-rules + output + actor-template + tier-selector), not individual rules. Audit-C C7.
- `CLAUDE.md` (repo root) — appends pointers to `core/output` + the credo, alongside the existing ground-rules + tier-selector citation.

### Notes
- The *"What this skill never does"* section is deliberately NOT re-added to `ground-rules` — the 0.3.0 refactor removed it as a Knowledge-vs-Actor violation; re-adding would reverse that refactor.
- This is an audit-C restructure of an earlier PR-1 attempt (commits `3dc1828` + `53d7c58`) that violated `CONTRIBUTING.md` DRY/KISS/SRP by adding format rules (Rules 6/7) into `ground-rules` and restating the 8 rules in `core/CLAUDE.md`. Those commits were discarded by `git reset --hard 01126d1` on `feature/credo-core` before this rebuild. Full rationale: `vision/plans/2026-05-20-credo-rollout-plan.md` §"Audit-C resolutions" (C1–C7).
- The LSA-skill refit (per-component formats from the plan's Layer 1.5 applied to all LSA skills + `tier-selector` confirm; each skill's Constraints adds one citation to `core/output`) lands in `lsa` v0.4.0 (PR 2 of the credo rollout, `feature/credo-lsa`). PR 1 is the core constitutional change; PR 2 is the propagation across LSA skills.

## [0.3.0] — 2026-05-20

Knowledge-vs-Actor boundary tightening across all three core skills. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 2.

### Changed
- `core/skills/tier-selector/SKILL.md` — Step 1 and Step 2 no longer inline the boundary-signal checklist or the four-row classification table. Both now cite `vision/VISION.md` §4 as the single source of truth. Resolves the self-flagged debt at the prior `lsa/ARCHITECTURE.md:459` ("revisit if a second skill restates them"). Body shrunk by ~16 lines.
- `core/skills/actor-template/SKILL.md` — removed the duplicate "Rules" section (which restated the three rules already embedded in the "Five required sections" descriptions) and the trailing "What this skill never does" block (which restated those rules negatively). The five-section spec + worked example + copy-paste template remain authoritative.
- `core/skills/ground-rules/SKILL.md` — removed the trailing "What this skill never does" block. The four numbered rules + their examples remain authoritative.
- `core/skills/tier-selector/SKILL.md` — frontmatter `description:` trimmed by one sentence (removed implementation-detail tail; trigger phrases preserved).

### Notes
- No skill behavior changes. The Goal / Input / Steps / Output / Constraints shape and the tier-selector chain-of-thought protocol are preserved; only restatements removed. `core/skills/ground-rules/SKILL.md` and `core/skills/actor-template/SKILL.md` frontmatter `description:` fields left as-is — already at ≤2 sentences with trigger phrases intact.
- Per `vision/VISION.md` §4 (*"ceremony scales to the weight of the task"*): citing the canonical table at VISION §4 means a future change to the tier classification rules is a single-edit operation, not a multi-file sweep.

## [0.2.1] — 2026-05-20

Docs-only patch — marks `core/CLAUDE.md` as the canonical source for the always-on rules block. Part of the repo-wide DRY / SRP prune in [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 1.

### Changed
- `core/CLAUDE.md` — added a header blockquote declaring the file as *"the single source-of-truth for the always-on rules block. Other locations (repo `CLAUDE.md`, READMEs, module specs) point here rather than restating the rules."* No change to the Ground rules or Tier selection sections.

### Notes
- The repo's `/CLAUDE.md` was shrunk in the same change-set (~108 → 34 lines) and now points to `core/CLAUDE.md` instead of duplicating its content. That edit is tracked in the repo-level refactor plan, not in this plugin's CHANGELOG.

## [0.2.0] — 2026-05-20

### Added
- `core/skills/tier-selector/SKILL.md` — Actor skill that classifies a task into T1/T2/T3 by applying Vision §4 boundary signals, then waits for human confirmation. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §4.1.
- `core/CLAUDE.md` — opt-in always-on fragment declaring both `ground-rules` and `tier-selector` as required pre-task invocations. Mirrors the always-on/on-demand split from `vision/VISION.md:106`.
- `core/tests/repo-anchored.md` — dogfood self-tests (4 `ground-rules` probes, 2 `actor-template` probes, 1 V3 behavior-comparison task) anchored in this repo as the source of truth. Complements `VERIFICATION.md` (generic, portable) with repo-specific probes whose expected answers can be checked against actual file content. (Previously listed under `[Unreleased]`; rolled into 0.2.0 release.)

### Changed
- `core/README.md` — adds `tier-selector` to "What's here" and adds a "Merge the CLAUDE.md fragment" install step.
- `core/VERIFICATION.md` — adds Probe C for `tier-selector` under V2.
- Plugin description in `core/.claude-plugin/plugin.json` extended to mention `tier-selector` (T1/T2/T3) chain-of-thought.

### Notes
- `core/registry` (the lazy-load map-not-territory skill) remains deferred to v0.3.0. `vision/VISION.md:177` notes Claude Code's per-component plugin discovery partially subsumes its role.

## [0.1.0] — 2026-05-20

First release. Two domain-neutral skills installable natively on Claude Code (via plugin marketplace) and Claude.ai (via Skills upload), with zero custom build steps.

### Added
- `ground-rules` skill — four discipline rules enforced together on every substantive task: (1) fact-grounding (every factual claim carries a source + searchable quote), (2) no fake-confidence hedging, (3) read the real source before answering, (4) deliver only what was asked. Each rule has a worked example; a "never does" tail closes the file.
- `actor-template` skill — the Goal / Input / Steps / Output / Constraints shape for any actor (Skill, slash command, or workflow). Demands every Step produce an observable result and forbids Knowledge bleed. Includes a PR-summary worked example and a copy-paste template.
- Plugin manifest (`core/.claude-plugin/plugin.json`) at v0.1.0.
- `README.md` with install paths for Claude Code and Claude.ai.
- `VERIFICATION.md` with V1 (install), V2 (description-match), V3 (behavior-change) probes plus the ~90% trigger-rate falsifiable threshold.

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/core-v0.1.0
