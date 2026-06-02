> **Trace.** On load, print first: `=============== [knowledge/index.md] [marketplace] ===============`

# Knowledge index — marketplace

Flat table of every knowledge file across the five marketplace plugins. Agents consult this index by **structure** (topic → path) instead of grepping. Heading-anchor citations elsewhere (notably [`helper/knowledge/onboarding-fast-path.md`](../helper/knowledge/onboarding-fast-path.md)) assume the rows here are current; a stale row breaks navigation silently.

Maintained manually. When a knowledge file is added, moved, or removed, update this index in the same commit. Per [`.lsa/pitches/readme-and-knowledge-base.md`](../.lsa/pitches/readme-and-knowledge-base.md) "Solution sketch".

## Catalog — 15 knowledge files

| Topic | Plugin | Path | One-sentence description |
|---|---|---|---|
| Fast-path source of truth | `core` | [`core/knowledge/fast-path-source-of-truth.md`](../core/knowledge/fast-path-source-of-truth.md) | The shared single-source-of-truth navigation fast-path contract — direct read + cited quote, exact-phrase detection, fall-through-on-failure — cited by `lsa:next`, `management:roadmap`, and Helper's onboarding catalog. |
| Output vocabulary | `core` | [`core/knowledge/output-vocabulary.md`](../core/knowledge/output-vocabulary.md) | The canonical marketplace verdict labels (PROPOSED, DRIFT, APPLIED, PASS, FAIL, etc.) cited by `core/output`. |
| Friction signals | `helper` | [`helper/knowledge/friction-signals.md`](../helper/knowledge/friction-signals.md) | When Helper auto-engages and when it stays out of the way; canonical spec for friction patterns the main agent matches against. |
| Knowledge scope | `helper` | [`helper/knowledge/knowledge-scope.md`](../helper/knowledge/knowledge-scope.md) | What Helper is allowed to read when answering, and in what scope order (in-repo → installed plugins → external via `context7`). |
| Onboarding fast-path | `helper` | [`helper/knowledge/onboarding-fast-path.md`](../helper/knowledge/onboarding-fast-path.md) | Catalog mapping onboarding triggers (install / start / what-is-X / how-do-I-run) to README excerpts so Helper short-circuits to seconds. |
| Output discipline | `helper` | [`helper/knowledge/output-discipline.md`](../helper/knowledge/output-discipline.md) | The seven golden output rules Helper applies to every response — re-grounded summary of `core/output` and `core/ground-rules`. |
| LSA conventions | `lsa` | [`lsa/knowledge/conventions.md`](../lsa/knowledge/conventions.md) | Cross-cutting conventions every LSA skill applies; referenced by section name rather than restated in each skill body. |
| Spec templates | `lsa` | [`lsa/knowledge/spec-templates.md`](../lsa/knowledge/spec-templates.md) | Markdown templates for LSA spec artifacts — `requirements.md`, `test-suites.md`, `design.md`. |
| Epic decomposition | `management` | [`management/knowledge/epic-decomposition.md`](../management/knowledge/epic-decomposition.md) | Rules for breaking a shaped pitch into epics; each epic maps to one LSA build cycle. |
| Pitch structure | `management` | [`management/knowledge/pitch-structure.md`](../management/knowledge/pitch-structure.md) | Canonical format for a shaped pitch — Problem / Appetite / Solution sketch / Rabbit holes / No-gos. |
| Role adaptation | `management` | [`management/knowledge/role-adaptation.md`](../management/knowledge/role-adaptation.md) | The self-selected domain-expert role the `product-manager` agent adopts per invocation, with visible chain-of-thought. |
| Sequencing heuristics | `management` | [`management/knowledge/sequencing-heuristics.md`](../management/knowledge/sequencing-heuristics.md) | Three factors for ordering backlog items — dependency, then risk, then value — grounded in roadmap and codebase state. |
| Actor ground rules | `prompt-engineer` | [`prompt-engineer/knowledge/actor-ground-rules.md`](../prompt-engineer/knowledge/actor-ground-rules.md) | Ten ground rules for agents and commands, plus the actor format template (Goal / Input / Steps / Output / Constraints). |
| Quality checks | `prompt-engineer` | [`prompt-engineer/knowledge/quality-checks.md`](../prompt-engineer/knowledge/quality-checks.md) | Knowledge-file quality checks, KISS/DRY audit, AI over-engineering sweep, context-budget ceiling, severity levels. |
| Separation of concerns | `prompt-engineer` | [`prompt-engineer/knowledge/separation-of-concerns.md`](../prompt-engineer/knowledge/separation-of-concerns.md) | Classification table and boundary violations for plugin file categories — Knowledge vs Actor. |

Rows are sorted by plugin (`core` → `helper` → `lsa` → `management` → `prompt-engineer`) so per-plugin contributions are countable from the table directly.

## Scope

This index covers `<plugin>/knowledge/**.md` only. It deliberately excludes:

- **Actors** — `<plugin>/skills/<skill>/SKILL.md`, `<plugin>/agents/<agent>.md`, `<plugin>/commands/<verb>.md`. Listed in each plugin's `README.md`.
- **Plugin manifests** — `<plugin>/.claude-plugin/plugin.json`. Listed in [`README.md#the-five-plugins`](../README.md#the-five-plugins).
- **LSA workspace** — `.lsa/VISION.md`, `.lsa/**` (specs, pitches, plans, standards, archive). Their own surface; see [`.lsa/main.spec.md`](../.lsa/main.spec.md) for the module index.
- **Project root docs** — `README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, per-plugin `README.md` and `CHANGELOG.md`. Listed in [`README.md#further-reading`](../README.md#further-reading).
