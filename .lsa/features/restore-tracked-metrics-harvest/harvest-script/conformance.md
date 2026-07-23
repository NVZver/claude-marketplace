# Conformance — restore-tracked-metrics-harvest/harvest-script

`reconcile: PASS @ b26c2b2` — independent grade, 2026-07-20 (see "Independent re-grade" below)
Graded: working tree on `feature/harvest-script` · Date: 2026-07-20 · N = `.lsa.yaml` `reconcile.runs` = **3** (pass = 3/3)

**Note on independence.** Everything from here to §"does · only · all" is the original
**self-check**, produced by the same agent that wrote the implementation, in the same context —
it does **not** satisfy `lsa/knowledge/quality-gate-contract.md`'s independence rule (a separate
context, a separate commit). It was submitted per the orchestrator's instruction to self-check
before handoff, deferring to an independent `lsa:reconcile` run as authoritative. That run never
happened before merge. It is supplied in §"Independent re-grade (2026-07-20)" below, which is
the authoritative verdict; the self-check is retained as the record of what was claimed at
handoff.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `scripts/metrics-harvest.sh` (usage + missing-file guards) | `harvest-script.feature` "Missing argument is a usage error" — **3/3**; "Missing file is an input error" — **3/3** (both via `scripts/tests/metrics-harvest-test.sh`) | ✅ |
| R2 | `scripts/metrics-harvest.sh` (4-line stdout contract + literal PROXY suffix) | `harvest-script.feature` "Canonical conformance file yields all three metrics" — **3/3**; "Citation metric is derived… labelled a proxy" — **3/3** | ✅ |
| R3 | `scripts/metrics-harvest.sh` (UNPARSEABLE + reason, no guessing) | `harvest-script.feature` "Non-canonical orphan line is reported UNPARSEABLE" — **3/3** | ✅ |
| R4 | `scripts/metrics-harvest.sh` (only-required-changes = (N−orphans)/N; UNPARSEABLE on N=0 / coverage-skeleton failure) | `harvest-script.feature` "Orphans are subtracted from the candidate-hunk denominator" — **3/3** (10 candidate hunks, 3 orphans → 7/10) | ✅ |
| R5 | `scripts/metrics-harvest.sh` (canonical orphan-line regex, anchored, ≠1 match → UNPARSEABLE) | `harvest-script.feature` "Non-canonical orphan line…" — **3/3** (real historical file, prose heading); "Multiple canonical orphan lines are ambiguous" — **3/3** | ✅ |
| R6 | `scripts/metrics-harvest.sh` (coverage-row parse: `^[RF][0-9]+[a-z]?$` first cell, last-non-empty-cell ✅ check) | `harvest-script.feature` "Canonical conformance file…" accuracy-to-task 3/4 — **3/3**; orphan-fixture accuracy-to-task 4/4 — **3/3**; real historical file 14/14 (manual verification, all F1–F13+F1b rows ✅) | ✅ |
| R7 | `scripts/metrics-harvest.sh` (check-citations.sh summary parse, ANSI-strip, OK/FAIL branches) | `harvest-script.feature` "Citation metric is derived from check-citations.sh…" — **3/3** (fake FAIL-emitting check-citations.sh: `FAIL 2 broken citation(s) of 50 checked` → `48/50`) | ✅ |
| R8 | `scripts/metrics-harvest.sh` header comment (computes-never-judges, repo-internal, proxy note); `set -uo pipefail`; `export LC_ALL=C`; `cd` to `git rev-parse --show-toplevel` w/ `pwd` fallback; no `mapfile`/assoc arrays; `chmod +x` | manual inspection of `scripts/metrics-harvest.sh:1-30` + `chmod +x` confirmed (`ls -l` shows `-rwxr-xr-x`); zero model calls / zero network calls — pure bash+git+awk+sed | ✅ |
| R9 | `scripts/metrics-harvest.sh` (`exit 0` after 4 lines printed, including UNPARSEABLE cases; non-zero only on R1 usage/missing-file) | all `harvest-script.feature` scenarios that reach the 4-line output — **3/3** each, all exit 0; usage/missing-file scenarios — **3/3** each, exit non-zero | ✅ |
| R10 | `scripts/metrics-harvest.sh` (stdout-only; no file writes; no `.lsa/metrics.md` append) | `harvest-script.feature` "The harvest never writes" — verified via `git status --short` (no untracked/modified files after runs) + real-historical-file byte-for-byte SHA-256 checksum unchanged — **3/3** | ✅ |
| R11 | `scripts/tests/metrics-harvest-test.sh` (hermetic, `chmod +x`, covers items 1-7) | self-run — **3/3** (11/11 assertions pass each run); does not modify any tracked repo file (`git status --short` empty pre/post) | ✅ |
| R12 | `scripts/run-tests.sh` auto-discovery (no wiring edit made) | `bash scripts/run-tests.sh` output contains literal `PASS  metrics-harvest-test.sh` — confirmed — **3/3** | ✅ |
| R13 | `bash scripts/gate.sh` full 5-check pass | gate.sh run **3/3** — exit 0 each time (see Gate section below) | ✅ |

