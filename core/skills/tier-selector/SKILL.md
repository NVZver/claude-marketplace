---
name: tier-selector
description: Apply before any non-trivial task — when the work touches behavior, adds a new module, changes an API or data model, exceeds ~5 files, or lacks an existing spec. Outputs a tier (T1 / T2 / T3) with visible chain-of-thought reasoning over boundary signals, then waits for human confirmation. Per Vision §4: ceremony scales to the weight of the task.
---

# Tier Selector

Classify a task into T1 / T2 / T3 by weighing boundary signals, then stop and wait for the human to confirm the tier before any downstream LSA ceremony fires. Per `vision/VISION.md` §4 (`vision/VISION.md:122`): *"the orchestrator picks the tier by chain-of-thought, then states its reasoning and the human confirms or overrides."*

## Goal

Produce a tier label (`T1`, `T2`, or `T3`) plus a 2–4-sentence rationale keyed to the boundary signals, present both to the human, and **wait** for an explicit confirmation before any LSA skill fires.

## Input

- The user's most recent task description (one or more sentences in natural language).
- The current repo state (only as needed to answer "does a spec already exist for this module?").

## Steps

1. **List the boundary signals present in the task.** Apply this checklist verbatim from `vision/VISION.md:124`:
   - **New module?** — does this introduce a module that does not already exist?
   - **API/contract change?** — does this introduce or change an externally-visible API, slash-command surface, or hook contract?
   - **Data-model change?** — does the persisted shape (schema, file format, on-disk state) change?
   - **> ~5 files?** — does the change span more than roughly five files?
   - **No existing spec?** — does the affected area lack a module spec already?

   Observable result: a five-item bulleted checklist with `yes` / `no` next to each signal, derived only from the task description (and a minimal repo read if needed for the spec-exists question).

2. **Apply the classification table** (verbatim from `vision/VISION.md:128`):

   | Pattern | Example | Tier |
   | --- | --- | --- |
   | One file, one string, no behavior change, no new contract | "Fix the typo in the login button label" | **T1** |
   | One bug in a spec'd module, behavior change, no new API | "The date formatter returns the wrong month off-by-one" | **T2** |
   | New behavior, new endpoint, multiple modules, no spec yet | "Add password-reset via email" | **T3** |
   | Many files, zero behavior change, mechanical (wide-shallow) | "Rename `getUser` to `fetchUser` everywhere" | **T2** |

   Observable result: the matched row (or the closest analogue) named in the chain-of-thought.

3. **State the chain-of-thought as a one-paragraph summary** keyed to the signals from Step 1 and the matched row from Step 2. Observable result: a 2–4-sentence rationale printed back to the human.

4. **Propose tier + rationale to the human and stop.** Output format:
   ```
   Proposed tier: T<N>
   Rationale: <2–4 sentences>
   Confirm? (y / n / override to T<other>)
   ```
   Observable result: the proposal is on screen; control returns to the human; no downstream skill has fired.

5. **On confirm, hand off** per tier:
   - **T1** — return control to the agent for a direct single-pass response. `ground-rules` still applies.
   - **T2** — invoke `lsa-discover` for the light three-question probe.
   - **T3** — invoke `lsa-discover` first, then `lsa-specify`. (Extension to `vision/VISION.md:120`: Vision's T3 loop is "specify → plan → implement → verify → sync"; v0.2.0 puts `lsa-discover` upfront so the light Q&A is universal across T2 and T3.)

   Observable result: the named downstream skill is invoked, or — for T1 — direct response begins.

## Output

A tier label (`T1` / `T2` / `T3`) and a 2–4-sentence rationale. Human-readable. Confirmed before any downstream LSA skill fires.

## Constraints

- Do not start LSA ceremony before tier confirmation. No `lsa-discover`, `lsa-specify`, or any other skill fires until the human responds.
- Do not invent boundary signals that are not actually present in the task description. If the task does not mention an API change, do not assume one.
- Do not silently choose a higher tier than the human picks. If the human overrides downward, log the override in the rationale and proceed at the human's tier.

---

On confirm, downstream LSA skills absorb the tier into their own gates. Every output still obeys `ground-rules`.
