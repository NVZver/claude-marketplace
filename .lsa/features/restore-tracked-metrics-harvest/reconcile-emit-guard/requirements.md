# Reconcile metrics emit + C17 anti-regression guard

## Summary

Epic 1 built `scripts/metrics-harvest.sh`; nothing calls it yet and `.lsa/metrics.md` is
still frozen at 2 rows from 2026-05-21. This epic (a) restores the emit step — `reconcile`
appends one row to `.lsa/metrics.md` on PASS, (b) tightens the `conformance.md` orphan line
in `lsa/skills/reconcile/SKILL.md` §Output so it is machine-readable, and (c) adds a
**C17** guard to `scripts/lint.sh` that FAILs when the emit step is removed.

The guard is the point. This layer died once already: `lsa` 0.16.0 removed the
`metrics.md` machinery as refactor collateral and **nothing caught it** (pitch rabbit
hole 2). So C17 is specified as a **falsification test** — the deliverable is not "a check
exists" but "deleting the emit step is proven to turn the gate red".

- Source: `.lsa/pitches/restore-tracked-metrics-harvest.md` (approved 2026-07-19), epic 2 of 2.
- Applies: `.lsa/VISION.md` §5 (three tracked metrics); `.lsa/VISION.md` §2 principle 1 ("Trust is the product").
- Target surface: `lsa/skills/reconcile/SKILL.md` §Output + §Steps · `scripts/lint.sh` (new C17) · `scripts/tests/metrics-emit-guard-test.sh` (new) · `.lsa/metrics.md` (schema note + rows) · `.lsa/VISION.md` §5 (gated, owner-only — R9).
- Style precedent: `scripts/lint.sh` C6 (lines 153-166, "Presence check only") and C15 (lines 456-475, two-surface presence guard with a `_MARKER` variable).

**Depends on epic 1** (`restore-tracked-metrics-harvest/harvest-script`).
`scripts/metrics-harvest.sh` is **new** — it does not exist when this spec is written.
Every claim below about its exact output text is tagged `[ASSUMPTION]` and MUST be
re-read from the shipped script before implementing.

## User Flows

1. **Reconcile finishes a cycle.** The owner runs `/lsa:reconcile`. On a PASS verdict the
   skill runs `scripts/metrics-harvest.sh` against the `conformance.md` it just wrote,
   cites the script output, and appends one row to `.lsa/metrics.md`. No new command is
   invoked by hand.
2. **Someone refactors `reconcile` and drops the emit step.** `bash scripts/lint.sh` prints
   a C17 FAIL line and exits 1, so `bash scripts/gate.sh` goes red and the regression is
   caught in the same commit — the failure mode that went unnoticed in `lsa` 0.16.0.
3. **The owner reads the ledger.** `.lsa/metrics.md` shows a per-cycle trend; its schema
   note states plainly that the citation column is a proxy and that the two May 2026 rows
   are pre-contract.

## Functional requirements (EARS)

- R1. `lsa/skills/reconcile/SKILL.md` §Output SHALL specify the orphan-hunk line as a
  **canonical, machine-readable** line, replacing the current free-prose allowance
  ("Below the table, list any orphan hunks", `lsa/skills/reconcile/SKILL.md:36`). The
  specified shape SHALL be exactly one line, at column 0, of one of two forms:
  - `Orphan hunks: none.` (zero orphans)
  - `Orphan hunks: <integer>` (that many orphans), optionally followed by a prose
    breakdown on **subsequent** lines.
  The SKILL SHALL state that a prose heading (e.g. `## Orphan hunks (over-delivery vs …)`)
  does NOT satisfy the contract, and that exactly one such line must appear per
  `conformance.md`. The synthetic coverage-table example at
  `lsa/skills/reconcile/SKILL.md:44-52` SHALL be updated to show the canonical line.
  `[ASSUMPTION]` the two forms above match epic 1's R5 parser — confirm against the
  shipped `scripts/metrics-harvest.sh` before writing.

