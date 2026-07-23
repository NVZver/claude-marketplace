# Metrics harvest script — three tracked metrics, derived from artifacts

## Summary

`.lsa/VISION.md` §5 commits to tracking three metrics; none are tracked today
(`.lsa/metrics.md` holds 2 rows, both dated 2026-05-21, and its writer was removed in
`lsa` 0.16.0). This epic adds `scripts/metrics-harvest.sh` — repo-internal bash, zero
model calls — which reads ONE `conformance.md` plus existing script output and prints
the three metrics as M/N pairs. It **computes, it never judges**: any input that is not
in the canonical shape is reported `UNPARSEABLE`, never guessed.

- Source: `.lsa/pitches/restore-tracked-metrics-harvest.md` (approved 2026-07-19), epic 1 of 2.
- Applies: `.lsa/VISION.md` §5 (*"accuracy to the task, proven facts with sources … only-required-changes"*); `.lsa/VISION.md` §2 principle 10 (deterministic work is scripted).
- Target surface: `scripts/metrics-harvest.sh` (new) + `scripts/tests/metrics-harvest-test.sh` (new).
- Style precedent: `scripts/coverage-skeleton.sh` (header: *"ENUMERATION ONLY. It never maps a hunk to a requirement — semantic judgment stays with reconcile"*), `scripts/check-citations.sh`.

**No plugin version bump.** Every `scripts/*.sh` in this repo is documented "Repo-internal —
NOT shipped in any plugin" (`scripts/coverage-skeleton.sh:19-20`, `scripts/check-citations.sh:35-37`)
and lives outside every `artifact_paths` list in `.lsa.yaml`. This epic touches only
`scripts/` and therefore triggers **no** `plugin.json` bump, no plugin CHANGELOG entry,
and no plugin README edit.

**Out of scope by pitch no-go 2:** no Wilson confidence interval, no Elo, no variance
statistic. `.lsa/VISION.md` §6 Adjust #3 deferred those and this epic does not reopen it.
Pass/fail counts only.

## User Flows

1. **Harvesting a finished cycle.** The owner (or `reconcile`, in epic 2) runs
   `bash scripts/metrics-harvest.sh .lsa/features/<slug>/conformance.md` and gets four
   fixed-format lines: the feature name plus the three metrics as `M/N`.
2. **Harvesting a pre-contract cycle.** The owner runs it against a historical
   `conformance.md` whose orphan-hunk line is prose rather than canonical (real case:
   `.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md:25`,
   `## Orphan hunks (over-delivery vs F1–F13)`). The only-required-changes line reads
   `UNPARSEABLE` with a reason; the other two metrics still print. Nothing is guessed and
   the historical file is never rewritten (pitch no-go 4).

## Functional requirements (EARS)

- R1. `scripts/metrics-harvest.sh` SHALL accept exactly one required positional argument —
  a path to a `conformance.md` file — and an optional second-and-later argument passed
  through verbatim as git-diff args to `scripts/coverage-skeleton.sh` (default `HEAD`,
  matching `scripts/coverage-skeleton.sh:23`). With zero arguments it SHALL print
  `metrics-harvest: usage: metrics-harvest.sh <conformance.md> [git-diff-args…]` to stderr
  and exit non-zero. When the named path does not exist it SHALL print
  `metrics-harvest: no such file: <path>` to stderr and exit non-zero.

- R2. It SHALL print exactly four lines to stdout, in this order and with these literal
  label prefixes:

  ```
  feature: <basename of the directory containing the conformance.md>
  only-required-changes: <M>/<N>
  accuracy-to-task: <M>/<N>
  citation-resolve-rate: <M>/<N>  (PROXY — resolve-rate, not quote integrity)
  ```

  The `(PROXY — resolve-rate, not quote integrity)` suffix on the third metric SHALL be
  emitted literally and unconditionally, including in its `UNPARSEABLE` form. It is
  required because `scripts/check-citations.sh:12-13` states a green run means
  *"the citation still points at a real line", not "the quote is intact"*. The column
  SHALL NOT be named "citation density" anywhere in the script, its output, or its
  comments (pitch rabbit hole 3).

- R3. Where a metric's inputs are not in the canonical shape, that metric's value field
  SHALL be the literal token `UNPARSEABLE` followed by a parenthesised reason, e.g.
  `only-required-changes: UNPARSEABLE (non-canonical orphan-hunk line)`. The other three
  lines SHALL still be printed. The script SHALL NOT infer, approximate, or regex-guess a
  value for an unparseable metric — mirroring `scripts/coverage-skeleton.sh:12-14`
  ("a script never guesses semantics").

- R4. **only-required-changes** SHALL be computed as `(N − orphans) / N`, where:
  - `N` = the number of `- [ ] ` prefixed lines emitted under `## Candidate hunks` by
    `bash scripts/coverage-skeleton.sh <feature-dir> [git-diff-args…]`, `<feature-dir>`
    being the directory containing the given `conformance.md`.
  - `orphans` = parsed from the conformance file per R5.
  When `N` is 0, or `coverage-skeleton.sh` exits non-zero, the metric SHALL be
  `UNPARSEABLE (no candidate hunks)` / `UNPARSEABLE (coverage-skeleton failed)`.

