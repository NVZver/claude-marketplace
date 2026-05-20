# Changelog

All notable changes to the `core` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

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