- R2. `lsa/skills/reconcile/SKILL.md` SHALL add a **metrics emit step** to §Steps and
  name it in §Output. The step SHALL: on a `reconcile: PASS` verdict only, run
  `bash scripts/metrics-harvest.sh <feature-dir>/conformance.md`, quote its output as the
  cited source, and append one row to `.lsa/metrics.md` using the existing six-column
  schema (`.lsa/metrics.md:7`: `feature · archived · accuracy (M/N) · facts (M/N) ·
  only-required-changes (M/N) · notes`). On a FAIL verdict no row SHALL be appended.

- R3. The emit step SHALL be **descriptive only**. It SHALL NOT change any PASS/FAIL
  verdict logic, gate threshold, or `reconcile.runs` semantics (pitch no-go 5), and a
  failure of `metrics-harvest.sh` SHALL NOT turn a PASS into a FAIL — it is recorded in
  the row's `notes` column instead. An `UNPARSEABLE` metric SHALL be written verbatim as
  `UNPARSEABLE` into its column, never omitted and never estimated.

- R4. `.lsa/metrics.md` SHALL be updated:
  - The writer line "Written by `lsa:verify` on clean PASS" (`.lsa/metrics.md:5`) SHALL be
    corrected to name `lsa:reconcile` and `scripts/metrics-harvest.sh`.
  - The schema note SHALL rename the `Facts` column to **`Citation resolve-rate`** and
    state the limitation in one sentence: the number is the
    `scripts/check-citations.sh` resolve-rate, which proves the citation still points at a
    real line, not that the quote is intact (`scripts/check-citations.sh:12-13`); it is a
    **proxy** for "proven facts with sources" and SHALL NOT be called "citation density"
    (pitch rabbit hole 3 / Fork 3).
  - The existing 2026-05-21 rows SHALL be kept and marked **pre-contract** in their
    `Notes` cell — not deleted, not recomputed.
  - The existing "Pass/fail counts only — no statistical eval" note SHALL be kept
    (pitch no-go 2: no Wilson CI, no Elo, no variance statistic).

- R5. `scripts/lint.sh` SHALL gain a check numbered **C17**. (C15 is the highest check in
  `scripts/lint.sh` today, at line 456; **C16 is reserved** by the
  `standards-conformance-agents-md/agents-md-canonical` epic, which ships before this one —
  the implementer SHALL NOT renumber, reuse, or occupy C16.) C17 SHALL follow the C6/C15
  presence-guard pattern: a banner comment block explaining *why* the guard exists (naming
  the `lsa` 0.16.0 silent removal), literal marker strings in shell variables, and
  `pass_line` / `fail_line` calls.

- R6. C17 SHALL assert the presence of **both** markers in `lsa/skills/reconcile/SKILL.md`:
  1. the literal string `scripts/metrics-harvest.sh`, and
  2. the literal string `.lsa/metrics.md`.
  Each marker SHALL emit its own `pass_line` / `fail_line`, with fail text naming the
  regression, e.g.
  `C17 metrics-harvest emit step missing from lsa/skills/reconcile/SKILL.md (metrics writer dropped again — see lsa 0.16.0)`.
  C17 SHALL be a **presence check only** — verifying that the emit step actually ran on a
  given cycle is reconcile's own job, not a grep (mirroring the C15 comment,
  `scripts/lint.sh:459-461`).

- R7. **Falsification requirement.** `scripts/tests/metrics-emit-guard-test.sh` SHALL prove
  that C17 fails when the emit step is deleted — not merely that C17 exists. It SHALL:
  1. Back up `lsa/skills/reconcile/SKILL.md` to a temp file and install a `trap … EXIT`
     that restores it unconditionally, so an interrupted run cannot leave the repo dirty.
  2. Assert the baseline: `bash scripts/lint.sh` output contains a C17 `PASS` line.
  3. **Negative control:** remove every line containing `scripts/metrics-harvest.sh` and
     every line containing `.lsa/metrics.md` from `lsa/skills/reconcile/SKILL.md`, re-run
     `bash scripts/lint.sh`, and assert (a) the output contains a C17 `FAIL` line and
     (b) `scripts/lint.sh` exits **non-zero**.
  4. Restore the file and assert the C17 `PASS` line returns and `scripts/lint.sh`'s C17
     lines are green again.
  A test that only checks step 2 SHALL be treated as not meeting this requirement.
  `scripts/run-tests.sh` auto-discovers `scripts/tests/*.sh`, so no runner edit is needed;
  the test SHALL appear as `PASS  metrics-emit-guard-test.sh` in its output.

