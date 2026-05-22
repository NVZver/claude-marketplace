# Discovery — diagonal-cross-artifact-analysis

- **Module(s):** `lsa`
- **Change:** Make Gate 2 of `lsa-specify` catch cross-artifact contradictions before approval by adding three coverage diagonals to the existing AC→Journey check (Journey→Design, Design→Contract, Contract→test-suites); any failing row blocks approval as a Rule 6 decision block.
- **Acceptance:** When `lsa-specify` reaches Gate 2 on any T3 feature, the gate output prints a 4-row coverage table (one row per artifact pair), every row cites the two specific artifact lines compared, and any failing row blocks approval until the human chooses `[a] revise X / [b] revise Y / [c] custom`.

## Source
- `vision/specs/roadmap.md:64-75` — feature definition (Tech Picture adoption 2026-05-20, item #3).
- `lsa/skills/lsa-specify/SKILL.md:154` — current Gate 2 behavior (AC→Journey coverage only).
- `vision/specs/archive/2026-05-20-credo-rollout/plan.md` §"S6 — lsa-specify Gate 2" — seed sample of AC→Journey check pattern.

## Tier
- **T3** — confirmed via `core/tier-selector` ([this session]).

## Dogfood findings logged during discover
- **Finding #1**: `lsa/skills/lsa-discover/SKILL.md` *Constraints* says *"Do not write to the configured `specs_root`"* but `lsa/skills/lsa-specify/SKILL.md:25` reads `discovery.md` from the working feature directory which is `${specs_root}/features/<feature-name>/` per `lsa/skills/lsa-specify/SKILL.md:36`. Pragmatic resolution: write here, log finding, address in a follow-up `lsa-revise-constitution` after the loop closes. Decision logged by human on 2026-05-21.
