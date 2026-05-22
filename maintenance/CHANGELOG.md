# Changelog

All notable changes to the `maintenance` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

## [0.1.0] — 2026-05-22

Initial release. Ships a single skill: `/maintenance:cleanup` — a repo-content audit + refactor tool that reduces ship-cost while preserving 6 defined invariants, with a 12-check verification protocol that resets the working tree on any failure.

Designed and validated against the manual cleanup pass on `feature/2026-05-21-maintenance-cleanup` (3 commits: `35b1068`, `9c1a9f2`, `cb2bad1`), which removed 52.1% of shipped-non-archive tokens. The skill encodes the 12-step procedure surfaced by that pass — see [`vision/specs/features/2026-05-21-maintenance-cleanup/manual-pass-notes.md`](../vision/specs/features/2026-05-21-maintenance-cleanup/manual-pass-notes.md) for the procedure capture and [`vision/specs/features/2026-05-21-maintenance-cleanup/`](../vision/specs/features/2026-05-21-maintenance-cleanup/) for the approved feature spec.

### Added
- `maintenance/skills/cleanup/SKILL.md` — the 6-phase actor (Preconditions → Inventory → Classify → Stage → Verify → Report). Refuses to run on `main` or with uncommitted changes. Stages but never commits. Idempotent on re-run (second run on unchanged input produces empty diff). Per `vision/specs/features/2026-05-21-maintenance-cleanup/design.md` § Technical Approach.
- `maintenance/.claude-plugin/plugin.json` — plugin manifest (name + description + version + author).
- `maintenance/README.md` — install, usage, 6 invariants, per-class token budgets (NF1), Ollama/Mistral target (NF3), V1/V2/V3 verification probes.
- `vision/specs/modules/maintenance/spec.md` — module-level invariants.
- `.claude-plugin/marketplace.json` — `maintenance` plugin entry appended.
- `.lsa.yaml` — `modules.maintenance` entry registered with `artifact_paths` covering the plugin's files.
- `vision/specs/main.spec.md` — `maintenance` row appended to Module Index.

### Notes
- **Depends on `core` v0.5.3+** for `core/actor-template` (skill body shape) and `core/output` Rule 5 (prompt voice for the skill's pickers).
- **Does NOT depend on `lsa`.** Orthogonal to the spec lifecycle. The skill operates on content discipline (slimness, citation integrity), not spec-grounding.
- **Opt-in plugin.** Not listed under repo `CLAUDE.md` "Default plugins" (which still names just `core` + `lsa`). Install on demand.
- **Single skill in this release.** Future skills (e.g., redundancy-extractor, prose-density-trimmer) may join in subsequent minor releases if the cleanup pass reveals demand.
