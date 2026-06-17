# Epic 4 — Parallel-Agent-Delivery Fleet Roll-up + Auto Autonomy

## Summary
The final epic: the fleet-scope transparency roll-up (so the gate output *is* the report) and the
`auto` autonomy rung (deploy + healthcheck, rollback on failure). Re-homes solution-design
components 5 and 4 (remainder).

- Source: pitch `.lsa/pitches/parallel-agent-delivery.md:21,42,41`; solution-design `:46-50, 38-44, 78`
- Builds on Epics 1–3.

## Dependency resolution (lsa-stage-reports)
The pitch (rabbit-hole 7, `:42`) requires **one report contract** and notes the roll-up "reuses (and
may supersede)" the `lsa-stage-reports` shape. Resolution: the fleet roll-up reuses the **existing**
`core/output` Rule 7 compressed inspection table + Conventional-Commits `type(scope)` grouping — the
same primitive `lsa-stage-reports` is built on — so the two are consistent, not duplicative. The
roll-up consumes each epic's `conformance.md` + gate artifacts (which already exist post-run), so it
does **not** block on the standalone per-stage `lsa-stage-reports` feature, which remains separately
scoped for single-loop runs (roadmap row updated to record this relationship).

## Functional requirements (EARS)
- R1. The run SHALL end with a fleet roll-up: per-agent attribution, per-epic gate verdicts, proven
  facts (checks passed, SHAs, healthcheck), open items. (pitch success #3, `:21`)
- R2. The roll-up SHALL reuse `core/output` Rule 7's inspection table for the files section and group
  by Conventional-Commits `type(scope)` — no new table format. (pitch rabbit-hole 7)
- R3. Every `state` in the roll-up SHALL obey Rule 7 — `merged @ <sha>` / `deployed` only when proven
  and cited; `attempted` / `pending` otherwise. (pitch success #1)
- R4. Open items (failed epics, un-torn-down worktrees, pending merges, deploy gaps) SHALL be surfaced
  in the roll-up, never buried.
- R5. `auto` autonomy SHALL run the project's deploy command + healthcheck after auto-merge, and SHALL
  report `deployed` only after the healthcheck passes. (pitch `:41`)
- R6. `auto` SHALL be gated by the same green gate as every level, and SHALL define a rollback/revert
  step run on healthcheck failure (reported `failed`, never `deployed`). (pitch rabbit-hole 6, `:41`)
- R7. No deploy/healthcheck tool SHALL be hardcoded; the repo supplies the commands. (pitch rabbit-hole 5)
- R8. `auto` SHALL NOT change the human-owned integration → `main` merge; default stays `manual`. (no-go #2)
- R9. `manager` SHALL bump SemVer + CHANGELOG + README.

## Out of scope
- The standalone per-stage `lsa-stage-reports` single-loop reporting feature (separate backlog).
- Building any deploy platform or CI engine (pitch no-go #1).
