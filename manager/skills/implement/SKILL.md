---
name: implement
description: "Plan and run parallel implementation of roadmap epics. Computes a dependency-ordered WAVE PLAN via the disjoint-epic decomposer, PROPOSES it for approval, then dispatches one agent per epic in an isolated git worktree, gates each via the independent lsa:reconcile + the .lsa.yaml gate: checks, and converges via the serialized merge — at MANUAL autonomy (the human performs the merge). Input: [epics] (slug/path list) + optional --parallel / --sequential. The no-arg form is a read-only preview of parallelizable backlog items. Output: an approved wave plan, per-epic worktree/PR dispatch, and a gate-proven per-epic status report (an epic is reported merged @ <sha> only when the gate proved it). Reads ${specs_root}/roadmap.md; honors .lsa.yaml autonomy (default manual)."
---

> **Trace.** On load, print first: `=============== [manager/skills/implement/SKILL.md] [manager] ===============`


# Implement

Run a set of roadmap epics in parallel, safely. The engine computes which epics can run at the same time (the **disjoint-epic decomposer**), proposes a **wave plan**, and on approval dispatches one agent per epic into an isolated git worktree, gates each with the Epic 1 safety core (the independent `lsa:reconcile` + the `.lsa.yaml` `gate:` checks), and converges via the serialized merge. The orchestration logic lives in [`../../knowledge/parallel-dispatch.md`](../../knowledge/parallel-dispatch.md) and [`../../knowledge/serialized-merge.md`](../../knowledge/serialized-merge.md); this skill is the actor that drives them.

**Autonomy.** Only `manual` autonomy is implemented (the engine prepares everything and stops at the merge boundary for the human). `semi` (auto-merge on green) and `auto` (deploy + healthcheck) are owned by `parallel-agent-delivery` Epics 3/4 ([`../../../.lsa/pitches/parallel-agent-delivery.md`](../../../.lsa/pitches/parallel-agent-delivery.md)); the fleet-scope roll-up is Epic 4.

## Goal

Take a set of epics and get each one built, gated, and ready to merge in parallel without the agents colliding — while never reporting a state the gate did not prove. The human approves the plan before any dispatch and performs the merge; the engine does the isolation, gating, and serialization in between.

## Input

