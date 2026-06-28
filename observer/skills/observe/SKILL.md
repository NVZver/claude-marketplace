---
name: observe
description: "Start a live observe-and-coach session that rides Claude Code's self-paced /loop and reacts to your file changes through a chosen role. Use when the user says observe me / watch me code / rubber-duck this / pair with me / interview me, or asks for live feedback while they work. Confirms a role first (rubber-duck, pair-programmer, interviewer, custom), optionally scaffolds an interviewer exercise, then emits role-appropriate feedback (or silence) each cycle until stopped. Reads all per-role lens/voice/cadence as data from observer/knowledge/roles.md — never hard-codes role behavior."
---

> **Trace.** On load, print first: `=============== [observer/skills/observe/SKILL.md] [observer] ===============`


# Observe

Orchestrator Actor. Rides the substrate's self-paced `/loop` (omit the interval to self-pace) and, on each wake, reads the file changes since the previous cycle and emits feedback through the **active role**. All role behavior — lens, voice, cadence, difficulty rules — is **data read from** [`../../knowledge/roles.md`](../../knowledge/roles.md); this Actor applies whichever bundle is active generically and contains no per-role branch logic. It rides the existing `/loop`; it does not build a scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9, *Substrate-native first*).

## Goal

From a confirmed role, run a live observe-and-coach session over the user's working changes — emitting feedback that matches the active role's lens/voice/cadence each `/loop` cycle — until a stop trigger ends the loop with a stated reason.

## Input

- The working context (current directory, open/recent files, language). Used to infer a candidate role.
- An optional role named by the user (rubber-duck, pair-programmer, interviewer, custom).
- For a custom role: a one-line lens/voice description.
- For an interviewer role: a target language and topic for the exercise.
- The role bundles (lens / voice / cadence / difficulty data) from [`../../knowledge/roles.md`](../../knowledge/roles.md).

## Steps

1. **Kickoff — confirm a role before observing** (F1.1–F1.3, F1.5). Read the working context. If the user named a role, adopt it without proposing an alternative (F1.2). Otherwise infer one candidate role from context and propose it via `AskUserQuestion`, offering the full role set (rubber-duck, pair-programmer, interviewer, custom) as the override options (F1.1, F1.3). Observable result: a single confirmed role, or — if the user confirms nothing — no session started and observing does not begin (F1.5).

2. **Custom-role lens gate** (F1.4). If the confirmed role is custom and no one-line lens/voice description was supplied, request one via `AskUserQuestion` before continuing. Observable result: a one-line custom lens/voice string captured; for non-custom roles this step is a no-op.

3. **Write session-state note** (carries mutable state across stateless `/loop` wakes — grounding design note). `Write` a small session-state note (scratchpad file) recording the active role, the custom lens line if any, the interviewer difficulty level (start: baseline), and a last-cycle marker (timestamp / change cursor). The `/loop` re-fires the same prompt each wake and does not remember state, so this note is the source of truth re-read every cycle. Observable result: a session-state file exists on disk with the active role and difficulty recorded.

4. **Scaffold an interviewer exercise — conditional** (F2.1–F2.3). Read the active role from the session-state note. If it is interviewer: if language or topic is missing, request them via `AskUserQuestion` first (F2.2); then `Write` an exercise file comprising a problem statement, a function placeholder, and a runnable test suite, and confirm it **fails on first run** (F2.1). If the active role is not interviewer, generate no exercise even if asked (F2.3). Observable result: for interviewer, an exercise file exists and its test suite is red on first run; for any other role, no exercise file is written.

5. **Start the observe loop** (F3.1). Start the substrate's self-paced `/loop` (omit the interval). Do not build a scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9). Observable result: a self-paced `/loop` is running with this Actor as its per-cycle prompt.