## Orphan hunks

`scripts/coverage-skeleton.sh .lsa/features/restore-tracked-metrics-harvest/harvest-script`
candidate hunks: `scripts/metrics-harvest.sh`, `scripts/tests/metrics-harvest-test.sh` — both
map to rows above.

Orphan hunks: none.

A third file, `project-map.yaml`, was touched but lives in a **separate, prior commit**
(`c0fa803`, "chore: regenerate project-map.yaml for restore-tracked-metrics-harvest epics") —
not part of this epic's diff. It fixed pre-existing baseline gate drift (see
`grounding.md` §"Baseline gate drift found and fixed") inherited from the branch tip and is not
an orphan of this spec; it precedes and is independent of it.

**Orphan hunks blocking PASS?** No.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` → **PASS** (exit 0), run 3/3 times, identical results each run:

| Check | Command | Exit |
|---|---|---|
| docs-invariants | `bash scripts/lint.sh` | 0 |
| citations | `bash scripts/check-citations.sh` | 0 |
| links | `bash scripts/check-links.sh` | 0 |
| project-map | `bash lsa/scripts/project-map-check.sh` | 0 |
| tests | `bash scripts/run-tests.sh` | 0 |

## does · only · all

- **does** — all 13 requirement rows proven by scenario runs at N=3 (3/3 each), gate PASS 3/3.
- **only** — 2 candidate hunks (`scripts/metrics-harvest.sh`, `scripts/tests/metrics-harvest-test.sh`), both mapped to requirement rows; no orphans.
- **all** — R1–R13 each have an implementing hunk, a proving run, and a ✅ verdict.

## Independent re-grade (2026-07-20)

The self-check above was never followed by the independent run it defers to; the epic merged
with its verdict left `@ <pending>`. That run is supplied here, in a separate context and by a
different model from the implementer.

**Re-run evidence:** `bash scripts/tests/metrics-harvest-test.sh` → all cases pass (now 14,
after three cases added by the 2026-07-20 findings sweep); `bash scripts/run-tests.sh` → 10/10;
`bash scripts/gate.sh` → 6/6 exit 0. R1–R13 as tabled above are confirmed.

**Two defects the self-check missed, both since fixed:**

1. **This file violated the contract its own epic defined.** The orphan line was written as a
   bolded `**Orphan hunks: none.**` under a `## Orphan hunks` prose heading — precisely the
   shape R5 declares invalid — so `metrics-harvest.sh` reported
   `only-required-changes: UNPARSEABLE` on the artifact of the epic that built it. Corrected to
   the canonical column-0 form; lint **C19** now enforces this on every post-contract
   `conformance.md`.
2. **`only-required-changes` was computable but wrong for any committed cycle.** With no
   explicit range the metric measured the current working tree, and untracked build output
   (`dist/`, ungitignored) counted as candidate hunks — this feature harvested as `65/65` at one
   point, against a real diff of 2 files. Fixed by the commit-range guard in
   `metrics-harvest.sh` and `coverage-skeleton.sh`, plus a `.gitignore` entry for `dist/`.

Neither defect changes the epic's PASS: the requirements are met as written. Both are defects
in what the requirements asked for, and are recorded in the findings sweep.

## Verdict

`reconcile: PASS @ b26c2b2` — independent grade. The self-check's verdict is superseded by
this one.
