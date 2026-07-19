# Conformance — deterministic-work-scripted-codify

`reconcile: PASS @ 62dc0d5+worktree` (graded 2026-07-19, uncommitted working tree).
Independent grader — authored in a context separate from the implementer; the
implementer's diff includes no edit to this file, the `.feature` scenarios, or the
`.lsa.yaml` gate config it is graded against.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 principle 10 text (script-cites, not recomputed) | `.lsa/VISION.md` §2 principle 10 | codify.feature S1 + S3 — 3/3 | ✅ |
| R2 meaningful-complexity boundary | `.lsa/VISION.md` §2 pr.10 ("a trivial one-item check is not forced… ceremony scales to weight, §3") | S1 — 3/3 | ✅ |
| R3 cross-refs + v0.13 changelog | `.lsa/VISION.md` pr.10 (cross-refs `.lsa.yaml:13`, fast-path) + §Changelog `**v0.13**` | — (doc requirement) | ✅ |
| R4 core card pointer, cite-by-link, no rule text | `core/CLAUDE.md:34-36` `## Deterministic work is scripted — [.lsa/VISION.md] §2 principle 10` | S3 — 3/3 | ✅ |
| R5 C15 PASS iff marker in BOTH surfaces | `scripts/lint.sh` C15 (two `grep -qiF` presence checks) | S1 — 3/3 | ✅ |
| R6 presence guard only (no determinism-detection) | `scripts/lint.sh` C15 comment + code (two greps, nothing more) | — (scope requirement) | ✅ |
| R7 lint.sh style + passes clean | C15 bash-3.2-safe (`pass_line`/`fail_line`, `grep -qiF`); `gate.sh` exit 0 | S1 + S2 — 3/3 | ✅ |
| R8 core MINOR bump + CHANGELOG + README | `core/.claude-plugin/plugin.json` 0.18.0→**0.19.0**; `core/CHANGELOG.md` [0.19.0]; `core/README.md` fragment pointer | — (versioning requirement) | ✅ |
| R9 VISION+lint.sh no plugin bump; only card drives core bump | diff bumps only `core/*`; `.lsa/VISION.md` + `scripts/lint.sh` are repo-level (`.lsa.yaml:52-104`) | — (scope requirement) | ✅ |

## does — Gherkin scenarios (N=3)

These are **deterministic** script/grep checks, not stochastic agent runs — 3/3 is
exact repetition, no variance.

- **S1 present → gate passes:** C15 emits 2 PASS lines; `bash scripts/gate.sh` → exit 0. 3/3.
- **S2 delete trips guard:** proven independently in a scratch copy — marker stripped from a
  `.lsa/VISION.md` copy → `grep -qiF` returns non-zero → `fail_line` → `fail=1` → exit 1.
  Real tree untouched (marker still present on both surfaces). 3/3.
- **S3 card carries pointer:** `core/CLAUDE.md:34-36` shows the one-line section citing
  `.lsa/VISION.md` §2 principle 10 by markdown link. 3/3.

## only — orphan-hunk check (feature scope)

- **`.lsa/VISION-digest.md` (2 ins, 1 del):** NOT orphan — traces to R7. C12 (`lint.sh:363`)
  fails the gate if the digest sha256 is stale; R1's VISION edit invalidates it, so
  regenerating via `scripts/build-vision-digest.sh` is the necessary gate-green consequence.
- **No other feature hunk is untraced.**

**Excluded as pre-existing (not this feature's diff — dirty at session start):**
`.github/workflows/lint.yml`, `.gitignore`, `.lsa/roadmap.yaml`, `CONTRIBUTING.md`,
`.lsa/features/cursor-equal-support/`, `.lsa/pitches/cursor-equal-support.md`,
`.lsa/features/marketplace-ai-engineering-audit/`, `scripts/generate-for-cursor.sh`,
`scripts/tests/generate-for-cursor-test.sh`.

## Gate (`.lsa.yaml` gate: block — required input)

`bash scripts/gate.sh` → **exit 0**:
- `docs-invariants  bash scripts/lint.sh` → exit 0 (incl. new C15: 2 PASS lines)
- `citations        bash scripts/check-citations.sh` → exit 0
- `links            bash scripts/check-links.sh` → exit 0
- `project-map      bash lsa/scripts/project-map-check.sh` → exit 0

`gate: PASS — every configured check exited 0`

## Verdict

**PASS** — does · only · all satisfied; every R1–R9 covered; no orphan hunk in scope; gate green.
No drift; the spec needs no absorption edit.
