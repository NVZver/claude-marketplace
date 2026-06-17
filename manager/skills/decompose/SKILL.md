---
name: decompose
description: "Decompose a pitch into independently-shippable epics. Input: a pitch slug or path (argument; if omitted, the first backlog pick). Output: the project-manager agent's epic list delivered and gated (approve / reject / adjust) via AskUserQuestion; on approval the first epic seeds an lsa:discover handoff and the remaining epics are surfaced. Reads ${specs_root}/pitches/<slug>.md."
---

> **Trace.** On load, print first: `=============== [manager/skills/decompose/SKILL.md] [manager] ===============`


# Decompose

Decompose a pitch into epics ready for the LSA build cycle. Dispatches the `project-manager` agent with the pitch, runs the epic-approval gate, and on approval invokes the staged `lsa:discover` handoff with the agent's first-epic seed. Does not contain decomposition logic — that lives in the agent and [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md). The dispatch → gate → re-render loop is the shared contract at [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).

## Goal

Turn an approved pitch into a list of independently-shippable epics — each keyed by a **stable slug** (`<feature-slug>/<short-kebab-scope>`, never a global ordinal) and scoped to one LSA cycle — and stage the first epic into discovery, without the user manually decomposing the pitch or invoking the agent directly. The slug is assigned once here and is immutable through commit and PR per [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md) §"Epic key".

## Input

- A pitch slug or path as the skill argument (e.g. `manager:decompose onboarding-checklist` or a path under `${specs_root}/pitches/`). If no argument is given, the agent decomposes the first backlog pick (per [`../../agents/project-manager.md`](../../agents/project-manager.md) Step 8).
- `specs_root` from `.lsa.yaml` at repo root (defaults per [`../../../lsa/knowledge/conventions.md`](../../../lsa/knowledge/conventions.md) §"`.lsa.yaml` defaults"). Used to resolve `${specs_root}/...` paths.

## Steps

1. **Dispatch the project-manager and run the epic-approval gate — per the shared contract.** Dispatch the `project-manager` agent with an explicit intent carrying the pitch (`intent: decompose <pitch>`) and run its returned gates per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md). The agent reads the pitch, decomposes it per [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md), and returns the **full epic list** as a pending gate — approve (recommended default) / reject / adjust ([`../../agents/project-manager.md`](../../agents/project-manager.md) Step 10). This skill delivers the list and presents the gate via `AskUserQuestion`; on reject/adjust it sends the feedback back and re-gates the fresh epic list. Observable result: epic list delivered; approve/reject/adjust gate resolved by the user.

2. **Run the staged handoff.** On epic approval, invoke `lsa:discover` via the `Skill` tool with the agent's staged seed text verbatim (first epic paragraph + pitch link, per [`../../agents/project-manager.md`](../../agents/project-manager.md) Step 11). Surface the agent's remaining-epics note. Observable result: `lsa:discover` executing with the first epic's context; remaining epic list displayed with instruction to continue (re-invoke `manager:decompose` for the next epic after the current one ships).

## Output

The agent's epic list — each epic carrying its **stable slug** key (`<feature-slug>/<short-kebab-scope>`, per [`../../knowledge/epic-decomposition.md`](../../knowledge/epic-decomposition.md) §"Epic key") — is delivered and the approve/reject/adjust gate is resolved. On approval `lsa:discover` is executing with the first epic's seed (slug included verbatim, so it survives unchanged into the eventual commit and PR) and the remaining epics are surfaced; on reject no handoff runs. The agent proposes; this skill runs the gate and the `lsa:discover` invocation.

### Example Output

[illustrative]

```
Dispatching project-manager (intent: decompose onboarding-checklist)...

Epics for "Onboarding checklist" (2 epics, keyed by stable slug):
- onboarding-checklist/knowledge-file — DoD: file exists with numbered items.
- onboarding-checklist/verify-drift — DoD: lsa:verify reports missing file.

Gate — epics: approve (recommended) / reject / adjust
> approve

Invoking lsa:discover with the staged seed (epic onboarding-checklist/knowledge-file)...
Remaining: onboarding-checklist/verify-drift (re-invoke manager:decompose after the first epic ships). Each slug stays fixed through commit and PR.
```

## Constraints

- **Orchestrator only — per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).** Dispatch with an explicit intent + pitch, run the gate, re-render, hand off. No decomposition logic here.
- **No silent handoff.** The epic-approval gate lives in THIS skill (the agent cannot ask); `lsa:discover` is invoked here only after epic approval, with the agent's staged seed.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/manager:decompose <pitch>` — manual invocation.
