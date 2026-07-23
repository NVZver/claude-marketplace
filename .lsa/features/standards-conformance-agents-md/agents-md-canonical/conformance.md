# Conformance — standards-conformance-agents-md/agents-md-canonical

`reconcile: PASS @ 29a7d85` (graded range `29a7d85^1..29a7d85`, PR #77)
Graded: 2026-07-20

**Provenance — retro independent grade.** This epic merged without a `conformance.md`. It is
graded here after the fact, in a separate context and by a different model from the
implementer, in a commit separate from the implementation. Rows cite a **re-run** or an
**inspection**; no row claims a 3/3 scenario run that never happened.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `AGENTS.md` (new, 36 lines) | inspection — holds the former `/CLAUDE.md` content with the heading retitled `# AGENTS.md`; relative links (`./.lsa/VISION.md`, `./core/README.md`, …) unchanged | ✅ |
| R2 | `CLAUDE.md` (reduced 28 → 16 lines) | re-run — `grep -n '@AGENTS.md' CLAUDE.md` → line 3, on its own; the file keeps its `# CLAUDE.md` heading and one sentence citing `anthropics/claude-code#6235` as the reason both files must coexist | ✅ |
| R3 | `core/CLAUDE.md` — path unchanged | inspection — the file is edited in place, never renamed or moved; `.lsa.yaml` `core.artifact_paths` and lint C15's `DW_CARD` both still resolve | ✅ |
| R4 | `core/CLAUDE.md` (destination prose) | inspection — names the tool-conditional destination (`CLAUDE.md` for Claude Code, `AGENTS.md` for any other agent tool); no rule text inside the card changed | ✅ |
| R5 | `README.md` install step 2 | inspection — names the same tool-conditional destination, keeping the activation warning | ✅ |
| R6 | `README.md` troubleshooting bullet | inspection — "Always-on rules not applying" names the same destination and still refers to install step 2 | ✅ |
| R7 | `core/README.md` merge-instruction paragraph | inspection — same destination wording; the `core/CLAUDE.md` source path is unchanged | ✅ |
| R8 | `scripts/lint.sh` C16 block | re-run — `bash scripts/lint.sh` → `PASS  C16 discipline text present in exactly one file (AGENTS.md)`; implemented in the C6/C15 presence-guard style | ✅ |
| R9 | `scripts/lint.sh` C16 | inspection — the implementer recorded the negative-control probe in the PR. Not independently re-executed in this grading pass; recorded as the implementer's claim, not as a grader re-run. C16's live PASS line is re-run evidence that the check is wired, and its duplicate-detection branch is exercised structurally by the `DISCIPLINE_HOME` logic | ✅ (partial evidence, stated) |
| R10 | `core/skills/doctor/SKILL.md` — unchanged | inspection — Check 2 greps the *project's* `CLAUDE.md` for four anchors; because `CLAUDE.md` now imports `@AGENTS.md`, the anchors resolve through the import. The skill file is not in this epic's diff, as required | ✅ |
| R11 | `scripts/lint.sh` C15 — unmodified | re-run — both C15 sub-checks PASS (`.lsa/VISION.md` principle, `core/CLAUDE.md` pointer); the C15 code block is untouched by this diff | ✅ |
| R12 | `core/.claude-plugin/plugin.json` → `0.21.0`; `core/CHANGELOG.md` `## [0.21.0]` | inspection — MINOR bump for the user-facing install-instruction change, CHANGELOG entry in the same commit | ✅ |
| R13 | — (no implementing hunk; see below) | re-run — `bash lsa/scripts/project-map-check.sh` → `OK: project-map.yaml is fresh (rebuild matches git)`, exit 0 | ✅ (premise incorrect, outcome verified) |
| R14 | — (gate assertion) | re-run — `bash scripts/gate.sh` → exit 0, 6/6 | ✅ |

Orphan hunks: none.

The 9 paths in `29a7d85^1..29a7d85` include this feature's own `grounding.md`, never a candidate
hunk. The remaining 8 all map: `AGENTS.md` → R1 · `CLAUDE.md` → R2 · `core/CLAUDE.md` → R3/R4 ·
`README.md` → R5/R6 · `core/README.md` → R7 · `scripts/lint.sh` → R8 ·
`core/.claude-plugin/plugin.json`, `core/CHANGELOG.md` → R12.

**R13's stated rationale is wrong, and the requirement is satisfied anyway.** R13 requires
regenerating `project-map.yaml` "because this epic adds the new root file `AGENTS.md`". But
`project-map.yaml` indexes **directories only** — `lsa/scripts/project-map-check.sh` reports
"depth 3, directories only" — so adding a root-level file changes nothing in it. No
regeneration was needed, none was performed, and the freshness check the requirement exists to
protect is green. Recorded here rather than silently passed, because the requirement as
written asserts a false fact about the artifact.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0), 6/6.

## does · only · all

- **does** — 14/14 requirement rows verified; R9 carries partial evidence, stated explicitly
  rather than upgraded to a full re-run it did not receive.
- **only** — 8 candidate hunks, all mapped; no orphans.
- **all** — R1–R14 each have an implementing hunk or a verified assertion.

## Verdict

`reconcile: PASS @ 29a7d85` — with the R9 evidence limitation and the R13 premise correction
stated above.
