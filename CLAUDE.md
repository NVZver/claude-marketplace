# CLAUDE.md

This repository is the **nz-vision claude-marketplace** — a personal, model-agnostic agentic engineering system distributed via Claude Code's plugin marketplace.

Operating rules live in [`vision/VISION.md`](./vision/VISION.md) — that file is the constitution. LSA configuration is at [`./.lsa.yaml`](./.lsa.yaml). This file is the slim Claude Code entry point.

## Default plugins

Two plugins ship from this marketplace and together form the development discipline for working in this repo. **Install both:**

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@nz-vision
/plugin install lsa@nz-vision
/reload-plugins
```

Install `core` first — `lsa` cites it for fact-grounding and tier-selection (see [`lsa/README.md`](./lsa/README.md) → "Depends on").

## Ground rules (always-on)

Apply `core/ground-rules` to every substantive task. Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked.

## Tier selection (always-on)

Before any non-trivial task, invoke `core/tier-selector` to classify the work as T1, T2, or T3 — and present the reasoning to the human for confirmation. Skip only for tasks that obviously stay inside T1 boundaries (single-string edits, single-question answers).

**The boundary signals** (Vision §4 `vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.

**Tier outcomes:**
- **T1** — single pass, no LSA ceremony. `ground-rules` still applies.
- **T2** — `lsa-discover` (light) → agent TDD → `lsa-verify`.
- **T3** — `lsa-discover` → `lsa-specify` → `lsa-plan` → implement → `lsa-verify` → `lsa-sync`.

## Where things live

```
.
├── CLAUDE.md                              ← you are here (slim Claude Code entry point)
├── README.md                              ← public one-liner ("My personal claude marketplace")
├── LICENSE
├── .lsa.yaml                              ← LSA config: constitution=vision/VISION.md, specs_root=vision/specs/, mode=docs
├── .lsa-sync-state.json                   ← per-module last-sync SHA (written by lsa-sync; not yet present — first sync writes it)
├── .claude-plugin/
│   └── marketplace.json                   ← marketplace catalog (lists core + lsa)
├── core/                                  ← the core plugin — v0.2.0
│   ├── .claude-plugin/plugin.json
│   ├── CHANGELOG.md  README.md  VERIFICATION.md
│   ├── CLAUDE.md                          ← opt-in always-on fragment (ground-rules + tier-selector rules)
│   ├── skills/
│   │   ├── ground-rules/SKILL.md          ← four discipline rules
│   │   ├── actor-template/SKILL.md        ← Goal/Input/Steps/Output/Constraints shape
│   │   └── tier-selector/SKILL.md         ← T1/T2/T3 chain-of-thought classifier
│   └── tests/repo-anchored.md             ← dogfood probes anchored in this repo
├── lsa/                                   ← the lsa plugin — v0.2.0; depends on core
│   ├── .claude-plugin/plugin.json
│   ├── ARCHITECTURE.md  CHANGELOG.md  README.md
│   ├── hooks/
│   │   ├── hooks.json                     ← SessionStart drift-warning manifest
│   │   └── session-start-drift-check.sh   ← diffs artifact_paths vs .lsa-sync-state.json
│   └── skills/
│       ├── lsa-init/SKILL.md              ← scaffold spec tree (greenfield or brownfield)
│       ├── lsa-discover/SKILL.md          ← Phase 0 — three-question probe (T2 + T3)
│       ├── lsa-specify/SKILL.md           ← Phase 1 — write the feature spec (T3)
│       ├── lsa-plan/SKILL.md              ← Phase 2 — decompose into ≤5 epics (T3)
│       ├── lsa-verify/SKILL.md            ← Phase 5 — code-mode/doc-mode/mixed verify
│       ├── lsa-sync/SKILL.md              ← Phase 6 — sync to module specs + archive + state writer
│       ├── lsa-reconcile/SKILL.md         ← Ad-hoc — absorb direct artifact edits (Level 2.5)
│       └── lsa-revise-constitution/SKILL.md  ← Phase 7 — propose constitution / standards changes
└── vision/
    ├── VISION.md                          ← THE CONSTITUTION (operating rules + design rationale)
    ├── specs/
    │   ├── main.spec.md                   ← module index, cross-plugin contracts, NFRs
    │   ├── roadmap.md                     ← prioritized backlog
    │   ├── research-backlog.md            ← parking lot for mid-feature ideas
    │   ├── 2026-05-20-lsa-v0.2.0-design.md  ← active design doc for the in-flight release
    │   ├── standards/
    │   │   ├── code.md  testing.md  agents.md
    │   ├── modules/
    │   │   ├── core/spec.md               ← the `core` module spec
    │   │   └── lsa/spec.md                ← the `lsa` module spec
    │   └── archive/
    │       └── 2026-05-20-core-v1/{design.md, tasks.md}   ← read-only history
    ├── plans/
    │   └── 2026-05-20-lsa-v0.2.0-plan.md  ← active plan for the in-flight release
    └── experience/                        ← source `.docx` documents (local-only; untracked)
```

Quick reference table:

| Looking for… | Path |
|---|---|
| The constitution | [`vision/VISION.md`](./vision/VISION.md) |
| The module map + NFRs | [`vision/specs/main.spec.md`](./vision/specs/main.spec.md) |
| Permanent module specs | [`vision/specs/modules/core/spec.md`](./vision/specs/modules/core/spec.md), [`vision/specs/modules/lsa/spec.md`](./vision/specs/modules/lsa/spec.md) |
| Cross-feature standards | [`vision/specs/standards/`](./vision/specs/standards/) — `code.md`, `testing.md`, `agents.md` |
| LSA config for this repo | [`./.lsa.yaml`](./.lsa.yaml) |
| Marketplace catalog | [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) |
| The two plugins | [`core/`](./core/), [`lsa/`](./lsa/) |
| Completed feature history | [`vision/specs/archive/`](./vision/specs/archive/) (read-only) |

## Discipline

- **Per-plugin SemVer + CHANGELOG.** Every plugin maintains `<plugin>/CHANGELOG.md` (Keep a Changelog) paired with a SemVer in `<plugin>/.claude-plugin/plugin.json`. **Bump version in the same commit as the changelog entry.** See [`vision/VISION.md`](./vision/VISION.md) §1 "Distribution + versioning".
- **Spec-grounding.** Every code/spec/skill change traces to a spec or plan; direct artifact edits are absorbed via `lsa-reconcile` (Level 2.5).
- **Fact-grounding.** Every claim with a path:line + quote. No hedging in place of sourcing.
- **GitHub account.** This repo lives at `github.com/NVZver/claude-marketplace`. Push under the `NVZver` GitHub account (`gh auth switch` if needed) — not the work account.
