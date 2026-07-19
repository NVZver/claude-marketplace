# Grounding — resolve-refs

Verdict: **GROUNDED** @ 2026-07-19 (branch feature/deterministic-work-scripted).

| Spec reference | Resolution |
|---|---|
| verify Step 1 reference resolution (wiring target, R7) | `exists @ lsa/skills/verify/SKILL.md:30` |
| `git grep -n` identifier resolution (R4) | proven: `git grep -n 'pass_line()'` → `scripts/lint.sh:27` |
| path+line resolution precedent (R3) | `exists @ scripts/check-citations.sh` |
| lsa current version (R9 bump target) | `0.27.0` (post epic-2) → **0.28.0** |
| scripts/tests convention (R8) | `exists @ scripts/tests/` |
| `scripts/resolve-refs.sh` · `scripts/tests/resolve-refs-test.sh` | `new` |

## Feasibility

Buildable: bash resolver (git grep + path/line existence) + one verify SKILL.md edit + test.
No infeasible flow.

## Gate

`bash scripts/gate.sh` → exit 0 (project-map re-synced + committed `09f1fd6`).

## Blockers

None. Implementer adds files under existing `scripts/` + `scripts/tests/` (no new dirs → no
further project-map churn).
