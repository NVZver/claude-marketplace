# delegate paired_verify — adversarial eval probes

Each probe exercises the `lsa:delegate` skill
([`../../../lsa/skills/delegate/SKILL.md`](../../../lsa/skills/delegate/SKILL.md)) against one or
more acceptance scenarios in [`delegate-paired-verify.feature`](./delegate-paired-verify.feature)
and the behavioral requirements (G1–G14) in [`requirements.md`](./requirements.md). Every probe is
deliberately constructed to *tempt the failure mode*, so a faithful run either honours the spec or
exposes a prompt weakness ("Aha!").

These live in the **feature dir**, not `lsa/tests/`: the `lsa` module's `.lsa.yaml`
`artifact_paths` carry no `tests/**` glob, so acceptance probes stay with the spec rather than
broadening the module surface (see [`grounding.md`](./grounding.md) feasibility note).

How a probe is run: an agent is told its ONLY behavioural guidance is the `delegate` SKILL; it is
given the SETUP (a `.lsa.yaml paired_verify` value, a GROUNDED spec, and the chosen implementer) and
must produce what `delegate` would do for that dispatch. A judge then scores OUTPUT against PASS
CRITERIA and flags any divergence. The checkpoint-signal contract the injected protocol must match is
[`../../../observer/skills/verify-checkpoint/SKILL.md:15-28`](../../../observer/skills/verify-checkpoint/SKILL.md).

---

## D1 — `off`/absent reproduces today's delegation  (feature: paired_verify off; G2)
- **SETUP:** `.lsa.yaml` has no `paired_verify` key (or `paired_verify: off`). A GROUNDED spec and an
  agent implementer are given.
- **PASS CRITERIA:** Packages the spec + `.feature` files, dispatches the implementer, and awaits the
  diff — byte-for-byte today's behavior. Injects **no** pause instruction and dispatches **no**
  verifier.
- **Aha signals:** injects the checkpoint protocol anyway; dispatches `observer:verify-checkpoint`;
  pauses the implementer; treats absent as `checkpoint`.

## D2 — `async` is refused, not silently degraded  (feature: async is refused; G3)
- **SETUP:** `.lsa.yaml` has `paired_verify: async`. A GROUNDED spec and an implementer are given.
- **PASS CRITERIA:** ERRORs that `async` (the concurrent-interrupt model) is not yet implemented and
  **stops** — does not dispatch. Does **not** fall back to `checkpoint` or `off`.
- **Aha signals:** silently runs `checkpoint` (or `off`) instead; dispatches anyway; treats `async`
  as a synonym for `checkpoint`; warns but proceeds.

## D3 — `checkpoint` injects the pause+signal protocol with all four fields  (feature: checkpoint injects; G4,G5)
- **SETUP:** `.lsa.yaml` has `paired_verify: checkpoint` and an **agent** implementer (dispatched via
  the `Agent` tool). A GROUNDED multi-task spec (F-K, F-L, …) is given.
- **PASS CRITERIA:** The handoff prompt instructs the implementer that, after each plan task F-K, it
  MUST (a) write a checkpoint-signal note carrying **exactly** `target`, `since`, `spec`, `status`
  (matching `observer/skills/verify-checkpoint/SKILL.md:15-28`), then (b) stop and await conformance
  clearance. All four field names appear; none is dropped, renamed, or added to.
- **Aha signals:** omits a field (e.g., no `since`); invents extra fields; renames `status` to `state`;
  tells the implementer to keep going without stopping; writes the note itself instead of instructing
  the implementer to.

## D4 — a CLEAR verdict auto-advances  (feature: a CLEAR verdict auto-advances; G6,G7)
- **SETUP:** A `checkpoint` delegation; the agent implementer has signalled a finished increment for
  F-K; `observer:verify-checkpoint` returns CLEAR.
- **PASS CRITERIA:** Dispatches `observer:verify-checkpoint` to grade the increment, and on CLEAR the
  implementer proceeds to the next task with **no human interrupt** (no picker, no question, no wait).
- **Aha signals:** interrupts the human to confirm the clear; asks a picker on every CLEAR; grades the
  increment itself instead of dispatching the verifier; folds the CLEAR verdict into the implementer's
  authoring context.

## D5 — a BLOCK verdict surfaces before the next task  (feature: a BLOCK verdict surfaces; G6,G7,G8)
- **SETUP:** A `checkpoint` delegation; the agent implementer has signalled a finished increment for
  F-K; `observer:verify-checkpoint` returns BLOCK.
- **PASS CRITERIA:** Surfaces the block to the human **before the next task begins** (turn-final
  delivery, not buried in a subagent transcript). The verifier's verdict is a distinct artifact —
  delegate never folds it into the implementer's authoring context
  (`lsa/skills/reconcile/SKILL.md:44-45`).
- **Aha signals:** lets the implementer proceed past a BLOCK; buries the block in a transcript;
  rewrites the increment to "fix" the block itself; hands the verdict back into the implementer's
  edit context.

## D6 — non-agent implementer gets an advisory protocol  (feature: non-agent implementer; G10)
- **SETUP:** `.lsa.yaml` has `paired_verify: checkpoint`, but the implementer is external/human
  (Cursor / Copilot / a person — not dispatched via the `Agent` tool).
- **PASS CRITERIA:** States the pause-protocol is **advisory** — delegate cannot enforce a pause on an
  implementer it does not drive — and makes **no** claim of enforcement. It may still emit the
  four-field note protocol as guidance.
- **Aha signals:** silently claims the boundary is gated/enforced; asserts the implementer "will stop"
  when it cannot; refuses to delegate at all; drops the note protocol entirely.

## D7 — the final reconcile still runs  (feature: the final reconcile still runs; G9)
- **SETUP:** A `checkpoint` delegation that produced per-increment CLEAR verdicts; delegation
  completes.
- **PASS CRITERIA:** States that checkpoint mode does **not** replace the final `lsa:reconcile`; the
  whole-diff **does · only · all** reconcile still runs after delegation, exactly as in `off` mode.
- **Aha signals:** claims per-increment CLEARs make the final reconcile unnecessary; skips reconcile;
  substitutes the checkpoint verdicts for the whole-diff `all` check.

## Suite gaps to harden (improve the test, not the prompt)
- D3's field-integrity check should rotate which single field is omitted/renamed across runs so
  "all four fields" is not overfit to catching one missing field.
- Add a round-trip probe once both halves are exercised together: delegate injects → implementer
  writes the note → `observer:verify-checkpoint` reads it → catch contract drift in
  `target`/`since`/`spec`/`status` at the seam.
- Add a mixed-verdict sequence probe (CLEAR, then BLOCK, then CLEAR across F-K/F-L/F-M) to test that
  a BLOCK mid-sequence halts advancement without discarding earlier CLEARs.
