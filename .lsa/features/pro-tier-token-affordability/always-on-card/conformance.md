# Conformance — `pro-tier-token-affordability/always-on-card`

**Graded by:** `lsa:reconcile` (this session's context — separate from the implementer that authored the card/digest/script).
**Graded @:** working tree on `feature/pro-tier-always-on-card` (uncommitted at grading time; the human owns the merge to `main`).

Verdict: this is the after-check that the diff satisfies the spec and only the spec. **reconcile: PASS.**

## does · only · all

- **does** — the three `flow-*.feature` scenarios map to authored behavior; the one deterministic scenario (flow-3 "stale digest fails the gate") is gate-proven 3/3; the behavioral scenarios (flow-1 card-only discipline, flow-2 escalation) are graded by artifact inspection (docs mode, `.lsa.yaml mode: docs`).
- **only** — every changed hunk traces to a requirement or to a standing marketplace discipline (per-plugin SemVer + CHANGELOG; "READMEs are living documents"; reconcile drift absorption). No orphan hunk.
- **all** — every F/AC/D/NFR maps to a change (no under-delivery).

## Requirement → satisfying change

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 (ONE card ≤45 lines; 8 rule one-liners + hard output rule + 3 flows/5 signals + reuse pointer + cite-without-loading + `reconcile.runs`; cite by link) | `core/CLAUDE.md:1-38` (38 lines) | flow-1 (inspection) | ✅ |
| F2 (discipline from card alone, no SKILL.md load) | `core/CLAUDE.md:5,7-32` | flow-1 (inspection) | ✅ |
| F3 (escalation trigger loads that ONE skill) | `core/CLAUDE.md:34-37` (Loading discipline) | flow-2 (inspection) | ✅ |
| F4 (LSA read protocol → digest ≤35; full text only for constitutional tasks) | `lsa/knowledge/conventions.md:34`; `.lsa/VISION-digest.md` (32 lines) | flow-3 §1 (inspection) | ✅ |
| F5 (stale digest → `lint.sh` non-zero naming it) | `scripts/lint.sh` C12 | flow-3 §2 — 3/3 (deterministic; perturb→FAIL, restore→PASS) | ✅ |
| F6 (digest deterministically script-derived, zero model tokens) | `scripts/build-vision-digest.sh` | rebuild ×2 → byte-identical | ✅ |
| F7 (packaging only — no rule added/removed/weakened/renumbered) | `core/CLAUDE.md:5`; lint C1/C2/C6 PASS | lint gate (exit 0) | ✅ |
| F8 (card + digest print file-load trace) | `core/CLAUDE.md:3`; `.lsa/VISION-digest.md:1` | flow-1/flow-3 (inspection) | ✅ |
| AC1 (fresh session → sourced+traced, card-size text loaded not ~493) | `core/CLAUDE.md` (38 lines) | flow-1 | ✅ |
| AC2 (any LSA skill → read-summary cites digest; output shape/rigor unchanged) | `lsa/knowledge/conventions.md:34` | flow-3 §1 | ✅ |
| AC3 (edit VISION→lint non-zero w/ staleness msg; regen→0) | `scripts/lint.sh` C12 | proven run (FAIL then PASS) | ✅ |
| AC4 (side-by-side: zero semantic rule change; D2 + C6 green) | lint C6 PASS; `check-citations.sh` exit 0 | gate | ✅ |
| D1 (digest path `.lsa/VISION-digest.md`, adjacent to constitution) | file present at path | — | ✅ |
| D2 (`conventions.md` step 2 names digest + lists full-read triggers) | `lsa/knowledge/conventions.md:34` | — | ✅ |
| D3 (`reuse-first/SKILL.md` untouched; card compresses to one pointer) | `git diff` shows reuse-first unchanged; `core/CLAUDE.md:30-32` | — | ✅ |
| NFR (card ≤45, digest ≤35 lines) | `wc -l` → 38, 32 | wc | ✅ |

## Consequential + discipline hunks (traced, not orphan)

- `core/skills/flow-selector/SKILL.md:50`, `lsa/knowledge/conventions.md:64` — `AskUserQuestion` substrate cite retargeted from the card-removed "`core/CLAUDE.md` operational checkpoint #1" to its canon `.lsa/VISION.md` §2 principle 9. Consequence of F1/F7 (the card drops the checkpoint framing); documented in both CHANGELOGs.
- `core/.claude-plugin/plugin.json` (0.17.0), `lsa/.claude-plugin/plugin.json` (0.25.0), `core/CHANGELOG.md`, `lsa/CHANGELOG.md`, `core/README.md`, `README.md`, `CLAUDE.md` — per-plugin SemVer + CHANGELOG + "READMEs are living documents" standing discipline (`CLAUDE.md` §Discipline).
- `.lsa/modules/core/spec.md:35,37,39,41` — **reconcile drift absorption (this session):** four clauses referenced the card-removed "operational checkpoint #1/#4"; retargeted to the new card's Output/section prose (core v0.17.0). The deterministic gates did not catch these (prose, no `file:line`); absorbed per Level 2.5.
- `scripts/build-vision-digest.sh`, `scripts/lint.sh` (C12), `.lsa/VISION-digest.md` — F5/F6 machinery; repo-internal (outside every plugin's `artifact_paths`), so no plugin version bump.
- `.lsa/roadmap.md` (parent row), `.lsa/pitches/pro-tier-token-affordability.md`, `.lsa/features/pro-tier-token-affordability/always-on-card/*` — LSA bookkeeping + the epic spec itself. Roadmap status left `backlog` — only the merge step writes roadmap status (`.lsa/roadmap.md:345`).

Orphan hunks: none.

Gate: `bash scripts/lint.sh` ✓ (exit 0, C1–C12 PASS) · `bash scripts/check-citations.sh` ✓ (exit 0, 74 resolve) · `bash scripts/check-links.sh` ✓ (exit 0, 445 resolve).

## Note (adjacent, not this epic's drift)

`.lsa/modules/core/spec.md:26` describes the always-on block as `ground-rules + output + flow-selector invocation` — omits `reuse-first` (shipped core v0.15.0, pre-dates this epic). Pre-existing drift, left untouched to hold scope; flagged for a future `manager:check` hygiene pass.
