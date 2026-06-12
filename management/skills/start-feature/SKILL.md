---
name: start-feature
description: "Shape a new feature from a vague idea into a structured pitch. Input: problem or opportunity description (argument or interactive prompt). Output: approved pitch file at ${specs_root}/pitches/<slug>.md — the agent returns a draft + pending gates, this skill runs the gates via AskUserQuestion — then handoff to management:roadmap for epic decomposition."
---

> **Trace.** On load, print first: `=============== [management/skills/start-feature/SKILL.md] [management] ===============`


# Start Feature

Orchestrator skill. Accepts a vague idea, dispatches the `product-manager` agent for shaping, runs the agent's returned human gates via `AskUserQuestion`, then hands off to `management:roadmap` for epic decomposition. Does not contain shaping logic or decomposition logic — those live in the agents.

## Goal

Go from a vague idea to a human-approved pitch with epics ready for the LSA build cycle — without the user manually shaping the pitch or invoking agents directly.

## Input

- Problem or opportunity description (argument to the skill, or interactive prompt if no argument given).
- `specs_root` from `.lsa.yaml` at repo root (defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults"). Used to resolve `${specs_root}/...` paths below.

## Steps

1. **Accept input.** Read the argument. If no argument provided, prompt the user for a problem or opportunity description. Observable result: description captured.

2. **Dispatch product-manager agent.** Invoke the `product-manager` agent via the `Agent` tool with the problem description. Wait for the agent to complete. Observable result: agent returns the draft pitch path + an ordered pending-gates list (role confirmation, shaping forks with recommended defaults, final approve/reshape/reject) per [`../../agents/product-manager.md`](../../agents/product-manager.md) Step 5.

3. **Run the returned gates.** Present each pending gate to the user via `AskUserQuestion`, in the agent's order: role confirmation first, then each shaping fork (offering the agent's recommended default), then the final approve / reshape / reject.
   - **Approve:** flip the pitch `Status:` to `approved` via `Edit` and record the gate decisions (confirmed role, fork choices) in the pitch metadata header; quote the changed header lines inline.
   - **Reshape:** re-dispatch the agent with the user's feedback (`SendMessage` continuation, or a new dispatch if the agent has exited), then run the freshly returned gates again.
   - **Reject:** set `Status: rejected` via `Edit`, note the rationale in the file, and exit cleanly — no downstream work.

   Observable result: every pending gate resolved by the user; pitch `Status:` flipped to `approved` or `rejected` with the changed lines quoted inline.

4. **Hand off to roadmap.** On approve, invoke `management:roadmap` via the `Skill` tool. The project-manager agent handles the roadmap entry (backlog row, priority, sequencing) and epic decomposition — this skill does not write to `${specs_root}/roadmap.md` directly. (On reject, Step 3 already exited cleanly.) Observable result: `management:roadmap` executing; pitch added to roadmap by project-manager.

## Output

Either `management:roadmap` is executing (approved path) or clean exit (rejected path). The pitch file exists at `${specs_root}/pitches/<slug>.md` regardless of outcome, with `Status:` flipped by this skill. Roadmap writes (backlog row, priority, sequencing) are handled by the project-manager agent via `management:roadmap` — this skill never writes to `${specs_root}/roadmap.md` directly.

### Example Output

[illustrative]

```
Agent returned: .lsa/pitches/onboarding-checklist.md (draft) + 3 pending gates.

Gate 1 — role: developer-tools product manager? > accept
Gate 2 — appetite fork: checklist knowledge file only (recommended)? > accept
Gate 3 — approve / reshape / reject? > approve

Status: draft → approved (.lsa/pitches/onboarding-checklist.md:3)
Handing off to management:roadmap for backlog entry and epic decomposition…
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (shaping, role adaptation, pitch assembly, decomposition) — dispatch, run the gates, hand off.
- **No silent handoff.** The human gates live in THIS skill (the agent cannot ask — `AskUserQuestion` is unavailable in subagent context): every pending gate the agent returns is presented via `AskUserQuestion` before any downstream step.
- **Clean exit on reject.** If the final gate returns reject, set `Status: rejected` and exit with no side effects — no branch, no downstream invocation.
- **Show changes inline.** The dispatched `product-manager` agent writes the draft pitch and quotes it inline before returning (write, show, comment) per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7; this skill quotes its own `Status:` flip inline; the downstream `management:roadmap` handoff surfaces each roadmap row inline. This orchestrator surfaces the agent's output verbatim and never reduces a write to "pitch created" / "added to roadmap" without the content.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:start-feature` — manual invocation.
