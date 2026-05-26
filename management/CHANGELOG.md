# Changelog

All notable changes to the `management` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.1.0] – 2026-05-26

Initial release. Plugin scaffold, knowledge files, product-manager agent, and start-feature skill.

### Added

- **Plugin manifest** ([`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)) at v0.1.0. Declares `dependencies: ["core"]`.
- **Knowledge file: pitch structure** ([`./knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)). Defines the 5-section pitch format with metadata header, markdown template, and worked example. Inspiration: Basecamp Shape Up shaping phase [unverified].
- **Knowledge file: role adaptation** ([`./knowledge/role-adaptation.md`](./knowledge/role-adaptation.md)). Defines how the product-manager agent self-selects a `<domain> product manager` role per invocation via visible chain-of-thought reasoning, with override via `AskUserQuestion`.
- **Product-manager agent** ([`./agents/product-manager.md`](./agents/product-manager.md)). Interactive shaping agent: adapts domain-expert role per invocation, drives multi-turn conversation to extract requirements, produces structured pitches per pitch-structure knowledge, gates on human approval. Inherits `core/ground-rules` and `core/output`.
- **Start-feature skill** ([`./skills/start-feature/SKILL.md`](./skills/start-feature/SKILL.md)). User-facing entry point. Accepts a problem description, dispatches the product-manager agent, hands off to `lsa:new` on approval. Orchestrator only — no shaping logic, no branch-creation logic.
- **Module spec** ([`vision/specs/modules/management/spec.md`](../vision/specs/modules/management/spec.md)). Module-level invariants and artifact paths.
- **Registrations** (`.lsa.yaml`, `vision/specs/main.spec.md`). Management module registered with artifact paths and cross-module contracts.
- **README** ([`./README.md`](./README.md)). Install instructions, dependency on `core`, skill and agent tables, flow diagram.
- **Pitches directory** ([`vision/specs/pitches/`](../vision/specs/pitches/)). Empty directory (`.gitkeep`) for pitch output files.
