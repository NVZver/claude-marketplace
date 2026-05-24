# Tasks: LSA Command Rename + Flow Simplification

## Epic Overview

| Epic | Branch | Status | Dependency |
|------|--------|--------|------------|
| E1: Structural rename + sync removal | feature/lsa-command-rename-flow-simplification-e1 | pending | none |
| E2: Merged discover skill | feature/lsa-command-rename-flow-simplification-e2 | pending | E1 |
| E3: Entry-point skills (new + next) | feature/lsa-command-rename-flow-simplification-e3 | pending | E1 |
| E4: Description rewrites + cross-reference sweep + versioning | feature/lsa-command-rename-flow-simplification-e4 | pending | E1, E2, E3 |

## Epics

## Epic 1: Structural rename + sync removal

### Description

Rename all 6 LSA skill directories to drop the `lsa-` prefix and delete the `lsa-sync` skill entirely. Pure file-system operations — no content changes beyond what git mv produces.

### Scope

- Files/modules touched: `lsa/skills/lsa-discover/` → `lsa/skills/discover/`, `lsa/skills/lsa-plan/` → `lsa/skills/plan/`, `lsa/skills/lsa-verify/` → `lsa/skills/verify/`, `lsa/skills/lsa-init/` → `lsa/skills/init/`, `lsa/skills/lsa-reconcile/` → `lsa/skills/reconcile/`, `lsa/skills/lsa-revise-constitution/` → `lsa/skills/revise-constitution/`
- Creates / modifies / deletes: renames 6 directories; deletes `lsa/skills/lsa-sync/` entirely; deletes `lsa/skills/lsa-specify/` (content moves to discover in E2)
- Does NOT touch: file content, cross-references, descriptions, plugin.json, READMEs

**Covers:** F1, F3, F4

### Technical Details

Use `git mv` for each directory rename to preserve history. For `lsa-specify`, move the directory content into a temporary holding location (or defer deletion to E2 which overwrites `discover/SKILL.md`). Delete `lsa-sync/` with `git rm -r`. The `lsa-specify/` directory is removed here; its content is consumed by E2.

### Acceptance Criteria

- [ ] AC1: `lsa/skills/` contains exactly: `discover/`, `plan/`, `verify/`, `init/`, `reconcile/`, `revise-constitution/` (no `lsa-` prefix directories remain)
- [ ] AC2: `lsa/skills/lsa-sync/` does not exist
- [ ] AC3: `lsa/skills/lsa-specify/` does not exist
- [ ] AC4: Git history is preserved for renamed files (`git log --follow` shows prior commits)

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Manual V1 | `/help` still lists all renamed skills by new slug | Must |
| Manual | `git log --follow lsa/skills/discover/SKILL.md` shows history | Should |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] No code smells per the constitution
- [ ] lsa-verify passed

---

## Epic 2: Merged discover skill

### Description

Combine `lsa-discover` and `lsa-specify` into a single `lsa/skills/discover/SKILL.md` with a flow-type branch: Standard executes the light 3-question infer-then-confirm; Extended continues into the full specify workflow (3 User Verifications, spec artifact output).

### Scope

- Files/modules touched: `lsa/skills/discover/SKILL.md` (overwrite with merged content)
- Creates / modifies / deletes: rewrites `discover/SKILL.md` to incorporate both behaviors
- Does NOT touch: other skills, cross-references (handled in E4), plugin.json, READMEs

**Covers:** F2, AC1, AC2

### Technical Details

The merged skill follows the Actor template (Goal/Input/Steps/Output/Constraints). Structure:

1. Steps 1-3: Current `lsa-discover` behavior (read .lsa.yaml, infer 3 answers, confirm). Same for both flows.
2. Step 3 branch — **Standard**: render 3-row table, stop.
3. Steps 4+: **Extended**: current `lsa-specify` behavior (scaffold feature dir, branch creation, User Verification 1 → requirements, User Verification 2 → test-suites + design, User Verification 3 → final integration).

The merge is structural (two SKILL.md files combined into one with a flow-type conditional), not behavioral. No new logic introduced. The branch creation (currently in `lsa-specify` Step 3) moves into the Extended path of the merged skill — but `lsa:new` (E3) will also handle branch creation as an alternative entry point, so the merged discover must accept "branch already exists" gracefully (skip branch creation if already on a feature branch).

### Acceptance Criteria

