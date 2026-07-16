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
2. **Greenfield:** create under `${specs_root}/` — `main.spec.md`, **`roadmap.yaml`** (YAML ledger SoT — starter below), `research-backlog.md`, `modules/`, `features/`, `standards/{code,testing}.md`, `archive/`; fill `standards/` from the constitution. **Do not create `roadmap.md`.** Starter ledger (write exactly):

   ```yaml
   version: 1
   items: []
   shipped_history: []
   ```

   After writing, quote the new `roadmap.yaml` inline (and a one-line list of the other created paths) per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 — never "spec tree created" without the quoted ledger. Observable result: `${specs_root}/roadmap.yaml` exists and is quoted; `${specs_root}/roadmap.md` does not. (→ spec tree)
3. **Existing markdown roadmap:** if `${specs_root}/roadmap.md` exists and `${specs_root}/roadmap.yaml` does not (or both exist), **do not** invent a second SoT by hand — load and follow [`../../knowledge/migration-instructions-ai.md`](../../knowledge/migration-instructions-ai.md) (migrate → verify → rewire → cleanup). Observable result: migration report cited, or an explicit skip with reason. (→ migrated ledger or deferred)
4. **Brownfield modules:** via `discover`, infer one `modules/<name>/spec.md` per logical module from `artifact_paths` (or `/src`); tag every inferred line `[ASSUMPTION]` (CORE §1); show, approve, write. (→ module specs)
5. **Project map:** run the shipped builder — prefer `bash "${CLAUDE_PLUGIN_ROOT}/scripts/project-map-build.sh"` when `CLAUDE_PLUGIN_ROOT` points at the installed `lsa` plugin; otherwise `bash lsa/scripts/project-map-build.sh` from a marketplace checkout. Observable result: repo-root `project-map.yaml` exists (3-level directory tree). Skip only if the script cannot be found — note the gap; discover falls back to a tree-walk. (→ project-map.yaml)

## Output

A populated spec tree at `${specs_root}` with **`roadmap.yaml` as the only roadmap SoT**, plus repo-root `project-map.yaml` when the builder script ran.

## Constraints

- **Never overwrite existing specs** — abort and name the conflict. **Never invent modules** not derivable from `artifact_paths` or `/src`.
- **YAML ledger is the default.** Never scaffold `roadmap.md` for new projects. Dual SoT (`roadmap.md` + `roadmap.yaml`) is forbidden after migration — see [`../../knowledge/migration-instructions-ai.md`](../../knowledge/migration-instructions-ai.md).

---

`/lsa:init` — manual invocation.
