# Feature: Checkpoint verification of an implementer increment (`observer:verify-checkpoint`)
Epic: paired-verify/observer-verifier · Parent: [paired-verify](../../pitches/paired-verify.md) · Module: observer

## Grounding
- Increment = an implementer's changes for ONE F-requirement, read as "changes since a marker"
  (reuses observe's pattern, `observer/skills/observe/SKILL.md:37`).
- does·only = two of reconcile's three checks (`lsa/skills/reconcile/SKILL.md:30-34`); the third
  ("all"/completeness) is deferred to the final reconcile (`lsa/skills/reconcile/SKILL.md:33`).
- Checkpoint signal = the record the implementer emits on pause, declaring it finished F-K
  (contract defined here; the writer ships in epic `paired-verify/lsa-delegate-wiring`).

## User flow: grade-one-increment
- Flow: /loop cycle → detect checkpoint signal → read increment + target requirement → grade
  does·only → emit verdict.
- Success: conformant → CLEAR (auto, no human interrupt); drift → BLOCK, surfaced to the human
  before the next task.
- I/O: in = checkpoint signal (target F-id + pause marker), increment diff, the spec (requirements
  + scoped scenarios), ground-rules. out = a CLEAR|BLOCK verdict citing the failing check, in a
  context the implementer could not author.
- Test: synthetic increments — seeded-drift → BLOCK; conformant → CLEAR.

## Behavioral requirements (scenario-backed)
- F1 (Identity). The system shall provide a skill `observer:verify-checkpoint`, distinct from
  `observe`, whose surface states it is NOT `lsa:verify` (the before-delegation grounding check).
- F2 (Substrate-native). While a session is active, the system shall ride the self-paced /loop and
  shall not implement a scheduler, timer, or poll (`.lsa/modules/observer/spec.md` Invariants,
  Substrate-native).
- F3 (Signal detection). When a /loop cycle begins, the system shall check for a checkpoint signal
  indicating the implementer paused having completed a specific F-requirement.
- F4 (No-signal no-op). If no checkpoint signal is present in a cycle, then the system shall
  produce no verdict and no user-facing output that cycle (mirrors observe's silence discipline,
  `observer/skills/observe/SKILL.md` step 6).
- F5 (Increment scoping). When a signal is present, the system shall identify the target
  F-requirement it names and scope grading to the changes since the previous checkpoint marker.
- F6 (does — scoped). When grading, the system shall run the acceptance scenarios mapped to the
  target F-requirement and treat scenarios of not-yet-built requirements as out of scope for this
  increment (`lsa/skills/reconcile/SKILL.md:31`).
- F7 (only). When grading, the system shall verify every changed hunk traces to a requirement and
  flag any untraced hunk as over-delivery (`lsa/skills/reconcile/SKILL.md:32`).
- F8 (no all). The system shall NOT apply a whole-plan completeness check per increment;
  completeness remains the final reconcile's responsibility (`lsa/skills/reconcile/SKILL.md:33`).
- F9 (Clear). If an increment passes does AND only, then the system shall emit a CLEAR verdict that
  auto-clears the boundary without interrupting the human.
- F10 (Block). If an increment fails does OR only, then the system shall emit a BLOCK verdict
  naming the failing check and surface it to the human before the next task begins.
- F11 (Independence/read-only). While grading, the system shall not write to the artifacts it
  grades (tests, `.feature` scenarios, `.lsa.yaml` `gate:` config); the verdict shall be an
  artifact the implementer could not author (`lsa/skills/reconcile/SKILL.md:44-45`).
- F12 (Gate voice). The system shall phrase verdicts as clear/block with a cited reason, not the
  coaching voice of observe's roles.
- F13 (Separation). The system shall not read or modify `observer/knowledge/roles.md`; its behavior
  is independent of observe's role bundles.

## Non-scenario requirements (reconcile checks these too)
- F14 (Version). observer `plugin.json` shall bump 0.1.1 → 0.2.0 with a CHANGELOG entry in the same
  commit as the new skill (new skill = minor).
- F15 (README). `observer/README.md` shall gain a verify-checkpoint row with the `lsa:verify`
  disambiguation, same commit.
- F16 (Evals). Adversarial assertions shall exist under `observer/tests/` covering seeded-drift →
  BLOCK and conformant → CLEAR, alongside `observer/tests/scenarios.md`.
- F17 (Module spec). `.lsa/modules/observer/spec.md` shall be updated to a two-Actor description
  (observe + verify-checkpoint) and its stale `v0.1.0` header corrected.