- [ ] AC1: `lsa/skills/discover/SKILL.md` exists with YAML frontmatter name `discover`
- [ ] AC2: Standard flow path produces 3-row table and stops (no spec files)
- [ ] AC3: Extended flow path produces requirements.md, test-suites.md, design.md, tasks.md (empty)
- [ ] AC4: The three User Verifications from lsa-specify are preserved in the Extended path
- [ ] AC5: Skill follows Actor template (Goal/Input/Steps/Output/Constraints)

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Manual V2 | Invoke `lsa:discover` on a Standard-flow task → 3-row table rendered, no files | Must |
| Manual V2 | Invoke `lsa:discover` on an Extended-flow task → full spec artifacts produced | Must |
| Manual | User override during confirm phase works | Should |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] No code smells per the constitution
- [ ] lsa-verify passed

---

## Epic 3: Entry-point skills (new + next)

### Description

Create two new entry-point skills (`lsa/skills/new/SKILL.md` and `lsa/skills/next/SKILL.md`) that eliminate the manual setup friction of starting a feature. `new` creates a branch + runs flow-selector + hands off to discover. `next` reads the roadmap, presents the top backlog pick, confirms, then chains through the same flow.

### Scope

- Files/modules touched: `lsa/skills/new/` (create), `lsa/skills/next/` (create)
- Creates / modifies / deletes: creates 2 new directories with SKILL.md each
- Does NOT touch: existing skills, cross-references (handled in E4), plugin.json, READMEs

**Covers:** F6, F7, NF3, AC7, AC8

### Technical Details

**`lsa/skills/new/SKILL.md`** — Actor template:
- **Goal:** Single-command entry to start a new feature from scratch.
- **Input:** Feature name or intent (argument or first-turn prompt).
- **Steps:**
  1. Accept feature name/intent. Derive kebab-case slug.
  2. Create branch `feature/<slug>` from current HEAD (or main if on main). If branch exists, ask: switch to it or pick different name.
  3. Invoke `core/flow-selector` — present the flow question.
  4. On flow confirmation, hand off to `lsa:discover` with confirmed flow type.
- **Output:** Feature branch exists, discovery phase running.

**`lsa/skills/next/SKILL.md`** — Actor template:
- **Goal:** Pick the highest-priority unstarted backlog item and begin working on it.
- **Input:** None (reads `${specs_root}/roadmap.md`).
- **Steps:**
  1. Read roadmap §"Feature Backlog" table. Filter Status="backlog". Sort: Must > Should > Could.
  2. Present top candidate via `AskUserQuestion`: feature name, priority, notes excerpt. Options: [Start this one] / [Skip — show next] / [Cancel].
  3. On "Skip" — present next candidate. On "Cancel" — stop.
  4. On "Start this one" — derive slug, create branch, invoke `core/flow-selector`, hand off to `lsa:discover`.
- **Output:** Feature branch exists, discovery phase running.

Both skills are orchestrators per NF3 — they hand off to discover, not duplicate its logic.

### Acceptance Criteria

- [ ] AC1: `lsa/skills/new/SKILL.md` exists with YAML frontmatter name `new`
- [ ] AC2: `lsa/skills/next/SKILL.md` exists with YAML frontmatter name `next`
- [ ] AC3: `new` creates a branch and hands off to discover (does not duplicate discovery logic)
- [ ] AC4: `next` reads roadmap, presents pick, confirms, creates branch, hands off to discover
- [ ] AC5: `next` handles empty backlog gracefully (reports nothing to pick)
- [ ] AC6: Both follow Actor template (Goal/Input/Steps/Output/Constraints)

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Manual V1 | `/help` lists `new` and `next` skills | Must |
| Manual V2 | `lsa:new "test feature"` → branch created → flow-selector fires → discover starts | Must |
| Manual V2 | `lsa:next` → roadmap read → pick presented → confirm → branch + discover | Must |
| Manual | `lsa:next` with no backlog items → graceful message | Should |
| Manual | `lsa:new` when branch already exists → offers switch or rename | Should |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] No code smells per the constitution
- [ ] lsa-verify passed

---

## Epic 4: Description rewrites + cross-reference sweep + versioning

### Description

Rewrite every LSA skill YAML frontmatter `description` to state input/output and make workflow order evident. Sweep all cross-references across the entire repo (active files only). Bump `lsa` to v0.8.0, bump `core` if changed. Update both CHANGELOGs and READMEs.

### Scope

- Files/modules touched: every file listed in design.md §"Cross-reference sweep" — `lsa/skills/*/SKILL.md` (frontmatter), `lsa/.claude-plugin/plugin.json`, `lsa/README.md`, `lsa/ARCHITECTURE.md`, `lsa/CHANGELOG.md`, `core/CLAUDE.md`, `core/README.md`, `core/CHANGELOG.md` (if changed), `vision/VISION.md`, `vision/specs/main.spec.md`, `vision/specs/modules/lsa/spec.md`, `vision/specs/modules/core/spec.md`, `vision/specs/roadmap.md`, root `CLAUDE.md`, root `README.md`, `CONTRIBUTING.md`, `lsa/knowledge/conventions.md`
- Creates / modifies / deletes: modifies all listed files (content edits only)
- Does NOT touch: archive files, old CHANGELOG entries (per NF2)

