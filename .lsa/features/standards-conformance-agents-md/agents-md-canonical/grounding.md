# Grounding — agents-md-canonical

Verdict: **GROUNDED** @ 2026-07-20 (branch feature/agents-md-canonical, based on chore/project-quality-improvements @ 9de6656).

| Spec reference | Resolution |
|---|---|
| `/CLAUDE.md` (rewire target, R1/R2) | `exists @ CLAUDE.md` (24 lines) |
| `/AGENTS.md` (new, R1) | `new` |
| `core/CLAUDE.md` (R3/R4, path pinned) | `exists @ core/CLAUDE.md` |
| `.lsa.yaml` `core.artifact_paths` incl. `core/CLAUDE.md`, `core/README.md` | `exists @ .lsa.yaml:59-60` (pitch cites `:61`, off-by-one vs. current file — immaterial, both paths present in the list) |
| lint C6 style precedent (banner + presence guard) | `exists @ scripts/lint.sh:153-165` (requirements.md cites 152-165, off-by-one, same block) |
| lint C15 style precedent + `DW_CARD` | `exists @ scripts/lint.sh:456-475`, `DW_CARD="core/CLAUDE.md"` @ `scripts/lint.sh:465` — exact match |
| `README.md` install step 2 (R5) | `exists @ README.md:71` — exact match, text verbatim as quoted in R5 |
| `README.md` troubleshooting bullet (R6) | `exists @ README.md:92` — exact match |
| `core/README.md` merge paragraph (R7) | `exists @ core/README.md:33` — exact match, begins "Copy the content of ..." |
| `core/skills/doctor/SKILL.md` Check 2 (R10, regression guard — do not edit) | `exists @ core/skills/doctor/SKILL.md:28` — greps the *consumer's* `CLAUDE.md` for 4 anchors; unaffected by this epic since `core/CLAUDE.md` fragment content is untouched |
| `core/.claude-plugin/plugin.json` version (R12) | `0.20.0` → **0.21.0** (MINOR) |
| `core/CHANGELOG.md` latest heading | `## [0.20.0] — 2026-07-19` (new `## [0.21.0]` heading to be added) |
| `scripts/lint.sh` C16 (new, R8/R9) | `new` — appended after C15 (`scripts/lint.sh:475`), before the final pass/fail summary |
| `project-map.yaml` (R13) | pre-existing drift found: `.lsa/features/standards-conformance-agents-md/` (added by base-branch commit `9de6656`, not yet reflected) makes `bash lsa/scripts/project-map-check.sh` fail on the *unmodified* tree (exit 1, confirmed below). R13 explicitly requires this epic's diff to include the regenerated, committed `project-map.yaml` — fixed as part of implementation, not a separate grounding-fix commit. |

## Feasibility

Buildable: two markdown file edits (`CLAUDE.md` rewire, new `AGENTS.md`), three README paragraph edits, one new `scripts/lint.sh` check in the existing C6/C15 style, one `plugin.json` bump + `CHANGELOG.md` entry, one `project-map.yaml` regen. No infeasible flow; no new module/function beyond the lint check.

## Gate (baseline, before implementation)

`bash scripts/gate.sh` on the unmodified tree → **exit 1**:

```
PASS  docs-invariants  bash scripts/lint.sh → exit 0
PASS  citations        bash scripts/check-citations.sh → exit 0
PASS  links            bash scripts/check-links.sh → exit 0
FAIL  project-map      bash lsa/scripts/project-map-check.sh → exit 1
PASS  tests            bash scripts/run-tests.sh → exit 0
```

The sole failure is the project-map staleness R13 already names as in-scope for this epic (new `.lsa/features/standards-conformance-agents-md/` directory added by the base branch, not yet regenerated/committed). `check-version-changelog.sh` (R14, not in the `.lsa.yaml` `gate:` block) independently passes: `OK 5 plugin(s) checked, every plugin.json version mirrors its CHANGELOG heading`.

This is not a spec-grounding defect — it is the exact drift R13 requires this epic to close. Fixed in the implementation commit; the gate is re-run and cited green in `conformance.md` / the final report, per the skill's "fix the grounding drift" instruction rather than blocking on a pre-existing, spec-anticipated condition.

## Blockers

None. All spec-cited file:line references resolve (two are off-by-one against the pitch/requirements citation, both immaterial — same code block / same paragraph). No `[ASSUMPTION]` required.
