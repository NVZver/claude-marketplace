---
name: init
description: Initialize the LSA spec tree on a project. Output: spec tree + module specs.
---

> **Trace.** On load, print first: `=============== [lsa/skills/init/SKILL.md] [lsa] ===============`

# LSA Init

See [CORE.md](../../CORE.md).

## Role

Project scaffolder.

## Goal

Stand up the LSA spec tree so the other skills can run.

## Inputs

| Input | Source |
|-------|--------|
| `.lsa.yaml` (or defaults) | `self` |
| Existing code (brownfield module inference) | `discover` |

## Steps

1. Resolve config — `constitution` / `specs_root` / `mode` (defaults: `.lsa/VISION.md`, `.lsa/`, `code`); print it. (→ config)
2. **Greenfield:** create under `${specs_root}/` — `main.spec.md`, `roadmap.md`, `research-backlog.md`, `modules/`, `features/`, `standards/{code,testing}.md`, `archive/`; fill `standards/` from the constitution. (→ spec tree)
3. **Brownfield:** via `discover`, infer one `modules/<name>/spec.md` per logical module from `artifact_paths` (or `/src`); tag every inferred line `[ASSUMPTION]` (CORE §1); show, approve, write. (→ module specs)
4. **Project map:** run the shipped builder — prefer `bash "${CLAUDE_PLUGIN_ROOT}/scripts/project-map-build.sh"` when `CLAUDE_PLUGIN_ROOT` points at the installed `lsa` plugin; otherwise `bash lsa/scripts/project-map-build.sh` from a marketplace checkout. Observable result: repo-root `project-map.yaml` exists (3-level dir/file tree). Skip only if the script cannot be found — note the gap; discover falls back to a tree-walk. (→ project-map.yaml)

## Output

A populated spec tree at `${specs_root}`, plus repo-root `project-map.yaml` when the builder script ran.

## Constraints

- **Never overwrite existing specs** — abort and name the conflict. **Never invent modules** not derivable from `artifact_paths` or `/src`.

---

`/lsa:init` — manual invocation.
