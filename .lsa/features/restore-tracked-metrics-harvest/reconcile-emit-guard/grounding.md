# Grounding — reconcile-emit-guard

Verdict: **NOT-GROUNDED → fixed → GROUNDED** @ 2026-07-20 (branch feature/reconcile-emit-guard,
base `chore/project-quality-improvements` @ dbc8b4a).

## Drift found and fixed

| Spec reference | Spec claim | Codebase reality | Fix |
|---|---|---|---|
| R8 / feature scenario "Versioning discipline" | `lsa` bumps **0.28.1 → 0.29.0** | `lsa/.claude-plugin/plugin.json` already reads `"version": "0.29.0"` (`name-conformance-as-rtm`, `lsa/CHANGELOG.md` `[0.29.0] — 2026-07-20`, merged into `chore/project-quality-improvements` before this epic's base commit `dbc8b4a`) | Corrected target to **0.29.0 → 0.30.0** in `requirements.md` R8 and `reconcile-emit-guard.feature` (version string `"0.30.0"`). The MINOR-bump *reason* (new `reconcile` behavior + tightened output contract) is unchanged — only the before/after numbers shift by one epoch. |

No other spec claim diverged from the codebase.

## Confirmed references

| Spec reference | Resolution |
|---|---|
| `scripts/metrics-harvest.sh` (epic 1, dependency) | `exists @ scripts/metrics-harvest.sh` — confirmed shipped, `chmod +x`, prints 4 labelled lines per epic-1 R2 |
| `scripts/metrics-harvest.sh` output labels `only-required-changes:` / `accuracy-to-task:` / `citation-resolve-rate:` | confirmed — script lines (echo statements) match R1's `[ASSUMPTION]`-tagged two orphan-line forms exactly (`Orphan hunks: none.` / `Orphan hunks: <integer>`, `scripts/metrics-harvest.sh` `orphan_re='^Orphan hunks: (none\.\|[0-9]+)[[:space:]]*$'`) |
| `scripts/metrics-harvest.sh` exits 0 even on `UNPARSEABLE` (R9 of epic 1) | confirmed — `exit 0` is the script's only exit path past the R1 usage/missing-file guards; R3's "never turns PASS into FAIL" holds without extra error handling |
| `lsa/skills/reconcile/SKILL.md:36` free-prose orphan allowance ("Below the table, list any orphan hunks") | confirmed present, no canonical shape specified — this is R1's edit target |
| `lsa/skills/reconcile/SKILL.md:44-52` synthetic coverage-table example, `Orphan hunks: none.` | confirmed — already uses the canonical zero-orphan form by coincidence; R1 makes it the *specified* contract rather than an example convention |
| `.lsa/metrics.md:5` "Written by `lsa:verify` on clean PASS" | confirmed present — R4's edit target |
| `.lsa/metrics.md:7` six-column schema (`feature · archived · accuracy (M/N) · facts (M/N) · only-required-changes (M/N) · notes`) | confirmed |
| `.lsa/metrics.md` two 2026-05-21 rows | confirmed present, 2 rows |
| `scripts/lint.sh` C15 (lines 456-475) / C16 (lines 477-497) | confirmed — C16 (`standards-conformance-agents-md/agents-md-canonical`) already merged into the base branch; highest check is C16, so **C17** is unoccupied, per R5/Assumption 3 |
| `scripts/lint.sh` C6 style (lines 152-165, "Presence check only") | confirmed — banner comment + single `grep -qiF`-style presence check |
| `scripts/tests/resolve-refs-test.sh` hermetic/trap style precedent | confirmed — `trap cleanup EXIT` pattern (line 35) used as the falsification-test's restore-on-exit model |
| `.lsa.yaml` `gate:` block, 5 checks | confirmed @ `.lsa.yaml:14-19` |
| `scripts/run-tests.sh` auto-discovery loop | confirmed @ `scripts/run-tests.sh:36` `for t in "${TESTS_DIR}"/*.sh` |
| `.lsa/VISION.md` §5 wording | confirmed @ `.lsa/VISION.md:167` — "The three you've chosen to track personally: **accuracy to the task**, **proven facts with sources** (citation density), and **only-required-changes** (scope-creep rate). Measure them the same disciplined way you measured the team projects." — no per-cycle/per-session distinction stated; R9's clarification target confirmed real |
| `lsa/README.md:8`, `lsa/README.md:70` | confirmed — reconcile description lines exist at both, no `.lsa/metrics.md` mention yet |

## Feasibility

Buildable. All edits are to existing files (SKILL.md prose, lint.sh append, metrics.md prose,
plugin.json/CHANGELOG/README) plus one new hermetic test script following the
`resolve-refs-test.sh` trap/backup pattern. No new directories, no infeasible flow.

## Baseline gate

`bash scripts/gate.sh` → exit 0 at `dbc8b4a` (base branch tip, before any reconcile-emit-guard
code). No baseline drift to fix.

## Blockers

None for the repo-surface work (R1-R8, R10-R11). R9 (`.lsa/VISION.md` §5 clarification) is
owner-gated per the requirement's own text — see the epic's final report for its disposition.