- **`[epics]`** — a list of epic slugs or paths to run. **When absent, the skill runs the read-only preview** (Step 1a) instead of dispatching — it lists the most recent `backlog` / `not started` roadmap rows with an indicative parallel note, so the bare form does something useful (per [`../../knowledge/command-naming.md`](../../knowledge/command-naming.md) §"The no-arg form does something useful").
- **`--parallel` / `--sequential`** — optional overrides. `--sequential` forces one epic per wave (one-at-a-time). `--parallel` forces a single wave (the user asserts disjointness, overriding the decomposer — and takes responsibility for it).
- **`.lsa.yaml` autonomy** — `manual | semi | auto`, default `manual`, per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md). `manual` (human merges) and `semi` (auto-merge on green) are implemented; `auto` (deploy + healthcheck) is Epic 4 and is clamped to `semi` with a one-line notice.
- The `.lsa.yaml` `gate:` contract ([`../../../lsa/knowledge/quality-gate-contract.md`](../../../lsa/knowledge/quality-gate-contract.md)) and the fast-path read contract ([`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md)).

## Steps

1. **Resolve targets + autonomy.** Read `[epics]`, any `--parallel` / `--sequential` flag, and the `.lsa.yaml` autonomy level (`manual | semi | auto`, default `manual`; `auto` clamps to `semi` with a one-line notice — per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md)). If no `[epics]` were supplied, go to Step 1a (preview) and stop. Observable result: the target epic list + the resolved autonomy level, or a branch to the preview.

   - **1a. No-arg preview (read-only).** `Read` `${specs_root}/roadmap.md`, locate `## Feature Backlog`, collect the last ~5 `backlog` / `not started` rows per the fast-path discipline ([`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — single read, exact anchor, no sub-agent). Quote each with a `file:line` citation; add an **indicative** parallel-vs-sequential note explicitly marked non-authoritative; state that passing `[epics]` runs them. Write nothing, dispatch nothing. Observable result: a cited candidate list + a "preview only — pass epics to run" close.

2. **Compute the wave plan.** Apply the disjoint-epic decomposer + wave planning ([`../../knowledge/parallel-dispatch.md`](../../knowledge/parallel-dispatch.md) §1–2) to the target epics: build the overlap graph (file/module overlap · output dependency · shared new data structure), group non-overlapping epics into waves, order waves by dependency. `--sequential` → one epic per wave; `--parallel` → one wave (record that the user asserted disjointness). When unsure, treat epics as overlapping. Observable result: an ordered wave plan, each epic tagged with its wave and the reason for any forced serialization.

3. **Propose the wave plan — human gate (before any dispatch).** Present the plan in full: the waves, the per-epic worktree + `feature/<epic-slug>` branch, the concurrency cap, and the disjointness rationale for each pairing. Require explicit approval before dispatching anything (ownership-over-automation, `core/ground-rules` Rule 0). The gate is self-contained — the plan rides in the message/`AskUserQuestion` the user sees, never only in a sub-agent payload (per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 5 *Self-contained gates* + Rule 7 *Delivery test*). On reject/adjust, recompute and re-propose. Observable result: an approved (or adjusted) wave plan; nothing dispatched without approval.

4. **Dispatch each wave (parallel within, sequential across).** For the current wave, dispatch up to the concurrency cap (default ~4) — one agent per epic, each in its own git worktree (`isolation: worktree`) on `feature/<epic-slug>` branched from the integration branch. Each agent runs the LSA loop (`discover → specify → verify → delegate → reconcile`) for its epic. Epics beyond the cap queue. When an agent finishes, run the Epic 1 gate: the **independent** `lsa:reconcile` (a context that cannot edit what it grades) + the `.lsa.yaml` `gate:` checks. Tear down each worktree when its epic merges or is abandoned; a worktree that cannot be torn down is an open item. A later wave starts only after every epic in the prior wave has **merged**. Observable result: per-epic gate outcomes (pass/fail, with cited gate output) and worktree teardown status.

5. **Converge — serialized merge, per autonomy level.** Merge per [`../../knowledge/serialized-merge.md`](../../knowledge/serialized-merge.md): one PR at a time, tested against the up-to-date base, merge only the tested SHA. The autonomy level (Step 1) decides the boundary behavior, per [`../../knowledge/autonomy-policy.md`](../../knowledge/autonomy-policy.md): at **`manual`** the engine stops and presents each gate-green PR (SHA + gate artifact) for the human to merge; at **`semi`** the serialized-merge step auto-merges each PR on green into the integration branch without a per-merge prompt (the human still owns the final merge to `main` and any deploy). The gate must be green either way — autonomy removes only the prompt, never the gate. Only the serialized-merge step writes `${specs_root}/roadmap.md` status, after the merge lands. Observable result: each PR merged-by-human (`manual`) or auto-merged-on-green (`semi`), each with its SHA; roadmap status written only post-merge.

6. **Report — gate-proven per-epic status.** For each epic, report `merged @ <sha>` only when the merge landed and the gate proved it, citing the gate artifact; report `attempted` (gate failed) or `pending` (gate green, human has not merged) otherwise, with evidence (branch, PR, gate output). Never claim a merge the human has not performed. Observable result: a per-epic status list where every "merged" carries a SHA + cited proof. (The full fleet-scope roll-up — per-agent attribution, proven-facts table — is layered by Epic 4.)

## Output

An approved wave plan; per-epic isolated-worktree dispatch with independent gating; a serialized, human-performed merge (manual autonomy); and a per-epic status report in which every completion state is gate-proven and cited. The no-arg form is a read-only preview. The skill never claims execution or a merge it did not prove.

## Constraints

- **Propose before dispatch.** No worktree is created and no agent is spawned before the human approves the wave plan (Step 3). The smart default is propose; the human owns the go.
- **Autonomy is `manual` or `semi`.** `manual` (human merges) and `semi` (auto-merge on green into the integration branch) are implemented; `auto` (deploy + healthcheck) is Epic 4 and clamps to `semi`. Never deploy. The human always owns the final merge to `main`. The gate must be green at every level.
- **Done is a gate-proven, cited predicate.** Report `merged @ <sha>` only when the serialized merge landed and the gate proved it, citing the artifact; everything else is `attempted`/`pending` with evidence. Per [`../../../core/skills/ground-rules/SKILL.md`](../../../core/skills/ground-rules/SKILL.md) Rule 7 + pitch Definition of success #1.
- **Isolation + teardown are mandatory.** One worktree/branch/PR per epic; tear every worktree down; report any that survive.
- **Disjointness is conservative.** When unsure, serialize. `--parallel` overrides the decomposer but shifts the disjointness responsibility to the user; it does not lower the gate.
- **The grader is independent.** `lsa:reconcile` runs in a context with no write access to the tests / `.feature` scenarios / `gate:` it judges (Epic 1, `lsa` 0.18.0).
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link/quote, never restated.

---

`/manager:implement [epics] [--parallel|--sequential]` — manual invocation. Bare `/manager:implement` previews.
