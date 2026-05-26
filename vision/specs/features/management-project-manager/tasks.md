# Tasks: Management Plugin — Project Manager Agent

## Epic Overview

| Epic | Status | Dependency |
|------|--------|------------|
| E1: Knowledge files | complete | none |
| E2: Project-manager agent prompt | complete | E1 (references knowledge files) |
| E3: Roadmap skill + start-feature modification | complete | E2 (skill dispatches agent) |
| E4: Plugin scaffolding | complete | E1-E3 (version bump, changelog, README, module spec reflect all new content) |

## Epics

## Epic 1: Knowledge files

### Description

Create the two new knowledge files that the project-manager agent will reference: `epic-decomposition.md` (rules for breaking pitches into epics) and `sequencing-heuristics.md` (three-factor sequencing model grounded in this repo's data sources).

### Scope

- Creates: `management/knowledge/epic-decomposition.md`, `management/knowledge/sequencing-heuristics.md`
- Does NOT touch: any existing files

**Covers:** F3 (partially — the heuristics and decomposition rules the agent applies), F4 (partially — what makes a good epic), NF2 (Knowledge vs Actor separation), NF3 (roadmap table format documented in sequencing-heuristics)

### Technical Details

Per `design.md` §Knowledge files:

**`epic-decomposition.md`** defines:
- What makes a good epic (independently shippable, one-sentence scope, one LSA cycle)
- How to find decomposition boundaries in a pitch (solution sketch segments, component boundaries, critical-path stages)
- Anti-patterns (sequential dependencies, "part 1 / part 2" splits)
- Epic format: one-sentence scope, definition of done, parent pitch link

**`sequencing-heuristics.md`** defines:
- The three factors (dependency order, technical risk, value delivery) and how each is detected from files in this repo
- The expected roadmap table format (`| Feature | Priority | Status | Notes |`) per `design.md` §Roadmap table format
- Worked example using existing roadmap items [illustrative]
- Explicitly grounded in available data sources — not a generic framework dump

Both are Knowledge files (what is true), not Actors. No Goal/Input/Steps/Output. File-load trace directive at top per `core` v0.5.4.

### Acceptance Criteria

- [ ] `epic-decomposition.md` defines independently-shippable epic criteria, decomposition boundaries, and anti-patterns
- [ ] `sequencing-heuristics.md` defines three factors grounded in this repo's data sources + documents roadmap table format
- [ ] Neither file contains execution steps, Goal, or Output — Knowledge only
- [ ] Both files have the file-load trace directive

### Definition of Done

- [ ] Both knowledge files exist and follow marketplace Knowledge conventions
- [ ] No boundary violations (Knowledge contains no Actor content)
- [ ] Prompt-engineer review passed

---

## Epic 2: Project-manager agent prompt

### Description

Create the `project-manager.md` agent file — the Actor that drives the three-mode conversation (recommend next, decompose, tidy). References the two knowledge files from E1.

### Scope

- Creates: `management/agents/project-manager.md`
- Reads (does not modify): `management/knowledge/epic-decomposition.md`, `management/knowledge/sequencing-heuristics.md`, `management/knowledge/pitch-structure.md`
- Does NOT touch: existing `product-manager.md`, any skill files

**Covers:** F1 (partially — agent behavior), F2 (four data sources), F3 (three modes), F4 (epic format), F5 (handoff to LSA), F6 (roadmap safety — inline diffs via AskUserQuestion), AC1, AC2, AC3, AC4

### Technical Details

Per `design.md` §Agent behavior:

The agent follows Goal/Input/Steps/Output/Constraints (actor template per `vision/VISION.md:42`). Tools: `Read`, `Grep`, `Glob`, `Bash` (for git branch/log), `AskUserQuestion`, `Write`, `Edit`, `Skill`.

Steps map to the three modes:
1. Read roadmap + filter backlog items + read linked pitches (Mode 1 setup)
2. Apply sequencing heuristics from `sequencing-heuristics.md`, flag tidy issues (Mode 1 + Mode 3)
3. Present recommendation + tidy proposals to user (Mode 1 + Mode 3)
4. On user pick: read full pitch, apply decomposition rules from `epic-decomposition.md` (Mode 2)
5. Present epic list for approval (Mode 2)
6. On approve: hand off first epic to LSA (Mode 2 → handoff)

Constraints section covers: read-only on everything except roadmap, inherits `core/ground-rules` + `core/output`, no persona theater, re-ground jargon, ownership-over-automation.

Agent description (frontmatter) must trigger on: "what should I work on next", "roadmap", "project status", "what's in flight", "sequence the backlog", "decompose this pitch".

### Acceptance Criteria

- [ ] Agent follows Goal/Input/Steps/Output/Constraints shape
- [ ] Three modes (recommend, decompose, tidy) are distinct steps with observable results
- [ ] References knowledge files by relative path — does not restate their content
- [ ] Constraints include read-only, core/ground-rules, core/output, no persona theater
- [ ] Frontmatter description triggers on relevant user intents

### Definition of Done

- [ ] Agent file exists at `management/agents/project-manager.md`
- [ ] No boundary violations (Actor does not restate Knowledge content)
- [ ] Prompt-engineer review passed

---

## Epic 3: Roadmap skill + start-feature modification

### Description

Create the `management:roadmap` orchestrator skill (dispatches project-manager agent) and modify `management:start-feature` to add a roadmap-entry step after pitch approval.

### Scope

- Creates: `management/skills/roadmap/SKILL.md`
- Modifies: `management/skills/start-feature/SKILL.md`
- Does NOT touch: agent files, knowledge files

**Covers:** F1 (skill entry point), F5 (handoff orchestration), F7 (product-manager roadmap entry), AC3, AC5

### Technical Details

**`management/skills/roadmap/SKILL.md`** — orchestrator skill per `design.md` §New files. Mirrors the `start-feature` → `product-manager` pattern:
1. Accept invocation (no arguments)
2. Dispatch `project-manager` agent via `Agent` tool
3. Agent handles the full conversation; skill waits for completion
4. On completion: clean exit (the agent handles the LSA handoff internally)

Follows Goal/Input/Steps/Output/Constraints actor template. Frontmatter: `name: roadmap`, description cites the single entry point purpose.

**`start-feature` modification** — per `design.md` §Product-manager output change:
- Add Step 2.5 (after agent returns approved pitch, before `lsa:new` handoff)
- Draft a roadmap row: `| <title> | <priority> | backlog | Pitch: [<slug>](vision/specs/pitches/<slug>.md) |`
- Ask user for priority via `AskUserQuestion` (Must / Should / Could)
- Present row inline for approval
- On approve: append row to `vision/specs/roadmap.md` Feature Backlog table
- On skip: proceed to `lsa:new` without writing

### Acceptance Criteria

- [ ] `management:roadmap` skill dispatches project-manager agent and waits
- [ ] `start-feature` adds roadmap row after pitch approval with user-confirmed priority
- [ ] Roadmap row is presented inline before writing — no silent writes
- [ ] Both skills follow Goal/Input/Steps/Output/Constraints shape

### Definition of Done

- [ ] Both skill files exist and follow marketplace skill conventions
- [ ] No boundary violations
- [ ] Prompt-engineer review passed

---

## Epic 4: Plugin scaffolding

### Description

Bump `plugin.json` to v0.2.0, write CHANGELOG 0.2.0 entry, update README with new skill + agent tables, update module spec to reflect the project-manager additions.

### Scope

- Modifies: `management/.claude-plugin/plugin.json`, `management/CHANGELOG.md`, `management/README.md`, `vision/specs/modules/management/spec.md`
- Does NOT touch: agent files, skill files, knowledge files

**Covers:** NF1 (version bump, marketplace conventions), AC6

### Technical Details

**`plugin.json`**: version `0.1.0` → `0.2.0`. Description updated to mention both agents (product-manager + project-manager) and both skills (start-feature + roadmap).

**`CHANGELOG.md`**: new `## [0.2.0]` entry per Keep a Changelog. Lists: new project-manager agent, new roadmap skill, new knowledge files (epic-decomposition, sequencing-heuristics), modified start-feature skill (roadmap-entry step).

**`README.md`**: Skills table gains `management:roadmap` row. Agents table gains `project-manager` row. "How it fits" diagram updated to show the full flow including the project-manager's role between shaping and building.

**`vision/specs/modules/management/spec.md`**: Module description updated to include project management (not just product management). Invariants section gains entries for: roadmap stewardship, epic decomposition format, read-only constraint on non-roadmap files. Version reference updated to v0.2.0.

### Acceptance Criteria

- [ ] `plugin.json` version is `0.2.0` and description covers both agents
- [ ] CHANGELOG has a `[0.2.0]` entry listing all new/modified components
- [ ] README skills and agents tables include new entries
- [ ] Module spec reflects the project-manager's role and invariants

### Definition of Done

- [ ] All four files updated consistently
- [ ] Version, changelog, and README are aligned
- [ ] Module spec invariants cover the project-manager's constraints

---

## Integration Checklist

- [ ] All epics complete
- [ ] Plugin installs cleanly (`/plugin install management@NVZver`)
- [ ] `/help` lists `management:roadmap`
- [ ] `management:roadmap` dispatches the project-manager agent
- [ ] `management:start-feature` adds roadmap entry on pitch approval
- [ ] Prompt-engineer review passed on all new/modified files
- [ ] Version, changelog, README consistent at 0.2.0
