# Conformance — pinned-library-specs/github-actions-pin

`reconcile: PASS @ a976926` (graded range `a976926^..a976926`, PR #82, merged as 1d42e80)
Graded: 2026-07-20

**Provenance — retro independent grade.** This epic merged without a `conformance.md`. It is
graded here after the fact, in a separate context and by a different model from the
implementer, in a commit separate from the implementation. Rows cite a **re-run** (a script
executed now against the merged tree) or an **inspection** (a claim read off the graded diff);
no row claims a 3/3 scenario run that never happened.

**Note on the pitch decision this epic supersedes.** The pitch's Fork 1 and rabbit hole 6 lock
the dogfood target as the *Claude Code platform surface*. This epic pinned `actions/checkout`
instead. That substitution is **authorised and correct**, not drift: the original target has no
manifest or lockfile, so `check-lib-pins.sh` would return `[cannot verify]` (exit 2)
permanently, and because the check sits in the `gate:` block (epic 1 R7), every `lsa:verify` in
this repo would return NOT-GROUNDED forever. The chain and the re-decision are recorded at
`.lsa/roadmap.yaml` (row `pinned-library-specs`, notes). Three separately-approved decisions
combined into a self-inflicted blocker that none revealed alone; catching it at implementation
time was the right call.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `.lsa/libs/actions-checkout.md` (new) | inspection — file exists in epic-1 R1 format | ✅ |
| R2 | `.lsa/libs/actions-checkout.md:6-9` | inspection — metadata block is exactly `Pinned-Version: v4` · `Manifest: .github/workflows/lint.yml` · `Lockfile: .github/workflows/lint.yml` · `Lockfile-Assertion: actions/checkout@v4` | ✅ |
| R3 | `.lsa/libs/actions-checkout.md:22-35` | inspection — documents the single call site and the absence of a `with:` block; explicitly lists the full input surface as undocumented by design. Verified against `.github/workflows/lint.yml:12`, which is indeed `- uses: actions/checkout@v4` with no `with:` | ✅ |
| R4 | `.lsa/libs/actions-checkout.md:3-4` | inspection — "Authored 2026-07-20 from the in-repo call site `.github/workflows/lint.yml:12`; human-reviewed before commit." Date differs from the requirement's illustrative 2026-07-19; the date is a fact, not a normative value | ✅ |
| R5 | `.lsa/libs/actions-checkout.md:11-20` | inspection — the caveat is present, headed, and states that `OK` asserts only "this repo's own declaration still reads `actions/checkout@v4`" and not that upstream is unchanged | ✅ |
| R6 | `.lsa/libs/actions-checkout.md` | re-run — `wc -l` → **39**, well under the 60-line cap | ✅ |
| R7 | `.lsa.yaml` `libs:` → `actions-checkout` (`spec` + `manifest`) | re-run — `bash scripts/check-lib-pins.sh` → `OK  actions-checkout v4 — assertion found in .github/workflows/lint.yml`, exit 0; `bash scripts/gate.sh` → 6/6 PASS | ✅ |
| R8 | `scripts/check-lib-pins.sh` — unmodified by this epic | inspection — the epic's diff touches 3 files, none of them the script; no allowlist, skip flag, `\|\| true` on the status branches, or exit-code remap was added. Epic 1 R5's never-green-on-unknown rule is intact | ✅ |
| R9 | `.lsa.yaml` `libs:` (1 entry) | re-run — `bash scripts/lint.sh` → `PASS  C18 … within the 5-entry cap (1 registered)` | ✅ |
| R10 | `.lsa/libs/actions-checkout.md` (conforms to, authors none of, the protocol text) | re-run — `grep -c 'via pin@' lsa/knowledge/conventions.md` → 1, epic 3's token; this epic added no protocol text | ✅ |
| R11 | no plugin version bump, no plugin CHANGELOG entry | inspection — the 3 changed files (`.lsa.yaml`, `.lsa/libs/actions-checkout.md`, `project-map.yaml`) all sit outside every plugin's `artifact_paths`; no plugin manifest changed in `a976926` | ✅ |

Orphan hunks: none.

All 3 files in `a976926` map: `.lsa/libs/actions-checkout.md` → R1–R6 · `.lsa.yaml` → R7/R9 ·
`project-map.yaml` → R1 (the repo-internal index is regenerated whenever a tracked file is
added; `lsa/scripts/project-map-check.sh` is a gate check, so omitting it would turn the gate
red — it is required by, not incidental to, R1).

**Deviation from R7's stated expectation, in the safe direction.** R7 and epic 3 R9 both
anticipated that registering the first pin would turn the gate red (`[cannot verify]`, exit 2).
It did not: because this epic chose a target whose declaration *is* its own resolved
reference, the assertion is checkable and `lib-pins` exits 0. The gate is green for a real
reason, not a suppressed one — R8 confirms no suppression mechanism was added.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0), 6/6: docs-invariants ·
citations · links · project-map · tests · lib-pins.

## does · only · all

- **does** — 11/11 requirement rows verified by named re-run or inspection; the pin resolves
  `OK` and the drift path was verified by the implementer by bumping the workflow to `@v5`
  (recorded in the commit message; reverted, not part of the diff — cited here as the
  implementer's claim, not as a grader re-run).
- **only** — 3 candidate hunks, all mapped; no orphans.
- **all** — R1–R11 each have an implementing hunk and a ✅ verdict.

## Verdict

`reconcile: PASS @ a976926` — with the scenario-run limitation stated under Provenance.
