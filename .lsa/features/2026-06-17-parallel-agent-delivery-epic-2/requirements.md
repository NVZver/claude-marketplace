# Epic 2 — Parallel-Agent-Delivery Fleet Dispatcher

## Summary
Promote `manager:implement` from a read-only preview stub to the **execution engine**: a
disjoint-epic decomposer that computes a dependency-ordered wave plan, proposes it for human
approval, then dispatches one agent per epic into an isolated git worktree, gates each via the
Epic 1 safety core (independent `lsa:reconcile` + `gate:` contract), and converges via the Epic 1
serialized merge — at `manual` autonomy (human merges). Re-homes solution-design component 2.

- Source: pitch `.lsa/pitches/parallel-agent-delivery.md:30,37`; solution-design `:20-27, 76`
- Builds on Epic 1: `core` 0.14.0 Rule 7, `lsa` 0.18.0 grader+gate, `manager` 0.11.0 serialized-merge
- Convergence target: `feature/parallel-agent-delivery`; human owns merge to `main`

## Functional requirements (EARS)

- R1. `manager:implement A, B, C` SHALL compute a **wave plan** — epics grouped into waves where a
  wave runs in parallel and waves run in dependency order (a later wave starts only after the prior
  wave's epics have merged). (solution-design `:109-117`)
- R2. The **disjoint-epic decomposer** SHALL classify two epics as parallel-safe only when they do
  not logically overlap — no shared edited files/modules, no dependency of one on the other's output,
  no shared new data structure. Overlap → same or later wave. (solution-design `:25`; the net-new risk)
- R3. The skill SHALL **propose the wave plan and require human approval before dispatching** — the
  smart default is propose, the human owns the go (ownership-over-automation, `core/ground-rules`
  Rule 0; solution-design `:100`).
- R4. On approval, each epic in a wave SHALL be dispatched to one agent in its **own git worktree +
  branch + PR** (Claude Code `isolation: worktree`). (pitch `:30`; prior-art C2)
- R5. Concurrency SHALL be capped (default ~4); epics beyond the cap queue. Worktree **teardown**
  SHALL be part of the run (cleanup footgun, pitch rabbit-hole 2 `:37`).
- R6. Each dispatched agent SHALL run the LSA loop and be gated by the Epic 1 safety core — the
  independent `lsa:reconcile` + the `.lsa.yaml` `gate:` checks — before its PR may merge; merge is
  serialized per `manager/knowledge/serialized-merge.md`. (Epic 1 dependency)
- R7. `--sequential` SHALL force one-at-a-time; `--parallel` SHALL force all-parallel (user asserts
  disjointness, overriding the decomposer). (solution-design `:106-107`)
- R8. At `manual` autonomy (this epic), the engine SHALL stop at the merge boundary and have the
  human merge; it SHALL NOT auto-merge or deploy. (pitch `:26`; `semi`/`auto` = Epics 3/4)
- R9. The engine SHALL NOT report any epic merged/done unless its gate proved it and the report cites
  the gate artifact + SHA (`core/ground-rules` Rule 7). A failed/ungated epic is reported
  `attempted`/`unknown`. (pitch success #1)
- R10. `manager` SHALL bump SemVer (minor — stub → engine) + CHANGELOG + README.

## Out of scope
- `semi`/`auto` autonomy, deploy, healthcheck — Epics 3/4.
- The fleet-scope transparency roll-up — Epic 4 (depends on `lsa-stage-reports`). Epic 2 emits a
  basic per-epic status list, not the full roll-up.
- Building any CI engine / merge queue — integrate GitHub-native primitives (pitch no-go #1).

## Build order
Parallel-dispatch knowledge file (decomposer + wave-planning + dispatch policy) → rewrite
`manager/skills/implement/SKILL.md` from stub to engine citing it → bump.
