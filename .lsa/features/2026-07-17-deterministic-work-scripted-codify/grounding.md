# Grounding — deterministic-work-scripted-codify

Verdict: **GROUNDED** @ 2026-07-18. Verify (before-delegate) check.

## Reference map

| Spec reference | Resolution |
|---|---|
| §2 principles end at 9 (clean append point for principle 10) — R1 | `exists @ .lsa/VISION.md:66` ("9. **Substrate-native first**"); next section `## 3.` @ `.lsa/VISION.md:70` |
| §Changelog anchor for the v0.13 entry — R3 | `exists @ .lsa/VISION.md:265` (`## Changelog`); top entry v0.12 @ `:267` (insert above) |
| Doctrine surfaces principle 10 unifies (cross-refs) — R3 | `exists @ .lsa.yaml:13`, `core/knowledge/fast-path-source-of-truth.md:5`, `manager/agents/project-manager.md:33` |
| core always-on card (mergeable; discipline sections) — R4 | `exists @ core/CLAUDE.md:1-5`; sections @ `:7,:20,:26,:30,:34` (new one-line pointer fits) |
| `lint.sh` C6 presence-guard pattern (reuse target) — R5/R7 | `exists @ scripts/lint.sh:153-164` (`grep -qiE … / pass_line / fail_line`) |
| `lint.sh` last check + append point — R5 | last check `C14 @ scripts/lint.sh:409`; success `exit 0 @ :458`, fail `exit 1 @ :461` (C15 appends before the exit) |
| `.lsa.yaml` gate block — R7 | `exists @ .lsa.yaml:14-18` (docs-invariants/citations/links/project-map) |
| lint.sh + VISION.md are repo-level (no plugin bump) — R9 | `exists @ .lsa.yaml:52-104` — neither is under any `modules.*.artifact_paths` glob |
| core current version (MINOR bump target) — R8 | `exists @ core/.claude-plugin/plugin.json:4` = `0.18.0` → **target 0.19.0** (resolves the R8 [ASSUMPTION]) |
| VISION §2 principle 10 · core card pointer · lint.sh C15 · Changelog v0.13 | `new` (created by the implementer) |

## Feasibility (3 flows)

- Flow 1 (read the constitution) — buildable: markdown append to §2. ✓
- Flow 2 (every-session card load) — buildable: one line in `core/CLAUDE.md`. ✓
- Flow 3 (lint regression guard) — buildable: C15 is a copy-shape of C6 (`lint.sh:153-164`) over two files. ✓

No infeasible flow. Docs-mode only (markdown + bash edits); no runtime surface.

## Gate (`.lsa.yaml` gate: block — verify Step 4)

`bash scripts/gate.sh` → exit 0:
- `docs-invariants  bash scripts/lint.sh` → exit 0
- `citations        bash scripts/check-citations.sh` → exit 0
- `links            bash scripts/check-links.sh` → exit 0
- `project-map      bash lsa/scripts/project-map-check.sh` → exit 0

`gate: PASS — every configured check exited 0`. The new spec files under `.lsa/features/` introduced no citation/link drift (gate exempts the `.lsa/` spec tree).

## Blockers

None. Spec is grounded and buildable. One [ASSUMPTION] from specify (R8 version target) is now resolved to 0.18.0 → 0.19.0.
