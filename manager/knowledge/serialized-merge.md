> **Trace.** On load, print first: `=============== [manager/knowledge/serialized-merge.md] [manager] ===============`

# Serialized merge + shared-ledger lock — knowledge

The convergence contract for parallel runs: how N per-epic PRs land on the integration branch without ever turning it red, and who is allowed to write the **shared ledgers** every epic touches — `CHANGELOG.md`, `plugin.json` version, and `${specs_root}/roadmap.md` (content + status). Owned by `manager` (the orchestrator); consumed by the `manager:implement` execution engine (built in the `parallel-agent-delivery` Epic 2 — this file is the contract that engine follows). The independent grade each PR must pass is `lsa:reconcile` + the [`lsa` quality-gate contract](../../lsa/knowledge/quality-gate-contract.md); the always-on rule that a merge may be *reported* only when proven is [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 7.

Source: `.lsa/pitches/parallel-agent-delivery.md:20,38,43` (no-go #2 `:48`, rabbit-hole 8 `:43`); `.lsa/research/parallel-agent-delivery-solution-design.md:30-36`.

## The problem

Two PRs can each pass their gate alone yet break when merged together — the "green alone, red merged" semantic conflict. And disjoint *code*-file decomposition gives **zero** protection on the shared **append-ledgers** — `CHANGELOG.md`, the `plugin.json` version, and `roadmap.md` — that *every* epic writes: each fork integration then requires a `git merge` + conflict resolution on those files. Observed live: a fork's integration conflicted on `CHANGELOG.md` (`UU`) and `roadmap.md` (`MM`) and recurred on every subsequent fork merge (`.lsa/observations/2026-06-17-tripanchor-manager-implement.md:34` — *"cross-fork collision on shared ledger files... the disjoint-code-file decomposition gives zero protection on the shared ledgers, so cross-fork integration requires a merge + conflict resolution every time"*; recurrence confirmed at `:38`).

## Serialized-merge contract

Merges are **serialized** — one PR lands at a time, and each is tested against the state it will actually merge into, not the stale base it branched from.

1. **Merge only the tested SHA against the up-to-date base.** Before a PR lands, its gate (the `lsa` `gate:` checks + `lsa:reconcile`) must pass against the base *as it will be after the merge* — not against the SHA the branch forked from. This is the "not-rocket-science rule" (`.lsa/research/parallel-agent-delivery-solution-design.md:30-36`).
2. **Prefer the GitHub merge queue** (`merge_group` event) when the repo has it enabled — it tests each PR against the latest target plus any already-queued PRs and merges only the tested SHA. Requires the `merge_group` Actions wiring, or the queue stalls.
3. **Local fallback when no merge queue:** rebase the PR onto the current integration-branch tip → re-run the gate → merge only if green → take the next PR. Re-gate immediately before each merge; never merge a PR gated only against a now-stale base.
4. **One at a time.** No two PRs merge concurrently. A failed re-gate sends the PR back to its agent; it does not block the queue behind it from being re-evaluated.

## Shared-ledger lock

**Only the serialized-merge step writes the shared ledgers.** A *shared ledger* is any file every parallel epic must append to or bump — concretely `CHANGELOG.md`, the `plugin.json` `version`, and `${specs_root}/roadmap.md` (both content rows and the status column). Per-epic agents **propose, never write** these; the merge step — which runs serially, one PR at a time — performs every shared-ledger write after that PR's merge lands. This removes the concurrent-write race the disjoint-code decomposition cannot (the roadmap-status case is pitch rabbit-hole 8, `:43`; the generalized defect is `.lsa/observations/2026-06-17-tripanchor-manager-implement.md:34`).

**Mechanism — propose-in-payload, serialized write at merge.** Each epic agent carries its ledger entries as *proposals* in its PR/payload — not edits to the shared files:

- a **CHANGELOG line** (Keep a Changelog category + text),
- a **version-bump intent** (the SemVer level the epic warrants: patch/minor/major), and
- a **roadmap delta** (the content row(s) to add/change + the status transition).

The merge step assembles these serially: as each PR lands it appends that epic's CHANGELOG line, folds its version-bump intent into a single resolved bump (highest level wins across the merged epics), and writes its roadmap row + status — one writer, one PR at a time, so the shared files are only ever touched on a serial path and never produce a merge conflict. This extends the existing serialized-write contract (the merge step already owned roadmap *status*) rather than introducing per-epic fragment files — minimal and consistent with "the merge step writes after the SHA is known".

- An agent's "done", its CHANGELOG line, its version-bump intent, and its roadmap delta are all **proposals** carried in the PR/payload, never edits to `CHANGELOG.md` / `plugin.json` / `roadmap.md`.
- The merge step writes each ledger only after the gate proved the merge and the SHA is known — so every written ledger entry is itself gate-proven (Rule 7), citing the merged SHA.
- This narrows, for parallel runs, the agent-owned roadmap write in [`roadmap-orchestration.md`](./roadmap-orchestration.md): single-feature roadmap edits stay agent-owned through the gate; during a parallel run all shared-ledger writes — CHANGELOG, version, roadmap content **and** status — are serialized through the merge step.

## Autonomy boundary

The contract above (what is tested, what may be written) is **identical at every autonomy level** — the level decides only *who pushes the button after green*, never whether the gate must be green. The level definitions (`manual | semi | auto`, default `manual`) live in [`autonomy-policy.md`](./autonomy-policy.md) and are not restated here. At no level does an auto-merge land into `main`: the integration branch converges here; the human owns the final merge to `main` (pitch no-go #2, `:48`).