**Covers:** F5, NF1, NF2, AC3, AC4, AC5, AC6

### Technical Details

**Description pattern** (per design.md §"Description rewrites"):

Main-flow skills include position marker:
```
discover: "Discover and specify a feature (step 1 of 4: discover → plan → implement → verify). Input: confirmed flow type from flow-selector. Output: [Standard] 3-row context table; [Extended] full spec artifacts."
plan: "Break a spec into implementation epics (step 2 of 4: discover → plan → implement → verify). Input: approved spec artifacts. Output: tasks.md with ≤5 ordered epics."
verify: "Verify implementation matches the spec (step 4 of 4: discover → plan → implement → verify). Input: completed implementation on feature branch. Output: pass/fail verdict with requirement trace."
```

Entry-point skills:
```
new: "Start a new feature (creates branch → selects flow → discovers). Input: feature name or description. Output: feature branch created, discovery phase running."
next: "Pick and start the next backlog item (reads roadmap → confirms pick → creates branch → discovers). Input: none. Output: feature branch created, discovery phase running."
```

Utility skills (no position marker):
```
init: "Initialize Living Spec Architecture for a project. Input: existing codebase (greenfield or brownfield). Output: .lsa.yaml + specs_root directory + module specs."
reconcile: "Absorb a direct artifact edit into its module spec. Input: artifact file edited outside the spec flow. Output: module spec updated, drift resolved."
revise-constitution: "Propose changes to the project constitution and standards. Input: feature decisions that should become permanent. Output: updated constitution + standards files."
```

**Cross-reference sweep:** Use grep to find all occurrences of old names (`lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-init`, `lsa-reconcile`, `lsa-revise-constitution`, `lsa-sync`) in active files. Replace with new names. Skip archive files per NF2.

**Versioning:**
- `lsa/.claude-plugin/plugin.json` version → "0.8.0"
- `lsa/CHANGELOG.md` — new `## [0.8.0]` entry
- `core/.claude-plugin/plugin.json` version → patch bump (if `core/` files changed)
- `core/CHANGELOG.md` — new patch entry (if changed)
- `vision/specs/roadmap.md` — status of this feature row → "shipped — lsa v0.8.0"

### Acceptance Criteria

- [ ] AC1: No active file in the repo contains `lsa-discover`, `lsa-specify`, `lsa-plan`, `lsa-verify`, `lsa-init`, `lsa-reconcile`, `lsa-revise-constitution`, or `lsa-sync` (except archive files and old CHANGELOG entries)
- [ ] AC2: Every LSA skill YAML frontmatter `description` states input and output
- [ ] AC3: Reading the 4 main-flow skill descriptions together reveals the order discover → plan → implement → verify
- [ ] AC4: `lsa/.claude-plugin/plugin.json` version is "0.8.0"
- [ ] AC5: `lsa/CHANGELOG.md` has a `[0.8.0]` entry documenting all changes
- [ ] AC6: `vision/specs/roadmap.md` shows this feature as shipped
- [ ] AC7: `lsa:sync` and `lsa:lsa-sync` do not resolve to any skill (sync is removed)

### Testing Plan

| Test Type | What to Cover | Priority |
|-----------|--------------|----------|
| Manual V1 | All 9 skills listed in `/help` with correct names | Must |
| Manual V2 | Each renamed command responds to new name | Must |
| Grep | `grep -r "lsa-discover\|lsa-specify\|lsa-plan\|lsa-verify\|lsa-init\|lsa-reconcile\|lsa-revise-constitution\|lsa-sync" --include="*.md" --include="*.json" --include="*.yaml"` returns only archive/CHANGELOG hits | Must |
| Manual | Attempt `lsa:sync` → skill not found | Must |

### Definition of Done

- [ ] All ACs pass
- [ ] Tests written and passing
- [ ] No code smells per the constitution
- [ ] lsa-verify passed

---

## Integration Checklist

- [ ] All epics merged into feature branch
- [ ] Manual V1 probe passes (all 9 skills listed)
- [ ] Manual V2 probes pass (each skill triggers correctly)
- [ ] Cross-reference grep clean (no stale old names in active files)
- [ ] lsa-verify passed on feature branch
- [ ] PR to main created
