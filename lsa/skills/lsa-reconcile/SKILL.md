---
name: lsa-reconcile
description: Absorbs direct artifact edits into the matching module spec (Level 2.5) — never blocks or reverts the edit. Use after direct edits to artifact files (a `SKILL.md`, a config, a plugin file edited by hand), or when SessionStart warns of drift.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-reconcile/SKILL.md] [lsa] ===============`


# LSA Reconcile

Implements the Level 2.5 reconcile loop from `vision/VISION.md:135` — when an artifact diverges from its spec, the spec absorbs reality rather than blocking the edit. One module at a time — stop and present each delta individually; do not proceed without explicit approval.

## Goal

Close the drift between artifact reality and module specs by absorbing each delta into the spec — Level 2.5 (`vision/VISION.md:138`).

## Input

- `.lsa.yaml` at repo root, providing the per-module `artifact_paths` and `spec` map.
- `.lsa-sync-state.json` at repo root, providing the last-sync commit SHA per module. If absent, treat the first commit on `main` as the baseline (do not error).
- The current git state of the working tree.

## Steps

> The 8-element drift block below is the exemplar that [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 generalizes from.

1. **Per-module drift diff.** For each module in `.lsa.yaml`, run `git diff <recorded-sha> -- <artifact_paths>` (working-tree against the recorded SHA — **no `..HEAD` suffix**; that form misses uncommitted edits, which is the very case `vision/VISION.md:138` is designed for). Observable result: a per-module diff summary printed (file count + line count + one-line summary of what changed).

2. **Exit if clean.** If no module has drift, print "no drift detected" and **stop**. No further steps.

3. **Classify each delta** as either:
   - **Class (a) — change to existing behavior** — the spec already has a requirement that's now contradicted by the artifact.
   - **Class (b) — new behavior** — the artifact introduces something the spec doesn't cover.

   Observable result: a draft "spec delta" block written to the working scratch for each module-with-drift, with the classification noted alongside.

4. **Per-module — stop and present each delta individually; do not proceed without explicit approval.** Verdict carries a preamble per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 6. Present each delta individually with the preamble in the user's frame — e.g., *"The auth spec says sessions expire after 24 hours, but the code now sets 7 days — one needs to win, otherwise the next review will block the merge until you pick one."* — then: DRIFT verdict + module name + file/line counts + classification (a or b) + verbatim spec quote with path:line + verbatim artifact quote with path:line + proposed one-line spec update + decision `[a] apply → spec edited in place (class a) or appended (class b); SHA bumped` / `[b] reject → spec untouched; row added to research-backlog.md`. Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for the decision. Observable result: the human picks per module. No implicit approvals.

5. **On confirm — reverse-sync** per `vision/VISION.md:143` (*"reverse-sync — the spec absorbs reality"*):
   - **Class (a) — update in place.** Edit the contradicted requirement line(s) so the spec now states the new behavior. **Replace, don't append next to.** Worked example from `vision/VISION.md:141`: the spec said *"sessions expire at 30 days"*; on confirm the spec is edited in-place to *"sessions expire at 7 days"*.
   - **Class (b) — append new requirement.** Add a new requirement line in the appropriate section of the module spec. (True append, not a "Drift absorbed" heading — that approach was rejected because it leaves the spec self-contradictory.)
   - **Update `.lsa-sync-state.json`** with the new HEAD SHA for that module (and a fresh ISO timestamp). Preserve other modules' entries.

   Observable result: the spec file is edited (specific line(s) shown in the diff); the state file is updated with the new SHA.

6. **On reject — leave the spec untouched.** Optionally append the rejected delta as a one-line row to `${specs_root}/research-backlog.md` so the question doesn't disappear. Observable result: spec file unchanged for that module; (optional) backlog row added.

## Output

- Updated module specs (those confirmed; in-place edit for class (a), append for class (b)).
- Updated `.lsa-sync-state.json` with new HEAD SHA per module-confirmed.
- A one-paragraph summary of what was absorbed and what was rejected.

## Constraints

- **Never block, revert, or reformat the artifact edits themselves.** Per `vision/VISION.md:144`: *"It does NOT block or revert."* The reconcile flow only edits the spec; the artifact is the source of truth.
- **Never leave the spec self-contradictory.** Class (a) replaces the contradictory value — it does not append the new value while leaving the old one in place.
- **One module at a time** — never bundle multiple modules into a single confirm gate.
- **If `.lsa-sync-state.json` is missing, initialize.** Treat as if the recorded SHA is the first commit on `main`, print a one-line note, and proceed; do not error.
- **If the recorded SHA is unreachable** (force-push, history rewrite) treat the failure as "first sync" — proceed with HEAD as the new baseline, print a warning.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:reconcile` — manual invocation. Also surfaced by the SessionStart drift-warning hook (see `lsa/hooks/hooks.json`).
