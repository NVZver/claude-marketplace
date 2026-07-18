# Conformance — coverage-skeleton

`reconcile: PASS @ 645393b+worktree` (graded 2026-07-19). Independent grader — separate
context from the implementer; graded via the gate + test scripts, not by assertion.
**Dogfood:** the enumeration below was produced by running the new
`scripts/coverage-skeleton.sh` on this epic's own feature dir.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 extract `[RF]\d+` IDs in order | `scripts/coverage-skeleton.sh` | test: R-ID + F-ID extraction — 3/3 | ✅ |
| R2 enumerate diff **+ untracked**, exclude feature-dir | `scripts/coverage-skeleton.sh` (merge `git diff` + `git ls-files --others`) | test: enum + exclusion + untracked; S1/S2/S3 — 3/3 | ✅ |
| R3 table skeleton, one row per ID | `scripts/coverage-skeleton.sh` | dogfood: 10 rows R1–R10 — 3/3 | ✅ |
| R4 candidate-hunks checklist | `scripts/coverage-skeleton.sh` | dogfood: `- [ ]` list — 3/3 | ✅ |
| R5 enumeration only (no mapping) | `scripts/coverage-skeleton.sh` (empty mapping cols) | S1 — 3/3 | ✅ |
| R6 scripts/ style + exit codes | `scripts/coverage-skeleton.sh` (`set -uo pipefail`, bash 3.2-safe) | test: bad-input non-zero; S4 — 3/3 | ✅ |
| R7 reconcile Step 4 cites script, no weakening | `lsa/skills/reconcile/SKILL.md:36` | table-shape + independence phrases intact (3 hits) | ✅ |
| R8 test coverage (incl. untracked) | `scripts/tests/coverage-skeleton-test.sh` | 8 cases PASS, exit 0 | ✅ |
| R9 lsa 0.27.0 + CHANGELOG + README | `lsa/.claude-plugin/plugin.json` (0.27.0); `lsa/CHANGELOG.md` [0.27.0]; `lsa/README.md:100` | — (versioning) | ✅ |
| R10 gate exit 0 | `bash scripts/gate.sh` | exit 0 (4/4 checks) | ✅ |

## does — scenarios (N=3, deterministic script/test)

- S1 enumerate both axes → 10-row skeleton + candidate list, exit 0. 3/3.
- S2 **untracked new file surfaces** → `src/untracked.txt` (and the script's own new files) listed. 3/3.
- S3 spec files excluded → feature-dir paths never candidate hunks. 3/3.
- S4 bad input → one-line diagnostic + non-zero exit. 3/3.

## only — orphan-hunk check (feature scope)

Candidate hunks (from the dogfood run), all traced:
`scripts/coverage-skeleton.sh`→R1–R6 · `scripts/tests/coverage-skeleton-test.sh`→R8 ·
`lsa/skills/reconcile/SKILL.md`→R7 · `lsa/.claude-plugin/plugin.json`+`lsa/CHANGELOG.md`+`lsa/README.md`→R9.
**No orphan.** Pre-existing dirty paths (`.github/workflows/lint.yml`, `.gitignore`,
`.lsa/roadmap.yaml`, `CONTRIBUTING.md`, `cursor-equal-support/`, `marketplace-ai-engineering-audit/`)
excluded — not this feature's diff.

## Reconcile-absorbed drift

The first dogfood run (spec as originally written, R2 = `git diff` only) **missed the epic's
own new untracked files** — the script couldn't grade itself. Absorbed per Level 2.5: R2
tightened to require `git ls-files --others --exclude-standard`, a matching acceptance
scenario added, and the one-line fix delegated back to the implementer (grader did not edit
the code/test it grades). Re-graded green.

## Gate

`bash scripts/gate.sh` → **exit 0**: docs-invariants · citations · links · project-map all PASS.

## Verdict

**PASS** — does · only · all satisfied; R1–R10 covered; no orphan; gate green.
