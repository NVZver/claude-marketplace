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
| `management:start-feature` | Shape a new feature. Accepts a problem description, dispatches the product-manager agent, optionally adds a roadmap backlog entry, hands off to `management:roadmap` for epic decomposition on approval. |
| `management:roadmap` | Manage the project roadmap. Dispatches the project-manager agent to recommend what to work on next, decompose pitches into epics, and tidy roadmap hygiene. |

## Agents

| Agent | What it does |
|---|---|
| `product-manager` | Interactive shaping agent. Adapts domain-expert role per invocation, drives multi-turn conversation, produces structured pitches, gates on human approval. |
| `project-manager` | Roadmap steward. Recommends next backlog item (dependency/risk/value reasoning), decomposes pitches into independently-shippable epics, proposes roadmap hygiene updates, hands first epic to LSA. |

## How it fits

```
management:start-feature → (human approves pitch) → roadmap entry → management:roadmap
                                                                                          ↓
                                                          pick next item → decompose into epics
                                                          ↓
                          lsa:discover → lsa:plan → lsa:implement → lsa:verify
```

The management plugin owns both the pre-build shaping phase (product-manager) and the project coordination phase (project-manager). The product-manager produces pitches; the project-manager converts them into roadmap items and decomposes them into epics for LSA. Human approval gates exist at every handoff — pitch approval, roadmap entry, epic approval, and LSA handoff.

## `management:roadmap` vs `lsa:next`

Both skills answer "what should I work on next?" — but at different levels:

- **`lsa:next`** — simple priority-sorted pop from the roadmap. No pitch reading, no dependency reasoning, no decomposition. Available without the management plugin.
- **`management:roadmap`** — reads linked pitches, applies sequencing heuristics (dependency/risk/value), decomposes into epics, hands off to LSA. Requires the management plugin.

When management is installed, use `management:roadmap` for the full project-management flow. `lsa:next` remains available as a lightweight fallback.
