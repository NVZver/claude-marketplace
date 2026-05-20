# Changelog

All notable changes to the `lsa` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

## [0.3.1] — 2026-05-20

KISS surgical edits. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 3.

### Changed
- `lsa-init/SKILL.md` Step 2 — replaced the redundant human question *"Greenfield or brownfield?"* with mechanical detection: *"If `${specs_root}/modules/` is empty AND `.lsa.yaml: modules.*` contains no `artifact_paths`, the mode is greenfield; otherwise brownfield. Print the determination and ask the human to confirm."* The gate is preserved; the question is no longer wasted on something derivable from repo state.
- `lsa-plan/SKILL.md` Step 2 — added the missing rationale for the ≤5 epics ceiling: *"chosen to keep epic-level human review tractable; if the work cannot be decomposed in five, the feature is too large and should be split at the spec level rather than at the plan level"*. Closes the magic-number gap surfaced in the simplification round-2 review.
- `lsa-specify/SKILL.md` — split contract trigger out of Step 4 into its own Step 5 *"Determine contract requirement"* so each step has one Goal/Output (round-2 finding). Renumbered subsequent steps: old Step 5 (`test-suites.md`) → 6, old 6 (`contract.yaml`) → 7, old 7 (`design.md`) → 8, old 8 (Final review) → 9. Updated cross-references inside the file (spec-tree comment, contract-step reference, Amending section).

### Removed
- Pre-Feature Checklist orphan — already deleted in 0.2.1 when `lsa/ARCHITECTURE.md` §5 (Workflow Phases) was pruned. Listed here for traceability against the round-2 finding.

### Notes
- Kept `.lsa.yaml: mode: mixed` as-is per the plan ("marginal complexity, removing would break an existing config surface").
- No behavioral semantics changed by these edits. The contract trigger still gates `contract.yaml` (now via Step 5 → Step 7); the ≤5 epics rule still escalates (now with the why); greenfield/brownfield still gates with explicit confirm (now mechanically pre-filled).

## [0.3.0] — 2026-05-20

Knowledge-vs-Actor boundary tightening across all eight LSA skills. New `lsa/knowledge/conventions.md` Knowledge surface owns cross-skill conventions formerly duplicated in skill bodies. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 2.

### Added
- `lsa/knowledge/conventions.md` — single Knowledge file holding (1) `.lsa.yaml` defaults, (2) the Read Protocol, (3) Hard / Soft Confirm gate type definitions, (4) the unified trace-tag format `<!-- <action>: <source> YYYY-MM-DD -->`. Each section was formerly restated in 6–7 skill bodies.
- `lsa/knowledge/**/*.md` added to `.lsa.yaml: modules.lsa.artifact_paths` so future Knowledge files are tracked by `lsa-verify` doc-mode.

### Changed
- All 8 LSA skill bodies (`lsa-init`, `lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-reconcile`, `lsa-revise-constitution`) — Step 1 read prose now cites `../knowledge/conventions.md` §"Read protocol" instead of inlining the `.lsa.yaml` defaults block + per-skill read protocol. Inputs cite conventions for the defaults.
- `lsa-specify/SKILL.md` — "Confirm gate definitions" section deleted; cited `../knowledge/conventions.md` §"Confirm gate types" instead.
- `lsa-sync/SKILL.md` — trace-tag format changed from `<!-- added: [feature-name] [YYYY-MM-DD] -->` to `<!-- added: <feature-name> YYYY-MM-DD -->` (unified shape per conventions.md).
- `lsa-reconcile/SKILL.md` — trace-tag format changed from `<!-- reconciled: YYYY-MM-DD -->` (no source slot) to `<!-- reconciled: drift YYYY-MM-DD -->` (with source slot, per conventions.md). Closes a round-2 finding that `reconciled` was the outlier.
- `lsa-revise-constitution/SKILL.md` — trace-tag format changed from `<!-- revised: [feature-name] [YYYY-MM-DD] -->` to `<!-- revised: <feature-name> YYYY-MM-DD -->` (unified shape).
- 6 LSA skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) — removed the redundant `[assumption: <why>]` / `[cannot verify]` Constraints line from each. The marker convention is owned by `core/skills/ground-rules/SKILL.md` Rule 1; LSA skills cite it instead of restating.
- All 8 LSA skill frontmatter `description:` fields trimmed to ≤2 sentences (verb + trigger phrases). Implementation detail moved to skill body. Trigger phrases preserved so description-match triggering is unaffected.

