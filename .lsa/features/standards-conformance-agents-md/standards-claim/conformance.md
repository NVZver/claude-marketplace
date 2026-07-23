# Conformance — standards-conformance-agents-md/standards-claim

`reconcile: PASS @ 1307431` (graded range `1307431^1..1307431`, PR #80)
Graded: 2026-07-20

**Provenance — retro independent grade.** This epic merged without a `conformance.md`. It is
graded here after the fact, in a separate context and by a different model from the
implementer, in a commit separate from the implementation. Rows cite a **re-run** or an
**inspection**; no row claims a 3/3 scenario run that never happened.

**This epic is the sweep's best moment and should be read as the reference case.** Its parent
pitch asserted 20/20 Agent Skills spec conformance as an established fact. The implementer ran
the actual reference validator instead of inheriting the assumption, found **13/20**, verified
the cause by direct byte inspection of the frontmatter, recorded the honest number, corrected
the README/VISION claims to a qualified form, and backlogged the fix rather than quietly
folding it into a citation-only epic. R5 pre-authorised exactly this kind of honesty; the
implementer went further and produced a real number rather than the `[unverified]` escape.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `scripts/lint.sh` C7 banner comment | inspection — cites `https://agentskills.io/specification` alongside the existing Anthropic best-practices URL | ✅ |
| R2 | `scripts/lint.sh` C9 banner comment | inspection — cites the same spec URL alongside the retained internal pitch-fork reference | ✅ |
| R3 | `scripts/lint.sh` (comment lines only) | inspection — the epic's `scripts/lint.sh` hunk is +9 lines, all comment; `DESC_LIMIT=1024`, `BODY_LIMIT=500`, the `awk` programs and every `pass_line`/`fail_line` string are untouched. Re-run: C7 and C9 both still PASS | ✅ |
| R4 | `core/VERIFICATION.md` §"Agent Skills spec conformance" | inspection — transcribes the `npx --yes skills-ref validate` invocation and the per-skill result over all 20 shipped skills | ✅ |
| R5 | `core/VERIFICATION.md` (honesty clause) | inspection — the escape hatch was **not** needed: the validator ran and returned a real number. The section records the original 13/20, names the 7 failing skills and the root cause (unquoted mid-string `: ` in `description:`), and never reported an unverified 20/20 | ✅ |
| R6 | `core/VERIFICATION.md` | re-run — exactly one greppable line explains that `license` / `metadata` are deliberately unset because the root `LICENSE` is the single source of truth | ✅ |
| R7 | — (a no-go assertion) | re-run — `grep -rl '^license:\|^metadata:' --include=SKILL.md .` → no matches; no SKILL.md frontmatter gained either field | ✅ |
| R8 | `.lsa.yaml` — unchanged | re-run — `git diff 1307431^1 1307431 -- .lsa.yaml` → **0 lines**; the `gate:` block is byte-identical and stays npm-free | ✅ |
| R9 | `README.md` §"Status + substrate" | inspection — names both standards by URL (`https://agents.md/`, `https://agentskills.io/specification`) | ✅ |
| R10 | `.lsa/VISION.md` (+ `.lsa/VISION-digest.md` regenerated) | inspection — names both standards by URL in the substrate/portability section | ✅ |
| R11 | `core/.claude-plugin/plugin.json` → `0.21.1`; `core/CHANGELOG.md` | inspection — one PATCH bump above the sibling epic's 0.21.0, with a matching CHANGELOG entry in the same commit | ✅ |
| R12 | — (no implementing hunk) | re-run — `bash lsa/scripts/project-map-check.sh` → fresh, exit 0. As in the sibling epic, `project-map.yaml` is directories-only, so no regeneration was required | ✅ |
| R13 | — (gate assertion) | re-run — `bash scripts/gate.sh` → exit 0, 6/6 | ✅ |

Orphan hunks: none.

All 7 files in `1307431^1..1307431` map: `scripts/lint.sh` → R1/R2/R3 · `core/VERIFICATION.md`
→ R4/R5/R6 · `README.md` → R9 · `.lsa/VISION.md`, `.lsa/VISION-digest.md` → R10 ·
`core/.claude-plugin/plugin.json`, `core/CHANGELOG.md` → R11.

**Subsequent state, recorded for accuracy.** `core/VERIFICATION.md` today reads **20/20**, not
the 13/20 this epic recorded. That is not drift in this epic: the follow-up item
`agent-skills-strict-yaml-conformance` (PR #84, core 0.21.2 / lsa 0.32.1) fixed the 7
descriptions and re-ran the validator. The file preserves the 13/20 history explicitly under a
"**History (not erased, because it's the credibility-relevant part)**" paragraph — the right
call, and the reason this grade can still verify what the epic actually claimed at its own SHA.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0), 6/6.

## does · only · all

- **does** — 13/13 requirement rows verified by named re-run or inspection.
- **only** — 7 candidate hunks, all mapped; no orphans.
- **all** — R1–R13 each have an implementing hunk or a verified assertion.

## Verdict

`reconcile: PASS @ 1307431` — with the scenario-run limitation stated under Provenance.
