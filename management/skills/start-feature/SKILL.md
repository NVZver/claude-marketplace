---
name: start-feature
description: "Shape a new feature from a vague idea into a structured pitch. Input: problem or opportunity description (argument or interactive prompt). Output: approved pitch file at vision/specs/pitches/<slug>.md, then handoff to management:roadmap for epic decomposition."
---

> **Trace.** On load, print first: `=============== [management/skills/start-feature/SKILL.md] [management] ===============`


# Start Feature

Orchestrator skill. Accepts a vague idea, dispatches the `product-manager` agent for interactive shaping and approval, then hands off to `management:roadmap` for epic decomposition. Does not contain shaping logic or decomposition logic — those live in the agents.

## Goal

Go from a vague idea to a human-approved pitch with epics ready for the LSA build cycle — without the user manually shaping the pitch or invoking agents directly.

## Input

- Problem or opportunity description (argument to the skill, or interactive prompt if no argument given).

## Steps

1. **Accept input.** Read the argument. If no argument provided, prompt the user for a problem or opportunity description. Observable result: description captured.

2. **Dispatch product-manager agent.** Invoke the `product-manager` agent via the `Agent` tool with the problem description. Wait for the agent to complete. Observable result: agent returns pitch file path + approval status.

3. **Hand off to roadmap.** Handle outcome based on agent approval status:
   - **Approved:** invoke `management:roadmap` via the `Skill` tool. The project-manager agent handles the roadmap entry (backlog row, priority, sequencing) and epic decomposition — this skill does not write to `vision/specs/roadmap.md` directly. Observable result: `management:roadmap` executing; pitch added to roadmap by project-manager.
   - **Rejected:** exit cleanly. No branch created, no downstream work. Observable result: clean exit, no side effects.

## Output

Either `management:roadmap` is executing (approved path) or clean exit (rejected path). The pitch file exists at `vision/specs/pitches/<slug>.md` regardless of outcome (with `approved` or `rejected` status in its metadata). Roadmap writes (backlog row, priority, sequencing) are handled by the project-manager agent via `management:roadmap` -- this skill never writes to `vision/specs/roadmap.md` directly.

### Example Output

[illustrative]

```
Pitch approved: vision/specs/pitches/onboarding-checklist.md
Handing off to management:roadmap for backlog entry and epic decomposition…
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (shaping, role adaptation, pitch assembly, decomposition) — dispatch and wait.
- **No silent handoff.** The agent's approval gate (`AskUserQuestion`) is the human decision point. This skill does not add a second approval step.
- **Clean exit on reject.** If the agent returns `rejected` status, exit with no side effects — no branch, no downstream invocation.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:start-feature` — manual invocation.
