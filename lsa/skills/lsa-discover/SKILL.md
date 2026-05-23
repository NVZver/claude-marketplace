---
name: lsa-discover
description: Infer-then-confirm discovery at the start of every Standard and Extended task — module, change, acceptance criterion. Use before any code or spec change when flow is Standard or Extended.
---

> **Trace.** On load, print first: `=============== [lsa/skills/lsa-discover/SKILL.md] [lsa] ===============`


# LSA Discover

The light discovery phase between `core/flow-selector` and either implementation (Standard) or `lsa-specify` (Extended). Cheap by design: three inferred answers confirmed in one shot, no spec writes for Standard, a small scratch handoff for Extended.

## Goal

Establish minimum-viable context — which module the change touches, what the change is in one sentence, and the acceptance criterion in one sentence — and hand off to the next phase appropriate to the flow.

## Input

- The task description from `core/flow-selector`'s confirmed handoff, including the confirmed flow (Standard or Extended).
- `.lsa.yaml` at repo root (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults") for the list of candidate module names.

## Steps

1. **Read `.lsa.yaml` and build module context.** Read `modules.*` keys (names + `artifact_paths` + spec paths); if `.lsa.yaml` is absent, list module directories under `${specs_root}/modules/` instead. Observable result: the candidate-module list available for Step 2's inference.

2. **Infer all three discovery answers — then confirm.** For each answer, cross-reference the task description against the module context from Step 1:

   - **Module** — match against each module's `artifact_paths` globs and spec content; if none match, capture as `new module: <name>`.
   - **Change** — one-sentence framing grounded in the task description and the matched module spec's current state.
   - **AC** — one-sentence criterion grounded in the task description and the module spec's existing invariants or gaps.

   Present all three in a single `AskUserQuestion` as a confirmation, not a quiz. The human overrides any line that is wrong; silence = approval. Observable result: three answers captured (module + change + AC).

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

- **Infer, don't ask.** Never ask the human for information derivable from repo state. Present all three answers in a single confirmation prompt. If deeper context is needed, escalate back to `flow-selector` for a flow-bump rather than asking question four.
- **Do not write to the configured `specs_root`.** That is `lsa-specify`'s responsibility. The Extended `discovery.md` is a working scratch file, not a spec write.
- **Do not invent module names** not present in `.lsa.yaml` (or under `${specs_root}/modules/` when `.lsa.yaml` is absent). If the chosen module does not exist, capture it explicitly as `new module: <name>` so downstream phases know to create it.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:discover` — manual invocation. On Extended completion, downstream is `lsa-specify`.
