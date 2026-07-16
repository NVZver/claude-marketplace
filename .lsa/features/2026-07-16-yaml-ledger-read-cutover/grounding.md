# Grounding — yaml-ledger-selective-load/read-cutover

Verdict: **GROUNDED** · Date: 2026-07-16 · Spec: `requirements.md` F1–F13 (+F1b) + 6 `.feature` files

## Reference map

| Reference (spec) | Status |
|---|---|
| `.lsa/roadmap.md` (378 ln / 91,834 B; anchors `## Feature Backlog` @ :7, `## Recently merged` @ :73) | exists @ `.lsa/roadmap.md:7,73` |
| Backlog-detail / Tech-Picture appendix sections (F1b) | exists @ `.lsa/roadmap.md:95-332` (9 `## ` sections total) |
| `scripts/roadmap-row.sh` (first-backlog-row extractor, exit-1 fallback) | exists @ `scripts/roadmap-row.sh:1-63` |
| `scripts/lint.sh` (C1–C13; C14 schema gate added here) | exists @ `scripts/lint.sh:1-415`; C14 = **new** |
| `scripts/check-links.sh` · `scripts/check-citations.sh` | exists @ `scripts/` |
| `scripts/gate.sh` (aggregate gate runner) | exists @ `scripts/gate.sh` |
| `.lsa/roadmap.yaml` (SoT) | **new** |
| `scripts/roadmap-query.sh` (`backlog --limit N` / `get <slug>` / `hygiene`) | **new** |
| `scripts/roadmap-print.sh` (human pretty-print) | **new** |
| one-shot migrator | **new** |
| `manager:next` Mode 0 fast-path (already prefers `roadmap-row.sh`) | exists @ `manager/skills/next/SKILL.md:24` |
| `project-manager` Mode 0 / Mode 1 read | exists @ `manager/agents/project-manager.md:33,37` |
| `manager:check` | exists @ `manager/skills/check/SKILL.md:3` |
| `manager:implement` 1a preview | exists @ `manager/skills/implement/SKILL.md:30` |
| roadmap table-format citation | exists @ `manager/knowledge/sequencing-heuristics.md:9` |
| fast-path callers table | exists @ `core/knowledge/fast-path-source-of-truth.md:46-47` |
| manager module spec (roadmap = primary data source) | exists @ `.lsa/modules/manager/spec.md:42` |

No unresolved reference; no `[ASSUMPTION]` remaining. Every flow (A–F) is buildable on what exists — the extractor + fallback contract, gate runner, and consumer surfaces all present; only additive `new` artifacts required.

## Gate block (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` → **PASS** (exit 0), baseline before implementation:

| Check | Command | Exit |
|---|---|---|
| docs-invariants | `bash scripts/lint.sh` | 0 |
| citations | `bash scripts/check-citations.sh` | 0 |
| links | `bash scripts/check-links.sh` | 0 |
| project-map | `bash lsa/scripts/project-map-check.sh` | 0 |

## Grounding history

- NOT-GROUNDED (initial): F1 assumed 2 roadmap sections; the file has 9 — 7 backlog-detail/appendix sections (`:95-332`) would be dropped, breaking lossless. Resolved by amendment **F1b** + `migrate.feature` scenario (owner-approved 2026-07-16).
