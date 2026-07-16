# Conformance — yaml-ledger-selective-load/read-cutover

`reconcile: PASS @ aff9453309d9f95b3cb78a914e571235a6830c96`  
Graded: `main...HEAD` on `feature/yaml-ledger-read-cutover` · Date: 2026-07-16 · N = `.lsa.yaml` `reconcile.runs` = **3** (pass = 3/3)

## Requirement ↔ hunk coverage

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | `scripts/roadmap-migrate.sh` (new); `.lsa/roadmap.yaml` (new SoT, 61 `items`); delete `.lsa/roadmap.md` | `migrate.feature` — Every backlog row… · Recently-merged… — **3/3** each (postcondition: yaml present; ruby counts items≥1 + shipped_history≥1) | ✅ |
| F1b | `scripts/roadmap-migrate.sh` appendix path; `.lsa/roadmap.yaml` `appendix:` (7) + item notes | `migrate.feature` — Backlog-detail appendix… — **3/3**; notes spot-check vs `origin/main:.lsa/roadmap.md` phrase `Adopted via Tech Picture 2026-05-20` | ✅ |
| F2 | migrator `notes: \|` block scalars; yaml item notes | `migrate.feature` — full notes scenario — **3/3**; same verbatim needle in yaml | ✅ |
| F3 | delete `.lsa/roadmap.md` in ship | `migrate.feature` — markdown SoT removed — **3/3** (`test ! -f .lsa/roadmap.md`) | ✅ |
| F4 | yaml schema + `scripts/lint.sh` C14; migrator field emit | migrate required-fields ruby check — **3/3**; C14 PASS in gate | ✅ |
| F5 | `scripts/roadmap-row.sh` | `query.feature` — First backlog row… — **3/3** | ✅ |
| F6 | `scripts/roadmap-query.sh backlog --limit N` | `query.feature` — Bounded backlog slice — **3/3** (`--limit 5` → ≤5 lines) | ✅ |
| F7 | `scripts/roadmap-query.sh get <slug>` | `query.feature` — Single record… — **3/3**; Missing data… — **3/3** (exit ≠0) | ✅ |
| F8 | `manager/skills/next/SKILL.md`, `manager/agents/project-manager.md`, `manager/skills/implement/SKILL.md` — non-zero → fall through to `Read` yaml | instruction wiring present (quoted fallback language); F9 test allows only marked fallbacks — **3/3** | ✅ |
| F9 | consumer rewires + `scripts/tests/no-wholefile-ledger-read.sh` | `consumer-load.feature` — both scenarios via F9 test + wiring grep — **3/3** | ✅ |
| F10 | `scripts/roadmap-print.sh` | `human-read.feature` — **3/3**; no second SoT file | ✅ |
| F11 | `scripts/lint.sh` C14 | `schema-gate.feature` — well-formed **3/3**; malformed structural fail **3/3** | ✅ |
| F12 | cite-sweep + gates | `reference-integrity.feature` — check-links **3/3**; check-citations **3/3** | ✅ |
| F13 | `manager/knowledge/sequencing-heuristics.md`; `core/knowledge/fast-path-source-of-truth.md:46-47`; `.lsa/modules/manager/spec.md:42`; manager consumer path renames | `reference-integrity.feature` — format citation + no live SoT load of `roadmap.md` in manager skills/agents/knowledge — **3/3**. Sole remaining `manager/` string hit: `manager/README.md:88` migration-runbook pointer (“Migrating an old `roadmap.md`”) — not a SoT load; accepted as non-live. | ✅ |

## Orphan hunks (over-delivery vs F1–F13)

| Cluster | Files (representative) | Disposition |
|---|---|---|
| Spec pack / pitch (meta) | `.lsa/features/2026-07-16-yaml-ledger-read-cutover/*`, `.lsa/pitches/yaml-ledger-selective-load.md` | Expected LSA artifacts — not production over-delivery |
| Measured-win docs | `README.md` §Scripts…; `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md`; `manager/CHANGELOG.md` Notes | Docs selling point — outside F1–F13; keep |
| LSA default + AI migration (post-cutover) | `lsa/skills/init/SKILL.md`, `lsa/knowledge/migration-instructions-ai.md`, `lsa/{ARCHITECTURE,README,CORE}.md`, `lsa/tests/scenarios.md`, `lsa/CHANGELOG.md` + `plugin.json` 0.26.0, `knowledge/index.md` | **Acknowledged in `requirements.md` Out of Scope** (“partially closed in lsa 0.26.0”). Orphan vs F-numbers; not a silent F-gap — OOS text absorbs intent. |
| Cite-adjacent | `.claude/agents/claude-dev.md` (`roadmap.md` → `roadmap.yaml` in tree diagram); `core/skills/output/SKILL.md` citation retarget; `lsa/knowledge/model-routing.md` cite-sweep | Serves F12; mapped above / adjacent |
| Version bumps | `core` 0.18.0, `manager` 0.18.0, `lsa` 0.25.1→0.26.0 + CHANGELOGs | Discipline for the behavioral/doc ships |

**Orphan hunks blocking PASS?** No — every F1–F13 (+F1b) row has implementing hunks + proving runs; orphans are either meta, docs, or OOS-acknowledged follow-on.

## Gate (`.lsa.yaml` `gate:`)

`bash scripts/gate.sh` → **PASS** (exit 0) at graded SHA:

| Check | Command | Exit |
|---|---|---|
| docs-invariants | `bash scripts/lint.sh` | 0 |
| citations | `bash scripts/check-citations.sh` | 0 |
| links | `bash scripts/check-links.sh` | 0 |
| project-map | `bash lsa/scripts/project-map-check.sh` | 0 |

## does · only · all

- **does** — all listed scenario probes **3/3** at N=3; gate PASS.
- **only** — no uncovered production requirement; orphans listed and classified (OOS / docs / meta).
- **all** — F1, F1b, F2–F13 each have a ✅ row.

## Verdict

`reconcile: PASS @ aff9453309d9f95b3cb78a914e571235a6830c96`
