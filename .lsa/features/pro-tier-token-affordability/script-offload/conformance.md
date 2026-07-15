# Conformance — `pro-tier-token-affordability/script-offload`

**Graded by:** `lsa:reconcile` (this session's context — separate from the implementer).
**Graded @:** `d5178a4` (implementation commit on `feature/pro-tier-always-on-card`); this verdict lands in a separate commit (independence rule — `lsa/knowledge/quality-gate-contract.md` §"Independence rule").

Verdict: the after-check that the diff satisfies the spec and only the spec. **reconcile: PASS.**

## does · only · all

- **does** — the two `flow-*.feature` files map to authored behavior, proven by **live runs** this
  session: `gate.sh` ran the whole `.lsa.yaml gate:` block in one pass (3/3 checks exit 0);
  `roadmap-row.sh` printed `.lsa/roadmap.md:13`; and in an isolated repo the three fall-through paths
  held (no-backlog → exit 1; `not started` row → exit 0; no `gate:` block → NOT-RUNNABLE exit 2). The
  skill-wiring scenarios (F4/F5) are docs-mode and graded by inspection.
- **only** — every changed hunk traces to a requirement or a standing discipline (SemVer + CHANGELOG;
  README version columns; the index regen forced by the new spec files). No orphan hunk.
- **all** — every F/AC/D maps to a change.
- **reward-hacking check** — this epic changed no `.lsa.yaml` `gate:` command and no `.feature`
  scenario that grades it; `gate.sh` only *runs* the unchanged block. Independence intact.

## Requirement → satisfying change

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 (aggregate `gate.sh`, one pass, per-check command+exit) | `scripts/gate.sh` | flow-1 §1 — live `gate: PASS` (3 checks exit 0) | ✅ |
| F2 (`roadmap-row.sh` prints first backlog row + `path:line`) | `scripts/roadmap-row.sh` | flow-2 §1, AC2 — live `.lsa/roadmap.md:13` | ✅ |
| F3 (reads `gate:` block, no duplicated command list) | `scripts/gate.sh` awk extraction of `.lsa.yaml` block | flow-1 §2 (inspection) | ✅ |
| F4 (verify/reconcile use aggregate runner; per-command fallback) | `lsa/skills/verify/SKILL.md` Step 4; `lsa/skills/reconcile/SKILL.md` Step 1 | flow-1 §3, AC4 (inspection) | ✅ |
| F5 (next Step 0 uses extractor; model-side fallback) | `manager/skills/next/SKILL.md` Step 0 | flow-2 §2, AC3 (inspection) | ✅ |
| F6 (scripts repo-internal, no plugin bump) | `scripts/gate.sh`, `scripts/roadmap-row.sh` outside `artifact_paths` | version-changelog 5/5 | ✅ |
| F7 (graceful degrade: NOT-RUNNABLE / non-zero, no crash) | `gate.sh` NOT-RUNNABLE guard; `roadmap-row.sh` non-zero exits | flow-1 §4, flow-2 §3, AC5 — live (isolated repo: exit 1 / exit 2) | ✅ |
| AC1 (gate.sh runs the block, exits 0 all-pass; new key auto-runs) | `scripts/gate.sh` | flow-1 (live) | ✅ |
| AC2 (`roadmap-row.sh` → `.lsa/roadmap.md:13`, exit 0) | `scripts/roadmap-row.sh` | live run | ✅ |
| AC3 (next Step 0 names extractor + fallback) | `manager/skills/next/SKILL.md:24` | flow-2 | ✅ |
| AC4 (verify+reconcile name runner + fallback; artifact = command+exit) | `verify/SKILL.md:33`, `reconcile/SKILL.md:33` | flow-1 | ✅ |
| AC5 (no backlog row → non-zero; no gate: block → NOT-RUNNABLE) | `gate.sh`, `roadmap-row.sh` guards | live (isolated repo) | ✅ |
| D1 (gate.sh parses `.lsa.yaml gate:`) | `scripts/gate.sh` awk | flow-1 §2 | ✅ |
| D2 (convention-over-config; no new schema key) | skill wiring references scripts by path + fallback | inspection | ✅ |
| D3 (owners lsa + manager; SemVer+CHANGELOG+README same commit) | `lsa` 0.28.0, `manager` 0.18.0; both CHANGELOGs; `README.md` columns | version-changelog gate | ✅ |
| D4 (only the two named offloads; no scope creep) | diff = 2 scripts + 3 skill wirings + version/docs | only-check | ✅ |

## Consequential + discipline hunks (traced, not orphan)

- `lsa/.claude-plugin/plugin.json` (0.28.0) + `lsa/CHANGELOG.md`; `manager/.claude-plugin/plugin.json`
  (0.18.0) + `manager/CHANGELOG.md`; `README.md` version columns — per-plugin SemVer + CHANGELOG +
  living-doc versions (`.lsa/standards/code.md:18-22`).
- `.lsa/PROJECT-index.md` regenerated — the new spec/conformance `.md` files changed the tracked set;
  kept fresh so C13 stays green (WS2 contract).
  *(Superseded 2026-07-15: atlas is now repo-root `project-map.yaml` gated by `lsa/scripts/project-map-check.sh`.)*
- `.lsa/features/pro-tier-token-affordability/script-offload/*` — the epic spec itself.

Orphan hunks: none.

Gate (this reconcile commit, `conformance.md` present + index regenerated): `bash scripts/gate.sh`
✓ (`gate: PASS` — docs-invariants/citations/links all exit 0) · `bash scripts/check-version-changelog.sh`
✓ (5/5).

## Remaining (pitch-level, not this epic)

- **Dogfood token-delta measurement** — the pitch's "a dogfood session shows … the cheapest tier" /
  "a Pro session completes `lsa:discover` … without context exhaustion" criteria need a live Pro
  session; human-owned validation, not gated here.
- **Feature complete** — WS3 was the last workstream (lever order WS1→WS4→WS2→WS3). All four epics of
  `pro-tier-token-affordability` are now implemented + reconciled on this branch.
