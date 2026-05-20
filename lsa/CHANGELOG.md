# Changelog

All notable changes to the `lsa` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

### Known follow-ups (v0.2.0 candidates)
- **Repo-root override.** Skills assume `/CLAUDE.md` at repo root and write specs to `/specs/`. To dogfood LSA on this marketplace (which uses `vision/VISION.md` and `vision/specs/`), `lsa-init` needs to accept a constitution-path override and a specs-root override.
- **Doc-mode.** This marketplace is markdown-only — no `/src/`. LSA's "every code change traces to a spec requirement" needs to generalize to "every artifact change" so it can verify spec/docs/skill changes.
- **Fact-grounding alignment.** LSA's §7 Fact-Check Policy duplicates `core/ground-rules` Rule 1. Should reference rather than restate, and adopt Core's lowercase `[assumption: <why>]` / `[cannot verify]` markers (LSA currently uses uppercase `[ASSUMPTION]`).

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
