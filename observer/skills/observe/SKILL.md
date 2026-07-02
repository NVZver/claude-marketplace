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
- An optional inactivity-limit override (default: 2 consecutive no-change `/loop` cycles — see Step 10).
- The role bundles (lens / voice / cadence / difficulty data) from [`../../knowledge/roles.md`](../../knowledge/roles.md).

## Steps

1. **Kickoff — read the context and check for a named role** (F1.2). Read the working context (current directory, open/recent files, language, test state). If the user named a role, adopt it without proposing an alternative (F1.2) and continue at Step 4. Observable result: either an adopted role, or the read context handed to Step 2.

2. **Kickoff — infer one candidate role from the signal→role map** (F1.1). Match the working context against this table, top-down; take the first row whose signal holds:

   | Signal (observable in the working context) | Inferred role |
   |---|---|
   | The user named a role | that role (adopted in Step 1 — no inference) |
   | Failing tests plus a stub / TODO / unimplemented target | interviewer |
   | Feature-in-progress edits to working code, with tests present | pair-programmer |
   | Exploratory work — reasoning aloud, no tests in play | rubber-duck |

   State only the one-line reason for the inferred role (the matched signal); do not diagnose bugs or name fixes before a role is confirmed. Observable result: one named candidate role plus its one-line matched-signal reason, and no feedback emitted yet.

3. **Kickoff — propose the candidate for confirmation** (F1.1, F1.3, F1.5). Propose the inferred role via `AskUserQuestion`, offering the full role set (rubber-duck, pair-programmer, interviewer, custom) as the override options. Observable result: a single confirmed role, or — if the user confirms nothing — no session started and observing does not begin (F1.5).

4. **Custom-role lens gate** (F1.4). If the confirmed role is custom and no one-line lens/voice description was supplied, request one via `AskUserQuestion` before continuing. Observable result: a one-line custom lens/voice string captured; for non-custom roles this step is a no-op.

5. **Write session-state note** (carries mutable state across stateless `/loop` wakes — grounding design note). `Write` a small session-state note (scratchpad file) recording the active role, the custom lens line if any, the interviewer difficulty level (start: baseline), the inactivity limit (default or the kickoff override — Step 10), and a last-cycle marker (timestamp / change cursor). The `/loop` re-fires the same prompt each wake and does not remember state, so this note is the source of truth re-read every cycle. Observable result: a session-state file exists on disk with the active role and difficulty recorded.

6. **Scaffold an interviewer exercise — conditional** (F2.1–F2.3). Read the active role from the session-state note. If it is interviewer: if language or topic is missing, request them via `AskUserQuestion` first (F2.2); then `Write` an exercise file comprising a problem statement, a function placeholder, and a runnable test suite, and confirm it **fails on first run** (F2.1). If the active role is not interviewer, generate no exercise even if asked (F2.3): decline, state the reason (scaffolding is interviewer-only), and offer a switch to interviewer via `AskUserQuestion`; if the user switches, record the new role in the session-state note and fall through to this step's language/topic gate (F2.2) before scaffolding. Observable result: for interviewer, an exercise file exists and its test suite is red on first run; for any other role, no exercise file is written and any scaffold request got a decline plus a switch offer.

7. **Start the observe loop** (F3.1). Start the substrate's self-paced `/loop` (omit the interval). Do not build a scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9). Observable result: a self-paced `/loop` is running with this Actor as its per-cycle prompt.

