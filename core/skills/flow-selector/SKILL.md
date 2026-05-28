---
name: flow-selector
description: Apply before any non-trivial task — when the work touches behavior, adds a new module, changes an API or data model, exceeds ~5 files, or lacks an existing spec. Outputs a flow (Quick / Standard / Extended) with visible chain-of-thought reasoning over boundary signals, then waits for human confirmation. Renamed from `tier-selector` in `core` v0.5.2; the three flows were `T1` / `T2` / `T3`.
---

> **Trace.** On load, print first: `=============== [core/skills/flow-selector/SKILL.md] [core] ===============`


# Flow Selector

Classify a task into Quick / Standard / Extended by weighing boundary signals, then stop and wait for the human to confirm the flow before any downstream LSA ceremony fires. Per `.lsa/VISION.md` §4 (`.lsa/VISION.md:122`): *"the orchestrator picks the flow by chain-of-thought, then states its reasoning and the human confirms or overrides."*

Three flows, named by *process shape*:

- **Quick** — single pass, no LSA ceremony.
- **Standard** — light discovery + agent TDD + verify.
- **Extended** — full spec-driven flow: discover → plan → implement → verify.

## Goal

Produce a flow label (`Quick`, `Standard`, or `Extended`) plus a 2–4-sentence rationale keyed to the boundary signals, present both to the human, and **wait** for an explicit confirmation before any LSA skill fires.

## Input

- The user's most recent task description (one or more sentences in natural language).
- The current repo state (only as needed to answer "does a spec already exist for this module?").

## Steps

1. **List the boundary signals present in the task.** Apply the five-item checklist at [`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) §4 — new module · API/contract change · data-model change · ~5 files · no existing spec.

   Observable result: a five-item bulleted checklist with `yes` / `no` next to each signal, derived only from the task description (and a minimal repo read if needed for the spec-exists question).

2. **Apply the classification table** at [`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) §4 — four worked-example rows mapping pattern → flow.

   Observable result: the matched row (or the closest analogue) named in the chain-of-thought.

3. **State the chain-of-thought as a one-paragraph summary** keyed to the signals from Step 1 and the matched row from Step 2. Observable result: a 2–4-sentence rationale printed back to the human.

4. **Propose flow + rationale to the human and stop.** Present:
   - the proposed flow label (Quick / Standard / Extended)
   - the 5-signal checklist from Step 1 (yes/no per signal)
   - the rationale paragraph from Step 3
   - decision. **Prompt voice (per [`../output/SKILL.md`](../output/SKILL.md) Rule 5).** Picker **question**: *"Run `<task-subject>` as a Quick / Standard / Extended flow?"*. Option **labels**:

     - `[a]` confirm `<proposed>` flow → hand off to `lsa:discover` (Standard / Extended) or direct response (Quick)
     - `[b]` override to a different flow — I re-route accordingly
     - `[c]` reconsider — I re-run the signal checklist

   Format per [`../output/SKILL.md`](../output/SKILL.md); `AskUserQuestion` in Claude Code (per `core/CLAUDE.md` operational checkpoint #1). Observable result: the proposal is on screen; control returns to the human; no downstream skill has fired.

5. **On confirm, hand off** per flow:
   - **Quick** — return control to the agent for a direct single-pass response. `ground-rules` still applies.
   - **Standard** — invoke `lsa:discover` for the light three-question probe.
   - **Extended** — invoke `lsa:discover` (which includes the specify phase internally). Vision's Extended loop is "discover → plan → implement → verify".

   Observable result: the named downstream skill is invoked, or — for Quick — direct response begins.

## Output

A flow label (`Quick` / `Standard` / `Extended`) and a 2–4-sentence rationale. Human-readable. Confirmed before any downstream LSA skill fires.

## Constraints

- Do not start LSA ceremony before flow confirmation. No `lsa:discover`, `lsa:plan`, or any other LSA skill fires until the human responds.
- Do not invent boundary signals that are not actually present in the task description. If the task does not mention an API change, do not assume one.
- Do not silently choose a heavier flow than the human picks. If the human overrides downward (e.g., Extended → Standard), log the override in the rationale and proceed at the human's flow.
- Outputs follow [`../output/SKILL.md`](../output/SKILL.md) — citation by link, never restated.

---

On confirm, downstream LSA skills absorb the flow into their own gates. Every output still obeys `core/ground-rules` (content) and `core/output` (format).
