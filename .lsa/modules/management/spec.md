> **Trace.** On load, print first: `=============== [.lsa/modules/management/spec.md] [vision] ===============`

# Module Spec — `management`

Product and project management discipline. Shapes vague ideas into structured pitches (product-manager) and stewards the roadmap from approved pitches through epic decomposition to LSA handoff (project-manager).

**Plugin manifest:** [`management/.claude-plugin/plugin.json`](../../../management/.claude-plugin/plugin.json) (v0.3.0)
**Plugin README** (install, dependencies, status): [`management/README.md`](../../../management/README.md)
**Knowledge** (pitch format, role adaptation, epic decomposition, sequencing heuristics): [`management/knowledge/`](../../../management/knowledge/)

## Role in the marketplace

`management` owns two phases of the development lifecycle:

1. **Shaping (product-manager)** — turns a user's vague idea into a structured pitch with clear scope, boundaries, and exclusions.
2. **Project coordination (project-manager)** — stewards the roadmap: recommends what to build next (dependency/risk/value reasoning), decomposes pitches into independently-shippable epics, proposes roadmap hygiene updates, and hands each epic to LSA.

The pitch is the bridge: the product-manager produces it, the project-manager consumes it. The LSA build cycle (`lsa:discover` → `lsa:plan` → `lsa:implement` → `lsa:verify`) receives individual epics from the project-manager.

Depends on `core` ([`management/README.md`](../../../management/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — format discipline every response inherits.

Reads `lsa` artifacts (roadmap, specs, branches) for codebase context but does not depend on `lsa` at the plugin level. `lsa` does not depend on `management`.

## Invariants

- **Versioning.** `management` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.3.0.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Depends on `core`.** Documented in `management/.claude-plugin/plugin.json` `dependencies` field and `management/README.md` *"Depends on"*.
- **Ownership over automation.** Both agents facilitate — they do not decide scope or sequencing. Per `.lsa/VISION.md:15`.
- **Domain-neutral.** The product-manager self-selects a domain role per invocation. Per `management/knowledge/role-adaptation.md`.
- **Pitch structure is canonical.** Format, sections, and heading structure defined in `management/knowledge/pitch-structure.md`. That file is the single source of truth for pitch format.
- **Epic decomposition rules are canonical.** Quality criteria, boundary signals, and anti-patterns defined in `management/knowledge/epic-decomposition.md`. That file is the single source of truth for epic format.
- **Sequencing heuristics are grounded.** Three factors (dependency, risk, value) defined in `management/knowledge/sequencing-heuristics.md`, each grounded in data sources the agent can read from this repo.
- **Human gate before every handoff.** A pitch must reach `approved` status before it enters project coordination. Epics must be user-approved before LSA handoff. Roadmap writes require explicit user approval.
- **Pitch output path.** All pitches land at `${specs_root}/pitches/<slug>.md` — `specs_root` is resolved from `.lsa.yaml` at the repo root (defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults"). In this repo, that resolves to `.lsa/pitches/<slug>.md`.
- **Roadmap is the single entry point for the project-manager.** The agent reads `${specs_root}/roadmap.md` as its primary data source (`specs_root` resolved from `.lsa.yaml`; in this repo, `.lsa/roadmap.md`). All roadmap modifications are proposed as inline diffs; no silent writes.
- **`specs_root` is resolved from `.lsa.yaml`.** Every entry-point skill (`management:start-feature`, `management:roadmap`) and both agents read `.lsa.yaml` to resolve `specs_root` for pitch/roadmap/feature paths, falling back to LSA's defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults". This is what lets management interoperate with LSA's configurable workspace instead of hardcoding `vision/specs/`.

## Artifact paths

```yaml
- management/agents/**/*.md
- management/skills/**/SKILL.md
- management/knowledge/**/*.md
- management/.claude-plugin/plugin.json
- management/README.md
```
