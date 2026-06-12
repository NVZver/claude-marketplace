# Changelog

All notable changes to the `management` plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/). The plugin's authoritative version lives in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) — bump it in the same commit that adds the changelog entry.

## [0.5.0] – 2026-06-12

Gate contract inverted: agents propose, skills gate. `AskUserQuestion` and the `Skill` tool are unavailable in subagent context — in live runs (2026-06-09 and 2026-06-12) both agents returned *"AskUserQuestion isn't available in this subagent context"* and produced un-gated outputs while the docs promised agent-side gating.

### Changed

- **`management/agents/product-manager.md`** — `tools:` drops `AskUserQuestion`; Step 1 records the adopted role + rationale as a pending gate instead of asking; Step 4 writes the pitch as `Status: draft` and never flips it; Step 5 returns pitch path + an ordered pending-gates list (role confirmation, shaping forks with recommended defaults, final approve/reshape/reject). New constraint: *Gates belong to the dispatcher.*
- **`management/agents/project-manager.md`** — `tools:` drops `AskUserQuestion` and `Skill`; Steps 5/7/10 return decision payloads (options + recommended default) instead of asking; Step 7 applies hygiene rows only after the dispatcher returns approvals (continuation), quoting each written row inline; Steps 11-12 stage the `lsa:discover` handoff as ready-to-use seed text instead of invoking the `Skill` tool. Same new constraint.
- **`management/skills/start-feature/SKILL.md`** — new Step 3 *"Run the returned gates"*: presents the agent's pending gates via `AskUserQuestion`, flips pitch `Status:` to `approved`/`rejected` and records the gate decisions in the pitch header via `Edit`, re-dispatches on reshape. "No silent handoff" constraint rewritten: the gates live in the skill; the agent proposes.
- **`management/skills/roadmap/SKILL.md`** — Steps 1-3 reworked: receive the agent's payload, run each decision via `AskUserQuestion`, send decisions back via `SendMessage` continuation for the agent-owned roadmap writes, and invoke `lsa:discover` via the `Skill` tool with the agent's staged seed. "No silent handoff" constraint rewritten to match. Step 0 fast-path untouched.
- **`management/knowledge/epic-decomposition.md`** — scope note (audit finding): the rules govern epics within one pitch; cross-feature sequencing between pitches is `sequencing-heuristics.md` Factor 1 (dependency order).
- **`management/knowledge/role-adaptation.md`** — the too-vague-to-select-a-domain "ask the user" clause glossed: when dispatched as a subagent, the ask travels as a pending gate run by the dispatching skill.
- **`management/README.md`** — handoff prose and agent/skill tables now state that the orchestrator skills run the human gates (the agents prepare them).
- **`management/.claude-plugin/plugin.json`** — version 0.4.3 → 0.5.0; description aligned with the agents-propose/skills-gate contract.
- **`.lsa/modules/management/spec.md`** — stale `v0.3.0` pins → `v0.5.0`; "Human gate before every handoff" invariant updated to the agents-propose/skills-gate contract.

### Why

When dispatched via the `Agent` tool by their orchestrator skills, the agents cannot use `AskUserQuestion` or invoke skills, so the documented agent-side gates could never run; the main-loop assistant had to improvise them. The human gates stay — they move to the orchestrator skills, which run in the main loop and have both tools. MINOR bump: documented decision-flow contract change.

## [0.4.3] – 2026-06-08

Marketplace-audit cleanup — removed-skill drift + Role sections + de-count.

### Fixed

- **`management/agents/project-manager.md`** — handoff invoked the removed `lsa:new`; now `lsa:discover` only.
- **`management/README.md`** — replaced the "vs `lsa:next`" section (removed skill) with `management:roadmap`'s own fast-path-vs-full-flow description.

### Changed

- **`management/agents/{product-manager,project-manager}.md`** — added explicit `## Role` sections (consistency across agents).
- **`management/.claude-plugin/plugin.json`** — description de-counts agents.

## [0.4.2] – 2026-06-08

Wording, citation, and LSA-loop reference cleanup surfaced by the cross-plugin prompt review.

### Fixed

- **`management/README.md`**, **`management/knowledge/epic-decomposition.md`** — the LSA build-cycle reference named the removed `lsa:plan` / `lsa:implement` skills; now `lsa:discover → lsa:specify → lsa:verify → lsa:delegate → lsa:reconcile`.

### Changed

- **`management/agents/product-manager.md`**, **`management/knowledge/sequencing-heuristics.md`**, **`management/knowledge/role-adaptation.md`** — removed filler adverbs ("progressively", "naturally", "fresh").
- **`management/knowledge/role-adaptation.md`** — `.lsa/VISION.md:127` citation → `§4` (drift-proof).

## [0.4.1] – 2026-06-02

Show-changes-inline cites on roadmap/pitch writes.

### Changed

- **`management/agents/project-manager.md`** — Step 7 and a new Constraints bullet require each written roadmap row to be quoted inline before the verdict, per `core/output` Rule 7; never "roadmap updated" without the row.
- **`management/skills/roadmap/SKILL.md`**, **`start-feature/SKILL.md`** — new Constraints bullets: the dispatched agent's quoted-inline roadmap/pitch writes are surfaced verbatim by the orchestrator, never reduced to "roadmap updated" / "pitch created".

## [0.4.0] – 2026-06-02

Fast-path "what's next" for `management:roadmap` and the `project-manager` agent — answer in seconds without the full agent dispatch.

### Added

- **`management/skills/roadmap/SKILL.md`** — new Step 0 branch before the unconditional agent dispatch: a plain "what's next" returns the first `backlog`/`not started` roadmap row quoted with a `file:line` citation and exits, no agent spawned. The full `project-manager` dispatch (dependency/risk/value sequencing, decomposition, hygiene) is reserved for "recommend an order" / "what should I pick" / "sequence the backlog" questions.
- **`management/agents/project-manager.md`** — new Mode 0 early-exit so direct agent invocation (bypassing the skill) also short-circuits a plain "what's next" to the cited roadmap row.

Both cite `core/knowledge/fast-path-source-of-truth.md`. README skill-table + "`management:roadmap` vs `lsa:next`" section updated.

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
