# Manager

Product and project management discipline for the NVZver marketplace. Two roles:

1. **Product manager** — shapes vague ideas into structured, buildable pitches before the build cycle begins. The shaping conversation follows a 5-section pitch format (defined in [`knowledge/pitch-structure.md`](./knowledge/pitch-structure.md)) inspired by Basecamp's Shape Up methodology [unverified]. The product-manager agent dynamically adapts its domain-expert role per invocation.

2. **Project manager** — stewards the roadmap after pitches are approved. Recommends what to build next using dependency/risk/value reasoning, decomposes chosen pitches into focused epics, and hands each epic to LSA for technical refinement. The project-manager agent reads the roadmap, pitches, branches, and spec state to ground every recommendation. Its commands follow the function-like naming convention in [`knowledge/command-naming.md`](./knowledge/command-naming.md) — verbs you call with arguments, not nouns you browse.

Spec: [`.lsa/modules/manager/spec.md`](../.lsa/modules/manager/spec.md).

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install manager@NVZver
/reload-plugins
```

Install `core` first — `manager` cites `core/ground-rules` for fact-grounding and `core/output` for format discipline.

## Depends on

- **`core`** — `core/ground-rules` (fact-grounding policy), `core/output` (format discipline). Declared in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `dependencies` field.

## Skills

| Skill | What it does |
|---|---|
| `manager:shape` | Shape a new feature. Accepts a problem description, dispatches the product-manager agent, **delivers the full pitch to you** (the agent's payload is invisible), runs the returned human gates (role, shaping forks, approve/reshape/reject), and writes the pitch file **only on approve** — nothing lands on disk on reject (since v0.6.0). Hands off to `manager:decompose` for epic decomposition on approval. |
| `manager:next` | Recommend what to work on next. A plain "what's next" gets a fast-path answer in seconds — a Step 0 branch reads `.lsa/roadmap.md` §`## Feature Backlog` directly and quotes the first `backlog`/`not started` row with a `file:line` citation, no agent dispatch (per [`../core/knowledge/fast-path-source-of-truth.md`](../core/knowledge/fast-path-source-of-truth.md)). The full project-manager dispatch (dependency/risk/value sequencing) is reserved for "recommend an order" / "what should I pick" questions. |
| `manager:decompose <pitch>` | Decompose a pitch into independently-shippable epics. Dispatches the project-manager agent with the pitch, runs the approve/reject/adjust epic gate, and on approval hands the first epic to `lsa:discover` (remaining epics surfaced for re-invocation). |
| `manager:check` | Check roadmap hygiene. Dispatches the project-manager agent to flag stale/inconsistent rows (missing pitch, status vs branch mismatch, merged-but-not-shipped), gates each proposed row diff one by one, and re-renders the rows the agent applies. |

## Agents

| Agent | What it does |
|---|---|
| `product-manager` | Shaping agent. Adapts domain-expert role per invocation, drafts the pitch and returns its full content + pending human gates for `manager:shape` to deliver and run — writes no files (since v0.6.0). |
| `project-manager` | Roadmap steward. Recommends next backlog item (dependency/risk/value reasoning), decomposes pitches into independently-shippable epics, proposes roadmap hygiene updates, stages the first-epic LSA handoff for `manager:decompose` to invoke. The three roadmap verbs (`manager:next` / `manager:decompose` / `manager:check`) dispatch it with a distinct intent; the shared dispatch → gate → re-render contract lives at [`knowledge/roadmap-orchestration.md`](./knowledge/roadmap-orchestration.md). |

## How it fits

```
manager:shape → (human approves pitch) → manager:decompose
                                                  ↓
                                roadmap entry + decompose into epics → (human approves epics)
                                                  ↓
              lsa:discover → lsa:specify → lsa:verify → lsa:delegate → lsa:reconcile

manager:next  → recommend what to work on next (fast-path or sequenced)
manager:check → check roadmap hygiene, gate proposed row diffs
```

The manager plugin owns both the pre-build shaping phase (product-manager) and the project coordination phase (project-manager). The product-manager produces pitches; the project-manager converts them into roadmap items and decomposes them into epics for LSA. Human approval gates exist at every handoff — pitch approval, roadmap entry, epic approval, and LSA handoff. The orchestrator skills run these gates; the agents prepare them (agents propose, skills gate — `AskUserQuestion` is unavailable in subagent context).

## `manager:next` — fast-path vs full reasoning

`manager:next` answers "what should I work on next?" at two levels:

- **Fast-path (Mode 0)** — a plain "what's next" returns the first `backlog` / `not started` roadmap row quoted with a `file:line` citation in seconds, without dispatching the agent or doing a deep read (per [`../core/knowledge/fast-path-source-of-truth.md`](../core/knowledge/fast-path-source-of-truth.md)).
- **Full flow** — when the question asks for ordering or selection reasoning, it dispatches the project-manager, which reads linked pitches and applies sequencing heuristics (dependency / risk / value), then runs the pick gate. Decomposing the chosen pitch into epics and the LSA handoff are `manager:decompose`'s job, not `manager:next`'s.
