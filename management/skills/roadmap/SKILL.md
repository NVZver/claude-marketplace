---
name: roadmap
description: "Manage the project roadmap. Dispatches the project-manager agent to recommend what to work on next, decompose pitches into epics, and tidy roadmap hygiene; runs the agent's returned pending gates via AskUserQuestion and invokes the staged lsa:discover handoff. Single entry point for project management."
---

> **Trace.** On load, print first: `=============== [management/skills/roadmap/SKILL.md] [management] ===============`


# Roadmap

Orchestrator skill. Dispatches the `project-manager` agent for roadmap management — sequencing, decomposition, hygiene — then runs the agent's returned pending gates and the staged LSA handoff. Does not contain recommendation logic, decomposition rules, or roadmap-write logic — those live in the agent and its knowledge files ([`../../knowledge/sequencing-heuristics.md`](../../knowledge/sequencing-heuristics.md), [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md)).

## Goal

Give the user a single entry point to manage the project roadmap — what to build next, in what order, and how to break it down — without manually reading roadmap state or invoking the agent directly.

## Input

- None required. The roadmap is the entry point; the agent reads ambient state (roadmap, pitches, branches, specs) internally.
- The fast-path contract at [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — governs the Step 0 branch that answers a plain "what's next" directly from the roadmap before dispatch.

## Steps

0. **Fast-path branch: "what's next" → cited roadmap row (before dispatch).** When the question shape is a plain "what's next" / "what's the next backlog item" (per [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) §"Question-shape detection"), do NOT dispatch the agent. `Read` `${specs_root}/roadmap.md`, locate the `## Feature Backlog` heading anchor, find the first row whose Status is `backlog` or `not started`, quote it back inline with a `file:line` citation per the shared knowledge file's §"Citation format", and exit cleanly. **Reserve the full agent dispatch in Step 1 for explicit "recommend an order" / "what should I pick" / "sequence the backlog" questions** — those need the agent's dependency/risk/value reasoning. **Fall through to Step 1** — with an observable note — if the `## Feature Backlog` anchor is missing, the table is empty, or the question carries the ordering/sequencing intent above. Observable result: either the first backlog row is quoted with its `file:line` citation and the skill exits, or an observable fall-through note and Step 1 dispatches the agent as today.

1. **Dispatch project-manager agent.** Invoke the `project-manager` agent via the `Agent` tool with no additional context — the agent reads ambient state itself per [`../../agents/project-manager.md`](../../agents/project-manager.md) Steps 1-3. Wait for the agent's payload: sequenced recommendation, proposed hygiene row diffs, epic list, and/or staged `lsa:discover` seed — each decision returned as a pending gate (the agent cannot ask). Observable result: agent payload received with its pending-gates list.

2. **Run the returned gates — self-contained.** The agent's payload is invisible to the user; every gate must carry its subject (row diff, epic list, candidate sequence) in the question text, option descriptions, or option `preview`, or be preceded by turn-final delivery of it — per [`core/output`](../../../core/skills/output/SKILL.md) Rule 5 *Self-contained gates* and Rule 7 *Delivery test*. Present each pending gate via `AskUserQuestion`: item pick (offering the agent's recommended default), hygiene row diffs one by one, epic approval (approve / reject / adjust). Send the decisions back to the agent via `SendMessage` continuation wherever the agent owns the write — approved roadmap rows are applied by the agent, which quotes them in its payload (Step 7); this skill **re-renders those quotes to the user**. Proceed directly where no write is needed. On reject/adjust of epics, send the feedback back and re-gate the fresh epic list. Observable result: every gate self-contained and resolved by the user; approved roadmap rows applied by the agent and re-rendered inline by this skill; rejected proposals discarded.

3. **Run the staged handoff.** On epic approval, invoke `lsa:discover` via the `Skill` tool with the agent's staged seed text verbatim (first epic paragraph + pitch link, per [`../../agents/project-manager.md`](../../agents/project-manager.md) Step 11). Surface the agent's remaining-epics note. Observable result: `lsa:discover` executing with the first epic's context; remaining epic list displayed with instruction to continue.

## Output

Clean exit after the gates are run and any approved handoff is dispatched. The agent proposes (sequenced recommendation, hygiene diffs, epic list, staged seed); this skill runs every human gate and the `lsa:discover` invocation.

### Example Output

[illustrative]

```
Dispatching project-manager...

Agent payload: 2 candidates sequenced, 1 hygiene diff, pending gates returned.

Gate — pick next item: [1] onboarding-checklist (recommended) / [2] plugin-scaffold / exit
> 1
Gate — hygiene diff .lsa/roadmap.md:12 (status backlog → in progress): approve / reject
> approve
  (agent applies the row and quotes it inline)
Gate — epics for "Onboarding checklist": approve / reject / adjust
> approve

Invoking lsa:discover with the staged seed...
Remaining: Epic 2 (re-invoke management:roadmap after Epic 1 ships).
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (sequencing, decomposition, roadmap writing) — dispatch, run the gates, dispatch the staged handoff. The agent proposes everything; roadmap writes stay agent-owned via continuation.
- **No silent handoff.** The human gates live in THIS skill (the agent cannot ask — `AskUserQuestion` and the `Skill` tool are unavailable in subagent context): every pending gate the agent returns is presented via `AskUserQuestion` before any downstream step, and `lsa:discover` is invoked here only after epic approval, with the agent's staged seed.
- **Show changes inline.** The dispatched `project-manager` agent writes roadmap rows only after this skill returns approvals; it must quote each written/changed row in its payload before its verdict (write, show, comment) per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 and `project-manager.md` Step 7. This skill **re-renders the agent's quotes through a channel the user actually sees** (turn-final message or gate `preview` — Rule 7 *Delivery test*; the agent's payload is invisible) and never summarizes the changes as "roadmap updated".
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:roadmap` — manual invocation.
