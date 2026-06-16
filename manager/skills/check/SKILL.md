---
name: check
description: "Check roadmap hygiene and apply approved fixes. Input: none. Output: the project-manager agent's proposed row diffs (stale/inconsistent entries — missing pitch, status vs branch mismatch, merged-but-not-shipped) delivered and gated one by one via AskUserQuestion; the agent applies only the approved rows and quotes each, which this skill re-renders. Reads ${specs_root}/roadmap.md."
---

> **Trace.** On load, print first: `=============== [manager/skills/check/SKILL.md] [manager] ===============`


# Check

Check the roadmap for hygiene issues — stale rows, missing pitches, status/branch mismatches — and apply the fixes the user approves. Dispatches the `project-manager` agent for the hygiene scan, gates each proposed row diff one by one, and re-renders the agent's applied rows. Does not contain hygiene-scan or roadmap-write logic — those live in the agent ([`../../agents/project-manager.md`](../../agents/project-manager.md) Steps 6-7). The dispatch → gate → re-render loop is the shared contract at [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).

## Goal

Keep the roadmap honest — flag rows whose observable state contradicts their status and apply the corrections the user approves — without the user manually auditing the roadmap or invoking the agent directly.

## Input

- None required. The roadmap is the entry point; the agent reads ambient state (roadmap, pitches, branches, specs) internally.

## Steps

1. **Dispatch the project-manager and gate the row diffs — per the shared contract.** Dispatch the `project-manager` agent with an explicit intent (`intent: hygiene-check`) and run its returned gates per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md). The agent scans for hygiene issues (backlog item with no linked pitch, status `backlog` but an active branch exists, merged branch but status not `shipped`, no branch/spec/activity) and returns each finding as a proposed row diff — previous row + proposed row, each quoted with `file:line` ([`../../agents/project-manager.md`](../../agents/project-manager.md) Steps 6-7). This skill presents each diff one by one via `AskUserQuestion` (approve / reject), sends approvals back via `SendMessage` continuation, and re-renders each row the agent applies and quotes. Observable result: each hygiene diff gated; approved rows applied by the agent and re-rendered inline; rejected diffs discarded.

## Output

Each proposed hygiene row diff is gated one by one; approved rows are applied by the agent (quoting each with `file:line`) and re-rendered inline by this skill; rejected diffs are discarded. If the roadmap is clean, the agent's confirmation is surfaced. No handoff. The agent proposes; this skill runs the gates and re-renders the writes.

### Example Output

[illustrative]

```
Dispatching project-manager (intent: hygiene-check)...

Agent payload: 1 hygiene finding returned as a row diff.

Gate — .lsa/roadmap.md:12 (status backlog → in progress; active feature/* branch exists): approve / reject
> approve
  Applied — .lsa/roadmap.md:12 "| onboarding-checklist | Should | in progress | ... |"
```

## Constraints

- **Orchestrator only — per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).** Dispatch with an explicit intent, gate each diff, re-render. No hygiene-scan or roadmap-write logic here.
- **No silent handoff.** The hygiene gates live in THIS skill (the agent cannot ask); the agent applies a row only after this skill returns its approval via continuation. No `lsa:discover` handoff.
- **Show changes inline.** Re-render each row the agent applies and quotes — never "roadmap updated" without the row. Per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/manager:check` — manual invocation.
