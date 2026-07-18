# Grounding — coverage-skeleton

Verdict: **GROUNDED** @ 2026-07-19 (branch feature/deterministic-work-scripted).

## Reference map

| Spec reference | Resolution |
|---|---|
| reconcile Step 4 coverage table (wiring target, R7) | `exists @ lsa/skills/reconcile/SKILL.md:36` |
| `scripts/` style precedents (R6) | `exists @ scripts/roadmap-query.sh`, `scripts/check-citations.sh` |
| requirement-ID format `[RF][0-9]+` (R1) | confirmed both in-repo: `F1.`…/`R1.`… across `.lsa/features/*/requirements.md` |
| lsa README reconcile row (R9 README target) | `exists @ lsa/README.md:8` |
| lsa current version (R9 bump target) | `exists @ lsa/.claude-plugin/plugin.json` = `0.26.0` → **0.27.0** |
| scripts/tests convention (R8) | `exists @ scripts/tests/` (generate-for-cursor-test.sh, no-wholefile-ledger-read.sh) |
| `scripts/coverage-skeleton.sh` · `scripts/tests/coverage-skeleton-test.sh` | `new` |

## Feasibility

All three flows buildable: a bash enumerator (grep+git) + one reconcile SKILL.md edit +
a bash test. No runtime service; docs-mode + repo script. No infeasible flow.

## Gate

`bash scripts/gate.sh` → exit 0 (project-map re-synced + committed `645393b`; all 4 checks PASS).

## Blockers

None. Note: adding the epic spec dir made `project-map.yaml` stale (depth-3 dir map);
resolved by regenerate + commit `645393b` before grounding — a mechanical coupling, not a
spec defect. The implementer adds files under existing dirs (`scripts/`, `scripts/tests/`),
so no further project-map churn is expected.
