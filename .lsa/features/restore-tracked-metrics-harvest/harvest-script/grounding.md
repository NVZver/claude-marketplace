# Grounding — harvest-script

Verdict: **GROUNDED** @ 2026-07-20 (branch feature/harvest-script).

| Spec reference | Resolution |
|---|---|
| `scripts/coverage-skeleton.sh` (R4, style precedent) | `exists @ scripts/coverage-skeleton.sh` |
| `scripts/coverage-skeleton.sh:12-14` "a script never guesses semantics" (R3) | confirmed — line 14 |
| `scripts/coverage-skeleton.sh:16` "both R- and F-keyed specs exist in-repo" (R6) | confirmed — line 16 |
| `scripts/coverage-skeleton.sh:23` usage default `HEAD` (R1) | confirmed — line 23 |
| `## Candidate hunks` / `- [ ] ` checklist shape (R4) | `exists @ scripts/coverage-skeleton.sh:84-93` |
| `scripts/check-citations.sh` (R7, style precedent) | `exists @ scripts/check-citations.sh` |
| `scripts/check-citations.sh:12-13` "the citation still points at a real line", not "the quote is intact" (R2) | confirmed — lines 12-13 |
| `scripts/check-citations.sh:47` TTY-only ANSI colour codes (R7) | confirmed — line 47 |
| `OK  <n> citation(s) checked, all resolve.` / `FAIL <v> broken citation(s) of <n> checked` summary shape (R7) | `exists @ scripts/check-citations.sh:128,131-132` |
| `lsa/skills/reconcile/SKILL.md:40` coverage-table shape (R6) | confirmed — Step-4 `| Req | Implementing hunks/files | Proving runs | Verdict |` table |
| `.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md:25` non-canonical orphan heading (R5, scenario 3) | confirmed — `## Orphan hunks (over-delivery vs F1–F13)`, prose, does not match the canonical `Orphan hunks: none.` / `Orphan hunks: <integer>` shape; that file's coverage table has 14 rows (F1, F1b, F2–F13), all `✅` |
| `resolve-refs.sh`'s `new`/`MISSING` non-gating handling (R9) | `exists @ scripts/resolve-refs.sh:26` "Exit 0 = every input resolved (a `new`/`MISSING`/`OUT-OF-RANGE` line is…)" |
| `scripts/tests/resolve-refs-test.sh` hermetic style precedent (R11) | `exists @ scripts/tests/resolve-refs-test.sh` |
| `scripts/run-tests.sh` auto-discovery loop (R12) | `exists @ scripts/run-tests.sh` — `for t in "${TESTS_DIR}"/*.sh` |
| `.lsa.yaml` `gate:` block (R13) | `exists @ .lsa.yaml:14-19` — 5 checks: docs-invariants, citations, links, project-map, tests |
| `scripts/metrics-harvest.sh` · `scripts/tests/metrics-harvest-test.sh` | `new` |

## Feasibility

Buildable: bash-3.2-safe deterministic parser reading one `conformance.md` + shelling out to
`coverage-skeleton.sh` and `check-citations.sh`. No infeasible flow. No new directories (both
paths land in existing `scripts/` and `scripts/tests/`), so no further project-map churn.

## Baseline gate drift found and fixed

`bash scripts/gate.sh` FAILed at the starting SHA — `project-map` check exited 1
(`project-map.yaml` stale by 4 lines: the `chore/project-quality-improvements` branch tip
commit `9de6656` added new `.lsa/features/` + `.lsa/pitches/` entries without regenerating the
tree). This is baseline drift unrelated to this epic's spec, not a grounding blocker for
harvest-script itself. Fixed via `bash lsa/scripts/project-map-build.sh` + commit `c0fa803`
("chore: regenerate project-map.yaml for restore-tracked-metrics-harvest epics") before any
harvest-script code was written, so the epic starts from and is graded against a green gate.

## Gate

`bash scripts/gate.sh` → exit 0 at `c0fa803` (post project-map fix, pre harvest-script code).

## Blockers

None.
