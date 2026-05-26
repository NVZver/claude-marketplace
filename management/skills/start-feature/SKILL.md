---
name: start-feature
description: "Shape a new feature from a vague idea into a structured pitch. Input: problem or opportunity description (argument or interactive prompt). Output: approved pitch file at vision/specs/pitches/<slug>.md, then handoff to lsa:new for branch creation and discovery."
---

> **Trace.** On load, print first: `=============== [management/skills/start-feature/SKILL.md] [management] ===============`


# Start Feature

Orchestrator skill. Accepts a vague idea, dispatches the `product-manager` agent for interactive shaping and approval, then hands off to `lsa:new` on approval. Does not contain shaping logic or branch-creation logic — those live in the agent and `lsa:new` respectively.

## Goal

Go from a vague idea to a human-approved pitch and a running LSA discovery — without the user manually shaping the pitch or invoking `lsa:new`.

## Input

- Problem or opportunity description (argument to the skill, or interactive prompt if no argument given).

## Steps

1. **Accept input.** Read the argument. If no argument provided, prompt the user for a problem or opportunity description. Observable result: description captured.

2. **Dispatch product-manager agent.** Invoke the `product-manager` agent via the `Agent` tool with the problem description. Wait for the agent to complete. Observable result: agent returns pitch file path + approval status.

3. **Handle outcome.**
   - **Approved:** invoke `lsa:new` via the `Skill` tool with the pitch file path as the feature description argument. The pitch context seeds the discovery phase. Observable result: `lsa:new` executing.
   - **Rejected:** exit cleanly. No branch created, no downstream work. Observable result: clean exit, no side effects.

## Output

Either `lsa:new` is executing (approved path) or clean exit (rejected path). The pitch file exists at `vision/specs/pitches/<slug>.md` regardless of outcome (with `approved` or `rejected` status in its metadata).

### Example Output

[illustrative]

```
Pitch approved: vision/specs/pitches/onboarding-checklist.md
Handing off to lsa:new…
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (shaping, role adaptation, pitch assembly) — dispatch and wait. Do not duplicate `lsa:new` logic (branch creation, flow-selector) — invoke and hand off.
- **No silent handoff.** The agent's approval gate (`AskUserQuestion`) is the human decision point. This skill does not add a second approval step.
- **Clean exit on reject.** If the agent returns `rejected` status, exit with no side effects — no branch, no `lsa:new` invocation.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:start-feature` — manual invocation.
