---
name: implement
description: "Plan and run parallel implementation of roadmap epics. Computes a dependency-ordered WAVE PLAN via the disjoint-epic decomposer, PROPOSES it for approval, then dispatches one agent per epic in an isolated git worktree, gates each via the independent lsa:reconcile + the .lsa.yaml gate: checks, and converges via the serialized merge. Honors the .lsa.yaml autonomy ladder (manual = human merges · semi = auto-merge on green · auto = + deploy + healthcheck; default manual). Input: [epics] (slug/path list) + optional --parallel / --sequential. The no-arg form is a read-only preview of parallelizable backlog items. Output: an approved wave plan, per-epic worktree/PR dispatch, and a gate-proven fleet roll-up (an epic is reported merged @ <sha> / deployed only when the gate proved it). Reads ${specs_root}/roadmap.md."
---

> **Trace.** On load, print first: `=============== [manager/skills/implement/SKILL.md] [manager] ===============`


# Implement

Run a set of roadmap epics in parallel, safely. The engine computes which epics can run at the same time (the **disjoint-epic decomposer**), proposes a **wave plan**, and on approval dispatches one agent per epic into an isolated git worktree, gates each with the Epic 1 safety core (the independent `lsa:reconcile` + the `.lsa.yaml` `gate:` checks), and converges via the serialized merge. The orchestration logic lives in [`../../knowledge/parallel-dispatch.md`](../../knowledge/parallel-dispatch.md) and [`../../knowledge/serialized-merge.md`](../../knowledge/serialized-merge.md); this skill is the actor that drives them.

**Autonomy.** The full ladder is implemented (per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md)): `manual` (default — the human merges), `semi` (auto-merge on green), `auto` (+ deploy + healthcheck, rollback on failure). The gate is identical at every level; no level auto-merges into `main`. The run ends with the fleet roll-up ([`../../knowledge/fleet-rollup.md`](../../knowledge/fleet-rollup.md)).

## Goal

Take a set of epics and get each one built, gated, and ready to merge in parallel without the agents colliding — while never reporting a state the gate did not prove. The human approves the plan before any dispatch and performs the merge; the engine does the isolation, gating, and serialization in between.

## Input

