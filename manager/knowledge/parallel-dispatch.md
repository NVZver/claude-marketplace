> **Trace.** On load, print first: `=============== [manager/knowledge/parallel-dispatch.md] [manager] ===============`

# Parallel dispatch — knowledge

How `manager:implement` turns a set of epics into a dependency-ordered **wave plan** and dispatches one isolated agent per epic. This is the net-new layer of the `parallel-agent-delivery` fleet dispatcher (Epic 2): GitHub/git provide isolation (worktrees) and the Epic 1 safety core provides the gate + serialized merge — this file provides the **disjointness analysis and dispatch policy** none of them give.

Source: pitch `.lsa/pitches/parallel-agent-delivery.md:30,37` (rabbit-hole 2/3); solution-design `.lsa/research/parallel-agent-delivery-solution-design.md:20-27, 109-117`. Distinct from [`epic-decomposition.md`](./epic-decomposition.md) (splitting *one pitch* into epics) — this file is about which *already-decomposed* epics may run *at the same time*.

## 1. Disjoint-epic decomposer

Two epics are **parallel-safe** only when none of these overlaps hold. If any holds, they must not share a wave.

1. **File / module overlap** — both edit the same file, or the same `.lsa.yaml` module's `artifact_paths`. Concurrent edits to the same surface produce merge conflicts the serialized merge can detect but not resolve.
2. **Output dependency** — epic B consumes an artifact, rule, or interface epic A produces (B cites A's file, or A's "definition of done" is B's precondition). B waits for A.
3. **Shared new data structure** — both introduce or mutate the same new config key, schema, or contract. They cannot be verified independently (mirrors `epic-decomposition.md` anti-pattern 3).

When unsure, treat epics as **overlapping** (the conservative default) — a false "disjoint" produces a semantic conflict that the gate catches only after wasted work; a false "overlapping" only costs serialization. Vendors isolate *file edits* but none guarantee *epic-logic* disjointness — that judgment is this decomposer's job, and the real risk the feature owns.

## 2. Wave planning

A **wave** is a set of epics with no pairwise overlap; waves run in dependency order.

1. Build an overlap graph over the target epics (edges = any §1 overlap).
2. Epics with no incoming output-dependency and no unsatisfied file/data conflict form **wave 1**.
3. Remove wave 1; repeat for wave 2, etc. An output-dependency edge A→B forces B into a strictly later wave than A.
4. Within a wave, epics run in parallel (capped, §3). Across waves, a later wave starts only after every epic in the prior wave has **merged** (not merely finished) — so each wave builds on a green base.

Worked shape (solution-design `:109-117`): `A` and `B` independent, `C` depends on `B` → wave 1 = {A, B} parallel, wave 2 = {C}.

## 3. Dispatch policy

- **One worktree + branch + agent + PR per epic.** Each agent runs in its own git worktree (Claude Code `isolation: worktree` / `EnterWorktree`), on `feature/<epic-slug>` branched from the integration branch, and opens one PR. The PR is the reviewable convergence unit (prior-art C2).
- **Concurrency cap, default ~4.** At most N agents run at once (vendors cap ~8; default conservative). Epics beyond the cap queue and start as slots free.
- **Each agent runs the LSA loop** (`discover → specify → verify → delegate → reconcile`) for its epic, then the Epic 1 gate runs: the independent `lsa:reconcile` + the `.lsa.yaml` `gate:` checks ([`../../lsa/knowledge/quality-gate-contract.md`](../../lsa/knowledge/quality-gate-contract.md)).
- **Convergence is serialized** per [`serialized-merge.md`](./serialized-merge.md): merge only the tested SHA against the up-to-date base; only the merge step writes roadmap status.
- **Teardown is part of the run.** Every worktree is removed when its epic merges or is abandoned — worktree sprawl is a known cleanup footgun (pitch rabbit-hole 2). A run that cannot tear down a worktree reports it as an open item.

## 4. Autonomy boundary

The engine dispatches and gates the same way at every autonomy level; the level (`.lsa.yaml` `autonomy:`, default `manual`) decides only the merge-boundary behavior — the level definitions live in [`autonomy-policy.md`](./autonomy-policy.md) and are not restated here. No level auto-merges into `main` — the human owns the final merge of the integration branch to `main` (pitch no-go #2).

## 5. Honesty contract

The engine reports an epic `merged @ <sha>` only when the serialized merge landed and the gate proved it (`core/ground-rules` Rule 7). An epic whose gate failed, or whose merge the human has not performed, is reported `attempted` / `pending` with its evidence (gate output, branch, PR) — never "done". Overriding the decomposer with `--parallel` does not lower this bar; it only asserts disjointness the human takes responsibility for.
