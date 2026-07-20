# Conformance — pinned-library-specs/format-and-staleness-gate

`reconcile: PASS @ 502f9450e54ece60dd9ccd30be27f335f02fde31`
Graded: 2026-07-20 · Range `502f945^..502f945` (PR #81, merged as 6a92b04)

**Provenance — retro independent grade.** This epic merged without a `conformance.md`; the
verdict was never authored. It is graded here after the fact, in a separate context and by a
different model from the implementer, in a commit separate from the implementation — which
satisfies `lsa/knowledge/quality-gate-contract.md`'s independence rule more strictly than an
inline reconcile would have. What it cannot reconstruct is scenario runs at the graded SHA:
the `staleness-gate.feature` scenarios were never executed at N=3 against that commit. Every
row below therefore cites either a **re-run** (a deterministic script executed now, against
the merged tree) or an **inspection** (a claim read directly off the graded diff). No row
claims a 3/3 scenario run that did not happen.

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/knowledge/pinned-library-specs.md` (metadata-block format); consumed by `scripts/check-lib-pins.sh:71-80` (first-20-line window, 4 keys) | inspection — the four keys `Pinned-Version` / `Manifest` / `Lockfile` / `Lockfile-Assertion` are parsed at `check-lib-pins.sh:71-76` and documented in the knowledge file | ✅ |
| R2 | `lsa/knowledge/pinned-library-specs.md` (≤60-line cap documented, cover-only-what-you-call rule) | re-run — `wc -l .lsa/libs/actions-checkout.md` → 39, within the 60-line cap; R2 is documentation-enforced by design, asserted by epic 2 R6 | ✅ |
| R3 | `.lsa.yaml` `libs:` block, sibling to `modules:`, keys `spec` + `manifest`, no `artifact_paths` | inspection — `git show 502f945:.lsa.yaml` shows `libs: {}` as a new top-level block | ✅ |
| R4 | `scripts/check-lib-pins.sh:36-51` (awk block extraction, nested one level deeper than `gate.sh`), status lines at `:65,:83,:89,:95,:101,:107,:109` | re-run — `bash scripts/check-lib-pins.sh` prints `  OK          actions-checkout v4 — assertion found in .github/workflows/lint.yml` | ✅ |
| R5 | `scripts/check-lib-pins.sh:114-121` (precedence: 1 outranks 2 outranks 0) | re-run — `scripts/tests/check-lib-pins-test.sh` **6/6**, covering exit 0 / 1 / 2 and both empty-`libs:` cases | ✅ |
| R6 | `scripts/check-lib-pins.sh:64-111` (six-step decision order); `manifest:` never consulted for freshness | re-run — test cases "fresh pin", "mismatched assertion", "Lockfile: none", "missing spec file" all pass; inspection confirms `${manifest}` is read but never branched on | ✅ |
| R7 | `.lsa.yaml` `gate:` → `lib-pins: bash scripts/check-lib-pins.sh` | re-run — `bash scripts/gate.sh` lists `PASS  lib-pins  bash scripts/check-lib-pins.sh → exit 0` | ✅ |
| R8 | `lsa/knowledge/pinned-library-specs.md` (84 lines: format, cap, schema, exit codes, 5-lib cap, human-review promotion boundary) | inspection — file present at 84 lines; contains no read-precedence text, correctly deferred to epic 3 | ✅ |
| R9 | `scripts/lint.sh` C18 block | re-run — `bash scripts/lint.sh` → `PASS  C18 .lsa.yaml libs: block within the 5-entry cap (1 registered)`; C16/C17 not reused | ✅ |
| R10 | `scripts/tests/check-lib-pins-test.sh` (151 lines, hermetic `mktemp -d` fixtures) | re-run — auto-discovered by `scripts/run-tests.sh`; **6/6 cases pass** | ✅ |
| R11 | `lsa/ARCHITECTURE.md:109` (`libs:` in the schema listing), `:140` (drift hook covers `modules:` only) | inspection — `:140` reads "**The drift hook covers `modules:` only** — pinned-library-spec staleness is surfaced by the `gate:` check (`lib-pins`), not the SessionStart hook" | ✅ |
| R12 | `lsa/.claude-plugin/plugin.json` → `0.31.0`; `lsa/CHANGELOG.md`, `lsa/README.md`, `knowledge/index.md` (21 files) | inspection — bumped to **0.31.0**, not the specified 0.29.0, because `name-conformance-as-rtm` (0.29.0) and `reconcile-emit-guard` (0.30.0) took those first. R12's own `[ASSUMPTION]` authorises this: "If another epic bumps `lsa` first, take the next unused MINOR instead." | ✅ |
| R13 | `.lsa.yaml` `libs: {}` (empty at this commit) | inspection — `git show 502f945:.lsa.yaml` → `libs: {}`; the first pin lands in epic 2, as specified | ✅ |

Orphan hunks: none.

All 10 files in `502f945` map to a requirement row: `.lsa.yaml` → R3/R7/R13 · `knowledge/index.md`,
`lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`, `lsa/README.md` → R12 ·
`lsa/ARCHITECTURE.md` → R11 · `lsa/knowledge/pinned-library-specs.md` → R8 ·
`scripts/check-lib-pins.sh` → R4/R5/R6 · `scripts/lint.sh` → R9 ·
`scripts/tests/check-lib-pins-test.sh` → R10.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` re-run at grading time → **PASS** (exit 0):

| Check | Command | Exit |
|---|---|---|
| docs-invariants | `bash scripts/lint.sh` | 0 |
| citations | `bash scripts/check-citations.sh` | 0 |
| links | `bash scripts/check-links.sh` | 0 |
| project-map | `bash lsa/scripts/project-map-check.sh` | 0 |
| tests | `bash scripts/run-tests.sh` | 0 |
| lib-pins | `bash scripts/check-lib-pins.sh` | 0 |

## does · only · all

- **does** — 13/13 requirement rows verified, each by a named re-run or a named inspection of
  the graded diff. The behavioural core (R4–R6) is proven by a 6/6 hermetic test suite that
  exercises all three exit codes.
- **only** — 10 candidate hunks, all mapped; no orphans.
- **all** — R1–R13 each have an implementing hunk and a ✅ verdict.

## Verdict

`reconcile: PASS @ 502f9450e54ece60dd9ccd30be27f335f02fde31` — with the scenario-run
limitation stated under Provenance. The epic is complete and correct as merged; what was
missing was the graded record, which this file supplies.
