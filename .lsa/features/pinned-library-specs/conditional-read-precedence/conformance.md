# Conformance — pinned-library-specs/conditional-read-precedence

`reconcile: PASS @ fc01047` (graded range `fc01047^..fc01047`, PR #83, merged as 8f781a2)
Graded: 2026-07-20

**Provenance — retro independent grade.** This epic merged without a `conformance.md`. It is
graded here after the fact, in a separate context and by a different model from the
implementer, in a commit separate from the implementation. Rows cite a **re-run** or an
**inspection**; no row claims a 3/3 scenario run that never happened.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/knowledge/conventions.md:49` — new step 1, ahead of the former step 1 | inspection — the pinned-spec step is now first in §"Library documentation protocol"; the former steps are renumbered 2–5 | ✅ |
| R2 | `lsa/knowledge/conventions.md:49` | inspection — reads "**Precedence is conditional, not positional:** … it earns the in-repo-doc rank only while its staleness check is green — never a soft pass", and names `.lsa/VISION.md` §2 principle 6 with its full ordering | ✅ |
| R3 | `lsa/knowledge/conventions.md:49` | inspection — "The green/not-green determination comes from `scripts/check-lib-pins.sh`'s status line and exit code, never the model's own judgment of freshness (principle 10)". No eyeballing, no manifest-range comparison | ✅ |
| R4 | `lsa/knowledge/conventions.md:49` | inspection — only `OK` permits the pinned read; `STALE`, `BROKEN`, `[cannot verify]` all "continue to step 2", and the step closes "An unverifiable pin does not outrank a fetchable answer" — no soft pass, no warn-and-proceed | ✅ |
| R5 | `lsa/knowledge/conventions.md:49` | re-run — `grep -c 'via pin@'` → 1; the token `lib:<name>:<api> via pin@<pinned-version>` is distinct from the existing `via context7` and `via <url>` forms | ✅ |
| R6 | `lsa/knowledge/conventions.md:50-55` | inspection — the four original steps survive in substance as steps 2–5, the terminal case ("state it… Never guess API signatures") is unchanged, and the "Skills that perform discovery (`lsa:discover`) do this proactively" sentence survives at `:55`. No behaviour changes for a non-registered library | ✅ |
| R7 | `lsa/knowledge/conventions.md:49` | inspection — the added path is a local file read plus local bash (`check-lib-pins.sh`, zero model calls, no network); no new runtime dependency introduced | ✅ |
| R8 | `lsa/.claude-plugin/plugin.json` → `0.32.0`; `lsa/CHANGELOG.md` entry | inspection — one MINOR bump, taken as **0.32.0** rather than the specified 0.30.0 because 0.30.0 (`reconcile-emit-guard`) and 0.31.0 (`format-and-staleness-gate`) landed first; the same next-unused-MINOR rule epic 1 R12 states explicitly. `lsa/README.md` correctly untouched — the edit is inside a knowledge file no README table names (R8's own exemption) | ✅ |
| R9 | — (no implementing hunk; a gate assertion) | re-run — `bash scripts/gate.sh` → exit 0, 6/6 | ✅ |

Orphan hunks: none.

All 3 files in `fc01047` map: `lsa/knowledge/conventions.md` → R1–R7 ·
`lsa/.claude-plugin/plugin.json` + `lsa/CHANGELOG.md` → R8.

**Note on R9's stated expectation.** R9 anticipated that if epic 2 had already merged,
`lib-pins` would exit 2 and the gate would be red "for that reason alone". It is green
instead, because epic 2's target is checkable (see that epic's conformance). R9's conditional
therefore never fired; the gate is green on its own merits.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0), 6/6: docs-invariants ·
citations · links · project-map · tests · lib-pins.

## does · only · all

- **does** — 9/9 requirement rows verified by named re-run or inspection. This is the epic
  that closes the pitch's sharpest risk (rabbit hole 1, the read-order inversion), and the
  implemented text handles it precisely: precedence is conditional, the signal is the script's
  exit code rather than the model's judgment, and an unknown is explicitly denied a soft pass.
- **only** — 3 candidate hunks, all mapped; no orphans.
- **all** — R1–R9 each have an implementing hunk (or, for R9, a gate re-run) and a ✅ verdict.

## Verdict

`reconcile: PASS @ fc01047` — with the scenario-run limitation stated under Provenance.
