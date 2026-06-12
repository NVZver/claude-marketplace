---
name: start-feature
description: "Shape a new feature from a vague idea into a structured pitch. Input: problem or opportunity description (argument or interactive prompt). Output: approved pitch file at ${specs_root}/pitches/<slug>.md — the agent returns the draft content + pending gates; this skill delivers the pitch to the user, runs the gates via AskUserQuestion, and writes the file only on approve (nothing on reject) — then handoff to management:roadmap for epic decomposition."
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

2. **Dispatch product-manager agent.** Invoke the `product-manager` agent via the `Agent` tool with the problem description. Wait for the agent to complete. Observable result: agent returns the full draft pitch content + proposed slug + an ordered pending-gates list (role confirmation, shaping forks with recommended defaults, final approve/reshape/reject) per [`../../agents/product-manager.md`](../../agents/product-manager.md) Step 5. Nothing is on disk.

3. **Deliver the pitch, then run the returned gates.** The agent's payload is invisible to the user — this skill re-renders it. First deliver the full pitch content per the [`core/output`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test*: as the turn-final message (no tool calls after it in that turn), or carried inside the gates below (option `preview`). Then present each pending gate via `AskUserQuestion` (Rule 5 *Self-contained gates*), in the agent's order: role confirmation first, then each shaping fork (offering the agent's recommended default), then the final approve / reshape / reject.
   - **Approve:** `Write` the pitch to `${specs_root}/pitches/<slug>.md` with `Status: approved` and the gate decisions (confirmed role, fork choices) in the metadata header; quote the written file inline — show → approve → write per Rule 7 *Authorization boundary*.
   - **Reshape:** re-dispatch the agent with the user's feedback (`SendMessage` continuation, or a new dispatch if the agent has exited), then deliver + gate the fresh payload again.
   - **Reject:** write nothing — no file exists. State the rationale in the conversation and exit cleanly — no downstream work.

   Observable result: pitch delivered through a rendered channel; every pending gate resolved by the user; on approve the file exists with `Status: approved` and is quoted inline; on reject no file exists.

4. **Hand off to roadmap.** On approve, invoke `management:roadmap` via the `Skill` tool. The project-manager agent handles the roadmap entry (backlog row, priority, sequencing) and epic decomposition — this skill does not write to `${specs_root}/roadmap.md` directly. (On reject, Step 3 already exited cleanly.) Observable result: `management:roadmap` executing; pitch added to roadmap by project-manager.

## Output

Either `management:roadmap` is executing (approved path) or clean exit (rejected path). The pitch file exists at `${specs_root}/pitches/<slug>.md` **only on approve** (`Status: approved`, written by this skill after its gates); on reject nothing is written. Roadmap writes (backlog row, priority, sequencing) are handled by the project-manager agent via `management:roadmap` — this skill never writes to `${specs_root}/roadmap.md` directly.

### Example Output

[illustrative]

```
Agent returned: pitch "Onboarding checklist" (content + 3 pending gates; nothing on disk).

<full pitch delivered as the turn-final message>

Gate 1 — role: developer-tools product manager? > accept
Gate 2 — appetite fork: checklist knowledge file only (recommended)? > accept
Gate 3 — approve / reshape / reject? > approve

Written: .lsa/pitches/onboarding-checklist.md (Status: approved) — file quoted inline
Handing off to management:roadmap for backlog entry and epic decomposition…
```

## Constraints

- **Orchestrator only.** Do not duplicate agent logic (shaping, role adaptation, pitch assembly, decomposition) — dispatch, run the gates, hand off.
- **No silent handoff.** The human gates live in THIS skill (the agent cannot ask — `AskUserQuestion` is unavailable in subagent context): every pending gate the agent returns is presented via `AskUserQuestion` before any downstream step.
- **Clean exit on reject.** If the final gate returns reject, set `Status: rejected` and exit with no side effects — no branch, no downstream invocation.
- **Show changes inline — and own the delivery.** The agent returns the pitch content in its payload, which the user never sees ([`core/output`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test*). THIS skill delivers the full pitch through a rendered channel before gating, writes the file only on approve (Rule 7 *Authorization boundary*), and quotes the written file inline. The downstream `management:roadmap` handoff surfaces each roadmap row inline. Never reduce a write to "pitch created" / "added to roadmap" without the content.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/management:start-feature` — manual invocation.