- R5. The **canonical orphan-hunk line** SHALL be defined as a line in the conformance
  file matching exactly one of:
  - `Orphan hunks: none.` → `orphans = 0`
  - `Orphan hunks: <integer>` → `orphans = <integer>`
  (anchored at start of line, leading `**`/whitespace not permitted). If the file contains
  **zero** such lines, or **more than one**, the only-required-changes metric SHALL be
  `UNPARSEABLE (non-canonical orphan-hunk line)`. A prose heading such as
  `## Orphan hunks (over-delivery vs F1–F13)` SHALL NOT match.

- R6. **accuracy-to-task** SHALL be computed from the requirement ↔ hunk coverage table
  that `reconcile` writes (`lsa/skills/reconcile/SKILL.md:40`). A **coverage row** is a
  line beginning with `|` whose first cell, after stripping whitespace and backticks,
  matches `^[RF][0-9]+[a-z]?$` (both R- and F-keyed specs exist in-repo —
  `scripts/coverage-skeleton.sh:16`; `F1b` exists at
  `.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md:11`). `N` = the number
  of coverage rows. `M` = the number of coverage rows whose **last** non-empty cell
  contains `✅`. A row whose last cell contains neither `✅` nor `❌` counts toward `N`
  and not toward `M`. When `N` is 0 the metric SHALL be
  `UNPARSEABLE (no coverage-table rows)`.

- R7. **citation-resolve-rate** SHALL be computed by running
  `bash scripts/check-citations.sh` and parsing its summary line:
  - `OK  <n> citation(s) checked, all resolve.` → `<n>/<n>`
  - `FAIL <v> broken citation(s) of <n> checked …` → `<n−v>/<n>`
  Any ANSI colour codes present in the output SHALL be stripped before matching (the
  script emits them only on a TTY — `scripts/check-citations.sh:47`). If neither form is
  found the metric SHALL be `UNPARSEABLE (check-citations summary not found)`. This is a
  repo-wide rate, not a per-feature one — that limitation is inherent to the proxy and is
  the reason for the R2 suffix.

- R8. The script SHALL make **zero model calls** and SHALL NOT perform any network access.
  It SHALL match `scripts/` house style: `#!/usr/bin/env bash`, `set -uo pipefail`,
  `export LC_ALL=C`, `cd` to `git rev-parse --show-toplevel` (falling back to `pwd`), and
  bash 3.2-safe constructs only (no `mapfile`, no associative arrays). It SHALL be
  `chmod +x`. Its header comment SHALL state (a) the computes-never-judges split, (b) that
  it is "Repo-internal — NOT shipped in any plugin", and (c) that the citation metric is a
  proxy.

- R9. It SHALL exit `0` whenever it printed its four output lines — including when one or
  more metrics are `UNPARSEABLE` (an unparseable metric is informational, not a failure,
  mirroring `resolve-refs.sh`'s `new`/`MISSING` handling). Non-zero exit SHALL occur only
  on the usage / missing-file errors of R1. The script SHALL NOT gate anything (pitch
  no-go 5: "Measurement observes the gate; it never becomes one").

- R10. It SHALL NOT write to any file. In particular it SHALL NOT append to
  `.lsa/metrics.md` — appending is epic 2's (`reconcile-emit-guard`) responsibility. It
  prints to stdout only.

- R11. `scripts/tests/metrics-harvest-test.sh` SHALL exist, be `chmod +x`, follow the
  hermetic style of `scripts/tests/resolve-refs-test.sh`, and cover at minimum:
  1. A canonical fixture conformance file (`Orphan hunks: none.` + a coverage table with
     both `✅` and `❌` rows) → all three metrics print as `M/N`, exit 0.
  2. `Orphan hunks: 3` → only-required-changes numerator reflects 3 orphans subtracted.
  3. The **real** repo file `.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md`
     → the only-required-changes line contains `UNPARSEABLE`, and the run still exits 0.
  4. accuracy-to-task derivation: a fixture with 4 coverage rows, 3 `✅` → `3/4`.
  5. citation-resolve-rate derivation: the printed line ends with the literal
     `(PROXY — resolve-rate, not quote integrity)`.
  6. Zero arguments → non-zero exit + usage diagnostic on stderr.
  7. A non-existent path → non-zero exit.
  The test SHALL NOT modify any tracked repo file.

- R12. `scripts/run-tests.sh` auto-discovers `scripts/tests/*.sh` (`scripts/run-tests.sh`
  loop over `"${TESTS_DIR}"/*.sh`), so no wiring edit is required; the new test SHALL
  nonetheless be confirmed to appear in `bash scripts/run-tests.sh` output as
  `PASS  metrics-harvest-test.sh`. `.lsa.yaml` `gate:` already runs it via
  `tests: bash scripts/run-tests.sh`.

- R13. `bash scripts/gate.sh` SHALL exit 0 after the change (all five checks:
  docs-invariants, citations, links, project-map, tests).

## Acceptance scenarios (Gherkin)

See [`harvest-script.feature`](./harvest-script.feature).

## Out of Scope

- Appending rows to `.lsa/metrics.md` — epic 2 (`reconcile-emit-guard`).
- The `scripts/lint.sh` C17 presence guard — epic 2.
- Rewriting historical `conformance.md` files to fit the canonical shape (pitch no-go 4).
- Any per-feature citation denominator or claim counting (pitch Fork 3: "No model-side
  claim counting").
- Any statistic beyond pass/fail counts (pitch no-go 2).
- Any dashboard, chart, or presentation layer (pitch no-go 6).
