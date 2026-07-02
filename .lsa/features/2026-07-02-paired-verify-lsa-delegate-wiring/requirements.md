# Feature: Checkpoint-mode delegation wiring (`lsa:delegate` paired_verify)
Epic: paired-verify/lsa-delegate-wiring · Parent: [paired-verify](../../pitches/paired-verify.md) · Module: lsa

## Grounding
- Signal contract (reader): `observer/skills/verify-checkpoint/SKILL.md:22-37` — fields target/since/spec/status + delegate-owned shared note path.
- delegate today: `lsa/skills/delegate/SKILL.md` (package → dispatch → await).
- schema pattern: `lsa/ARCHITECTURE.md:79-120` (`gate:` / `autonomy:`); defaults in `lsa/knowledge/conventions.md`.

## User flow: delegate-with-paired-verify
- Flow: read `.lsa.yaml` `paired_verify` → off: unchanged; checkpoint: inject pause+signal protocol,
  dispatch verify-checkpoint per increment, gate on verdict; async: error not-yet-implemented.
- Success: checkpoint catches drift at each F-boundary; CLEAR auto-proceeds; BLOCK surfaces before
  the next task; off reproduces today's dispatch exactly; final `lsa:reconcile` still runs.
- I/O: in = `.lsa.yaml paired_verify` value, grounded spec, chosen implementer. out = the
  implementer's diff (as today) + per-increment verdicts (checkpoint mode).
- Test: paired_verify off → unchanged dispatch; checkpoint → pause+signal+verifier loop; async → errors.

## Behavioral requirements (scenario-backed)
- G1 (schema). `.lsa.yaml` shall define `paired_verify: off|checkpoint|async` (default off), documented
  in ARCHITECTURE §3 (YAML block + per-key bullet) and `conventions.md` defaults.
- G2 (default/back-compat). When paired_verify is absent or off, delegate behaves exactly as today —
  package spec, dispatch, await diff; no pause instruction, no verifier injected.
- G3 (async errors). If paired_verify is async, delegate errors "not yet implemented" and does not
  proceed (no silent degradation) — reserved for the true-interrupt pitch.
- G4 (inject protocol). When checkpoint AND the implementer is agent-dispatched, delegate injects an
  instruction: after each plan task F-K, (a) write the checkpoint-signal note, (b) stop and await
  conformance clearance.
- G5 (signal fields). The injected note protocol emits exactly target/since/spec/status per the
  verify-checkpoint contract (`observer/skills/verify-checkpoint/SKILL.md:22-37`).
- G6 (dispatch verifier). When checkpoint, delegate dispatches `observer:verify-checkpoint` to grade
  each signalled increment.
- G7 (gate on verdict). CLEAR → implementer proceeds to the next task with no human interrupt;
  BLOCK → delegate surfaces the block to the human before the next task.
- G8 (independence). The dispatched verifier runs read-only per its own contract; delegate never
  folds the verdict into the implementer's authoring context
  (`lsa/skills/reconcile/SKILL.md:44-45`).
- G9 (reconcile unchanged). Checkpoint mode does not replace the final `lsa:reconcile`; the overall
  reconcile still runs after delegation (pitch No-go #5).
- G10 (non-agent implementer). When checkpoint but the implementer is external/human, delegate
  states the pause-protocol is advisory (it cannot enforce a pause on a non-agent) — no silent claim
  of enforcement.
- G15 (note-path interlock). The checkpoint-signal note's file PATH is owned by the delegating
  context (delegate) and passed as the SAME path to BOTH the writer (implementer) and the reader
  (`observer:verify-checkpoint`). The path is ephemeral (scratchpad / gitignored) and NOT committed;
  the four contract fields (target/since/spec/status) are unchanged — the path locates the note, the
  fields are its contents.
- G16 (invocation model reconciled). `observer:verify-checkpoint` documents two invocation modes with
  identical grading — (a) per-increment dispatch (how delegate drives it) and (b) standalone `/loop`
  rider; delegate dispatches it per-increment (its first-class mode), not as a standalone loop.

## Non-scenario requirements
- G11 (version). lsa `plugin.json` 0.22.0 → 0.23.0 + CHANGELOG entry (Keep a Changelog), same commit.
- G12 (README). `lsa/README.md` documents delegate's paired_verify modes.
- G13 (schema docs). `lsa/ARCHITECTURE.md` §3 + `lsa/knowledge/conventions.md` updated (default off).
- G14 (tests). Eval assertions assert: off→unchanged, checkpoint→inject+dispatch+CLEAR-proceeds /
  BLOCK-surfaces, async→errors, note carries the 4 contract fields.
