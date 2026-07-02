---
name: delegate
description: Hand the grounded spec to any implementer and collect the returned diff. The implementer is external to LSA. Optionally gate the build per-increment via checkpoint-mode paired verification (`.lsa.yaml paired_verify`).
allowed-tools: Read, Write, Bash, Agent, AskUserQuestion
---

> **Trace.** On load, print first: `=============== [lsa/skills/delegate/SKILL.md] [lsa] ===============`

# LSA Delegate

See [CORE.md](../../CORE.md). The handoff boundary — LSA writes no production code.

## Role

Handoff.

## Goal

Get a grounded spec built by the implementer the developer already uses, and collect the result. When `paired_verify: checkpoint` is set, gate the build increment-by-increment via an independent verifier without ever writing code itself.

## Inputs

| Input | Source |
|-------|--------|
| The grounded spec + `<flow>.feature` files | `verify` (GROUNDED) |
| The chosen implementer (Claude Code / Cursor / Copilot / human) | `user` |
| `.lsa.yaml paired_verify` (`off` \| `checkpoint` \| `async`; default `off`) | `.lsa.yaml` (per [`../../knowledge/conventions.md`](../../knowledge/conventions.md) Read protocol) |

## Steps

1. **Read the paired-verify mode.** Read `.lsa.yaml paired_verify` (per the [conventions](../../knowledge/conventions.md) Read protocol). Absent ⇒ `off`. Values: `off` \| `checkpoint` \| `async`; schema in [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §3. Observable result: the mode is named back to the human. (→ mode)

2. Package the spec + `.feature` files as repo files — the self-contained handoff. (→ handoff)

3. **Branch on the mode:**

   - **`off` (default / absent) — unchanged delegation (G2).** Dispatch to the developer's implementer (this runs **outside** LSA), then await the returned diff. Inject **no** pause instruction and dispatch **no** verifier — byte-for-byte today's behavior. Skip to Step 6. (→ delegated → diff)

   - **`async` — refuse, do not degrade (G3).** ERROR: `async (concurrent-interrupt model) is not yet implemented — reserved for a later pitch`. Do **not** fall back to `checkpoint` or `off`; do not dispatch. Stop here — no silent degradation.

   - **`checkpoint` — inject the pause+signal protocol, then gate per increment (G4–G8, G10).** Continue to Step 4.

4. **Inject the checkpoint protocol into the handoff (G4, G5, G10).**

   **Delegate OWNS the checkpoint-signal note path.** Before injecting, delegate picks one **ephemeral** note path (a scratchpad / gitignored location — **not** committed) and passes the **same** path to both the implementer (the writer, in this step) and `observer:verify-checkpoint` (the reader, Step 5). The path locates the note; its contents are the four contract fields — `target` · `since` · `spec` · `status` — defined once in the reader contract, [`observer/skills/verify-checkpoint/SKILL.md:22-37`](../../../observer/skills/verify-checkpoint/SKILL.md) §"The checkpoint-signal contract".

   - **Agent-dispatched implementer** (delegate dispatches it via the `Agent` tool): inject into the handoff prompt an instruction that, **after each plan task F-K**, the implementer MUST:
     1. **Write a checkpoint-signal note** at the delegate-provided path, carrying **exactly** the four contract fields with the meanings the reader contract defines (link above) — no extra fields, none omitted.
     2. **Stop and await conformance clearance** — do not begin the next task until the verifier's verdict clears the boundary.

     Observable result: the handoff prompt names the delegate-owned note path and contains the after-each-F-K write-note-then-stop instruction naming all four fields.

   - **Non-agent implementer** (human / Cursor / Copilot — not dispatched via the `Agent` tool) (G10): state that the pause-protocol is **ADVISORY** — delegate cannot enforce a pause on an implementer it does not drive. Emit the same four-field note protocol as guidance, but make **no** claim of enforcement. Do not silently assert the boundary is gated.

5. **Gate each signalled increment (G6, G7, G8).** For each checkpoint the agent implementer signals:
   - **Dispatch `observer:verify-checkpoint` in its per-increment mode** (via the `Agent` tool) to grade that one signalled increment (does · only, scoped to the note's `target`). Pass it the **same** ephemeral note path delegate provided the writer in Step 4, so the reader reads the file the writer wrote — this is `verify-checkpoint`'s first-class per-increment invocation mode ([`../../../observer/skills/verify-checkpoint/SKILL.md`](../../../observer/skills/verify-checkpoint/SKILL.md)), not its standalone `/loop` mode.
   - **Gate on the verdict (G7):**
     - **CLEAR** → the implementer proceeds to the next task with **no human interrupt** (no picker, no question, no wait).
     - **BLOCK** → **surface the block to the human before the next task begins** (turn-final delivery, not buried in a subagent transcript — [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7).
   - **Keep the verifier independent (G8):** it runs read-only per its own contract; **never fold its verdict into the implementer's authoring context** — the verdict lands as a distinct artifact the implementer could not author ([`../reconcile/SKILL.md:58`](../reconcile/SKILL.md)). Delegate orchestrates the loop; it writes no code and grades nothing itself.

6. **Await and return the diff.** Collect the implementer's returned diff, ready for `reconcile`. (→ diff)

7. **The final reconcile still runs (G9).** Checkpoint mode does **not** replace the final `lsa:reconcile` — per-increment does·only verdicts gate the boundaries, but the whole-diff **does · only · all** reconcile still runs after delegation ([`../reconcile/SKILL.md`](../reconcile/SKILL.md)). Observable result: delegation completing hands off to `reconcile` as it does in `off` mode.

## Output

The implementer's diff, ready for `reconcile`. In `checkpoint` mode, additionally: per-increment `CLEAR`/`BLOCK` verdicts (authored by the independent verifier, not delegate), each CLEAR auto-clearing its boundary and each BLOCK surfaced to the human before the next task.

## Constraints

- **LSA writes no production code** — the implementer is external. Delegate orchestrates the checkpoint loop but writes no code; the implementer writes code, the verifier grades read-only.
- Only delegate a `GROUNDED` spec (CORE §6).
- **`async` never degrades** — it errors and stops; it does not fall back to `checkpoint` or `off` (G3).
- **Checkpoint does not replace reconcile** — the final whole-diff `lsa:reconcile` still runs after delegation (G9).
- **The verifier is independent** — its verdict is never folded into the implementer's authoring context ([`../reconcile/SKILL.md:58`](../reconcile/SKILL.md)) (G8).
- **No silent enforcement claim** — for a non-agent implementer the pause-protocol is advisory only (G10).
- **Delegate owns the note path** — the checkpoint-signal note path is chosen by delegate and passed as the SAME ephemeral (scratchpad / gitignored, not committed) path to both the writer (implementer) and the reader (`observer:verify-checkpoint`); the four fields are unchanged.

---

`/lsa:delegate` — manual invocation.