### Notes
- No behavioral semantics changed. Hard/Soft Confirm gates fire identically; tag-format changes are mechanical and apply only to newly written tags.
- `lsa/.lsa.yaml` for this repo now includes `lsa/knowledge/**/*.md` under `modules.lsa.artifact_paths` so the new Knowledge surface is tracked by `lsa-verify` doc-mode.
- The "tag format change" is non-breaking: historical tags using the old shape (e.g., `<!-- added: [user-auth] [2026-05-15] -->`) remain valid in already-written specs; only new tags use the unified shape. No spec rewrite required.

## [0.2.1] — 2026-05-20

Pure DRY / SRP / KISS docs prune. No skill behavior change. Per [`vision/plans/2026-05-20-simplification-refactor-plan.md`](../vision/plans/2026-05-20-simplification-refactor-plan.md) PR 1.

### Changed
- `ARCHITECTURE.md` — shrunk ~540 → ~145 lines. Kept §1 Purpose, §2 Directory Structure, §3 `.lsa.yaml` configuration, §4 Branch Management, §5 Resolved Decisions. Deleted §2 (8 first principles — duplicated `vision/VISION.md` §2), §4.1–§4.9 component definitions (duplicated each `SKILL.md`), §5 Workflow Phases (duplicated each `SKILL.md`), §6 Testing Policy (duplicated `vision/specs/standards/testing.md`), §7 Fact-Check Policy (duplicated `core/skills/ground-rules/SKILL.md`), §8 Constitution Revision (duplicated `lsa-revise-constitution/SKILL.md`), §10 Skills Index (duplicated `README.md`). Each deleted section's content survives at its canonical source.
- `README.md` — "Naming note" no longer lists `agents.md` (file deleted).
- `lsa/skills/lsa-init/SKILL.md` — greenfield template no longer includes `standards/agents.md` (mechanical sweep; file deleted).
- `lsa/skills/lsa-revise-constitution/SKILL.md` — Step 1 read list no longer includes `${specs_root}/standards/agents.md` (mechanical sweep; file deleted).

### Removed
- *(repo-level, not plugin-level, but listed here for traceability)* `vision/specs/standards/agents.md` deleted. The file self-declared as a digest of upstream sources; every section now lives at its canonical home (`vision/VISION.md` §2 for the eight first principles; `core/skills/ground-rules/SKILL.md` for the marker convention; `lsa/skills/lsa-specify/SKILL.md` for the gate types; `vision/VISION.md:124` for the boundary signals).

