> **Trace.** On load, print first: `=============== [manager/knowledge/serialized-merge.md] [manager] ===============`

# Serialized merge + roadmap-write lock — knowledge

The convergence contract for parallel runs: how N per-epic PRs land on the integration branch without ever turning it red, and who is allowed to write `${specs_root}/roadmap.md` status. Owned by `manager` (the orchestrator); consumed by the `manager:implement` execution engine (built in the `parallel-agent-delivery` Epic 2 — this file is the contract that engine follows). The independent grade each PR must pass is `lsa:reconcile` + the [`lsa` quality-gate contract](../../lsa/knowledge/quality-gate-contract.md); the always-on rule that a merge may be *reported* only when proven is [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 7.

Source: `.lsa/pitches/parallel-agent-delivery.md:20,38,43` (no-go #2 `:48`, rabbit-hole 8 `:43`); `.lsa/research/parallel-agent-delivery-solution-design.md:30-36`.

## The problem

Two PRs can each pass their gate alone yet break when merged together — the "green alone, red merged" semantic conflict. And when N agents each finish an epic, two of them can race to mark the same kind of roadmap status, double-writing the shared file.

## Serialized-merge contract

Merges are **serialized** — one PR lands at a time, and each is tested against the state it will actually merge into, not the stale base it branched from.

1. **Merge only the tested SHA against the up-to-date base.** Before a PR lands, its gate (the `lsa` `gate:` checks + `lsa:reconcile`) must pass against the base *as it will be after the merge* — not against the SHA the branch forked from. This is the "not-rocket-science rule" (`solution-design.md:30-36`).
2. **Prefer the GitHub merge queue** (`merge_group` event) when the repo has it enabled — it tests each PR against the latest target plus any already-queued PRs and merges only the tested SHA. Requires the `merge_group` Actions wiring, or the queue stalls.
3. **Local fallback when no merge queue:** rebase the PR onto the current integration-branch tip → re-run the gate → merge only if green → take the next PR. Re-gate immediately before each merge; never merge a PR gated only against a now-stale base.
4. **One at a time.** No two PRs merge concurrently. A failed re-gate sends the PR back to its agent; it does not block the queue behind it from being re-evaluated.

## Roadmap-write lock

**Only the serialized-merge step writes `${specs_root}/roadmap.md` status.** Per-epic agents *propose* a status change ("this epic is done"); they never write the status column themselves. The merge step — which runs serially, one PR at a time — commits the status after the merge lands. This removes the concurrent-write race on the shared roadmap (pitch rabbit-hole 8, `:43`).

- An agent's "done" is a **proposal** carried in its PR/payload, not a roadmap edit.
- The merge step writes the status only after the gate proved the merge and the SHA is known — so the written status is itself gate-proven (Rule 7), citing the merged SHA.
- This narrows, for parallel runs, the agent-owned roadmap write in [`roadmap-orchestration.md`](./roadmap-orchestration.md): single-feature roadmap edits stay agent-owned through the gate; **status** transitions during a parallel run are serialized through the merge step.

## Autonomy boundary

The contract above (what is tested, what may be written) is identical at every autonomy level — autonomy decides only *who pushes the button after green*, per [`autonomy-policy.md`](./autonomy-policy.md):

- `manual` (default) — the human performs each merge after seeing the gate-green PR + SHA.
- `semi` — the serialized-merge step auto-merges each PR on green into the integration branch, no per-merge prompt.
- `auto` — `semi` + deploy + healthcheck (Epic 4; clamps to `semi` until built).

At no level does an auto-merge land into `main`: the integration branch converges here; the human owns the final merge to `main` (pitch no-go #2, `:48`).
