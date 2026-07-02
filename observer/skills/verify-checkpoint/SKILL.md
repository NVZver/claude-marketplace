---
name: verify-checkpoint
description: "Grade ONE signalled increment as a gate — in either of two invocation modes with identical grading: per-increment dispatch (how lsa:delegate drives it) or a standalone self-paced /loop rider. On a checkpoint signal an implementer emits when it pauses having finished one F-requirement, grade that increment does·only — do the scenarios mapped to the target F pass, and does every changed hunk trace to a requirement. Pass both → CLEAR (auto, no human interrupt); fail either → BLOCK naming the failing check, surfaced to the human before the next task. Read-only to the artifacts it grades. NOT lsa:verify (that is the before-delegation grounding check); this is per-increment, after the implementer's changes."
---

> **Trace.** On load, print first: `=============== [observer/skills/verify-checkpoint/SKILL.md] [observer] ===============`


# Verify Checkpoint

Grader Actor — the second Actor in the `observer` module, sibling to [`observe`](../observe/SKILL.md). Where `observe` coaches through a role, this Actor **gates**. Its core unit of work is **grading one signalled increment**: on a **checkpoint signal** an implementer emits when it pauses having completed one F-requirement, it grades that single increment against the spec on two of reconcile's three checks — **does · only** — and emits a CLEAR or BLOCK verdict.

That grading logic is the spine, and it is **identical across two invocation modes** — the mode is only the entry point:

- **(a) Per-increment dispatch** (first-class) — the delegating context ([`lsa:delegate`](../../../lsa/skills/delegate/SKILL.md)) dispatches this Actor once per signalled increment via the `Agent` tool; the Actor grades that one increment and returns the verdict. No loop is started.
- **(b) Standalone `/loop` rider** — this Actor rides the substrate's self-paced `/loop` (omit the interval to self-pace) and, on each wake, checks for a checkpoint signal, grading each signalled increment as it wakes.

In `/loop` mode it rides the existing loop; it does not build a scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9, *Substrate-native first*).

This is **not** `lsa:verify`. `lsa:verify` is the *before*-delegation grounding check (is the spec ready to hand to an implementer). This Actor is an *after*-the-increment check (did the increment the implementer just finished conform), scoped to one F-requirement — the per-increment analogue of `lsa:reconcile`, which grades the whole plan at the end. It applies **does · only** only; the third check, **all** (whole-plan completeness), stays with the final `lsa:reconcile` ([`../../../lsa/skills/reconcile/SKILL.md:34`](../../../lsa/skills/reconcile/SKILL.md)).

## The checkpoint-signal contract

This Actor **reads** the signal; it does not write it. The writer ships in epic `paired-verify/lsa-delegate-wiring`. This section defines the contract that epic must satisfy so the two halves interlock.

A **checkpoint signal** is a small note the implementer emits when it pauses, declaring "I finished F-K." It mirrors `observe`'s session-state-note pattern (a scratchpad file re-read each cycle, because `/loop` is stateless between wakes — [`../observe/SKILL.md:31`](../observe/SKILL.md)). The note is the single source of truth this Actor re-reads every cycle. Its required fields:

| Field | Meaning | Used by |
|---|---|---|
| `target` | The F-id the increment claims to complete (e.g., `F-K`), matching an id in the spec's `requirements.md`. | F5 (scoping), F6 (scenario selection) |
| `since` | The previous checkpoint marker (a commit SHA, change cursor, or timestamp) that bounds "changes since the last checkpoint." | F5 (increment boundary) |
| `spec` | Path to the spec dir — `requirements.md` (the F-list) + the `<flow>.feature` scenarios (each annotated with its `# F…` numbers). | F6 (does), F7 (only) |
| `status` | A pause marker meaning "implementer stopped, awaiting a verdict" (present ⇒ a signal this cycle; absent ⇒ no signal). | F3 (detection), F4 (no-op) |

Absent a note, or a note whose `status` is not the pause marker, **there is no signal this cycle** (F3/F4). The `# F…` annotations already carried by each scenario in the `.feature` file are the F-requirement → scenario map (per [grounding.md](../../../.lsa/features/2026-07-01-paired-verify-observer-verifier/grounding.md) reference map) — no separate map is authored.

