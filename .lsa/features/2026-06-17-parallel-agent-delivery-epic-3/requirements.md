# Epic 3 — Parallel-Agent-Delivery Semi Autonomy

## Summary
The autonomy knob and its second rung: `.lsa.yaml` `autonomy: manual | semi | auto` (default
`manual`), with `semi` bound to auto-merge on green. Re-homes solution-design component 4 (partial).

- Source: pitch `.lsa/pitches/parallel-agent-delivery.md:22,26`; solution-design `:38-44, 77`
- Builds on Epic 2 (engine) + Epic 1 (gate + serialized merge). Gated on `manual` proving safe (pitch `:26`).

## Functional requirements (EARS)
- R1. `.lsa.yaml` SHALL support `autonomy: manual | semi | auto`, default `manual`; absent/unrecognized → `manual`. (pitch success #4)
- R2. The `.lsa.yaml` schema SHALL document the `autonomy:` key (it is LSA's config file). (lsa/ARCHITECTURE §3)
- R3. Under `semi`, the serialized-merge step SHALL auto-merge each gate-green PR into the integration branch without a per-merge prompt — one at a time, merging only the tested SHA. (solution-design `:44`)
- R4. The gate SHALL be identical at every autonomy level — `semi`/`auto` remove only the post-green human prompt, never the gate; a red gate blocks the merge at every level. (pitch `:41`)
- R5. No autonomy level SHALL auto-merge into `main`; the human always owns the final integration-branch → `main` merge. (pitch no-go #2)
- R6. `auto` SHALL clamp to `semi` with a notice until Epic 4 builds deploy + healthcheck.
- R7. `manager` + `lsa` SHALL bump SemVer + CHANGELOG + README for their respective surfaces.

## Out of scope
- `auto` autonomy / deploy / healthcheck — Epic 4.
- The fleet-scope roll-up — Epic 4.
