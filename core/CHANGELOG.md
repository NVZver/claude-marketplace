# Changelog

All notable changes to the `core` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [Unreleased]

### Added
- `core/tests/repo-anchored.md` — dogfood self-tests (4 `ground-rules` probes, 2 `actor-template` probes, 1 V3 behavior-comparison task) anchored in this repo as the source of truth. Complements `VERIFICATION.md` (generic, portable) with repo-specific probes whose expected answers can be checked against actual file content.

## [0.1.0] — 2026-05-20

First release. Two domain-neutral skills installable natively on Claude Code (via plugin marketplace) and Claude.ai (via Skills upload), with zero custom build steps.

### Added
- `ground-rules` skill — four discipline rules enforced together on every substantive task: (1) fact-grounding (every factual claim carries a source + searchable quote), (2) no fake-confidence hedging, (3) read the real source before answering, (4) deliver only what was asked. Each rule has a worked example; a "never does" tail closes the file.
- `actor-template` skill — the Goal / Input / Steps / Output / Constraints shape for any actor (Skill, slash command, or workflow). Demands every Step produce an observable result and forbids Knowledge bleed. Includes a PR-summary worked example and a copy-paste template.
- Plugin manifest (`core/.claude-plugin/plugin.json`) at v0.1.0.
- `README.md` with install paths for Claude Code and Claude.ai.
- `VERIFICATION.md` with V1 (install), V2 (description-match), V3 (behavior-change) probes plus the ~90% trigger-rate falsifiable threshold.

[0.1.0]: https://github.com/NVZver/claude-marketplace/releases/tag/core-v0.1.0
