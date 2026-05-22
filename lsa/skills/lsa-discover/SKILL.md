---
name: lsa-discover
description: Light three-question discovery probe at the start of every Standard and Extended task — module, change, acceptance criterion. Use before any code or spec change when flow is Standard or Extended.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-discover/SKILL.md] [lsa] ===============`


# LSA Discover

The light discovery phase between `core/flow-selector` and either implementation (Standard) or `lsa-specify` (Extended). Cheap by design: three questions, no spec writes for Standard, a small scratch handoff for Extended.

## Goal

Establish minimum-viable context — which module the change touches, what the change is in one sentence, and the acceptance criterion in one sentence — and hand off to the next phase appropriate to the flow.

## Input

- The task description from `core/flow-selector`'s confirmed handoff, including the confirmed flow (Standard or Extended).
- `.lsa.yaml` at repo root (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults") for the list of candidate module names.

## Steps

1. **Read `.lsa.yaml` and list candidate module names.** Read `modules.*` keys; if `.lsa.yaml` is absent, list module directories under `${specs_root}/modules/` instead. Observable result: the candidate-module list printed back to the human (so the answer to question (a) below is constrained, not invented).

2. **Ask the three-question discovery probe — assume-then-override.** Question (a) is constrained to the candidates from Step 1. For (b) and (c), propose 2 candidate framings from the module spec(s) so the human picks rather than invents. Silence on a line = approval.

   Present:
   - module(s) — picked from Step 1's list, or `new module: <name>`
   - 2 candidate one-line framings for the change + `custom` option
   - 2 candidate one-line acceptance criteria + `custom` option

   Format per [`core/output`](../../../core/skills/output/SKILL.md); `AskUserQuestion` for each pick in Claude Code. Observable result: three answers captured (module + change + AC) in the working scratch.

3. **For Standard only** — render the discovery as a 3-row table (Module / Change / Acceptance) per [`core/output`](../../../core/skills/output/SKILL.md). **Stop** there. The agent then writes a failing test, implements the change, and runs `/lsa:verify`. Observable result: the table printed back to the human; no files written to `${specs_root}/`.

4. **For Extended only** — write a draft `discovery.md` block under the working feature directory (a scratch file, not yet committed; `lsa-specify` consumes and expands it into the formal feature spec):

   ```markdown
   # Discovery — <feature-name>

   - **Module(s):** <answer (a)>
   - **Change:** <answer (b)>
   - **Acceptance:** <answer (c)>
   ```

   Then hand off to `lsa-specify` with a one-line message naming the chosen module(s) and feature name. Observable result: `discovery.md` exists; the handoff is invoked.

## Output

- **Standard** — short context paragraph (oral only; no file).
- **Extended** — `discovery.md` scratch file at the working feature path, plus a one-line handoff message naming the chosen module(s) and the feature name.

## Constraints

- **Three questions, no more.** If deeper context is needed, escalate back to `flow-selector` for a flow-bump rather than asking question four.
- **Do not write to the configured `specs_root`.** That is `lsa-specify`'s responsibility. The Extended `discovery.md` is a working scratch file, not a spec write.
- **Do not invent module names** not present in `.lsa.yaml` (or under `${specs_root}/modules/` when `.lsa.yaml` is absent). If the chosen module does not exist, capture it explicitly as `new module: <name>` so downstream phases know to create it.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:discover` — manual invocation. On Extended completion, downstream is `lsa-specify`.