6. **Per cycle — read changes, apply the active role's bundle** (F3.1–F3.5). On each wake: (a) re-read the session-state note to recover the active role + difficulty; (b) read the file changes since the last-cycle marker; (c) read that role's bundle from [`../../knowledge/roles.md`](../../knowledge/roles.md) and apply its lens (in the bundle's order), voice, and cadence **generically** — this Actor selects no behavior inline; (d) emit feedback, or stay silent when the bundle's cadence is quiet and the changes hold no genuine catch — silence means producing NO user-facing text for that cycle: no marker, token, placeholder, status line, or parenthetical (such as "<SILENT>", "no catch", or "(empty)"), and no narration of the decision to stay silent. A silent cycle produces zero output and simply ends after step (e); (e) update the last-cycle marker (and, for interviewer, the difficulty level) in the session-state note per the bundle's difficulty rules. Observable result: each cycle either emits feedback shaped by the active bundle or emits nothing, and the session-state note's last-cycle marker (and interviewer difficulty) is updated. The bundle drives whether pair-programmer stays silent (F3.2), whether it consults the wider project before flagging (F3.3), the interviewer's solution→bugs→performance→style ordering with non-breaking safer-alternative phrasing (F3.4), and the interviewer's cross-cycle difficulty adaptation (F3.5).

7. **Role-switch mid-session** (F4.1). When the user requests a different role during the session, update the active role (and custom lens, if custom) in the session-state note; the change takes effect on the next cycle, which reads the new bundle. Do not restart the loop. Observable result: the session-state note records the new active role and the next cycle's feedback follows the new bundle with no loop restart.

8. **Stop** (F5.1–F5.2). End the `/loop` when the user requests stop (F5.1), when the session is self-determined over, or when inactivity exceeds the timeout (F5.2). On stop, report the reason. Observable result: the loop is ended and a one-line stop reason is reported (user request, concluded, or inactivity timeout).

## Output

A live observe session: a confirmed role and (for interviewer) a red exercise file at kickoff; per-cycle feedback or silence shaped by the active role's bundle; on role-switch the next cycle follows the new bundle without a restart; on stop the loop ends with a stated reason. The session-state note is the persistent record of active role + interviewer difficulty across cycles.

## Example Output

[illustrative]

```
=============== [observer/skills/observe/SKILL.md] [observer] ===============

Kickoff — context: a Python file with failing pytest, no role named.
Proposed role: pair-programmer (override: rubber-duck / interviewer / custom) > interviewer
Language/topic? > Python / binary search
Wrote exercise: scratchpad/exercise_binary_search.py + test — 3 tests RED on first run.
Session-state: role=interviewer difficulty=baseline (scratchpad/observe-state.md)

[loop started — self-paced]

cycle 1 — change: implemented bisect loop.
  bugs: off-by-one — `hi = mid` re-tests a midpoint you've already excluded (the
  approach is right; this is a defect within it). Safer direction: move the bound that
  excludes the checked midpoint — which bound, and by how much? (you write the line).
cycle 2 — no edits for the inactivity timeout.

Stopped: inactivity timeout (no changes for the configured window).
```

## Constraints

- **No per-role branch logic.** This Actor never hard-codes a role's lens/voice/cadence or difficulty thresholds inline — it reads the active bundle from [`../../knowledge/roles.md`](../../knowledge/roles.md) and applies it generically (SoC invariant, [`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 4).
- **No scheduler.** Ride the substrate's self-paced `/loop`; do not implement polling, timers, or a wake scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9).
- **No observing without a confirmed role** (F1.5). Kickoff must resolve to one confirmed role before Step 5.
- **Scaffold is interviewer-only** (F2.3). Never write an exercise in a non-interviewer role.
- **State lives in the session-state note, not in loop memory.** The `/loop` is stateless between wakes; the active role and interviewer difficulty are re-read from the note each cycle and written back on change.
- **Non-destructive feedback.** Emit feedback as explanation; do not edit the user's working files to "fix" them. In the interviewer role, state the gotcha and the *direction* of a safer alternative — do not write the corrected code or a copy-paste-ready fix line; the candidate must still write it.
- Outputs follow [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) — citation by link, never restated; trace line on load.
