# Test Suites: EARS + Journey-shape AC Discipline

## Journey: Author a new feature spec

**Goal:** A human authors a new feature spec via `lsa-specify` and reaches Gate 3 with a `requirements.md` whose AC sub-block is 100% EARS-form and 100% journey-shaped.
**Covers:** AC1, AC2

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | Human runs `lsa-specify` → drafts `requirements.md` with AC block already in EARS journey-shape form → Gate 2 diagonal table renders ✓ on all 6 rows (5 when contract skipped) → Human approves → Gate 3 → spec complete |
| 2 | Non-EARS AC caught | Human runs `lsa-specify` → drafts `requirements.md` with one AC in free-form prose (e.g., *"system handles errors gracefully"*) → Gate 2 EARS-pattern row renders ✗ citing `requirements.md:<line>` → System renders Rule 6 decision block (`[a]` rewrite in EARS / `[b]` move to unit-test scope / `[c]` custom) → Approval blocked → Human picks `[a]` and rewrites → Gate 2 re-renders ✓ → Human approves |
| 3 | Unit-shaped AC caught | Human runs `lsa-specify` → drafts `requirements.md` with one AC naming an internal function (e.g., *"`isTokenExpired()` returns true for past timestamps"*) → Gate 2 journey-shape row renders ✗ citing `requirements.md:<line>` → System renders Rule 6 decision block (`[a]` rewrite in journey-shape / `[b]` move to unit-test scope / `[c]` custom) → Approval blocked → Human picks `[b]` and moves the check to unit-test scope (deleting the line from AC sub-block) → Gate 2 re-renders ✓ → Human approves |

**Expected outcome:** Happy path produces a `requirements.md` whose AC sub-block passes both new diagonal rows (EARS-pattern + journey-shape). Corner paths surface the specific offending line with a `file:line` citation per `core/ground-rules` Rule 1 and reuse the same Rule 6 failing-row decision-block render already documented at `lsa/skills/lsa-specify/SKILL.md:162-176`. Approval cannot proceed until every ✗ is resolved.

## Journey: Verify a feature implementation

**Goal:** A human runs `lsa-verify` on a completed feature branch and receives a verdict (PASS / FAIL / PASS WITH WARNINGS per `core/knowledge/output-vocabulary.md`) reflecting whether every implementation diff traces to a requirement ID and whether every AC has covering implementation/test.
**Covers:** AC3, AC4

**Paths:**
| # | Path | Actions |
|---|------|---------|
| 1 | Happy | Human runs `lsa-verify` → every non-trivial diff hunk has a covering task in `tasks.md` whose body cites an AC ID → every AC ID in `requirements.md` has ≥1 covering task → Report: **PASS** |
| 2 | Orphan diff hunk (AC3) | Human runs `lsa-verify` → one diff hunk (e.g., a refactor outside any planned task) has no task→requirement trace → Report: **FAIL** with citation `<artifact-file>:<line> has no requirement trace` |
| 3 | Orphan AC (AC4) | Human runs `lsa-verify` → every diff hunk has a trace, but one AC (e.g., AC2) has zero covering tasks/implementations → Report: **FAIL** with citation `requirements.md:<AC2-line> has no covering implementation` |

**Expected outcome:** Happy path produces **PASS**. Corner paths produce **FAIL** with `file:line` citations per `core/ground-rules` Rule 1, pointing at the specific orphan (diff hunk or AC). The report leads with the verdict per the LSA report format (`lsa/skills/lsa-verify/SKILL.md`).