### Notes
- Out of scope for this patch: skill body deduplication (PR 2), KISS surgical edits (PR 3).
- Module specs at `vision/specs/modules/{core,lsa}/spec.md` were shrunk in the same change-set (not part of this plugin's CHANGELOG; tracked in the repo-level refactor plan).
- Repo `/CLAUDE.md` was shrunk in the same change-set; the always-on rules block now points to `core/CLAUDE.md` as the canonical source instead of restating it.

## [0.2.0] — 2026-05-20

Closes the seven Vision-alignment gaps between v0.1.1 and `vision/VISION.md` v0.4. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md`.

### Added
- `lsa/skills/lsa-discover/SKILL.md` — light three-question discovery probe at the start of every T2 and T3 task (Phase 0). T2 oral; T3 emits scratch `discovery.md` consumed by `lsa-specify`. Design §4.3.
- `lsa/skills/lsa-reconcile/SKILL.md` — absorbs direct artifact edits into module specs (Level 2.5, `vision/VISION.md:138`). Per-module hard confirm; reverse-sync in-place (class a) or append (class b); both tagged `<!-- reconciled: YYYY-MM-DD -->`. Updates `.lsa-sync-state.json` on confirm. Design §4.4.
- `lsa/hooks/hooks.json` + `lsa/hooks/session-start-drift-check.sh` — SessionStart drift-warning hook (matcher `startup`, type `command`, timeout 10s). Diffs `artifact_paths` against `.lsa-sync-state.json`'s recorded SHA per module; surfaces a one-line notice when drift is detected. Design §7.
- `.lsa.yaml` loader across every reshaped skill — `constitution`, `specs_root`, `mode` (code / docs / mixed), and per-module `{spec, artifact_paths}`. Defaults preserve v0.1.1 behavior when the file is absent. Design §6.
- Doc-mode in `lsa-verify` — when `.lsa.yaml: mode` is `docs` or `mixed`, verify diffs each module's `artifact_paths` against `main`. Tracing satisfied by (a) feature spec naming the file/dir in an AC, or (b) the diff being wholly mechanical. Design §8.
- `.lsa-sync-state.json` writer in `lsa-sync` (records HEAD SHA + ISO timestamp per touched module; preserves untouched modules' entries). Consumed by `lsa-reconcile` and the SessionStart hook. Design §7.
- Per-feature `metrics.md` writer in `lsa-verify` — emitted only on clean T3 PASS to `${specs_root}/archive/<feature>/metrics.md`; pass/fail counts for accuracy / facts-with-sources / only-required-changes. Design §9.
- Aggregate metrics row appended to `${specs_root}/metrics.md` by `lsa-sync` when per-feature `metrics.md` exists.
- Dependency note on `core` v0.2.0 (uses `core/tier-selector` upstream of T2/T3 paths). Carried in plugin description.

### Changed
- All six existing skills (`lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`) reshaped to the `core/actor-template` five-section shape: Goal / Input / Steps / Output / Constraints (replacing the historical `## Step 1 — ...`, `## Step 2 — ...` headers). Step content preserved as numbered sub-items under a single `## Steps` block, with each Step now stating its observable result. Design §5.
- Hardcoded `/CLAUDE.md` and `/specs/...` paths replaced with `${constitution}` and `${specs_root}/...` reads from `.lsa.yaml` (with defaults). Design §5.
- `lsa-init` brownfield mode scans `modules.*.artifact_paths` from `.lsa.yaml` (falling back to `/src/` when the file is absent).
- Marker convention swept to lowercase `[assumption: <why>]` and `[cannot verify]` across all 8 skills + `ARCHITECTURE.md` §7. Matches `core/skills/ground-rules/SKILL.md`. The historical `[ASSUMPTION: ...]` (uppercase) and `[INFERRED — verify]` markers are removed.
- `ARCHITECTURE.md` — major update: new §4.8/§4.9 (lsa-discover, lsa-reconcile), §4.10 (`.lsa.yaml`), Phase 0 + ad-hoc Phase Reconcile in §5, Knowledge-vs-Actor note in §7, OQ5–OQ8 in §11. Status line bumped to 0.2.0.
- `README.md` — skills table now lists all 8 skills; new "Configuration" section documents `.lsa.yaml`.
- Plugin description in `lsa/.claude-plugin/plugin.json` extended to mention all 8 skills + tier-awareness + `.lsa.yaml` configurability.

### Notes
- `.lsa.yaml` schema version is informational (`# Schema version: 1`); a future LSA major (1.x.y) will introduce a hard `schema_version: N` key if a breaking schema change is needed. v0.2.0 additions remain non-breaking.
- Claude Code's plugin manifest still does not expose a `dependencies` field. The LSA→Core dependency stays prose-only in `README.md` and `plugin.json` description (`lsa/CHANGELOG.md:21` carries forward).
- `core/registry` (the lazy-load map-not-territory skill) stays deferred — now to core v0.3.0 — per `vision/VISION.md:177`.

## [0.1.1] — 2026-05-20

### Changed
- `ARCHITECTURE.md` §2 P4 and §7 Fact-Check Policy now defer to [`core/ground-rules`](../core/skills/ground-rules/SKILL.md) rather than restating its content. Eliminates a DRY violation against the marketplace's "core + packs" architecture (`vision/VISION.md` §3).
- `README.md` adds a **Depends on** section: install `core` before `lsa`.
- Plugin manifest `description` notes the dependency on `core`.

### Notes
- Claude Code's plugin manifest does not (as of writing) expose a `dependencies` field. The LSA→Core dependency is prose-only in `README.md` and `plugin.json` `description`. If a manifest field becomes available, adopt it in a future patch.

## [0.1.0] — 2026-05-20

First release. Migrates the six pre-vision LSA skill drafts into a proper Claude Code plugin.

### Added
- Six skills: `lsa-init`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-sync`, `lsa-revise-constitution`. Each enforces a phase with explicit human gates per `ARCHITECTURE.md` §5.
- `ARCHITECTURE.md` — the LSA methodology document migrated from pre-v1 `LSA/LSA-ARCHITECTURE.md`.
- Plugin manifest at v0.1.0.

### Changed
- Migrated from `LSA/` (flat layout, repo root) to `lsa/` (plugin layout) per the marketplace's "core + packs" architecture (`vision/VISION.md` §3).
- Renamed LSA-internal `/specs/ground-rules/` → `/specs/standards/` (across 4 files) to remove name collision with Core's `ground-rules` discipline skill.
- `ARCHITECTURE.md` status updated from "Draft — Pending stress test" to "0.1.0 — Installable; pending stress test on actual project use".

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/lsa-v0.1.0
