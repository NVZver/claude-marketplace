# Design: Management Plugin — Product Manager Agent

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `management` (new) | new — entire plugin scaffold |
| `lsa` | read-only — `lsa:new` receives handoff; no code changes to `lsa` |
| `core` | read-only — agent inherits `core/ground-rules` and `core/output`; no code changes to `core` |
| vision/specs | modify — `.lsa.yaml` module entry, `main.spec.md` module index row |

## Technical Approach

### Plugin structure

Following the established pattern from `helper` and `lsa` plugins:

```
management/
├── .claude-plugin/
│   └── plugin.json          # name, version, description, author, dependencies
├── agents/
│   └── product-manager.md   # Actor: the shaping agent
├── skills/
│   └── start-feature/
│       └── SKILL.md         # Actor: entry-point skill, dispatches agent
├── knowledge/
│   ├── pitch-structure.md   # Knowledge: the 5-section pitch format + worked example
│   └── role-adaptation.md   # Knowledge: how to self-select a domain-expert role
├── CHANGELOG.md
└── README.md
```

Per `vision/VISION.md:42` — Knowledge vs Actor separation. The agent file (`product-manager.md`) is the Actor that defines Goal/Input/Steps/Output/Constraints. Domain methodology (pitch structure, role adaptation logic) lives in Knowledge files the agent reads.

### Agent behavior — three phases

**Phase 1: Role adaptation.** The agent reads the user's initial input and reasons (visible chain-of-thought) about which domain-expert role provides the best shaping expertise. It states the chosen role and why, then offers the user an override. This is Step 1 of the agent's Steps.

Source for the pattern: the agent dynamically narrows its focus per invocation, similar to how `core/flow-selector` reasons about flow type before committing. Per `vision/VISION.md:127` *"The orchestrator picks the flow by chain-of-thought, then states its reasoning and the human confirms or overrides."* — same principle applied to role selection.

**Phase 2: Interactive shaping.** The agent drives a conversation to fill the five pitch sections. It uses `AskUserQuestion` for genuine forks (per `core/output` Rule 5) and direct questions for information extraction. The user is the primary source; the agent enriches answers by reading the codebase (roadmap, existing specs, code). The conversation is progressive — the agent confirms understanding section-by-section rather than gathering all answers then producing output.

**Phase 3: Pitch approval + handoff.** The agent assembles the completed pitch, writes it to `vision/specs/pitches/<slug>.md`, presents it for approval. On approve → invokes `lsa:new` with the pitch context. On reshape → re-enters Phase 2 for the sections the user wants to change. On reject → clean exit.

### Pitch artifact format

```markdown
# Pitch: <Feature Name>

**Shaped by:** product-manager agent (<adopted-role>)
**Date:** <ISO date>
**Status:** approved | draft | rejected
**Why now:** <one sentence — what makes this timely>

## Problem
Who has this problem and what evidence exists.

Current workaround: how users cope today.

Definition of success: how we will know the problem is solved.

## Appetite
Time/scope boundary — what we're willing to spend.

## Solution Sketch
- Key user interactions: what the user does differently.
- Main components: which parts of the system are touched.
- Critical path: the one sequence that must work.

## Rabbit Holes
Known complexities to call out up front.

## No-Gos
What this pitch explicitly excludes.
```

Stored at `vision/specs/pitches/<slug>.md`. The predictable heading structure, metadata header, and labeled sub-elements (Current workaround, Definition of success, Key user interactions, Main components, Critical path) allow the future `project-manager` agent to parse and consume pitches programmatically.

### Handoff to `lsa:new`

The `start-feature` skill invokes `lsa:new` after pitch approval. The pitch file path is passed as context so `lsa:discover` can read it during the discovery phase. `lsa:new` handles branch creation and flow-selector — no duplication of that logic in `management`.

### Registration

- `.lsa.yaml` gains a `management` module entry with `artifact_paths` covering `management/**`.
- `vision/specs/main.spec.md` module index gains a `management` row.
- `vision/specs/modules/management/spec.md` created as the module spec.

## Data Model Changes

None.

## API / Interface Changes

None — no external API. The skill-to-skill handoff (`start-feature` → `lsa:new`) uses Claude Code's native `Skill` invocation.

## Cross-Module Contracts

- **`management` depends on `core`.** Cites `core/ground-rules` for fact-grounding and `core/output` for format discipline. Declared in `plugin.json` `dependencies` field.
- **`management` reads `lsa` artifacts.** The product-manager agent reads `vision/specs/roadmap.md` and existing specs during shaping. `lsa` does NOT depend on `management`.
- **Handoff contract:** `management:start-feature` → `lsa:new`. The pitch file path is passed as the feature description argument. `lsa:new` creates the branch and invokes `lsa:discover` which reads the pitch.

## Open Questions

- **OQ1** — Should the pitch directory be `vision/specs/pitches/` (feature-neutral, all pitches in one place) or nested under `vision/specs/features/<name>/pitch.md` (co-located with the feature spec)? The design assumes `vision/specs/pitches/` for discoverability by the future project-manager, but co-location has traceability advantages.
- **OQ2** — Should the role-adaptation step use a fixed catalog of known roles (extensible Knowledge file) or fully open-ended reasoning? The design assumes open-ended reasoning with visible chain-of-thought, but a catalog could improve consistency.
