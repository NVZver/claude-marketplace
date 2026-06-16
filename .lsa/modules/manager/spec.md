> **Trace.** On load, print first: `=============== [.lsa/modules/manager/spec.md] [vision] ===============`

# Module Spec — `manager`

Product and project management discipline. Shapes vague ideas into structured pitches (product-manager) and stewards the roadmap from approved pitches through epic decomposition to LSA handoff (project-manager).

**Plugin manifest:** [`manager/.claude-plugin/plugin.json`](../../../manager/.claude-plugin/plugin.json) (v0.8.0)
**Plugin README** (install, dependencies, status): [`manager/README.md`](../../../manager/README.md)
**Knowledge** (pitch format, role adaptation, epic decomposition, sequencing heuristics, command naming): [`manager/knowledge/`](../../../manager/knowledge/)

## Role in the marketplace

`manager` owns two phases of the development lifecycle:

1. **Shaping (product-manager)** — turns a user's vague idea into a structured pitch with clear scope, boundaries, and exclusions.
2. **Project coordination (project-manager)** — stewards the roadmap: recommends what to build next (dependency/risk/value reasoning), decomposes pitches into independently-shippable epics, proposes roadmap hygiene updates, and hands each epic to LSA.

The pitch is the bridge: the product-manager produces it, the project-manager consumes it. The LSA build cycle (`lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`) receives individual epics from the project-manager.

Depends on `core` ([`manager/README.md`](../../../manager/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — format discipline every response inherits.

Reads `lsa` artifacts (roadmap, specs, branches) for codebase context but does not depend on `lsa` at the plugin level. `lsa` does not depend on `manager`.

## Invariants

- **Versioning.** `manager` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.8.0.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Depends on `core`.** Documented in `manager/.claude-plugin/plugin.json` `dependencies` field and `manager/README.md` *"Depends on"*.
- **Ownership over automation.** Both agents facilitate — they do not decide scope or sequencing. Per `.lsa/VISION.md:15`.
- **Domain-neutral.** The product-manager self-selects a domain role per invocation. Per `manager/knowledge/role-adaptation.md`.
- **Pitch structure is canonical.** Format, sections, and heading structure defined in `manager/knowledge/pitch-structure.md`. That file is the single source of truth for pitch format.
- **Epic decomposition rules are canonical.** Quality criteria, boundary signals, and anti-patterns defined in `manager/knowledge/epic-decomposition.md`. That file is the single source of truth for epic format.
- **Sequencing heuristics are grounded.** Three factors (dependency, risk, value) defined in `manager/knowledge/sequencing-heuristics.md`, each grounded in data sources the agent can read from this repo.
- **Command naming is canonical.** The function-like convention `<actor>:<action>-<modifier> args` is defined in `manager/knowledge/command-naming.md`; that file is the single source of truth for command naming.
- **Human gate before every handoff — agents propose, skills gate.** A pitch must reach `approved` status before it enters project coordination; epics must be user-approved before LSA handoff; roadmap writes require explicit user approval. The gates run in the orchestrator skills (`manager:shape`, `manager:roadmap`) — `AskUserQuestion` and the `Skill` tool are unavailable in subagent context, so the agents return pending gates and a staged `lsa:discover` seed in their payloads instead of asking or invoking.
- **Gate-delivery — show → approve → write (management v0.6.0).** Adopts `core` v0.13.0 (`.lsa/modules/core/spec.md`, Rule 7 *Authorization boundary* / *Delivery test*). The `product-manager` agent writes **no file** — it returns the full pitch content + proposed slug in its payload (tools narrowed to `Read, Grep, Glob`). The dispatching skill (`manager:shape`) re-renders that payload through a rendered channel (turn-final message or gate `preview` — the agent payload is invisible to the user), runs the gates, and writes `${specs_root}/pitches/<slug>.md` with `Status: approved` **only on approve**; on reject nothing is written. The `project-manager` / `manager:roadmap` path applies the same rule to roadmap rows and epic lists.
- **Pitch output path.** Approved pitches land at `${specs_root}/pitches/<slug>.md` — `specs_root` is resolved from `.lsa.yaml` at the repo root (defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults"). In this repo, that resolves to `.lsa/pitches/<slug>.md`. Written only on approve per the gate-delivery invariant above; a rejected pitch is never written.
- **Roadmap is the single entry point for the project-manager.** The agent reads `${specs_root}/roadmap.md` as its primary data source (`specs_root` resolved from `.lsa.yaml`; in this repo, `.lsa/roadmap.md`). All roadmap modifications are proposed as inline diffs; no silent writes.
- **`specs_root` is resolved from `.lsa.yaml`.** Every entry-point skill (`manager:shape`, `manager:roadmap`) and both agents read `.lsa.yaml` to resolve `specs_root` for pitch/roadmap/feature paths, falling back to LSA's defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults". This is what lets the manager plugin interoperate with LSA's configurable workspace instead of hardcoding `vision/specs/`.

## Artifact paths

```yaml
- manager/agents/**/*.md
- manager/skills/**/SKILL.md
- manager/knowledge/**/*.md
- manager/.claude-plugin/plugin.json
- manager/README.md
```