- **`[epics]`** — a list of epic slugs or paths to run. **When absent, the skill runs the read-only preview** (Step 1a) instead of dispatching — it lists the most recent `backlog` / `not started` roadmap rows with an indicative parallel note, so the bare form does something useful (per [`../../knowledge/command-naming.md`](../../knowledge/command-naming.md) §"The no-arg form does something useful").
- **`--parallel` / `--sequential`** — optional overrides. `--sequential` forces one epic per wave (one-at-a-time). `--parallel` forces a single wave (the user asserts disjointness, overriding the decomposer — and takes responsibility for it).
- **`.lsa.yaml` autonomy** — `manual | semi | auto`, default `manual`, per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md). `manual` = human merges; `semi` = auto-merge on green; `auto` = + deploy + healthcheck (with rollback on failure). All three are implemented; the gate is identical at every level.
- The `.lsa.yaml` `gate:` contract ([`../../../lsa/knowledge/quality-gate-contract.md`](../../../lsa/knowledge/quality-gate-contract.md)) and the fast-path read contract ([`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md)).

## Steps

1. **Resolve targets + autonomy.** Read `[epics]`, any `--parallel` / `--sequential` flag, and the `.lsa.yaml` autonomy level (`manual | semi | auto`, default `manual` — per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md)). If no `[epics]` were supplied, go to Step 1a (preview) and stop. Observable result: the target epic list + the resolved autonomy level, or a branch to the preview.

   - **1a. No-arg preview (read-only).** `Read` `${specs_root}/roadmap.md`, locate `## Feature Backlog`, collect the last ~5 `backlog` / `not started` rows per the fast-path discipline ([`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — single read, exact anchor, no sub-agent). Quote each with a `file:line` citation; add an **indicative** parallel-vs-sequential note explicitly marked non-authoritative; state that passing `[epics]` runs them. Write nothing, dispatch nothing. Observable result: a cited candidate list + a "preview only — pass epics to run" close.

2. **Compute the wave plan.** Apply the disjoint-epic decomposer + wave planning ([`../../knowledge/parallel-dispatch.md`](../../knowledge/parallel-dispatch.md) §1–2) to the target epics: build the overlap graph (file/module overlap · output dependency · shared new data structure), group non-overlapping epics into waves, order waves by dependency. `--sequential` → one epic per wave; `--parallel` → one wave (record that the user asserted disjointness). When unsure, treat epics as overlapping. Observable result: an ordered wave plan, each epic tagged with its wave and the reason for any forced serialization.

3. **Propose the wave plan — human gate (before any dispatch).** Present the plan in full: the waves, the per-epic worktree + `feature/<epic-slug>` branch, the concurrency cap, and the disjointness rationale for each pairing. Require explicit approval before dispatching anything (ownership-over-automation, `core/ground-rules` Rule 0). The gate is self-contained — the plan rides in the message/`AskUserQuestion` the user sees, never only in a sub-agent payload (per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 5 *Self-contained gates* + Rule 7 *Delivery test*). On reject/adjust, recompute and re-propose. Observable result: an approved (or adjusted) wave plan; nothing dispatched without approval.

4. **Dispatch each wave (parallel within, sequential across).** For the current wave, dispatch up to the concurrency cap (default ~4) — one agent per epic, each in its own git worktree (`isolation: worktree`) on `feature/<epic-slug>` branched from the integration branch. Each agent runs the LSA loop (`discover → specify → verify → delegate → reconcile`) for its epic. Epics beyond the cap queue. When an agent finishes, run the Epic 1 gate: the **independent** `lsa:reconcile` (a context that cannot edit what it grades) + the `.lsa.yaml` `gate:` checks. Tear down each worktree when its epic merges or is abandoned; a worktree that cannot be torn down is an open item. A later wave starts only after every epic in the prior wave has **merged**. Observable result: per-epic gate outcomes (pass/fail, with cited gate output) and worktree teardown status.

5. **Converge — serialized merge, per autonomy level.** Merge per [`../../knowledge/serialized-merge.md`](../../knowledge/serialized-merge.md): one PR at a time, tested against the up-to-date base, merge only the tested SHA. The autonomy level (Step 1) decides the boundary behavior, per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md): **`manual`** stops and presents each gate-green PR (SHA + gate artifact) for the human to merge; **`semi`** auto-merges each PR on green into the integration branch without a per-merge prompt; **`auto`** does `semi` then runs the project's configured `deploy` command + `healthcheck` and may report `deployed` only after the healthcheck passes — on healthcheck failure it runs the configured rollback and reports the deploy `failed`. The gate must be green at every level; autonomy removes only the prompt. No level auto-merges into `main`. Only the serialized-merge step writes `${specs_root}/roadmap.md` status, after the merge lands. Observable result: each PR merged-by-human (`manual`) or auto-merged-on-green (`semi`/`auto`), plus deploy+healthcheck results at `auto`; roadmap status written only post-merge.

6. **Report — the fleet roll-up.** Emit the end-of-run roll-up per [`../../knowledge/fleet-rollup.md`](../../knowledge/fleet-rollup.md): the per-epic table (epic · agent · wave · gate verdict · state · proof), the files-changed section reusing the `core/output` Rule 7 inspection table grouped by Conventional-Commits `type(scope)`, the proven-facts line (checks passed, SHAs, healthcheck), and the open-items line (failed epics, un-torn-down worktrees, pending merges, deploy gaps). Every `state` obeys Rule 7 — `merged @ <sha>` / `deployed` only when proven and cited; `attempted` / `pending` otherwise. Observable result: a one-screen roll-up where every completion state carries cited proof and nothing is buried.

## Output

An approved wave plan; per-epic isolated-worktree dispatch with independent gating; a serialized, human-performed merge (manual autonomy); and a per-epic status report in which every completion state is gate-proven and cited. The no-arg form is a read-only preview. The skill never claims execution or a merge it did not prove.

## Constraints

- **Propose before dispatch.** No worktree is created and no agent is spawned before the human approves the wave plan (Step 3). The smart default is propose; the human owns the go.
- **Autonomy ladder.** `manual` (human merges), `semi` (auto-merge on green), `auto` (+ deploy + healthcheck, with rollback on healthcheck failure) — all implemented; default `manual`. No level auto-merges into `main`; the human always owns the final integration → `main` merge. `deployed` is reported only after the healthcheck passes. The gate must be green at every level.
- **Done is a gate-proven, cited predicate.** Report `merged @ <sha>` only when the serialized merge landed and the gate proved it, citing the artifact; everything else is `attempted`/`pending` with evidence. Per [`../../../core/skills/ground-rules/SKILL.md`](../../../core/skills/ground-rules/SKILL.md) Rule 7 + pitch Definition of success #1.
- **Isolation + teardown are mandatory.** One worktree/branch/PR per epic; tear every worktree down; report any that survive.
- **Disjointness is conservative.** When unsure, serialize. `--parallel` overrides the decomposer but shifts the disjointness responsibility to the user; it does not lower the gate.
- **The grader is independent.** `lsa:reconcile` runs in a context with no write access to the tests / `.feature` scenarios / `gate:` it judges (Epic 1, `lsa` 0.18.0).
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link/quote, never restated.

---

`/manager:implement [epics] [--parallel|--sequential]` — manual invocation. Bare `/manager:implement` previews.
