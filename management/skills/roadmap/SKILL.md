---
name: roadmap
description: "Manage the project roadmap. Dispatches the project-manager agent to recommend what to work on next, decompose pitches into epics, and tidy roadmap hygiene. Single entry point for project management."
---

> **Trace.** On load, print first: `=============== [management/skills/roadmap/SKILL.md] [management] ===============`


# Roadmap

Orchestrator skill. Dispatches the `project-manager` agent for roadmap management — sequencing, decomposition, hygiene. Does not contain recommendation logic, decomposition rules, or roadmap-write logic — those live in the agent and its knowledge files ([`../../knowledge/sequencing-heuristics.md`](../../knowledge/sequencing-heuristics.md), [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md)).

## Goal

Give the user a single entry point to manage the project roadmap — what to build next, in what order, and how to break it down — without manually reading roadmap state or invoking the agent directly.

## Input

- None required. The roadmap is the entry point; the agent reads ambient state (roadmap, pitches, branches, specs) internally.
- The fast-path contract at [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — governs the Step 0 branch that answers a plain "what's next" directly from the roadmap before dispatch.

## Steps

0. **Fast-path branch: "what's next" → cited roadmap row (before dispatch).** When the question shape is a plain "what's next" / "what's the next backlog item" (per [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) §"Question-shape detection"), do NOT dispatch the agent. `Read` `${specs_root}/roadmap.md`, locate the `## Feature Backlog` heading anchor, find the first row whose Status is `backlog` or `not started`, quote it back inline with a `file:line` citation per the shared knowledge file's §"Citation format", and exit cleanly. **Reserve the full agent dispatch in Step 1 for explicit "recommend an order" / "what should I pick" / "sequence the backlog" questions** — those need the agent's dependency/risk/value reasoning. **Fall through to Step 1** — with an observable note — if the `## Feature Backlog` anchor is missing, the table is empty, or the question carries the ordering/sequencing intent above. Observable result: either the first backlog row is quoted with its `file:line` citation and the skill exits, or an observable fall-through note and Step 1 dispatches the agent as today.

1. **Dispatch project-manager agent.** Invoke the `project-manager` agent via the `Agent` tool with no additional context — the agent reads ambient state itself per [`../../agents/project-manager.md`](../../agents/project-manager.md) Steps 1-3. Wait for the agent to complete. Observable result: agent running; it handles recommendation, tidy, decomposition, and LSA handoff internally.

2. **Handle completion.** The agent manages its own LSA handoff (Step 11-12 of `project-manager`). On agent return, exit cleanly. Observable result: clean exit, no post-agent work.

## Output

Clean exit after the agent completes. The agent's own output (sequenced recommendation, epic list, hygiene updates, LSA handoff) is delivered directly to the user during its run.

### Example Output

[illustrative]

```
Dispatching project-manager...

Sequenced backlog (2 candidates):
1. Onboarding checklist — Should priority, no dependencies, unblocks plugin-scaffold.
2. Plugin scaffolding command — blocked until onboarding-checklist ships.

Which item to work on? [1] / [2] / [exit]
> 1

Epics for "Onboarding checklist" (2 epics):
1. Onboarding checklist knowledge file
2. Verify integration for checklist drift

Approve epics? [approve] / [reject] / [adjust]
> approve

Handing off Epic 1 to lsa:discover...
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (sequencing, decomposition, roadmap writing) — dispatch and wait. The agent handles all modes and handoff internally.
- **No silent handoff.** The agent's `AskUserQuestion` prompts are the human decision points. This skill does not add approval steps.
- **Show changes inline.** The dispatched `project-manager` agent writes roadmap rows; it must quote each written/changed row inline before its verdict (write, show, comment) per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 and `project-manager.md` Step 7. This skill surfaces the agent's output verbatim and does not summarize the changes as "roadmap updated".
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:roadmap` — manual invocation.
