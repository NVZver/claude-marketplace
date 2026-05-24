---
name: init
description: Initialize Living Spec Architecture for a project. Input: existing codebase (greenfield or brownfield). Output: .lsa.yaml + specs_root directory + module specs.
---

> **Trace.** On load, print first: `=============== [lsa/skills/init/SKILL.md] [lsa] ===============`


# LSA Init

## Goal

Scaffold the LSA spec tree on a project so the rest of the LSA skills (`discover`, `plan`, `verify`, `new`, `next`, `reconcile`, `revise-constitution`) can run against it.

## Input

- Project root containing the configured constitution file (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").
- Optional `.lsa.yaml` at repo root.
- Human-confirmed mode: **greenfield** (empty project) or **brownfield** (existing codebase).

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix: any module-level constitution-fragment files if present. Observable result: a short note printing `constitution=<path>`, `specs_root=<path>`, `mode=<value>` so the human can confirm the config is correctly picked up.

2. **Determine mode (mechanical).** If `${specs_root}/modules/` is empty (or absent) AND `.lsa.yaml: modules.*` contains no configured `artifact_paths`, the mode is **greenfield**; otherwise **brownfield**. Print the determination back to the human (e.g., `Detected mode: brownfield (modules.*.artifact_paths populated).`) and ask the human to confirm. Observable result: mode determined mechanically + confirmed by human.

   ### Greenfield

   Create this structure under `${specs_root}`:

   ```
   ${specs_root}/
     main.spec.md
     roadmap.md
     research-backlog.md
     modules/
     features/
     standards/
       code.md
       testing.md
     archive/
   ```

   Populate `${specs_root}/standards/` by extracting the relevant sections from `${constitution}`. `${specs_root}/modules/` starts empty.

   ### Brownfield

   1. Scan the artifact paths configured for each module in `.lsa.yaml: modules.*.artifact_paths` (fall back to scanning `/src/` if `.lsa.yaml` is absent — the v0.1.1 behavior).
   2. For each logical module found, create `${specs_root}/modules/<module-name>/spec.md`.
   3. Infer functional requirements from the artifacts. Mark every inferred item `[assumption: inferred from <source>; verify]`.
   4. **Stop.** Present: PROPOSED verdict (`<N>` modules inferred) + per-module table (Module / Source path-glob with file count / Confidence with reason) + reminder that each generated spec is tagged `[assumption: inferred from <source>; verify]` + decision. **Prompt voice (per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 5).** Picker **question** names the project subject — *"Write `<N>` inferred module specs for this project?"* — not *"Approve brownfield init?"* (`brownfield` is project jargon). Option **labels**:

   - `[a]` write all `<N>` specs → I create them under `${specs_root}/modules/` and you proceed to `/lsa:discover`
   - `[b]` write only some — I'll ask which → I re-prompt per module
   - `[c]` reject all → no files written; reconsider module boundaries

   Format per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code (per `core/CLAUDE.md` operational checkpoint #1).
   5. Wait for explicit human confirmation before writing any spec files.

   Observable result: the spec tree exists on disk after approval; the human confirms the skeleton.

3. **Write spec files.** Write `${specs_root}/main.spec.md`:

   ```markdown
   # [Project Name] — Main Spec

   ## Purpose
   [From the constitution]

   ## Module Index
   | Module | Spec | Status |
   |--------|------|--------|
   | [name] | ${specs_root}/modules/[name]/spec.md | active / stub |

   ## Cross-Module Contracts
   [API boundaries, shared types, event contracts]

   ## Non-Functional Requirements
   [From the constitution]
   ```

   Write `${specs_root}/roadmap.md`:

   ```markdown
   # Roadmap

   ## Feature Backlog
   | Feature | Priority | Status | Notes |
   |---------|----------|--------|-------|
   ```

   Write `${specs_root}/research-backlog.md`:

   ```markdown
   # Research Backlog

   | Date | Topic | Summary | Recommendation | Status |
   |------|-------|---------|----------------|--------|
   ```

   Observable result: the three files exist with the templates above.

4. **Report to human.** List all files created. State: "Run `/lsa:discover` (Standard / Extended entry) or `/lsa:specify` (Extended direct) to start the first feature."

## Output

A populated spec tree at `${specs_root}` (greenfield) or skeleton module specs (brownfield, pending human confirmation), plus an inventory printed back to the human.

## Constraints

- **Never overwrite existing specs.** If `${specs_root}/` already exists with non-empty content, abort with a message naming the conflicting paths and ask the human to relocate or rename before re-running.
- **Never invent module structure** in brownfield mode that is not derivable from `artifact_paths` (or `/src/` as the documented fallback). Every inferred requirement is tagged `[assumption: inferred from <source>; verify]` per [`../../../core/skills/ground-rules/SKILL.md`](../../../core/skills/ground-rules/SKILL.md) Rule 1.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:init` — manual invocation.
