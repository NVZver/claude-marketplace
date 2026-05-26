# Design: Management Plugin — Project Manager Agent

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `management` | modify — new agent, skill, knowledge files; product-manager output change; version bump |
| `lsa` | read-only — `lsa:discover` / `lsa:new` receive handoff; no code changes to `lsa` |
| `core` | read-only — agent inherits `core/ground-rules` and `core/output`; no code changes to `core` |
| vision/specs | modify — module spec update, roadmap detail status update |

## Technical Approach

### New files

Following the established pattern from the product-manager agent:

```
management/
├── agents/
│   ├── product-manager.md    # existing
│   └── project-manager.md    # NEW — Actor: roadmap steward agent
├── skills/
│   ├── start-feature/
│   │   └── SKILL.md          # MODIFY — add roadmap-entry step after pitch approval
│   └── roadmap/
│       └── SKILL.md          # NEW — Actor: entry-point skill, dispatches agent
├── knowledge/
│   ├── pitch-structure.md    # existing
│   ├── role-adaptation.md    # existing
│   ├── epic-decomposition.md # NEW — Knowledge: rules for breaking pitches into epics
│   └── sequencing-heuristics.md # NEW — Knowledge: three-factor sequencing model
├── .claude-plugin/
│   └── plugin.json           # MODIFY — version 0.1.0 → 0.2.0, description updated
├── CHANGELOG.md              # MODIFY — 0.2.0 entry
└── README.md                 # MODIFY — new skill + agent rows
```

### Agent behavior — three modes in one conversation

The project-manager agent operates in a single conversation flow with three modes that activate based on roadmap state:

**Mode 1: Recommend next.** The agent reads the roadmap table, filters for `backlog` status rows, reads linked pitch files for each, and applies the three sequencing heuristics from `management/knowledge/sequencing-heuristics.md`:

1. **Dependency order** — if item B's pitch references work from item A (in Solution sketch or Rabbit holes), A must ship first. Detected by: reading pitch cross-references, checking if referenced feature branches exist and are merged.
2. **Technical risk** — items with more Rabbit holes or vaguer Solution sketches rank earlier (fail fast). Detected by: counting rabbit-hole entries, checking solution-sketch specificity.
3. **Value delivery** — items with higher stated priority and stronger "Why now" urgency rank earlier. Detected by: reading the Priority column and the pitch's "Why now" metadata.

The agent presents a numbered recommendation with one-sentence rationale per item. The user picks one.

**Mode 2: Decompose.** After the user confirms a pick, the agent reads the full pitch file and applies the epic decomposition rules from `management/knowledge/epic-decomposition.md`:

- Each epic maps to a distinct boundary in the pitch's Solution sketch (key interaction, component, or critical-path segment).
- Each epic is independently shippable — completing it delivers observable value even if subsequent epics are deferred.
- Each epic fits one LSA build cycle: `lsa:discover` → `lsa:plan` → `lsa:implement` → `lsa:verify`.
- Format per epic: one-sentence scope, definition of done, parent pitch link.

The agent presents the epic list. The user approves, requests re-decomposition, or adjusts.

**Mode 3: Tidy.** During the recommendation phase (Mode 1), the agent also scans for roadmap hygiene issues:

- Items with status `backlog` but no linked pitch file.
- Items whose linked pitch is dated >4 weeks ago with no active `feature/*` branch.
- Items whose status should be updated based on branch/spec state (e.g., branch merged but status still says "backlog").

Proposed updates are presented as inline diffs via `AskUserQuestion`. The agent never writes to the roadmap without explicit approval.

### Product-manager output change (F7)

The `management:start-feature` skill gains one additional step after pitch approval:

1. (existing) Agent returns pitch path + approved status.
2. (NEW) Skill drafts a roadmap row: `| <pitch-title> | <priority> | backlog | Pitch: [<slug>](vision/specs/pitches/<slug>.md) |`
3. (NEW) Skill presents the row inline for user approval via `AskUserQuestion`.
4. (NEW) On approve, skill appends the row to the Feature Backlog table in `vision/specs/roadmap.md`.
5. (existing) Skill invokes `lsa:new`.

The priority is asked from the user via `AskUserQuestion` with options: Must / Should / Could. The skill does not guess priority.

### Handoff to LSA

After the user approves the epic list, the agent hands off the first epic:

- If a `feature/<epic-slug>` branch does not exist → invoke `lsa:new` with the epic description + pitch link.
- If the user is already on a feature branch → invoke `lsa:discover` directly with the epic description + pitch link.

Each subsequent epic is handed off after the previous one completes (the user re-invokes `management:roadmap` to continue).

### Knowledge files

**`management/knowledge/epic-decomposition.md`** — Knowledge (what is true), not Actor. Defines:
- What makes a good epic (independently shippable, one-sentence scope, one LSA cycle).
- How to find decomposition boundaries in a pitch (solution sketch segments, component boundaries, critical-path stages).
- Anti-patterns: epics that depend on each other in sequence (split differently), epics that are just "part 1 / part 2" (find real boundaries).

**`management/knowledge/sequencing-heuristics.md`** — Knowledge (what is true), not Actor. Defines:
- The three factors (dependency, risk, value) and how each is detected from the data sources the agent can read.
- Explicitly NOT a generic framework dump — each heuristic is grounded in what files and fields exist in this repo.
- Worked example using existing roadmap items [illustrative].

### Roadmap table format

The agent expects the roadmap's Feature Backlog table to follow the current format at `vision/specs/roadmap.md:9`:

```markdown
| Feature | Priority | Status | Notes |
|---|---|---|---|
```

The `sequencing-heuristics.md` knowledge file documents this format so the agent can validate on read. Parse failures are reported clearly, not silently ignored.

## Data Model Changes

None.

## API / Interface Changes

None — no external API. Skill-to-skill handoff uses Claude Code's native `Skill` and `Agent` invocations.

## Cross-Module Contracts

- **`management` depends on `core`.** Unchanged from v0.1.0. Cites `core/ground-rules` for fact-grounding and `core/output` for format discipline.
- **`management` reads `lsa` artifacts.** The project-manager agent reads roadmap, specs, and branches. `lsa` does NOT depend on `management`. No changes to `lsa`.
- **Handoff contract:** `management:roadmap` → `lsa:discover` or `lsa:new`. The epic description (one paragraph + pitch link) is passed as the task description. LSA reads the linked pitch during discovery for additional context.
- **Product-manager → roadmap contract:** `management:start-feature` writes a row to the Feature Backlog table after pitch approval. The row format matches the existing table structure.

## Open Questions

None — all design decisions resolved in the clarification round and pitch approval.
