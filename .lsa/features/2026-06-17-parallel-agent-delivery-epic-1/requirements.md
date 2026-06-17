# Epic 1 — Parallel-Agent-Delivery Safety Core

## Summary
The first shippable slice of the parallel-agent-delivery pitch, at `manual` autonomy only:
a verifiable-done content rule (`core`), an independent spec-conformance grader the work cannot
edit (`lsa`), and a serialized merge that keeps the convergence branch always-green with a
roadmap-write lock (`manager`). Re-homes solution-design components 1, 3, 6.

- Source pitch: `.lsa/pitches/parallel-agent-delivery.md` (Appetite `:26`, success criteria `:18-23`)
- Solution design: `.lsa/research/parallel-agent-delivery-solution-design.md:62-69, 75`
- Roadmap row: `.lsa/roadmap.md` §"2026-06-17 backlog detail" Epic 1
- Convergence target: integration branch `feature/parallel-agent-delivery`; human owns merge to `main`

## Scope (three plugin-touching subtasks)
- **S1 (core)** — new always-on content rule: "done = a cited, gate-proven predicate."
- **S2 (lsa)** — `lsa:reconcile` as an independent grader run in a no-write-access context + the
  repo-local quality-gate script contract (per-check name → command).
- **S3 (manager)** — serialized-merge step (merge-queue `merge_group` when available, else local
  rebase + re-gate) + the roadmap-write lock (only the merge step writes `.lsa/roadmap.md` status).

## Functional requirements (EARS)

### S1 — done-predicate rule (`core`)
- R1. The `core/ground-rules` skill SHALL carry a content rule stating that an agent may report a
  completion state (`merged @ <sha>`, `migration applied`, `tests green`, `deployed`) only when a
  deterministic, agent-inaccessible gate proved it AND the report cites the gate artifact.
  (pitch `:19`; solution-design `:52-56`)
- R2. When a state is not gate-proven, the agent SHALL report it as `attempted` or `unknown` with the
  available evidence attached — never as done. (pitch `:19`)
- R3. The rule SHALL cite its evidence base: memory `feedback_verifiable_done_predicate.md`, the S7
  "Inaccurate Self-Reporting" finding, and the Claude best-practices "'looks done' is the only signal
  available" quote. (solution-design `:55`; constitution §1 fact-grounding)
- R4. `core/CLAUDE.md` always-on fragment SHALL reference the new rule so it loads on every task.
- R5. `core` SHALL bump SemVer (minor — new always-on rule) + add a CHANGELOG entry + update
  `core/README.md` if the ground-rules count is user-visible there. (per-plugin discipline)

### S2 — independent grader + gate contract (`lsa`)
- R6. `lsa/skills/reconcile/SKILL.md` SHALL state that the conformance grade is run by a context with
  no write access to the tests, acceptance `.feature` scenarios, or gate config it grades — the
  grader is unwritable by the work it judges. (solution-design `:18`; pitch no-go #5 `:51`)
- R7. The feature SHALL define a repo-local **quality-gate script contract**: a per-project mapping of
  each check name (lint · typecheck · test · migration-applied · build) → command, consumed as the
  set of required-check slots. (solution-design `:16-17`)
- R8. Where the gate contract is documented, it SHALL hardcode no specific migration/deploy tool —
  only the requirement that each configured check pass and be cited before its state may be claimed.
  (pitch rabbit-hole 5 `:40`)
- R9. `lsa` SHALL bump SemVer + CHANGELOG + README if user-visible surface changed.

### S3 — serialized merge + roadmap-write lock (`manager`)
- R10. The serialized-merge step SHALL test each PR against the up-to-date base and merge only the
  tested SHA — GitHub merge-queue `merge_group` when available, else a local rebase-onto-main +
  re-gate fallback before each merge. (pitch `:20,38`; solution-design `:30-36`)
- R11. Only the serialized-merge step SHALL write `.lsa/roadmap.md` status; agents propose "done",
  the merge step commits it. (pitch rabbit-hole 8 `:43`; solution-design `:36`)
- R12. `manager` SHALL bump SemVer + CHANGELOG + README if user-visible surface changed.

### Cross-cutting
- R13. This epic SHALL operate at `manual` autonomy only — no auto-merge, no deploy. `semi`/`auto`
  are Epics 3/4. (pitch `:26`)
- R14. No stale `arxiv 2505.19955` reference SHALL remain in any live artifact (Epic 0 defect O1;
  pitch `:12` already corrected to `2406.10162`). (conformance.md O1)

## Out of scope
- Building any CI engine, hosted merge-queue, or deploy platform — integrate GitHub-native primitives
  only. (pitch no-go #1 `:47`)
- The `fleet` dispatcher / `manager:implement` engine — Epic 2.
- `semi`/`auto` autonomy + deploy + healthcheck — Epics 3/4.
- The fleet-scope roll-up — Epic 4 (depends on `lsa-stage-reports`).

## Build order (subtask sequencing)
S1 (core, self-contained, lowest blast radius) → S2 (lsa grader + gate contract) → S3 (manager merge
+ lock). Each subtask is independently committable to the integration branch with its own SemVer +
CHANGELOG + README delta.
