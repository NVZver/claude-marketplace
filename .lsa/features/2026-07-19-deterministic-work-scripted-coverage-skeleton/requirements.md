# Coverage-skeleton script — reconcile set-math

## Summary

Give `lsa:reconcile` a deterministic pre-computed coverage skeleton instead of
hand-enumerating it every grade. `scripts/coverage-skeleton.sh` enumerates the two
axes of the requirement↔hunk table — requirement IDs from `requirements.md` and
changed files from `git diff` — and emits the table skeleton + a candidate-hunks
checklist. The model fills only the semantic mapping (which hunk satisfies which
requirement) and reads off orphans / uncovered. This is the first instance of
principle 10 applied to a floored, N×-repeated surface.

- Source: discover handoff 2026-07-17 (deterministic-work sweep, epic 2 of 4).
- Applies: `.lsa/VISION.md` §2 principle 10 (enumeration = script; judgment = model).
- Target surface: `lsa/skills/reconcile/SKILL.md:34-36` (Step 4 coverage table).
- Style precedent: `scripts/roadmap-query.sh`, `scripts/check-citations.sh`
  (bash 3.2-safe, grep+git only, exit-coded).
- No-fragile-matching discipline reused: the doc-lint gate's R2 (a script never
  guesses semantics).

## User Flows

1. **Reconciling a diff (`reconcile`).** A grader runs `reconcile` on a returned diff.
   Before building the coverage table by hand, it runs `coverage-skeleton.sh` to get
   the enumerated skeleton (every requirement ID as a row, every changed file as a
   candidate hunk), then fills the semantic mapping and reads off orphans / uncovered.
2. **Author runs it directly.** A contributor runs
   `bash scripts/coverage-skeleton.sh <feature-dir>` and gets the skeleton on stdout;
   exit 0 = emitted, non-zero = bad input (missing dir / missing `requirements.md`).

## Functional requirements (EARS)

### Script
- R1. `scripts/coverage-skeleton.sh <feature-dir> [git-diff-args…]` SHALL extract every
  requirement ID matching `^- [RF][0-9]+\.` from `<feature-dir>/requirements.md`, in
  document order (handles both `R`- and `F`-keyed specs — both exist in-repo).
- R2. It SHALL enumerate changed files via `git diff --name-only` with the passed
  `git-diff-args` (default `HEAD`) **and** untracked files via
  `git ls-files --others --exclude-standard` (merged, deduped, sorted), and SHALL exclude
  `<feature-dir>` itself — the spec files are never implementing hunks. Untracked inclusion
  is load-bearing: reconcile grades before the epic commit, so an epic's NEW files are
  untracked and must still surface as candidate hunks (proven by this epic dogfooding
  itself — the first run missed its own new script).
- R3. It SHALL emit a markdown coverage-table skeleton — one row per requirement ID with
  empty `implementing hunks/files` · `proving runs` · `verdict` columns — for the model
  to fill.
- R4. It SHALL emit the enumerated changed files as a `Candidate hunks` checklist below
  the table (the deterministic enumeration the model assigns to rows).
- R5. It SHALL be enumeration only — it SHALL NOT attempt to map a hunk to a requirement
  (semantic judgment stays with `reconcile`), per principle 10's enumeration/judgment
  split and the doc-lint gate's no-fragile-matching discipline.
- R6. It SHALL match `scripts/` style — `set -uo pipefail`, bash 3.2-safe, grep+git only,
  no new deps; exit 0 on success, non-zero with a one-line diagnostic on bad input
  (missing dir / missing `requirements.md`).

### Wiring
- R7. `lsa/skills/reconcile/SKILL.md` Step 4 SHALL cite `scripts/coverage-skeleton.sh` as
  the enumeration source (run it to get the F-ID × changed-file skeleton; fill the mapping
  column; read off orphans / uncovered) — the model still authors the does·only·all
  verdicts. The edit SHALL NOT weaken any existing reconcile check.

### Test + versioning
- R8. `scripts/tests/coverage-skeleton-test.sh` SHALL cover: `R`- and `F`-ID extraction,
  changed-file enumeration, feature-dir exclusion (R2), and the bad-input non-zero exit.
- R9. `lsa` SHALL bump SemVer (0.26.0 → 0.27.0, MINOR — new reconcile enumeration behavior)
  + CHANGELOG + README (the `reconcile` skill row names the script). The script + its test
  are repo-level (outside every `artifact_paths` per `.lsa.yaml:52-104`) and trigger no
  bump on their own — only the `reconcile/SKILL.md` edit drives the `lsa` bump.
- R10. `bash scripts/gate.sh` SHALL exit 0 after the change (the new `reconcile` citation of
  `scripts/coverage-skeleton.sh` resolves; `.sh` files are outside the citation/link scan).

## Acceptance scenarios (Gherkin)

```gherkin
Feature: Coverage-skeleton enumeration for reconcile

  Scenario: Enumerate both axes of the coverage table
    Given a feature dir whose requirements.md lists R1..R9
    And 3 files changed since HEAD outside that feature dir
    When "bash scripts/coverage-skeleton.sh <feature-dir>" runs
    Then stdout has a coverage-table skeleton with 9 requirement rows
    And a "Candidate hunks" checklist with the 3 changed files
    And it exits 0

  Scenario: The spec's own files are excluded as hunks
    Given the changed files include "<feature-dir>/requirements.md"
    When the script runs
    Then that spec file is NOT listed as a candidate hunk

  Scenario: Bad input exits non-zero
    Given a feature dir path that does not exist
    When the script runs
    Then it prints a one-line diagnostic
    And it exits non-zero
```

## Out of Scope

- Mapping a hunk to a requirement (R5 — semantic judgment stays with `reconcile`).
- Computing the final orphan/uncovered verdict inside the script (the model reads it off
  the filled table; a future epic could add a verify-the-filled-mapping second pass).
- Any change to the does (scenario N×) or gate steps of `reconcile` — only Step 4's
  enumeration is scripted.
