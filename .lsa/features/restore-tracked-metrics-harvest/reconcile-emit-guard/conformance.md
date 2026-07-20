# Conformance — restore-tracked-metrics-harvest/reconcile-emit-guard

`reconcile: PASS @ ea3df0c` (graded range `ea3df0c^1..ea3df0c`, PR #79)
Graded: 2026-07-20

**Provenance — retro independent grade.** This epic merged without a `conformance.md`. It is
graded here after the fact, in a separate context and by a different model from the
implementer, in a commit separate from the implementation. Rows cite a **re-run** or an
**inspection**; no row claims a 3/3 scenario run that never happened.

**The irony this grade has to record.** This is the epic that made the canonical orphan-hunk
line mandatory (R1) and restored the metrics emit step (R2). It shipped without producing a
`conformance.md` of its own, so it never applied its own contract, and the emit step it
restored never ran — `.lsa/metrics.md` still held only its two May rows until this grading
pass. R5–R7's C17 guard passed throughout, because C17 greps `reconcile/SKILL.md` for the
instruction text and cannot observe whether the step executed. That gap is closed by lint
**C19** (added 2026-07-20), which checks the emitted artifact rather than the instruction.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/skills/reconcile/SKILL.md` Step 4 + §Output | inspection — Step 4 now specifies "exactly one line, at column 0, either `Orphan hunks: none.` or `Orphan hunks: <integer>`", and explicitly rejects a prose heading. Replaces the former free-prose allowance | ✅ |
| R2 | `lsa/skills/reconcile/SKILL.md` Step 5 (new), named in §Output | inspection — Step 5 runs `bash scripts/metrics-harvest.sh <feature-dir>/conformance.md` on PASS only, quotes its output, appends one row to `.lsa/metrics.md`, and maps the harvest's three names onto the six-column schema | ✅ |
| R3 | `lsa/skills/reconcile/SKILL.md` Step 5 | inspection — "This step is **descriptive only**: it never changes the PASS/FAIL verdict, the gate threshold, or `reconcile.runs` semantics"; `UNPARSEABLE` is recorded verbatim in `notes` and never turns a PASS into a FAIL | ✅ |
| R4 | `.lsa/metrics.md:5` (writer line), schema note | re-run — `grep -n 'Written by'` → "Written by `lsa:reconcile` on a PASS verdict, via `scripts/metrics-harvest.sh`". The former `Facts` column is renamed `Citation resolve-rate` with the proxy limitation stated | ✅ |
| R5 | `scripts/lint.sh` C17 block | re-run — `bash scripts/lint.sh` → two `PASS  C17 …` lines; C16 not reused or renumbered | ✅ |
| R6 | `scripts/lint.sh` C17 (two markers, two `pass_line`/`fail_line` pairs) | re-run — both markers (`scripts/metrics-harvest.sh`, `.lsa/metrics.md`) emit their own line; fail text names the lsa 0.16.0 regression | ✅ |
| R7 | `scripts/tests/metrics-emit-guard-test.sh` (123 lines, backup + `trap … EXIT` restore) | re-run — **6/6 cases pass**, including the negative control: with both markers stripped, C17 emits FAIL and `scripts/lint.sh` exits 1; the file is restored byte-for-byte. This is real falsification, not a green-run observation | ✅ |
| R8 | `lsa/.claude-plugin/plugin.json` → `0.30.0`; `lsa/CHANGELOG.md`, `lsa/README.md` | inspection — bumped to **0.30.0** per the corrected grounding (0.29.0 was taken by `name-conformance-as-rtm` on the base branch) | ✅ |
| R9 | `.lsa/VISION.md` §5 clarification (v0.14), `.lsa/VISION-digest.md` regenerated | inspection — shipped as its own commit `1e37950` on branch `constitution/reconcile-emit-guard-metrics-clarification`, merged separately (`d1de2d7`). Correctly **not** self-applied inside the epic commit, per R9's owner-gated rule | ✅ |
| R10 | — (a no-go assertion) | inspection — the diff adds no hook, event log, network call, external service, dashboard, or chart; `.lsa/metrics.md` remains a markdown table | ✅ |
| R11 | — (a gate assertion) | re-run — `bash scripts/gate.sh` → exit 0, 6/6; `bash scripts/run-tests.sh` → **10/10**, including `metrics-emit-guard-test.sh` | ✅ |

Orphan hunks: none.

The 12 paths in `ea3df0c^1..ea3df0c` include 3 of this feature's own spec files
(`requirements.md`, `reconcile-emit-guard.feature`, `grounding.md`), which are never candidate
hunks. The remaining 9 all map: `lsa/skills/reconcile/SKILL.md` → R1/R2/R3 · `.lsa/metrics.md`
→ R4 · `scripts/lint.sh` → R5/R6 · `scripts/tests/metrics-emit-guard-test.sh` → R7 ·
`lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`, `lsa/README.md` → R8 · `.lsa/VISION.md`,
`.lsa/VISION-digest.md` → R9.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0), 6/6.

## does · only · all

- **does** — 11/11 requirement rows verified. R7's falsification test is the strongest artifact
  in this epic and the right pattern for an anti-regression guard.
- **only** — 9 candidate hunks, all mapped; no orphans.
- **all** — R1–R11 each have an implementing hunk (or, for R10/R11, a verified assertion).

## Verdict

`reconcile: PASS @ ea3df0c` — the epic's requirements are met as written. The requirements
themselves under-specified the guard: R5–R7 asked only that C17 prove the emit step is still
*documented*, which is what the implementer built. Enforcing that the step's *output* is
well-formed needed a separate check (C19) and a separate finding to notice it was missing.
