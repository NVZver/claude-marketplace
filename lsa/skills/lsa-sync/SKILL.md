---
name: lsa-sync
description: Syncs a completed feature spec into permanent module specs and archives the feature. Use whenever a feature has passed `lsa-verify`, when the user says "sync the spec", "archive this feature", "merge and sync", or "feature is done". Mandatory before merging any feature branch to `main`.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-sync/SKILL.md] [lsa] ===============`


# LSA Sync

## Goal

Extract the feature delta into permanent module specs, archive the feature spec, record per-module last-sync SHAs in `.lsa-sync-state.json` (used by `lsa-reconcile` and the SessionStart drift hook), and aggregate per-feature metrics into a repo-level summary.

## Input

- A verified feature branch (lsa-verify returned clean PASS).
- `.lsa.yaml` for `constitution` path, `specs_root`, and `modules.*` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/features/<feature-name>/requirements.md`
   - `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   - `${specs_root}/features/<feature-name>/design.md`
   - `${specs_root}/features/<feature-name>/tasks.md`
   - `${specs_root}/modules/<name>/spec.md` for each module this feature touched
   - `${specs_root}/main.spec.md`

   Observable result: per-source one-liner printed per the protocol.

2. **Extract delta.** From the feature spec, identify only system-level decisions to carry forward:
   - New behaviors added to a module
   - New non-functional constraints
   - New or modified cross-module contracts
   - New or modified API endpoints and data types from `contract.yaml` (if exists)
   - Technical decisions that apply to future features

   Do NOT extract: task statuses, implementation details, scaffolding, or anything specific to this feature that does not affect how the system works going forward.

   Produce a delta summary:

   ```markdown
   ## Delta: [Feature Name]
   Date: [date]

   ### Module Deltas
   | Module | Type | Decision |
   |--------|------|----------|
   | ...    | new behavior / constraint / contract | ... |

   ### Cross-Module Contracts
   [New or modified. If none, write "none"]

   ### main.spec.md Updates
   [Module index changes, new global NFRs. If none, write "none"]
   ```

   Present: Module Deltas table (Module / Type / Decision) + specs-touched list (module → spec path) + main.spec.md updates list + decision `[a] apply → module specs edited; feature archived next` / `[b] modify → revise delta, re-present` / `[c] reject → stop, sync aborted`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Wait for explicit approval before writing any files. Observable result: delta scratch quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 — full single-change block when the delta is ≤10 lines, compressed inspection table when larger; human approval logged.

3. **Merge into module specs.** For each affected module:
   1. Open `${specs_root}/modules/<module-name>/spec.md`.
   2. Append or extend the relevant sections with delta content.
   3. Do not rewrite or delete existing content.
   4. If a conflict exists between new and existing content, stop and ask human.

   Observable result: per-module diff shown inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 — full single-change block when the merge is ≤10 lines, compressed inspection table when larger.

4. **Update `main.spec.md`.**
   - Add new modules to the module index if created.
   - Add new global NFRs or contracts if any.
   - If `contract.yaml` exists, update the Cross-Module Contracts section with new or modified endpoints and data types.

   Observable result: `${specs_root}/main.spec.md` updated; diff quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 — full single-change block when ≤10 lines, compressed inspection table when larger.

5. **Archive feature spec.**

   ```bash
   mv ${specs_root}/features/<feature-name>/ ${specs_root}/archive/$(date +%Y-%m-%d)-<feature-name>/
   ```

   `${specs_root}/features/` must be empty after this step (for this feature). Observable result: `mv` command echoed back with source + destination paths quoted inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (mark type tag) — names the archived directory at `${specs_root}/archive/<date>-<feature-name>/`, names the now-absent `${specs_root}/features/<feature-name>/` source.

6. **Update `.lsa-sync-state.json`** at the repo root (sibling of `.lsa.yaml`). Shape:

   ```json
   {
     "modules": {
       "<name>": {
         "last_sync_sha": "<HEAD-SHA>",
         "last_sync_iso": "<ISO-8601 timestamp>"
       }
     }
   }
   ```

   If the file exists, update only the modules touched by this feature; preserve other modules' entries. If absent, create it. Observable result: the new `.lsa-sync-state.json` fragment per touched module quoted back inline as a fenced `json` code block per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (edit type tag) — names the fresh SHA + ISO timestamp; full single-change block when ≤10 lines, compressed inspection table when larger.

7. **Aggregate metrics (optional).** If `${specs_root}/archive/$(date +%Y-%m-%d)-<feature-name>/metrics.md` exists (i.e., `lsa-verify` wrote it on clean PASS for this Extended-flow feature; was `T3`), append a one-line row to `${specs_root}/metrics.md` (create the file with a header if absent). One row per archived feature. Observable result: the appended row quoted back inline per [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 (append type tag) — names `${specs_root}/metrics.md` path with line number, quotes the verbatim row content.

8. **Sync report.**

   ```markdown
   # Sync Report: [Feature Name]
   Date: [date]

   ## Module Specs Updated
   | Module | Changes |
   |--------|---------|
   | ...    | ... |

   ## main.spec.md Updated
   [yes — what changed / no]

   ## Archived To
   ${specs_root}/archive/[date]-[feature-name]/

   ## .lsa-sync-state.json
   [modules updated]

   ## Aggregate metrics
   [row appended / no metrics.md present]

   ## PR Checklist
   - [ ] Module specs reviewed by human
   - [ ] main.spec.md reviewed by human
   - [ ] Feature spec archived
   - [ ] Branch ready for PR to main
   ```

   Verdict carries a preamble per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 6. Present the preamble in the user's frame — e.g., *"Module specs for `<modules>` now reflect the merged feature — the docs are current, and the next decision is just whether to open the PR now or later."* — then: APPLIED verdict + updated-modules list (module → spec path) + main.spec.md updated note + archive path + count of module SHAs bumped in `.lsa-sync-state.json`. **Closing offer (optional, not a gate).** Sync is complete at this point — module specs are written, the feature is archived, the branch is ready for PR. Offer *one* closing picker: *"Create PR now? — Yes (run `gh pr create`) / No (hold; PR later)"*. **Silent-default = `hold`** — if the human does not respond, the skill exits cleanly with the branch ready; no PR is created without explicit `Yes`. Apply the [`core/output`](../../../core/skills/output/SKILL.md) Rule 5 *Genuine-fork test*: this is a next-step offer the user can override, not a mid-flow fork the skill must resolve before proceeding. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` in Claude Code if the offer is shown. Observable result: report on screen; if the human picks `Yes`, `gh pr create` runs; on `No` or silence, the skill exits with the branch held.

## Output

Updated module specs, updated `${specs_root}/main.spec.md`, archived feature directory at `${specs_root}/archive/YYYY-MM-DD-<feature-name>/`, updated `.lsa-sync-state.json` at repo root, optional appended row in `${specs_root}/metrics.md`, and a sync report.

## Constraints

- **Human reviews the delta before any spec write.** No silent merges into module specs.
- **Never delete content** during sync. Conflicts halt the skill.
- **Preserve other modules' state** when writing `.lsa-sync-state.json`. Only touch the keys for modules involved in this feature.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:sync` — manual invocation.