**The note's file PATH is owned by the delegating context, not fixed by this Actor.** The four fields above are the note's *contents*; the *location* of the note is supplied from outside. When `lsa:delegate` drives per-increment dispatch, it OWNS the checkpoint-signal note path and passes the SAME path to both the implementer (the **writer**) and this Actor (the **reader**) at dispatch — so both halves read and write one file ([`../../../lsa/skills/delegate/SKILL.md`](../../../lsa/skills/delegate/SKILL.md) Steps 4–5). The path is **ephemeral** — a scratchpad / gitignored location — and is **NOT committed**. In standalone `/loop` mode the same shared path is supplied at loop start. The path locates the note; the four fields are unchanged by it.

## Goal

Grade one signalled increment does·only against its target F-requirement — whether the increment is dispatched per-increment by the delegating context or detected on a self-paced `/loop` cycle — emitting an independent CLEAR verdict that auto-clears the boundary, or a BLOCK verdict naming the failing check and surfaced to the human before the next task — while writing nothing to the artifacts it grades.

## Input

- The checkpoint signal note (fields above) at the path the delegating context provides, if one is present. In `/loop` mode, re-read it every cycle; it is the source of truth across stateless wakes.
- The increment: the file changes since the note's `since` marker (F5).
- The spec named by the note: `requirements.md` (the F-list) and the `<flow>.feature` scenarios, each annotated with its `# F…` numbers (F6, F7).
- `core/ground-rules` (fact-grounding: every cited reason carries a source) and `core/output` (verdict format discipline).

## Steps

1. **Enter via one of two invocation modes** (F2). The core unit is grading one signalled increment; the mode is only the entry point. **Per-increment dispatch:** the delegating context ([`lsa:delegate`](../../../lsa/skills/delegate/SKILL.md)) dispatches this Actor once for a single signalled increment — grade it (Steps 2–7) and return the verdict; no loop is started. **Standalone `/loop` rider:** start the substrate's self-paced `/loop` (omit the interval) with this Actor as its per-cycle prompt and grade each signalled increment as it wakes. In either mode, do not build a scheduler, timer, or poll ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9). Observable result: either a single dispatched grading of one increment, or a self-paced `/loop` running with this Actor as its per-cycle prompt.

