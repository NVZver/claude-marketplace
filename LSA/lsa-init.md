---
name: lsa-init
description: >
  Initializes the Living Spec Architecture (LSA) for a project. Use this skill whenever
  the user says "initialize LSA", "set up specs", "init the spec structure", starts a new
  project from scratch, or wants to retrofit specs onto an existing codebase. Also triggers
  when CLAUDE.md exists but /specs/ directory does not. This skill MUST run before any
  other LSA skill can be used.
---

# LSA Init

## Step 1 — Read Sources

1. `/CLAUDE.md` (mandatory)
2. Module-level `CLAUDE.md` files if present

## Step 2 — Determine Mode

Ask the human: **"Greenfield (empty project) or brownfield (existing codebase)?"**

### Greenfield

Create this structure:

```
/specs/
  main.spec.md
  roadmap.md
  research-backlog.md
  /modules/
  /features/
  /ground-rules/
    code.md
    testing.md
    agents.md
  /archive/
```

Populate `/specs/ground-rules/` by extracting the relevant sections from `/CLAUDE.md`.
`/specs/modules/` starts empty.

### Brownfield

1. Scan `/src`
2. For each logical module found, create `/specs/modules/<module-name>/spec.md`
3. Infer functional requirements from code. Mark every inferred item `[INFERRED — verify]`
4. Stop. Tell human: **"Skeleton specs generated. Review and confirm before I continue."**
5. Wait for explicit human confirmation.

## Step 3 — Write Spec Files

Write `/specs/main.spec.md`:

```markdown
# [Project Name] — Main Spec

## Purpose
[From CLAUDE.md]

## Module Index
| Module | Spec | Status |
|--------|------|--------|
| [name] | /specs/modules/[name]/spec.md | active / stub |

## Cross-Module Contracts
[API boundaries, shared types, event contracts]

## Non-Functional Requirements
[From CLAUDE.md]
```

Write `/specs/roadmap.md`:

```markdown
# Roadmap

## Feature Backlog
| Feature | Priority | Status | Notes |
|---------|----------|--------|-------|
```

Write `/specs/research-backlog.md`:

```markdown
# Research Backlog

| Date | Topic | Summary | Recommendation | Status |
|------|-------|---------|----------------|--------|
```

## Step 4 — Report to Human

List all files created. State: "Run `/lsa:specify` to start the first feature."

---

`/lsa:init` — manual invocation
