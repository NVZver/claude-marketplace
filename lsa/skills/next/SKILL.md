---
name: next
description: Pick and start the next backlog item (reads roadmap → confirms pick → creates branch → discovers). Input: none. Output: feature branch created, discovery phase running.
---

> **Trace.** On load, print first: `=============== [lsa/skills/next/SKILL.md] [lsa] ===============`


# LSA Next

Reads the roadmap, identifies the highest-priority unstarted item, presents it for confirmation, then creates the branch and kicks off discovery. Eliminates the manual step of scanning the backlog to decide what to work on next.

## Goal

Pick the next backlog item by priority and start working on it in one command, without the user manually reading the roadmap or creating a branch.

## Input

- `.lsa.yaml` at repo root for `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").
- `${specs_root}/roadmap.md` §"Feature Backlog" table.

## Steps

1. **Read roadmap.** Read `${specs_root}/roadmap.md` and parse the Feature Backlog table. Filter rows where Status = "backlog". Sort by Priority: Must > Should > Could. Observable result: candidate list built.

2. **Present top candidate.** Show the highest-priority backlog item via `AskUserQuestion`: feature name, priority, notes excerpt (first sentence of Notes column). Options:

   - `[a]` Start this one → proceed to Step 3
   - `[b]` Skip — show next → present the next candidate (repeat Step 2)
   - `[c]` Cancel → stop

   If no backlog items remain, report: "No items with status 'backlog' in the roadmap." and stop. Observable result: user confirmed a pick (or cancelled).

3. **Create branch and start.** Derive kebab-case slug from the confirmed feature name. Create git branch `feature/<slug>`. Invoke `core/flow-selector` to determine the flow type. Hand off to `lsa:discover` with the confirmed flow type. Observable result: discovery phase running.

## Output

Feature branch `feature/<slug>` exists. `lsa:discover` is executing with the confirmed flow type.

## Constraints

- **Orchestrator only.** Do not duplicate discovery, flow-selection, or roadmap-editing logic — hand off to owning skills.
- **Never auto-pick without confirmation.** The human always confirms which item to start.
- **Read-only on the roadmap.** This skill reads `roadmap.md` but never modifies it. Status updates happen during the cross-reference sweep at ship time.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:next` — manual invocation.