2. **Detect a checkpoint signal** (F3, F4). On each wake (loop mode) or on the dispatched increment (dispatch mode), look for the checkpoint-signal note at the path the delegating context provided and read its `status`. If no note is present, or `status` is not the pause marker, this cycle has **no signal**: produce no verdict and no user-facing output — silence means NO user-facing text (no marker, token, placeholder, status line, or parenthetical such as `<no-signal>` or `(idle)`), and no narration of the decision to stay silent. A no-signal cycle produces zero output and ends here (mirrors `observe`'s silence discipline, [`../observe/SKILL.md:37`](../observe/SKILL.md) step 6d). Observable result: on a signal-less cycle, zero output; otherwise, continue to Step 3.

3. **Scope the increment** (F5). Read the note's `target` (the F-id) and `since` marker. Scope grading to exactly the changes between `since` and the current state — the increment for this one F-requirement. Do not read changes outside that window. Observable result: the target F-id is named and the changed-hunk set for the increment is bounded by `since`.

4. **Grade "does" — scoped** (F6). Select from the `<flow>.feature` the scenarios annotated with the target F-id (its `# F…` numbers). Run each **as reasoning** against the increment — the same execution-as-reasoning model `lsa:reconcile` uses ("run each Gherkin scenario", [`../../../lsa/skills/reconcile/SKILL.md:32`](../../../lsa/skills/reconcile/SKILL.md)); this module carries no test-runner harness. Treat scenarios of not-yet-built requirements as **out of scope** for this increment — a requirement after the target is not under-delivery here ([`../../../lsa/skills/reconcile/SKILL.md:32`](../../../lsa/skills/reconcile/SKILL.md)). Observable result: a does result — each target-scoped scenario marked pass or fail, with the failing scenario named if any.

5. **Grade "only"** (F7). Verify every changed hunk in the increment traces to a requirement. A hunk that traces to no requirement is **over-delivery** ([`../../../lsa/skills/reconcile/SKILL.md:33`](../../../lsa/skills/reconcile/SKILL.md)). Observable result: an only result — each changed hunk mapped to its requirement, with any untraced hunk named as over-delivery.

6. **Do NOT grade "all"** (F8). Apply no whole-plan completeness check this cycle. That every requirement in the plan maps to a change is the final `lsa:reconcile`'s responsibility ([`../../../lsa/skills/reconcile/SKILL.md:34`](../../../lsa/skills/reconcile/SKILL.md)), not this per-increment grader's. Observable result: no requirement outside the target F is flagged as missing, and the verdict depends only on Steps 4–5.

7. **Emit the verdict** (F9, F10, F11, F12). Combine does and only:
   - **Both pass → CLEAR.** Emit a CLEAR verdict; the boundary auto-clears without interrupting the human — no picker, no question, no wait (F9). Record it as an artifact (a written verdict line), not merely inline pre-tool-call text.
   - **Either fails → BLOCK.** Emit a BLOCK verdict that names the failing check (does or only) and the specific failing scenario or untraced hunk, with a cited reason (F10, F12). Surface it to the human before the next task begins — a BLOCK is turn-final delivery, not buried in a subagent transcript (per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 *Delivery test*).

   Phrase both in **gate voice** — `CLEAR` / `BLOCK` plus a cited reason — not the coaching voice of `observe`'s roles (F12). Do not write to the graded artifacts (tests, `.feature` scenarios, `.lsa.yaml` `gate:` config); the verdict is an artifact the implementer could not author ([`../../../lsa/skills/reconcile/SKILL.md:44-45`](../../../lsa/skills/reconcile/SKILL.md)) (F11). Observable result: one `CLEAR` or `BLOCK` verdict line naming the checks it graded and the target F-id, emitted as a distinct artifact; graded files unchanged.

## Output

Per cycle: either nothing (no signal, F4) or one gate verdict for the signalled increment — `CLEAR @ <target-F> (does·only)` that auto-clears the boundary, or `BLOCK @ <target-F> — <does|only>: <named failing scenario or untraced hunk>` surfaced to the human before the next task. The verdict is a written artifact in a context the implementer could not author; the graded artifacts (tests, `.feature`, `.lsa.yaml` `gate:`) are never modified.

## Example Output

[illustrative]

```
=============== [observer/skills/verify-checkpoint/SKILL.md] [observer] ===============

[loop started — self-paced]

cycle 1 — no checkpoint signal (no note / status not paused).
cycle 2 — signal: target=F7, since=3aa8147, spec=.lsa/features/…/
  does — F7 scenarios (# F7,F10): scope-creep-blocks → pass. (in scope)
  only — 4 hunks; hunk 3 (observer/knowledge/roles.md edit) traces to no requirement.
  BLOCK @ F7 — only: untraced hunk observer/knowledge/roles.md = over-delivery.
  [surfaced to human before next task]
cycle 3 — signal: target=F7, since=3aa8147 (re-graded after fix)
  does — F7 scenarios: pass.  only — all 3 hunks trace to F7.
  CLEAR @ F7 (does·only). [boundary auto-cleared, no interrupt]
```

## Constraints

- **Not `lsa:verify`.** This is the after-increment gate scoped to one F-requirement (the per-increment analogue of `lsa:reconcile`), never the before-delegation grounding check. State this on the surface (F1).
- **does·only only — never all.** Apply the does and only checks; never apply the whole-plan completeness ("all") check per increment — that stays with the final `lsa:reconcile` ([`../../../lsa/skills/reconcile/SKILL.md:34`](../../../lsa/skills/reconcile/SKILL.md)) (F8).
- **Not-yet-built is out of scope.** A requirement after the target F is not under-delivery for this increment; do not flag it (F6, F8).
- **Two invocation modes, one grading spine.** The core unit is grading one signalled increment; it runs via per-increment dispatch (how `lsa:delegate` drives it) or as a standalone self-paced `/loop` rider, with identical grading logic (F2).
- **No scheduler.** In `/loop` mode, ride the substrate's self-paced `/loop`; implement no polling, timer, or wake scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9) (F2).
- **Silence on no signal.** A signal-less cycle produces zero user-facing output — no marker, token, placeholder, status line, parenthetical, or narration (mirrors [`../observe/SKILL.md:37`](../observe/SKILL.md) step 6d) (F4).
- **Independent, read-only grader.** Never write to the artifacts graded — tests, acceptance `.feature` scenarios, `.lsa.yaml` `gate:` config. The verdict lands as a distinct artifact the implementer could not author ([`../../../lsa/skills/reconcile/SKILL.md:44-45`](../../../lsa/skills/reconcile/SKILL.md)) (F11).
- **Gate voice, cited.** Verdicts are `CLEAR` / `BLOCK` with a source-cited reason, not `observe`'s coaching voice (F12).
- **Separation from `observe`.** Do not read or modify [`../../knowledge/roles.md`](../../knowledge/roles.md); this Actor's behavior is independent of `observe`'s role bundles (F13).
- Outputs follow [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) — citation by link, never restated; trace line on load.