- R8. `lsa` SHALL bump SemVer **0.29.0 → 0.30.0** (MINOR — new `reconcile` behavior +
  tightened output contract; the spec's original wording said 0.28.1 → 0.29.0, but
  `name-conformance-as-rtm` already shipped 0.29.0 on the base branch before this epic
  started — grounding drift, corrected per `grounding.md`) in `lsa/.claude-plugin/plugin.json`, with a matching
  `lsa/CHANGELOG.md` entry (Keep a Changelog, same commit) and a `lsa/README.md` update
  where the `reconcile` surface is described (`lsa/README.md:8`, `lsa/README.md:70`) noting
  that reconcile now writes a `.lsa/metrics.md` row on PASS. `scripts/lint.sh`,
  `scripts/tests/*`, `.lsa/metrics.md` and `.lsa/VISION.md` are repo-level (outside every
  `artifact_paths` in `.lsa.yaml`) — only the `lsa/skills/reconcile/SKILL.md` edit drives
  the bump. No other plugin bumps.

- R9. **Owner-gated, do NOT self-apply.** `.lsa/VISION.md` §5 currently describes the three
  metrics as session-level personal measurement; this epic measures **per cycle, from
  artifacts**. A one-line §5 clarification SHALL ship in the same cycle, stating that the
  three metrics are measured per LSA cycle from `conformance.md` + gate-script output, not
  per session. Constitution edits are **owner-only** and go through `lsa:revise-constitution`
  (pitch rabbit hole 5, Fork 4). The implementer SHALL draft the one-line wording, surface
  it as a pending gate for the owner, and SHALL NOT edit `.lsa/VISION.md` directly. If the
  gate is not run, the requirement is reported as blocked — never silently applied.

- R10. No session-level telemetry, hook, event log, network call, or external service SHALL
  be added (pitch no-gos 1 and 3). No dashboard, chart, or visualization (no-go 6).
  `.lsa/metrics.md` stays a markdown table.

- R11. `bash scripts/gate.sh` SHALL exit 0 after the change (docs-invariants, citations,
  links, project-map, tests), and `bash scripts/run-tests.sh` SHALL report every test
  passing, including `metrics-emit-guard-test.sh`.

## Acceptance scenarios (Gherkin)

See [`reconcile-emit-guard.feature`](./reconcile-emit-guard.feature).

## Out of Scope

- `scripts/metrics-harvest.sh` itself and its test — epic 1
  (`restore-tracked-metrics-harvest/harvest-script`).
- Backfilling `.lsa/metrics.md` rows for the 23 historical `conformance.md` files, or
  rewriting those files to fit the canonical contract (pitch no-go 4). The two May 2026
  rows are marked pre-contract and left alone (R4).
- Editing `.lsa/VISION.md` directly (R9 — owner-gated via `lsa:revise-constitution`).
- Any change to PASS/FAIL logic, gate thresholds, or `reconcile.runs` (R3, pitch no-go 5).
- Any statistic beyond pass/fail counts (pitch no-go 2).

## Assumptions

- `[ASSUMPTION]` The canonical orphan-line forms in R1 match epic 1's parser exactly.
  Epic 1 defines the format; re-read `scripts/metrics-harvest.sh` before writing R1's text.
- `[ASSUMPTION]` `scripts/metrics-harvest.sh` prints one labelled line per metric and exits
  0 even when a metric is `UNPARSEABLE`, so R3's "never turns PASS into FAIL" holds without
  extra error handling. Confirm against the shipped script.
- `[ASSUMPTION]` C16 is taken by `standards-conformance-agents-md/agents-md-canonical` and
  is already merged when this epic runs. If `scripts/lint.sh` shows no C16 at
  implementation time, still use C17 — numbers are never reused.
