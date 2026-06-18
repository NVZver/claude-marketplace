# Epic A–D — Fix the parallel-engine findings (manager + lsa)

**Bet:** Close the six seam-level defects surfaced by observing `manager:implement` run live on the TripAnchor-1 external project (2026-06-17). The core engine works (gate-proven done, disjoint-code parallelism, high throughput); every defect is at an integration seam. Source observation log with citations: [`../../observations/2026-06-17-tripanchor-manager-implement.md`](../../observations/2026-06-17-tripanchor-manager-implement.md).

- **Tracks:** `manager` (A, B, C, D-fleet-rollup), `lsa` (D-reconcile/gate). Delivered as **one integration branch** `feature/fix-parallel-engine-findings`, four disjoint epics in wave 1.
- **Base:** `main` (`6c52e6a`... marketplace `1cc345f`). Citations against that tree.
- **Convergence:** epics edit disjoint content files; the orchestrator owns all shared ledgers (`manager/CHANGELOG.md`, `lsa/CHANGELOG.md`, both `plugin.json` versions, root `README.md`, `.lsa/roadmap.md`) and writes them serially at merge — dogfooding the C4 ledger-lock fix.

## Findings → epics

| Finding | Defect (observed) | Epic |
|---|---|---|
| C1 | `manager:implement` undiscoverable at entry (Opus searched before finding it) | C |
| C2 | Epic IDs unstable + colliding: E14–18 (spec) → E19–23 (commit) → E31–35 (PR); two commits both "E27"; non-monotonic | B |
| C3 | Reconcile folded into the impl commit — "independent grader" not observable at git/gate layer | D |
| C4 | Cross-fork collision on shared ledgers (`CHANGELOG.md`, `roadmap.md`) — write-lock covers only roadmap *status* | A |
| C5 | Fully autonomous PR-after-PR churn, no human gate between features — confirm/ document intended default | C |
| C6 | Non-code infra check (Vercel permissions) pollutes gate signal; correct-but-noisy | D |

## Epic decomposition (wave 1, disjoint files)

### Epic A: Convergence ledger-lock (C4)
**Definition of done:** `manager/knowledge/serialized-merge.md` §Roadmap-write lock generalized to a **shared-ledger lock** covering `CHANGELOG.md`, version `plugin.json`, and roadmap *content* (not just the status column); `parallel-dispatch.md` §3 updated so per-epic agents *propose* ledger entries and the serialized-merge step writes them. States the per-epic-fragment OR serialized-write mechanism explicitly. Cites the observation log C4.
**Files (write):** `manager/knowledge/serialized-merge.md`, `manager/knowledge/parallel-dispatch.md`

### Epic B: Stable epic identity (C2)
**Definition of done:** `manager/knowledge/epic-decomposition.md` epic format keyed by **stable slug**, not a global ordinal `N` (resolving the existing contradiction with its own anti-pattern 2 at `:26`); a stated rule that the epic key is assigned once at decompose and is immutable through commit/PR; `manager/skills/decompose/SKILL.md` emits that stable key. Cites the observation log C2.
**Files (write):** `manager/knowledge/epic-decomposition.md`, `manager/skills/decompose/SKILL.md`

### Epic C: Discoverability + autonomy doc (C1, C5)
**Definition of done:** `manager/skills/implement/SKILL.md` description/frontmatter carries explicit trigger phrasing ("run agents in parallel", "implement the backlog", "build epics in parallel") so it resolves on first try; a pointer from `manager/skills/next/SKILL.md` and `manager/README.md` to `manager:implement` as the build-execution entry point; `manager/knowledge/autonomy-policy.md` documents the intended default and whether unattended multi-PR churn is in-scope for each level. Cites the observation log C1/C5.
**Files (write):** `manager/skills/implement/SKILL.md`, `manager/skills/next/SKILL.md`, `manager/README.md`, `manager/knowledge/autonomy-policy.md`

### Epic D: Gate observability + hygiene (C3, C6)
**Definition of done:** `lsa/skills/reconcile/SKILL.md` + `lsa/knowledge/quality-gate-contract.md` make reconcile's independence **observable** — reconcile runs as a separate context and emits a gate artifact/commit the implementer cannot author (so "independent grader" is provable at the git/gate layer, not just asserted); the gate contract classifies **required vs. non-required** checks so a non-code infra failure (e.g. deploy-permission) does not read as a correctness failure; `manager/knowledge/fleet-rollup.md` roll-up distinguishes blocking from non-blocking check status. Cites the observation log C3/C6.
**Files (write):** `lsa/skills/reconcile/SKILL.md`, `lsa/knowledge/quality-gate-contract.md`, `manager/knowledge/fleet-rollup.md`

## Out of scope (No-gos)
No engine *code* rewrite (these are contract/prompt/doc refinements); no change to the core gate-proven-done thesis (it works); no new plugin; orchestrator owns shared-ledger writes — **epics must not touch** `CHANGELOG.md`, `plugin.json`, root `README.md`, or `.lsa/roadmap.md`.
