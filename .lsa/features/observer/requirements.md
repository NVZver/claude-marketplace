# Feature: observer — live observe-and-coach

## Summary
A new `observer` plugin (deps: core) that rides Claude Code's self-paced `/loop`
and reacts to the user's file changes through a chosen ROLE. One Actor skill
(`observe`) reads role behavior as data from one Knowledge file (`roles.md`);
roles are rubber-duck, pair-programmer, interviewer, custom.

## User Flows
| Flow | Success | I/O | Scenario |
|------|---------|-----|----------|
| F1 Kickoff | a role is confirmed, then observing begins | optional role/lang/topic → confirmed role | kickoff.feature |
| F2 Scaffold (interviewer) | a runnable, initially-failing exercise exists | lang+topic → exercise file | scaffold.feature |
| F3 Observe cycle | role-appropriate feedback (or silence) per change | file changes → feedback | observe.feature |
| F4 Role-switch | later feedback follows the new role, no restart | switch request → new active role | role-switch.feature |
| F5 Stop | loop ends with a stated reason | stop trigger → ended loop + reason | stop.feature |

## Functional Requirements (EARS)

### Kickoff
- F1.1 When the user starts `observe` without naming a role, the system shall
  infer a candidate role from the working context and propose it for confirmation.
- F1.2 When the user starts `observe` naming a role, the system shall adopt that
  role without proposing an alternative.
- F1.3 Where a proposed role is rejected, the system shall offer the role set
  (rubber-duck, pair-programmer, interviewer, custom) for selection.
- F1.4 When the selected role is custom, the system shall require a one-line
  lens/voice description before observing.
- F1.5 If no role is confirmed, then the system shall not begin observing.

### Scaffold
- F2.1 While the confirmed role is interviewer, when the user provides a language
  and topic, the system shall generate an exercise comprising a problem
  statement, a function placeholder, and a test suite that fails when first run.
- F2.2 Where language or topic is missing for an interviewer session, the system
  shall request them before generating the exercise.
- F2.3 If the confirmed role is not interviewer, then the system shall not
  generate an exercise.

### Observe cycle
- F3.1 When an observation cycle fires, the system shall read the changes since
  the previous cycle and emit feedback consistent with the active role's lens,
  voice, and cadence.
- F3.2 While the active role's cadence is quiet (pair-programmer), when the
  changes hold no genuine catch, the system shall emit nothing that cycle —
  zero user-facing output: no text, marker, placeholder, or narration of the
  silence.
- F3.3 While the active role is pair-programmer, when evaluating changes, the
  system shall consult the wider project (existing dependencies and prior code)
  before reporting a reuse or simplification catch.
- F3.4 While the active role is interviewer, when emitting feedback, the system
  shall order findings solution → bugs → performance → style (solution = wrong
  approach; bugs = defect within a right approach; performance = suboptimal
  complexity; style = readability), naming a level only when it has a catch, and
  present each as a non-breaking explanation that gives the DIRECTION of a safer
  alternative, not the corrected code.
- F3.5 While the active role is interviewer, the system shall track the user's
  progress across cycles, lower exercise difficulty when the user is persistently
  stuck, and rebuild it once the user is unblocked.

### Role-switch
- F4.1 When the user requests a different role during a session, the system shall
  apply the new role's lens/voice/cadence on the next cycle without restarting
  the loop.

### Stop
- F5.1 When the user requests stop, the system shall end the observation loop.
- F5.2 When the session is self-determined over, or inactivity exceeds the
  timeout, the system shall end the loop and report why it stopped.

## Out of Scope / Design constraints (not mechanism in requirements)
- Substrate-native: rides the existing self-paced `/loop`; does NOT implement its
  own scheduler (VISION.md:66, principle 9).
- SoC invariant: all role lens/voice/cadence lives in `roles.md` (Knowledge);
  `observe` (Actor) reads it, never hard-codes per-role branches (VISION.md:61).
- No file-watch daemon in v1 — polling via /loop cycles is the mechanism.
- Ships a behavioral test suite (`observer/tests/`): per-role probes exercised by
  an adversarial generate→judge eval (see `observer/tests/eval-findings-2026-06-27.md`).
  Verification scaffolding, not runtime behavior.