8. **Per cycle — read changes, apply the active role's bundle** (F3.1–F3.5). On each wake: (a) re-read the session-state note to recover the active role + difficulty; (b) read the file changes since the last-cycle marker; (c) read that role's bundle from [`../../knowledge/roles.md`](../../knowledge/roles.md) and apply its lens (in the bundle's order), voice, and cadence **generically** — this Actor selects no behavior inline; (d) emit feedback, or stay silent when the bundle's cadence is quiet and the changes hold no genuine catch — silence per [`../../knowledge/roles.md`](../../knowledge/roles.md) §"Silence — the zero-output rule". A silent cycle produces zero output and simply ends after step (e); (e) update the last-cycle marker (and, for interviewer, the difficulty level) in the session-state note per the bundle's difficulty rules. Observable result: each cycle either emits feedback shaped by the active bundle or emits nothing, and the session-state note's last-cycle marker (and interviewer difficulty) is updated. The bundle drives whether pair-programmer stays silent (F3.2), whether it consults the wider project before flagging (F3.3), the interviewer's solution→bugs→performance→style ordering with non-breaking safer-alternative phrasing (F3.4), and the interviewer's cross-cycle difficulty adaptation (F3.5).

9. **Role-switch mid-session** (F4.1). When the user requests a different role during the session, update the active role (and custom lens, if custom) in the session-state note; the change takes effect on the next cycle, which reads the new bundle. Do not restart the loop. Observable result: the session-state note records the new active role and the next cycle's feedback follows the new bundle with no loop restart.

10. **Stop** (F5.1–F5.2). End the `/loop` when the user requests stop (F5.1), when the session is self-determined over, or when inactivity reaches the **inactivity limit** (F5.2): **2 consecutive `/loop` cycles with no file changes** since the last-cycle marker — cycle-based because the loop is self-paced (no wall clock). That is the default; the escape hatch is a user override at kickoff (e.g. "keep watching for 5 quiet cycles"), recorded in the session-state note and read from there. On stop, report the reason. Observable result: the loop is ended and a one-line stop reason is reported (user request, concluded, or inactivity limit reached — with the cycle count).

## Output

A live observe session: a confirmed role and (for interviewer) a red exercise file at kickoff; per-cycle feedback or silence shaped by the active role's bundle; on role-switch the next cycle follows the new bundle without a restart; on stop the loop ends with a stated reason. The session-state note is the persistent record of active role + interviewer difficulty across cycles.

## Example Output

[illustrative]

```
=============== [observer/skills/observe/SKILL.md] [observer] ===============

Kickoff — context: a Python file with a `# TODO` stub and a failing pytest, no role named.
Inferred: interviewer — signal matched: failing tests plus a stub.
Proposed role: interviewer (override: rubber-duck / pair-programmer / custom) > confirmed
Language/topic? > Python / binary search
Wrote exercise: scratchpad/exercise_binary_search.py + test — 3 tests RED on first run.
Session-state: role=interviewer difficulty=baseline (scratchpad/observe-state.md)

[loop started — self-paced]

cycle 1 — change: implemented bisect loop.
  bugs: off-by-one — `hi = mid` re-tests a midpoint you've already excluded (the
  approach is right; this is a defect within it). Safer direction: move the bound that
  excludes the checked midpoint — which bound, and by how much? (you write the line).
cycle 2 — no file changes since the last-cycle marker (1st consecutive quiet cycle).
cycle 3 — no file changes (2nd consecutive — inactivity limit reached).

Stopped: inactivity limit (2 consecutive no-change /loop cycles — default; overridable at kickoff).
```

## Constraints

- **No per-role branch logic.** This Actor never hard-codes a role's lens/voice/cadence or difficulty thresholds inline — it reads the active bundle from [`../../knowledge/roles.md`](../../knowledge/roles.md) and applies it generically (SoC invariant, [`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 4).
- **No scheduler.** Ride the substrate's self-paced `/loop`; do not implement polling, timers, or a wake scheduler ([`../../../.lsa/VISION.md`](../../../.lsa/VISION.md) principle 9).
- **No observing without a confirmed role** (F1.5). Kickoff must resolve to one confirmed role before Step 7, and pre-confirmation output is bounded to the one-line matched-signal reason (Step 2) — no diagnosing bugs or naming fixes before the role is confirmed.
- **Scaffold is interviewer-only** (F2.3). Never write an exercise in a non-interviewer role.
- **State lives in the session-state note, not in loop memory.** The `/loop` is stateless between wakes; the active role and interviewer difficulty are re-read from the note each cycle and written back on change.
- **Non-destructive feedback.** Emit feedback as explanation; do not edit the user's working files to "fix" them. In the interviewer role, state the gotcha and the *direction* of a safer alternative — do not write the corrected code or a copy-paste-ready fix line; the candidate must still write it.
- Outputs follow [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) — citation by link, never restated; trace line on load.
