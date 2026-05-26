# Tasks: Management Plugin — Product Manager Agent

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E1: Plugin scaffold + knowledge + registration | feature/management-product-manager | pending | none |
| E2: Product-manager agent | feature/management-product-manager | pending | E1 (knowledge files must exist for agent to reference) |
| E3: Start-feature skill + handoff | feature/management-product-manager | pending | E2 (skill dispatches the agent) |

## Epics

## Epic 1: Plugin scaffold + knowledge + registration

### Description

Create the `management` plugin directory structure, manifest, documentation scaffold, knowledge files, and register the module in `.lsa.yaml` + `main.spec.md`. This is the foundation — everything else references it.

### Scope

- Files/modules touched: `management/` (new directory tree), `.lsa.yaml`, `vision/specs/main.spec.md`, `vision/specs/modules/management/spec.md`
- Creates: `management/.claude-plugin/plugin.json`, `management/CHANGELOG.md`, `management/README.md`, `management/knowledge/pitch-structure.md`, `management/knowledge/role-adaptation.md`, `vision/specs/pitches/` directory, `vision/specs/modules/management/spec.md`
- Modifies: `.lsa.yaml` (new module entry), `vision/specs/main.spec.md` (new row in Module Index)
- Does NOT touch: `core/`, `lsa/`, `helper/`, any existing plugin

**Covers:** F5, NF1, NF3, AC7

### Technical Details

- `plugin.json`: `name: "management"`, `version: "0.1.0"`, `dependencies: ["core"]`. Pattern: `helper/.claude-plugin/plugin.json`.
- `pitch-structure.md`: Knowledge file defining the 5-section pitch format (Problem, Appetite, Solution sketch, Rabbit holes, No-gos) with a worked example. Predictable heading structure for future project-manager parsing (NF3).
- `role-adaptation.md`: Knowledge file defining how the agent self-selects a domain-expert role — visible chain-of-thought reasoning, user override mechanism. Open-ended reasoning (OQ2 resolution: open-ended, not catalog).
- `.lsa.yaml` entry: `management` module with `artifact_paths` covering `management/**/*.md` and `management/.claude-plugin/plugin.json`.
- `main.spec.md`: new row in Module Index pointing to `vision/specs/modules/management/spec.md`.
- `vision/specs/pitches/`: directory for pitch artifacts (OQ1 resolution: standalone directory for project-manager discoverability).
- README: plugin purpose, install command, skill table, dependency on `core`.
- CHANGELOG: initial `0.1.0` entry.

### Acceptance Criteria

- [ ] `management/.claude-plugin/plugin.json` exists with `dependencies: ["core"]` (AC7)
- [ ] `management/knowledge/pitch-structure.md` defines the 5-section format with predictable headings (F5, NF3)
- [ ] `management/knowledge/role-adaptation.md` defines the role-selection methodology (F2 knowledge half)
- [ ] `.lsa.yaml` lists `management` as a module
- [ ] `vision/specs/main.spec.md` Module Index includes `management`
- [ ] `vision/specs/modules/management/spec.md` exists
- [ ] `vision/specs/pitches/` directory exists
- [ ] All files follow marketplace conventions (NF1): trace directive, Knowledge vs Actor separation

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Structural | `plugin.json` is valid JSON, has required fields, declares `core` dependency | Must |
| Structural | Knowledge files have no Actor sections (Goal/Steps/Output/Constraints) — Knowledge vs Actor per `vision/VISION.md:42` | Must |
| E2E | Install plugin via Claude Code, verify `management` appears in plugin list (Journey 2, Path 1) | Must |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] No convention violations per `core/ground-rules`
- [ ] File-load trace directive on every instructional file

---

## Epic 2: Product-manager agent

### Description

Write the `product-manager.md` agent Actor file — the core behavioral definition. The agent drives an interactive shaping conversation: adapts its domain role, extracts information from the user, reads the codebase for grounding, progressively builds a structured pitch, and presents it for approval.

### Scope

- Files/modules touched: `management/agents/product-manager.md` (new)
- Creates: `management/agents/product-manager.md`
- Does NOT touch: `core/`, `lsa/`, `helper/`, knowledge files (read-only reference), plugin.json

**Covers:** F1, F2, F3, F4, F5, F6, NF2, AC1, AC2, AC3, AC4, AC5

### Technical Details

