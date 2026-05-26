# Management

Product and project management discipline for the NVZver marketplace. Shapes vague ideas into structured, buildable pitches before the build cycle begins — so the developer agent receives a clear scope, not an open-ended wish.

The shaping conversation follows a 5-section pitch format (defined in [`knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)) inspired by Basecamp's Shape Up methodology [unverified]. The product-manager agent dynamically adapts its domain-expert role per invocation — the marketplace is domain-neutral, so the agent reasons about the right lens each time.

Spec: [`vision/specs/modules/management/spec.md`](../vision/specs/modules/management/spec.md).

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
| `management:start-feature` | Entry point for shaping a new feature. Accepts a problem description, dispatches the product-manager agent, hands off to `lsa:new` on approval. |

## Agents

| Agent | What it does |
|---|---|
| `product-manager` | Interactive shaping agent. Adapts domain-expert role per invocation, drives multi-turn conversation, produces structured pitches, gates on human approval. |

## How it fits

```
management:start-feature → (human approves pitch) → lsa:discover → lsa:plan → lsa:implement → lsa:verify
```

The management plugin owns the pre-build phase. Once a pitch reaches `approved` status, `start-feature` automatically invokes `lsa:new` to create the feature branch and begin discovery. The human approval gate inside the product-manager agent is the decision point — no second confirmation required.
