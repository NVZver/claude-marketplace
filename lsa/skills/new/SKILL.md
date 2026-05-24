---
name: new
description: Start a new feature (creates branch → selects flow → discovers). Input: feature name or description. Output: feature branch created, discovery phase running.
---

> **Trace.** On load, print first: `=============== [lsa/skills/new/SKILL.md] [lsa] ===============`


# LSA New

Single-command entry point to start a feature from scratch. Creates the branch, determines the flow, and hands off to `lsa:discover` — eliminating the manual setup steps.

## Goal

Go from a feature idea to running discovery in one command, without the user manually creating a branch or invoking `core/flow-selector`.

## Input

- Feature name or intent (argument or first-turn prompt from user).
- `.lsa.yaml` at repo root for `specs_root` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Accept feature name.** Read the argument or prompt the user for a feature name/intent. Derive kebab-case slug from the name. Observable result: slug captured.

2. **Create feature branch.** Create git branch `feature/<slug>` from current HEAD. If the branch already exists, present via `AskUserQuestion`:

   - `[a]` switch to existing branch → `git switch feature/<slug>`
   - `[b]` pick a different name → re-prompt for name

   Observable result: on branch `feature/<slug>`.

3. **Invoke flow-selector.** Run `core/flow-selector` to determine the flow type (Quick / Standard / Extended). Observable result: flow type confirmed by user.

4. **Hand off to discover.** Invoke `lsa:discover` with the confirmed flow type and task description. Observable result: discovery phase running.

## Output

Feature branch `feature/<slug>` exists. `lsa:discover` is executing with the confirmed flow type.

## Constraints

- **Orchestrator only.** Do not duplicate discovery or flow-selection logic — hand off to the owning skills.
- **Respect existing branch state.** If already on a feature branch, ask before switching.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:new` — manual invocation.