- Actor shape per `core/skills/actor-template/SKILL.md`: Goal / Input / Steps / Output / Constraints.
- Frontmatter: `name: product-manager`, `description` (trigger conditions), `tools` (Read, Grep, Glob, AskUserQuestion, Write, Skill).
- **Step 1 — Role adaptation.** Read user's initial input. Reason about best domain-expert role (visible chain-of-thought). State role + why. Offer override via `AskUserQuestion`. References `../knowledge/role-adaptation.md`.
- **Step 2 — Interactive shaping.** Drive conversation to fill five pitch sections. User is primary source (F3). Ask targeted questions for missing information. Read codebase (roadmap, specs, code) to enrich. Progressive — confirm section-by-section (F4). References `../knowledge/pitch-structure.md`.
- **Step 3 — Pitch assembly.** Write completed pitch to `vision/specs/pitches/<slug>.md` per the pitch-structure Knowledge file.
- **Step 4 — Approval gate.** Present pitch via `AskUserQuestion`: approve / reshape / reject (F6). On reshape → re-enter Step 2 for changed sections. On reject → clean exit.
- **Step 5 — Handoff.** On approve → invoke `lsa:new` via `Skill` with pitch file path as context (F7). This step is *initiated* by the agent but *executed* by the start-feature skill — the agent's Step 5 is "signal to the skill that approval happened."
- Constraints: inherits `core/ground-rules` + `core/output` (NF2). User-authoritative (F3, AC3). No roadmap population. No silent decisions.

### Acceptance Criteria

- [ ] Agent file has Goal/Input/Steps/Output/Constraints sections (actor-template compliance)
- [ ] Step 1 implements visible role reasoning + user override (AC2)
- [ ] Step 2 asks clarifying questions before producing pitch (AC1)
- [ ] Step 2 treats user input as authoritative, codebase as grounding (AC3)
- [ ] Step 3 produces a pitch with all 5 sections (AC4)
- [ ] Step 4 waits for explicit approval via AskUserQuestion (AC5)
- [ ] Agent frontmatter declares appropriate tools

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Structural | File matches actor-template shape: 5 required sections, no Knowledge content in Actor | Must |
| Structural | Every Step has an Observable result line | Must |
| E2E | Invoke agent → role adaptation fires → clarifying questions asked → pitch produced (Journey 1, Paths 1-6) | Must |
| E2E | Role override path (Journey 1, Path 2) | Should |
| E2E | Reshape and reject paths (Journey 1, Paths 4-5) | Should |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] Agent follows `core/ground-rules` and `core/output`
- [ ] File-load trace directive present
- [ ] No Knowledge content in Actor file (all methodology in knowledge/)

---

## Epic 3: Start-feature skill + handoff

### Description

Write the `management:start-feature` SKILL.md — the user-facing entry point that dispatches the product-manager agent, manages the pitch approval gate, and hands off to `lsa:new` on approval.

### Scope

- Files/modules touched: `management/skills/start-feature/SKILL.md` (new)
- Creates: `management/skills/start-feature/SKILL.md`
- Does NOT touch: `core/`, `lsa/`, `helper/`, agent file (read-only dispatch), knowledge files

**Covers:** F1, F6, F7, AC5, AC6

### Technical Details

- Actor shape per `core/skills/actor-template/SKILL.md`: Goal / Input / Steps / Output / Constraints.
- Frontmatter: `name: start-feature`, `description` (trigger: "start a feature", "shape a feature", "new feature idea", "what should we build").
- **Step 1 — Accept input.** Read argument or prompt the user for a problem description. Derive kebab-case slug for the pitch file. Observable result: slug + description captured.
- **Step 2 — Dispatch agent.** Spawn the `product-manager` agent (via `Agent` tool) with the problem description. The agent runs through its own phases (role adaptation → shaping → pitch assembly → approval). Observable result: agent running.
- **Step 3 — Handoff on approval.** When the agent signals approval, invoke `lsa:new` via `Skill` with the pitch file path as the feature description. Observable result: `lsa:new` executing.
- Constraint: orchestrator only — do not duplicate agent logic. On reject, exit cleanly with no side effects.

### Acceptance Criteria

- [ ] Skill file has Goal/Input/Steps/Output/Constraints sections (actor-template compliance)
- [ ] Skill dispatches product-manager agent (F1)
- [ ] Skill waits for pitch approval before handoff (AC5)
- [ ] Skill invokes `lsa:new` on approval with pitch context (AC6, F7)
- [ ] Skill exits cleanly on reject (no side effects)

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Structural | File matches actor-template shape | Must |
| Structural | Every Step has an Observable result line | Must |
| E2E | Full flow: invoke skill → agent shapes → approve → lsa:new fires (Journey 1, Path 1) | Must |
| E2E | Reject flow: invoke skill → agent shapes → reject → clean exit (Journey 1, Path 5) | Should |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] Skill follows `core/ground-rules` and `core/output`
- [ ] File-load trace directive present
- [ ] No logic duplication with agent file

---

## Integration Checklist

- [ ] All epics completed on feature branch
- [ ] E2E test: full Journey 1 Path 1 (happy path) passes
- [ ] E2E test: Journey 2 Path 1 (plugin install) passes
- [ ] All structural checks pass (actor-template, Knowledge/Actor separation, trace directives)
- [ ] lsa:verify passed on feature branch
- [ ] PR to main created
