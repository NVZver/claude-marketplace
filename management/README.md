# Management

Product and project management discipline for the NVZver marketplace. Two roles:

1. **Product manager** — shapes vague ideas into structured, buildable pitches before the build cycle begins. The shaping conversation follows a 5-section pitch format (defined in [`knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)) inspired by Basecamp's Shape Up methodology [unverified]. The product-manager agent dynamically adapts its domain-expert role per invocation.

2. **Project manager** — stewards the roadmap after pitches are approved. Recommends what to build next using dependency/risk/value reasoning, decomposes chosen pitches into focused epics, and hands each epic to LSA for technical refinement. The project-manager agent reads the roadmap, pitches, branches, and spec state to ground every recommendation.

Spec: [`.lsa/modules/management/spec.md`](../.lsa/modules/management/spec.md).

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install management@NVZver
/reload-plugins
```

Install `core` first — `management` cites `core/ground-rules` for fact-grounding and `core/output` for format discipline.

## Depends on

- **`core`** — `core/ground-rules` (fact-grounding policy), `core/output` (format discipline). Declared in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `dependencies` field.

## Skills

| Skill | What it does |
|---|---|
| `management:start-feature` | Shape a new feature. Accepts a problem description, dispatches the product-manager agent, runs the agent's returned human gates (role, shaping forks, approve/reshape/reject), hands off to `management:roadmap` for epic decomposition on approval. |
| `management:roadmap` | Manage the project roadmap. A plain "what's next" gets a fast-path answer in seconds — a Step 0 branch reads `.lsa/roadmap.md` §`## Feature Backlog` directly and quotes the first `backlog`/`not started` row with a `file:line` citation, no agent dispatch (per [`../core/knowledge/fast-path-source-of-truth.md`](../core/knowledge/fast-path-source-of-truth.md)). The full project-manager dispatch (dependency/risk/value sequencing, epic decomposition, hygiene) is reserved for "recommend an order" / "what should I pick" questions. |

## Agents

| Agent | What it does |
|---|---|
| `product-manager` | Shaping agent. Adapts domain-expert role per invocation, produces structured draft pitches, returns pending human gates for `management:start-feature` to run. |
| `project-manager` | Roadmap steward. Recommends next backlog item (dependency/risk/value reasoning), decomposes pitches into independently-shippable epics, proposes roadmap hygiene updates, stages the first-epic LSA handoff for `management:roadmap` to invoke. |

## How it fits

```
management:start-feature → (human approves pitch) → roadmap entry → management:roadmap
                                                                                          ↓
                                                          pick next item → decompose into epics
                                                          ↓
              lsa:discover → lsa:specify → lsa:verify → lsa:delegate → lsa:reconcile
```

The management plugin owns both the pre-build shaping phase (product-manager) and the project coordination phase (project-manager). The product-manager produces pitches; the project-manager converts them into roadmap items and decomposes them into epics for LSA. Human approval gates exist at every handoff — pitch approval, roadmap entry, epic approval, and LSA handoff. The orchestrator skills run these gates; the agents prepare them (agents propose, skills gate — `AskUserQuestion` is unavailable in subagent context).

## `management:roadmap` — fast-path vs full reasoning

`management:roadmap` answers "what should I work on next?" at two levels:

- **Fast-path (Mode 0)** — a plain "what's next" returns the first `backlog` / `not started` roadmap row quoted with a `file:line` citation in seconds, without dispatching the agent or doing a deep read (per [`../core/knowledge/fast-path-source-of-truth.md`](../core/knowledge/fast-path-source-of-truth.md)).
- **Full flow** — when the question asks for ordering or selection reasoning, it reads linked pitches, applies sequencing heuristics (dependency / risk / value), decomposes the chosen pitch into epics, and hands off to LSA.
