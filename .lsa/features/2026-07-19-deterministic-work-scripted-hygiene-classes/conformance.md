# Conformance — hygiene classes

`reconcile: PASS @ 89fe9fd+worktree` (graded 2026-07-19). Independent grader — separate
context from the implementer. Grounding for this epic was produced by
`scripts/resolve-refs.sh` (epic 3) and enumeration by `scripts/coverage-skeleton.sh`
(epic 2) — the sweep grading itself with its own tools.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 class 4 merged-not-shipped | `scripts/roadmap-query.sh` (hygiene awk + `git branch --merged`, default-branch resolution) | test: class-4 fires (alpha) + silent when shipped (beta) — 3/3 | ✅ |
| R2 class 5 no-artifacts | `scripts/roadmap-query.sh` (branch ∪ features-dir ∪ pitch existence) | test: class-5 fires (gamma) + silent with pitch (delta) — 3/3 | ✅ |
| R3 recency OUT of scope, stated in script + agent | script header SCOPE NOTE + inline hint text + `project-manager.md` Step 6 boundary para | test: boundary-text assertion; live hint reads "(artifact-existence proxy, not a recency check)" — 3/3 | ✅ |
| R4 classes 1–3 + multi-hint + clean line + exit 0 preserved | `scripts/roadmap-query.sh` | live: class1=2, class3=3 (identical to pre-change); test: class-3 regression + zero-hits clean line — 3/3 | ✅ |
| R5 awk pipeline, bash 3.2-safe, git+awk only, no whole-file read | `scripts/roadmap-query.sh` | `scripts/tests/no-wholefile-ledger-read.sh` still passes | ✅ |
| R6 Step 6 attributes all 4 conditions to the script | `manager/agents/project-manager.md` Step 6 | "All four conditions below are script-derived; none is a model-side scan"; judgment/gate contract retained (8 hits) | ✅ |
| R7 hermetic test, 5 required cases | `scripts/tests/roadmap-query-hygiene-test.sh` | 8 cases PASS, exit 0 | ✅ |
| R8 manager 0.19.0 + CHANGELOG + README | `manager/.claude-plugin/plugin.json`, `manager/CHANGELOG.md` [0.19.0], `manager/README.md` | — (versioning) | ✅ |
| R9 gate exit 0 | `bash scripts/gate.sh` | exit 0 (4/4) | ✅ |

## does — scenarios (N=3, deterministic)

- S1 merged branch + non-shipped → class-4 hint. 3/3 (hermetic).
- S2 merged branch + shipped → silent. 3/3 (hermetic).
- S3 zero artifacts → class-5 hint. 3/3 (hermetic + live).
- S4 pitch file exists → no class-5 hint. 3/3 (hermetic).
- S5 class-3 regression → stale-in-progress still fires. 3/3 (hermetic + live).

**Why hermetic was mandatory:** the live tree has no merged branch matching a roadmap slug,
so class 4 emits **zero** hints on real data (confirmed). A green live run proves nothing
about class 4 — the fixture is the only real proof. Flagged in grounding.md before delegation.

## only — orphan-hunk check (feature scope)

Traced: `scripts/roadmap-query.sh`→R1–R5 · `scripts/tests/roadmap-query-hygiene-test.sh`→R7 ·
`manager/agents/project-manager.md`→R6 · `manager/.claude-plugin/plugin.json`+`manager/CHANGELOG.md`+`manager/README.md`→R8.
**No orphan.** The implementer added 2 assertions beyond the 5 listed (R3 boundary text,
R4 zero-hits clean line) — not scope creep: both cover requirements that were otherwise
untested.

## Observations (not defects)

- **Live hint volume rose 5 → 14** (class 5 adds 9). Expected: class 5 flags every actionable
  item with no branch, no feature dir and no pitch — on a long backlog that is a real,
  actionable set ("classify as deferred or active"), not noise from a heuristic. Classes 1
  and 3 fire on exactly the same rows as before.
- **Class 4 is a forward guard.** Zero hits today by construction; it earns its keep when a
  feature branch merges while its roadmap row still says `in_progress`.

## Gate

`bash scripts/gate.sh` → **exit 0**. All five `scripts/tests/*.sh` suites exit 0 (no
regression in neighbours).

## Verdict

**PASS** — does · only · all satisfied; R1–R9 covered; no orphan; gate green.
Sweep complete: `project-manager.md` Step 6 now has zero model-side scan conditions.
