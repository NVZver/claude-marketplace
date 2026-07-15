# Conformance — `pro-tier-token-affordability/project-index`

**Graded by:** `lsa:reconcile` (this session's context — separate from the implementer).
**Graded @:** `79409d2` (implementation commit on `feature/pro-tier-always-on-card`); this verdict lands in a separate commit (independence rule — `lsa/knowledge/quality-gate-contract.md` §"Independence rule").

Verdict: the after-check that the diff satisfies the spec and only the spec. **reconcile: PASS.**

## does · only · all

- **does** — the three `flow-*.feature` scenarios map to authored behavior. Flow 1 (deterministic
  generation) and Flow 3 (freshness + budget gate) are proven by **live deterministic gates** run this
  session: two identical builds, and C13/C14 PASS + a demonstrated C13 FAIL on a corrupted index.
  Flow 2 (discover consults the index) is a docs-mode wiring scenario graded by inspection; the live
  Pro-session token-delta remains the pitch-level human-owned validation.
- **only** — every changed hunk traces to a requirement or a standing discipline (SemVer + CHANGELOG;
  READMEs-are-living-documents). No orphan hunk.
- **all** — every F/AC/D maps to a change.

## Requirement → satisfying change

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 (deterministic script generator, no model calls) | `scripts/build-index.sh` | flow-1 §1 — two builds byte-identical (live) | ✅ |
| F2 (trace + DO-NOT-EDIT banner + staleness handling) | `scripts/build-index.sh` header block; `.lsa/PROJECT-index.md:1-2` | flow-1 §3, AC5 | ✅ |
| F3 (≤1k-token hard budget, lint-enforced) | `scripts/lint.sh` **C14 PASS** (~756 ≤ 1000) | flow-3 §2, AC2 — C14 green | ✅ |
| F4 (verbatim H1 / counts; no model descriptions) | `build-index.sh` `h1()` + count/slug logic; `.lsa/PROJECT-index.md` spine H1s | flow-1 §2, AC1 | ✅ |
| F5 (freshness gate FAILs stale/missing, names the fix) | `scripts/lint.sh` **C13** (regenerate-and-diff) | flow-3 §1,§3, AC3 — demonstrated FAIL then PASS (live) | ✅ |
| F6 (read protocol consults index before tree-walk) | `lsa/knowledge/conventions.md` §"Read protocol"; `lsa/skills/discover/SKILL.md:29` | flow-2 §1, AC4 (inspection) | ✅ |
| F7 (absent index / missing H1 degrades, no hard error) | `build-index.sh` `h1()` (`|| true`); conventions.md fall-back clause | flow-2 §3 | ✅ |
| F8 (index prints file-load trace line) | `.lsa/PROJECT-index.md:1` | flow-1 §3, AC5 | ✅ |
| AC1 (idempotent build; spine by H1; trees collapsed) | `.lsa/PROJECT-index.md`; two-build diff | flow-1 | ✅ |
| AC2 (budget check prints estimate ≤ 1000, PASS) | `scripts/lint.sh` C14 output | gate | ✅ |
| AC3 (stale/added file → C13 FAIL; regen → PASS) | `scripts/lint.sh` C13 | flow-3 (live FAIL→PASS) | ✅ |
| AC4 (conventions + discover name the index) | `conventions.md` §"Read protocol"; `discover/SKILL.md:29` | flow-2 | ✅ |
| AC5 (trace + DO-NOT-EDIT banner open the file) | `.lsa/PROJECT-index.md:1-2` | flow-1 §3 | ✅ |
| D1 (home `.lsa/PROJECT-index.md`; freshness-checked not link-checked) | file present; `.lsa/` excluded @ `check-links.sh:88` | — | ✅ |
| D2 (generator repo-internal, no plugin bump) | `scripts/build-index.sh` outside `artifact_paths` | version-changelog gate 5/5 | ✅ |
| D3 (staleness = regenerate-and-diff, not auto-hook) | `scripts/lint.sh` C13; rationale in requirements.md D3 + grounding.md | flow-3 | ✅ |
| D4 (budget proxy chars/4, cap 1000) | `scripts/lint.sh` C14 | AC2 | ✅ |
| D5 (owner `lsa`; SemVer+CHANGELOG+README same commit) | `lsa/.claude-plugin/plugin.json` 0.27.0; `lsa/CHANGELOG.md`; `README.md`+`lsa/README.md` | version-changelog gate | ✅ |

## Consequential + discipline hunks (traced, not orphan)

- `lsa/.claude-plugin/plugin.json` (0.27.0) + `lsa/CHANGELOG.md` entry — per-plugin SemVer + CHANGELOG
  in the same commit (`.lsa/standards/code.md:18-22`).
- `README.md` (lsa version column 0.26.0→0.27.0), `lsa/README.md` (discover skill-table row names the
  index) — "READMEs are living documents" (behavior change to an existing skill).
- `.lsa/PROJECT-index.md` regenerated in this reconcile commit — adding `conformance.md` changed the
  tracked-markdown set, so the index headline count updates; a deterministic consequence, kept fresh
  so C13 stays green at this commit.
- `.lsa/features/pro-tier-token-affordability/project-index/*` — the epic spec itself.

Orphan hunks: none.

Gate (this reconcile commit, with `conformance.md` present + index regenerated): `bash scripts/lint.sh`
✓ (exit 0, C1–C14) · `bash scripts/check-citations.sh` ✓ · `bash scripts/check-links.sh` ✓ ·
`bash scripts/check-version-changelog.sh` ✓ (5/5).

## Audit addition (2026-07-15, post-merge-review)

Added `scripts/tests/test-build-index.sh` — an executable real-flow harness (20 checks over isolated
throwaway git repos) that exercises the three `flow-*.feature` scenarios directly: deterministic
byte-identical output (F1/AC1), verbatim-H1 spine + collapsed historical trees (F4/AC1), the
generated banner/trace (F2/F8/AC5), the discovery-scoping pointers (F6), missing-H1 graceful degrade
+ not-a-git-repo clean exit (F7), the add-a-file drift the C13 gate detects (F5/AC3), bounded budget
under a large tree (F3), and the live repo's C13/C14 PASS. Wired into CI (`.github/workflows/lint.yml`)
as a step — same class as `check-version-changelog.sh` (a CI gate, not a `.lsa.yaml gate:` entry).
Repo-internal (outside every `artifact_paths`) ⇒ no plugin bump. Previously flows 1/3 were proven by
ad-hoc live runs during reconcile; this makes that coverage repeatable and CI-enforced.

## Remaining (pitch-level, not this epic)

- **Dogfood token-delta measurement** — the pitch success criterion "a Pro session completes
  `lsa:discover` plus one shaped pitch without context exhaustion" requires a live Pro session; it is
  human-owned validation, not a code deliverable, and is not gated here.
- **WS3 (script-offload)** remains — the last workstream in the lever order (WS1→WS4→WS2→WS3).
