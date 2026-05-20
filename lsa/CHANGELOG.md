# Changelog

All notable changes to the `lsa` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

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
