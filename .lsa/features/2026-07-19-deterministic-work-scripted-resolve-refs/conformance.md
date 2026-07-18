# Conformance — resolve-refs

`reconcile: PASS @ 09f1fd6+worktree` (graded 2026-07-19). Independent grader — separate
context from the implementer; verdicts rest on the gate + test scripts and on defect
reproduction, not assertion. **Dogfood:** candidate hunks enumerated by
`scripts/coverage-skeleton.sh` (epic 2's deliverable).

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 args take precedence; stdin only when no args; empty → non-zero | `scripts/resolve-refs.sh` (`if [[ $# -gt 0 ]]`, `-t 0` removed) | hang test completes immediately; args-precedence; stdin fallback; empty-input — 3/3 | ✅ |
| R2 path → `exists @ <path>` \| `new` | `scripts/resolve-refs.sh` | sanity: `scripts/gate.sh`→exists, `scripts/nope.sh`→new — 3/3 | ✅ |
| R3 `path:line` in-range \| MISSING \| OUT-OF-RANGE | `scripts/resolve-refs.sh` | sanity: `README.md:1`→exists, `:999999`→OUT-OF-RANGE — 3/3 | ✅ |
| R4 identifier → first `git grep -n` hit \| `new` | `scripts/resolve-refs.sh` | sanity: `pass_line`→`exists @ …:18` — 3/3 | ✅ |
| R5 resolution only (never guesses symbols) | `scripts/resolve-refs.sh` (resolves given list) | — (scope) | ✅ |
| R6 scripts/ style + exit contract | `scripts/resolve-refs.sh` (`set -uo pipefail`, bash 3.2-safe) | exit 0 with `new`/`OUT-OF-RANGE` results | ✅ |
| R7 verify Step 1 cites script; no weakening | `lsa/skills/verify/SKILL.md:30` | Steps 2/3/4 intact; "Never delegate an ungrounded spec" intact | ✅ |
| R8 test coverage | `scripts/tests/resolve-refs-test.sh` | 11 cases PASS, exit 0 | ✅ |
| R9 lsa 0.28.0 + CHANGELOG + README | `lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md` [0.28.0], `lsa/README.md` | — (versioning) | ✅ |
| R10 gate exit 0 | `bash scripts/gate.sh` | exit 0 (4/4) | ✅ |

## does — scenarios (N=3, deterministic)

- S1 mixed path/missing/identifier → exists@ / new / exists@file:line, exit 0. 3/3.
- S2 `path:line` range → in-range exists@, over-length OUT-OF-RANGE. 3/3.
- S3 **arg-only never blocks on stdin** → completes immediately (previously hung >4s). 3/3.
- S4 empty input → usage diagnostic, non-zero. 3/3.

## only — orphan-hunk check (feature scope)

Traced: `scripts/resolve-refs.sh`→R1–R6 · `scripts/tests/resolve-refs-test.sh`→R8 ·
`lsa/skills/verify/SKILL.md`→R7 · `lsa/.claude-plugin/plugin.json`+`lsa/CHANGELOG.md`+`lsa/README.md`→R9.
**No orphan.** Excluded as pre-existing (not this feature): `.github/workflows/lint.yml`,
`.gitignore`, `.lsa/roadmap.yaml`, `CONTRIBUTING.md`, `.lsa/features/cursor-equal-support/*`,
`.lsa/features/marketplace-ai-engineering-audit/*`, `.lsa/pitches/cursor-equal-support.md`,
`scripts/generate-for-cursor.sh`, `scripts/tests/generate-for-cursor-test.sh`.

## Reconcile-absorbed drift

Original R1 ("args AND/OR stdin", `-t 0`-guarded) produced a **confirmed hang**: arg-only
invocation blocked >4s and had to be killed. The primary consumer (`lsa:verify`) runs inside
an agent harness where stdin is an open pipe that never EOFs, so this broke the main use
case while the implementer's tests passed — they used `</dev/null`, which masked the exact
condition. Absorbed: R1 rewritten to conventional Unix precedence (args win; stdin is the
no-args fallback), acceptance scenario S3 added, fix delegated back to the implementer
(grader did not edit the code/test it grades). Implementer additionally proved the new FIFO
regression test discriminates old-vs-new logic rather than passing vacuously.

## Known boundaries (documented, not defects)

- **R4 first-hit semantics:** `pass_line` resolves to `.lsa/features/…/conformance.md:18`
  (first tracked-path-order hit), not its definition at `scripts/lint.sh:27`. Per R4's
  "first hit" contract; preferring code files over docs would be a fragile heuristic. The
  model reviews the reference map, so a doc-mention hit is visible, not silent.
- **Candidate-hunk noise:** since epic 2 added untracked enumeration, pre-existing untracked
  work appears in the list. Correct behavior — the grader scopes to the feature.

## Gate

`bash scripts/gate.sh` → **exit 0**: docs-invariants · citations · links · project-map all PASS.

## Verdict

**PASS** — does · only · all satisfied; R1–R10 covered; no orphan; gate green.
