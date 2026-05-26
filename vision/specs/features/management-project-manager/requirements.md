# Feature: Management Plugin — Project Manager Agent

## Summary

The marketplace has a strong shaping phase (product-manager → pitch) and a strong build phase (LSA: discover → plan → implement → verify), but nothing in between. Once a pitch is approved, the user must manually add roadmap entries, decide sequencing, decompose into epics, and keep the roadmap up to date. This feature adds a `project-manager` agent and `management:roadmap` skill that stewards the roadmap — recommending what to work on next (with dependency/risk/value reasoning), decomposing pitches into focused epics, and handing each epic to LSA for technical refinement.

Source: `vision/specs/pitches/project-manager-agent.md` — *"A roadmap steward that converts approved pitches into scoped work items, keeps the roadmap tidy and reliable, and hands focused epics to LSA."*

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | `management:roadmap` skill accepts no arguments, dispatches the `project-manager` agent, which reads the roadmap and drives an interactive conversation about what to work on and how to decompose it. | Must |
| F2 | The agent reads four data sources: roadmap table (`vision/specs/roadmap.md`), pitch files (`vision/specs/pitches/*.md`), active `feature/*` branches (via git), and spec artifacts (`vision/specs/features/*/`). | Must |
| F3 | The agent operates in three modes within one conversation: (a) **Recommend next** — applies sequencing heuristics (dependency order, technical risk, value delivery) to backlog items and presents a recommendation with per-item rationale; (b) **Decompose** — reads the selected pitch and breaks it into focused, independently-shippable epics; (c) **Tidy** — scans roadmap for stale/completed items and proposes updates. | Must |
| F4 | Each decomposed epic has a one-sentence scope, a clear definition of done, and a link to the parent pitch. Epics are small enough for one LSA build cycle (`lsa:discover` → `lsa:verify`). | Must |
| F5 | After the user approves the epic list, the agent hands the first epic to `lsa:discover` (or `lsa:new` if no feature branch exists) with enough context to seed discovery. | Must |
| F6 | All roadmap modifications (add/update/remove rows) are proposed as inline diffs via `AskUserQuestion`. The agent never silently writes to the roadmap. | Must |
| F7 | The product-manager output is extended: after pitch approval, `management:start-feature` also produces a roadmap backlog entry (title, priority, status `backlog`, pitch link) — with user approval before writing. | Should |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | Same `management` plugin, version bumped to 0.2.0. Agent inherits `core/ground-rules` (6 content rules) and `core/output` (7 format rules). Per `vision/VISION.md:46` *"Distribution + versioning."* |
| NF2 | Knowledge vs Actor separation per `vision/VISION.md:42`. The agent file is an Actor (Goal/Input/Steps/Output/Constraints). Epic decomposition rules and sequencing heuristics are Knowledge files. |
| NF3 | The roadmap table format must be documented in a knowledge file so the agent can validate it on read and report parse failures clearly. |

## Inputs & Outputs

- **Input:** The user invokes `management:roadmap`. No arguments required — the roadmap is the entry point.
- **Output:** A sequencing recommendation, approved epics, and handoff to LSA. Optionally, roadmap updates (with user approval).
- **Side effects:** New agent, skill, and knowledge files added to `management/`. Product-manager's `start-feature` skill gains a roadmap-entry step.

## Constraints

- The agent is read-only on everything except the roadmap. Pitches, specs, branches, and git state are read but never modified by this agent.
- `lsa` does not depend on `management`. The `lsa:next` skill stays unchanged; `management:roadmap` is a separate, recommended path when the management plugin is installed.
- The agent does not invent sequencing frameworks — it applies three concrete heuristics (dependency order, risk, value) grounded in data it can actually read from this repo. Per pitch §Rabbit holes #2.
- The epic decomposition format must be rich enough for LSA discovery but not so prescriptive that it duplicates LSA's spec authoring. Each epic is a one-paragraph description + pitch link.

## Out of Scope

- Automated status updates from git/LSA state (per pitch No-go #1).
- Sprint/iteration planning (per pitch No-go #2).
- Multi-contributor coordination (per pitch No-go #3).
- Real-time progress tracking during implementation (per pitch No-go #4).
- External tool integration — Jira, Linear, GitHub Issues (per pitch No-go #5).
- Changes to `lsa:next` — it stays as-is; no hard dependency on management.

## Acceptance Criteria

<!-- Each AC: (a) journey-shaped per vision/VISION.md §2 sub-principle 2a — user-observable behavior at the user/system boundary, not unit-test scope; (b) EARS-form per vision/VISION.md:201 — one of Ubiquitous / Event / State / Optional / Unwanted. -->
- [ ] AC1: When the user invokes `management:roadmap`, the system shall read the roadmap table and present a sequencing recommendation with per-item rationale citing dependencies, risk, and value.
- [ ] AC2: When the user confirms a roadmap item to work on, the system shall read the linked pitch file and decompose it into focused, independently-shippable epics with one-sentence scope each.
- [ ] AC3: When the user approves the epic list, the system shall hand off the first epic to `lsa:discover` for technical refinement.
- [ ] AC4: When the system proposes a roadmap modification (add/update/remove a row), it shall present the exact change inline and wait for explicit user approval before writing.
- [ ] AC5: When a user approves a pitch via `management:start-feature`, the system shall also produce a roadmap backlog entry (title, priority, status, pitch link) with user approval.
- [ ] AC6: While the management plugin is installed, its `plugin.json` shall declare `"dependencies": ["core"]` and the version shall be bumped to 0.2.0.
