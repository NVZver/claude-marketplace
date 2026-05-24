# Design: LSA Command Rename + Flow Simplification

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `lsa` | modify — skill directory renames, skill merge (specify+discover → discover), skill removal (sync), description rewrites, plugin.json update, README update, ARCHITECTURE.md update, CHANGELOG entry, version bump to 0.8.0 |
| `core` | modify — cross-reference updates in `core/CLAUDE.md` where it names LSA skills (patch bump if changes land) |
| `vision` | modify — cross-reference updates in `VISION.md`, `main.spec.md`, `modules/lsa/spec.md`, `roadmap.md` |

## Technical Approach

### Directory renames (F1)

Rename each skill directory under `lsa/skills/`:

| Current path | New path |
|---|---|
| `lsa/skills/lsa-discover/` | `lsa/skills/discover/` |
| `lsa/skills/lsa-specify/` | *(merged into `lsa/skills/discover/`)* |
| `lsa/skills/lsa-plan/` | `lsa/skills/plan/` |
| `lsa/skills/lsa-verify/` | `lsa/skills/verify/` |
| `lsa/skills/lsa-init/` | `lsa/skills/init/` |
| `lsa/skills/lsa-reconcile/` | `lsa/skills/reconcile/` |
| `lsa/skills/lsa-revise-constitution/` | `lsa/skills/revise-constitution/` |
| `lsa/skills/lsa-sync/` | *(deleted)* |

Claude Code discovers skills by scanning `skills/*/SKILL.md` under a plugin's root directory. The directory name becomes the skill slug. Renaming the directory is the only change needed for the command name to update — no registry or routing config exists.

### Skill merge: specify + discover → discover (F2)

The merged `lsa/skills/discover/SKILL.md` will:
1. Accept the flow type (Standard or Extended) from `core/flow-selector`'s confirmed handoff.
2. **Standard flow:** Execute the current `lsa-discover` behavior (three inferred answers, confirm, 3-row table, stop).
3. **Extended flow:** Execute the current `lsa-discover` infer-then-confirm phase, then continue into the current `lsa-specify` behavior (clarification → requirements → User Verification 1 → test suites + design → User Verification 2 → User Verification 3). The three User Verifications and all spec artifact outputs are preserved exactly.

The merge is structural (two files combined into one with a flow-type branch), not behavioral. No new logic is introduced.

### Skill removal: sync (F3)

Delete `lsa/skills/lsa-sync/` entirely. Remove all references to `lsa-sync` from:
- `lsa/.claude-plugin/plugin.json` description
- `lsa/README.md` skill table
- `lsa/ARCHITECTURE.md`
- `vision/specs/modules/lsa/spec.md`
- `vision/specs/main.spec.md` (if referenced)
- `core/CLAUDE.md` (if referenced)
- `vision/VISION.md` (active sections only)
- `CONTRIBUTING.md`
- Root `README.md`
- `lsa/knowledge/conventions.md` (if referenced)

Archive files and old CHANGELOG entries keep original names per NF2.

### Description rewrites (F5)

Each skill's YAML frontmatter `description` will follow the pattern:

```
<what this command does>. Input: <what you need before running>. Output: <what it produces>.
```

The main-flow skills will include a position marker:

```
discover: "Discover and specify a feature (step 1 of 4: discover → plan → implement → verify). Input: ..."
plan: "Break a spec into implementation epics (step 2 of 4: discover → plan → implement → verify). Input: ..."
verify: "Verify implementation matches the spec (step 4 of 4: discover → plan → implement → verify). Input: ..."
```

Utility skills (init, reconcile, revise-constitution) omit the position marker.

### Cross-reference sweep

Every active file in the repo that references `lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-init`, `lsa-reconcile`, `lsa-revise-constitution`, or `lsa-sync` by the old name must be updated. The sweep covers:

- `lsa/skills/*/SKILL.md` — internal cross-references between skills
- `lsa/knowledge/*.md`
- `lsa/.claude-plugin/plugin.json`
- `lsa/README.md`
- `lsa/ARCHITECTURE.md`
- `lsa/CHANGELOG.md` — new entry only (old entries untouched per NF2)
- `core/CLAUDE.md`
- `core/README.md` (if it references LSA skills)
- `vision/VISION.md` (active sections only)
- `vision/specs/main.spec.md`
- `vision/specs/modules/lsa/spec.md`
- `vision/specs/modules/core/spec.md` (if it references LSA skills)
- `vision/specs/roadmap.md` (status update to "shipped" for this row)
- Root `CLAUDE.md`
- Root `README.md`
- `CONTRIBUTING.md`

## Data Model Changes

None.

## API / Interface Changes

None — these are CLI plugin skills, not HTTP APIs. The "interface" change is the skill slug (directory name), which is covered by F1.

## Cross-Module Contracts

- **`lsa` depends on `core`** — unchanged. The `core/flow-selector` → `lsa:discover` handoff remains the same; only the skill name on the receiving end changes.
- **`core/CLAUDE.md` references to LSA skills** — must be updated to new names. No behavioral contract change.

## Open Questions

None — all decisions were confirmed in the roadmap detail (vision/specs/roadmap.md lines 109-114).
