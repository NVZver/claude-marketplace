> **Trace.** On load, print first: `=============== [knowledge/index.md] [repo] ===============`

# Knowledge index

Flat table of every knowledge file across the five packs. Agents consult this index by **structure** (topic → path) instead of grepping. Heading-anchor citations assume the rows here are current; a stale row breaks navigation silently.

Maintained manually. When a knowledge file is added, moved, or removed, update this index in the same commit. Per [`../.lsa/pitches/readme-and-knowledge-base.md`](../.lsa/pitches/readme-and-knowledge-base.md) "Solution sketch".

## Catalog — 21 knowledge files

| Topic | Pack | Path | One-sentence description |
|---|---|---|---|
| Fast-path source of truth | `core` | [`../skills/core/knowledge/fast-path-source-of-truth.md`](../skills/core/knowledge/fast-path-source-of-truth.md) | The shared single-source-of-truth navigation fast-path contract — direct read + cited quote, exact-phrase detection, fall-through-on-failure — cited by `manager:next`. |
| Output vocabulary | `core` | [`../skills/core/knowledge/output-vocabulary.md`](../skills/core/knowledge/output-vocabulary.md) | The canonical marketplace verdict labels (PROPOSED, DRIFT, APPLIED, PASS, FAIL, etc.) cited by `core/output`. |
| LSA conventions | `lsa` | [`../skills/lsa/knowledge/conventions.md`](../skills/lsa/knowledge/conventions.md) | Cross-cutting conventions every LSA skill applies; referenced by section name rather than restated in each skill body. |
| Migration instructions (AI) | `lsa` | [`../skills/lsa/knowledge/migration-instructions-ai.md`](../skills/lsa/knowledge/migration-instructions-ai.md) | AI runbook to migrate `${specs_root}/roadmap.md` → `roadmap.yaml` (detect → migrate → verify → rewire → cleanup → gates); cited by `lsa:init`. |
| Quality gate contract | `lsa` | [`../skills/lsa/knowledge/quality-gate-contract.md`](../skills/lsa/knowledge/quality-gate-contract.md) | The required-vs-non-blocking check taxonomy and the independent-grader gate contract `lsa:reconcile` enforces. |
| Model routing | `lsa` | [`../skills/lsa/knowledge/model-routing.md`](../skills/lsa/knowledge/model-routing.md) | The `.lsa.yaml` `routing:` map schema, per-dispatch resolution algorithm (floored surfaces + absent-⇒-inherit), and the per-dispatch tier table — cited cross-plugin by `manager` and `prompt-engineer`. |
| Pinned library specs | `lsa` | [`../skills/lsa/knowledge/pinned-library-specs.md`](../skills/lsa/knowledge/pinned-library-specs.md) | The `${specs_root}/libs/<lib-name>.md` pinned-spec file format, the `.lsa.yaml` `libs:` registration schema, and `scripts/check-lib-pins.sh`'s staleness-gate exit codes (OK/STALE/`[cannot verify]`/BROKEN). |
| Autonomy policy | `manager` | [`../skills/manager/knowledge/autonomy-policy.md`](../skills/manager/knowledge/autonomy-policy.md) | The `manual`/`semi`/`auto` autonomy-ladder definitions + per-level scope of unattended multi-PR churn; the single source for autonomy levels. |
| Command naming | `manager` | [`../skills/manager/knowledge/command-naming.md`](../skills/manager/knowledge/command-naming.md) | The function-like command-naming convention `<actor>:<action>-<modifier> args` — verbs you call with arguments, not nouns you browse; the single source of truth for command naming. |
| Epic decomposition | `manager` | [`../skills/manager/knowledge/epic-decomposition.md`](../skills/manager/knowledge/epic-decomposition.md) | Rules for breaking a shaped pitch into epics; each epic maps to one LSA build cycle. |
| Parallel dispatch | `manager` | [`../skills/manager/knowledge/parallel-dispatch.md`](../skills/manager/knowledge/parallel-dispatch.md) | How `manager:implement` turns epics into a dependency-ordered wave plan and dispatches one worktree-isolated agent per epic (disjointness analysis + dispatch policy). |
| Parallel-implementation roll-up | `manager` | [`../skills/manager/knowledge/parallel-rollup.md`](../skills/manager/knowledge/parallel-rollup.md) | The end-of-run report contract for parallel `manager:implement` runs — per-epic table, files-changed, proven-facts, open-items; reuses `core/output` Rule 7. |
| Pitch structure | `manager` | [`../skills/manager/knowledge/pitch-structure.md`](../skills/manager/knowledge/pitch-structure.md) | Canonical format for a shaped pitch — Problem / Appetite / Solution sketch / Rabbit holes / No-gos. |
| Roadmap orchestration | `manager` | [`../skills/manager/knowledge/roadmap-orchestration.md`](../skills/manager/knowledge/roadmap-orchestration.md) | The shared dispatch → gate → re-render contract the two dispatching roadmap verb skills (`manager:next` / `manager:decompose`) cite when they dispatch the `project-manager` agent and run its returned gates. |
| Role adaptation | `manager` | [`../skills/manager/knowledge/role-adaptation.md`](../skills/manager/knowledge/role-adaptation.md) | The self-selected domain-expert role the `product-manager` agent adopts per invocation, with visible chain-of-thought. |
| Sequencing heuristics | `manager` | [`../skills/manager/knowledge/sequencing-heuristics.md`](../skills/manager/knowledge/sequencing-heuristics.md) | Three factors for ordering backlog items — dependency, then risk, then value — grounded in roadmap and codebase state. |
| Serialized merge | `manager` | [`../skills/manager/knowledge/serialized-merge.md`](../skills/manager/knowledge/serialized-merge.md) | The serialized-merge convergence contract + shared-ledger lock — who writes `CHANGELOG.md` / version / roadmap during a parallel run, and how N per-epic PRs land without turning the branch red. |
| Observe roles | `observer` | [`../skills/observer/knowledge/roles.md`](../skills/observer/knowledge/roles.md) | Per-role lens / voice / cadence bundles (rubber-duck, pair-programmer, interviewer, custom) that the `observer:observe` Actor reads as data — role behavior lives here, not in the skill. |
| Actor ground rules | `prompt-engineer` | [`../skills/prompt-engineer/knowledge/actor-ground-rules.md`](../skills/prompt-engineer/knowledge/actor-ground-rules.md) | Eleven ground rules for agents and commands, plus the actor format template (Goal / Input / Steps / Output / Constraints). |
| Quality checks | `prompt-engineer` | [`../skills/prompt-engineer/knowledge/quality-checks.md`](../skills/prompt-engineer/knowledge/quality-checks.md) | Knowledge-file quality checks, KISS/DRY audit, AI over-engineering sweep, context-budget ceiling, severity levels. |
| Separation of concerns | `prompt-engineer` | [`../skills/prompt-engineer/knowledge/separation-of-concerns.md`](../skills/prompt-engineer/knowledge/separation-of-concerns.md) | Classification table and boundary violations for plugin file categories — Knowledge vs Actor. |

Rows are sorted by pack (`core` → `lsa` → `manager` → `observer` → `prompt-engineer`) so per-pack contributions are countable from the table directly.

## Scope

This index covers `skills/<pack>/knowledge/**.md` only. It deliberately excludes:

- **Actors** — `skills/<pack>/<skill>/SKILL.md`, `skills/<pack>/agents/<agent>.md`, `skills/<pack>/commands/<verb>.md`. Listed in each pack's `README.md`.
- **LSA workspace** — `.lsa/constitution.md`, `.lsa/**` (specs, pitches, plans, standards, archive). Their own surface; see [`../.lsa/main.spec.md`](../.lsa/main.spec.md) for the module index.
- **Project root docs** — `README.md`, `CONTRIBUTING.md`, `AGENTS.md`, per-pack `README.md` and `CHANGELOG.md`. Listed in [`../README.md#further-reading`](../README.md#further-reading).
