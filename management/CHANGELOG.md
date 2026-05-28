# Changelog

All notable changes to the `management` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.3.0] – 2026-05-28

Paths parametrized on `${specs_root}`. Management now interoperates with LSA's configurable spec tree instead of hardcoding `vision/specs/`.

### Changed

- **`management/agents/product-manager.md`**, **`management/agents/project-manager.md`** — Input sections declare `specs_root` (read from `.lsa.yaml`, defaults per `lsa/knowledge/conventions.md`). Steps, Output, and Constraints reference `${specs_root}/pitches/<slug>.md`, `${specs_root}/roadmap.md`, and `${specs_root}/features/*/` instead of hardcoded `vision/specs/...`.
- **`management/skills/start-feature/SKILL.md`** — Same parametrization. Description updated to use `${specs_root}/pitches/<slug>.md`. Note: v0.2.1 had already refactored the hand-off to `management:roadmap`; v0.3.0 retains that structure and only parametrizes path strings.
- **`management/knowledge/sequencing-heuristics.md`**, **`management/knowledge/pitch-structure.md`** — `vision/specs/roadmap.md` and `vision/specs/pitches/<slug>.md` → `${specs_root}/roadmap.md` and `${specs_root}/pitches/<slug>.md`. Worked-example tables use repo-root-relative `pitches/<slug>.md` links.
- **`management/knowledge/epic-decomposition.md`** — epic-format template uses `../../pitches/<slug>.md` (relative to a feature file at `${specs_root}/features/<slug>/`) instead of `../../vision/specs/pitches/<slug>.md`. The previous template included a redundant `vision/specs/` segment that produced an incorrect path when resolved.
- **`management/.claude-plugin/plugin.json`** — version 0.2.2 → 0.3.0.

### Why

Before this change, management hardcoded `vision/specs/...` in six files. Any project whose `.lsa.yaml` set `specs_root` to something else — e.g., the new LSA default of `.lsa/` — would have management writing pitches and roadmap entries to a directory LSA didn't read from. Parametrization aligns management with the `specs_root` contract.

## [0.2.2] – 2026-05-27

Prompt audit remediation — knowledge deduplication and boundary fix.

### Changed

- **`agents/project-manager.md`** — Steps 4 and 9 now reference `knowledge/sequencing-heuristics.md` and `knowledge/epic-decomposition.md` by path instead of restating their rules inline. Removed duplicate "Inherits core/ground-rules and core/output" from frontmatter description (kept in Constraints). Removed "No unexplained jargon" constraint (covered by core/output).
- **`skills/start-feature/SKILL.md`** — replaced inline roadmap-write logic (Step 3a-e) with clean handoff to `management:roadmap`, making project-manager the single owner of roadmap writes.
- **`skills/roadmap/SKILL.md`** — removed no-op Step 1 ("Accept invocation"); renumbered remaining steps.

## [0.2.1] – 2026-05-27

### Fixed

- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). Step 4 now hands off to `management:roadmap` (project-manager → epic decomposition) instead of `lsa:new`. Completes the intended flow: product-manager → pitch + roadmap → project-manager → epics → LSA.
- **README** ([`./README.md`](./README.md)). Skill table and flow diagram updated to reflect the corrected handoff.
- **Product-manager agent** ([`./agents/product-manager.md`](./agents/product-manager.md)). Completion signal and constraint references updated from `lsa:new` to `management:roadmap`.

## [0.2.0] – 2026-05-26

Project-manager agent and roadmap skill. Bridges the gap between shaping (product-manager → pitch) and building (LSA cycle) with structured roadmap stewardship.

### Added

- **Project-manager agent** ([`./agents/project-manager.md`](./agents/project-manager.md)). Roadmap steward with three modes: (1) Recommend next — applies sequencing heuristics (dependency order, technical risk, value delivery) from linked pitches to recommend what to build next; (2) Tidy — flags stale items, missing pitches, and status inconsistencies; (3) Decompose — breaks a chosen pitch into independently-shippable epics per `management/knowledge/epic-decomposition.md`. Hands first epic to LSA. Read-only on everything except roadmap (writes require explicit user approval). Inherits `core/ground-rules` and `core/output`.
- **Roadmap skill** ([`./skills/roadmap/SKILL.md`](./skills/roadmap/SKILL.md)). Single entry point for project management. Dispatches the project-manager agent; agent handles recommendation, hygiene, decomposition, and LSA handoff internally.
- **Knowledge file: epic decomposition** ([`./knowledge/epic-decomposition.md`](./knowledge/epic-decomposition.md)). Rules for breaking pitches into epics: 5 quality criteria (independently shippable, one-sentence scope, one LSA cycle, clear definition of done, parent pitch link), 3 boundary-finding signals, 4 anti-patterns.
- **Knowledge file: sequencing heuristics** ([`./knowledge/sequencing-heuristics.md`](./knowledge/sequencing-heuristics.md)). Three-factor sequencing model grounded in this repo's data sources. Documents the roadmap table format for agent parsing.

### Changed

- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). Added Step 3: after pitch approval, optionally adds a roadmap backlog entry (title, user-confirmed priority, status `backlog`, pitch link) to `.lsa/roadmap.md`. Skippable at user's discretion.
- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)). Version 0.1.0 → 0.2.0. Description updated to cover both agents and both skills.

## [0.1.0] – 2026-05-26

Initial release. Plugin scaffold, knowledge files, product-manager agent, and start-feature skill.

### Added

- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)) at v0.1.0. Declares `dependencies: ["core"]`.
- **Knowledge file: pitch structure** ([`./knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)). Defines the 5-section pitch format with metadata header, markdown template, and worked example. Inspiration: Basecamp Shape Up shaping phase [unverified].
- **Knowledge file: role adaptation** ([`./knowledge/role-adaptation.md`](./knowledge/role-adaptation.md)). Defines how the product-manager agent self-selects a `<domain> product manager` role per invocation via visible chain-of-thought reasoning, with override via `AskUserQuestion`.
- **Product-manager agent** ([`./agents/product-manager.md`](./agents/product-manager.md)). Interactive shaping agent: adapts domain-expert role per invocation, drives multi-turn conversation to extract requirements, produces structured pitches per pitch-structure knowledge, gates on human approval. Inherits `core/ground-rules` and `core/output`.
- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). User-facing entry point. Accepts a problem description, dispatches the product-manager agent, hands off to `lsa:new` on approval. Orchestrator only — no shaping logic, no branch-creation logic.
- **Module spec** ([`.lsa/modules/management/spec.md`](../.lsa/modules/management/spec.md)). Module-level invariants and artifact paths.
- **Registrations** (`.lsa.yaml`, `.lsa/main.spec.md`). Management module registered with artifact paths and cross-module contracts.
- **README** ([`./README.md`](./README.md)). Install instructions, dependency on `core`, skill and agent tables, flow diagram.
- **Pitches directory** ([`.lsa/pitches/`](../.lsa/pitches/)). Empty directory (`.gitkeep`) for pitch output files.
