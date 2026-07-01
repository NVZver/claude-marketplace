Shaped by: Nikita Zverev
Date: 2026-07-01
Status: approved
Role lens: developer-tooling product manager
Decisions:
- Fork A (green-checkpoint clearance): auto-clear green agent-to-agent, surface to human only on drift.
- Fork B (verifier host): a new sibling skill in `observer` that rides the same `/loop` substrate (a second Actor), not a role bundle in `roles.md`.
- Fork C (`paired_verify` schema surface): ship all three enum values now — `off` / `checkpoint` / `async` — with `async` documented as not-yet-implemented (reserved for the true-interrupt pitch).
- Discovery refinement (2026-07-01, epic `paired-verify/observer-verifier`): the per-increment grader runs **does·only** only — the **all** / completeness check stays with the final `lsa:reconcile`. Mid-flight, requirements F(K+1…N) are intentionally unbuilt, so applying reconcile's whole-plan "all" (`lsa/skills/reconcile/SKILL.md:33`) per-increment would spuriously flag every early checkpoint as under-delivery. Wherever this pitch says "does·only·all" for the per-increment grader below, read "does·only (completeness deferred to the final reconcile)". Verifier skill named `observer:verify-checkpoint`; invocation model = continuous `/loop` rider keyed off a checkpoint signal the implementer emits.
Why now: observer:observe just shipped (observer 0.1.1, commit 0bd6939) and reconcile's
does·only·all lens is mature — this branch's thesis is reuse, and both halves the feature
needs now exist to compose rather than build.

# Checkpoint-gated paired verification during delegation (`observer` verifier skill)

An opt-in verifier agent that rides alongside the LSA implementer during delegation and clears
each plan-task boundary against the spec — so spec/rule drift is caught per-increment instead of
only at the post-hoc reconcile gate.

(LSA = Living Spec Architecture, this repo's spec-driven cycle. "Appetite" = the scope
constraint we commit to, not an estimate. "Pitch" = this shaped proposal.)

## Problem

During an LSA delegation cycle, the implementer builds the whole grounded spec, and correctness
is judged only afterward: `lsa:reconcile` is explicitly "the *after* check"
(`lsa/skills/reconcile/SKILL.md:8`), running does·only·all over the completed diff
(`lsa/skills/reconcile/SKILL.md:30-34`). Any spec or ground-rule drift introduced early in the
implementation is therefore not surfaced until the diff is complete — by which point it has
compounded across every later task that built on it.

Who has it: the developer owning an LSA loop with a non-trivial, multi-F-requirement spec.
Evidence: the cycle shape is roughly ~1h implement → 30m reconcile → 1h fix
[user estimate — not from a logged metric; the compounding claim follows from reconcile being
structurally an after-the-fact gate over the full diff, `lsa/skills/reconcile/SKILL.md:8,30-34`].

Current workaround: nothing sits between `lsa:delegate` handing off the spec
(`lsa/skills/delegate/SKILL.md:30-33`) and reconcile grading the returned diff — the implementer
runs unwatched to completion, and drift is absorbed only at the end
(`lsa/skills/reconcile/SKILL.md:35,43`).

Definition of success: when `paired_verify: checkpoint` is set, the implementer pauses at each
F-requirement task boundary and a drift caught at task K is reported before task K+1 begins — so
the fix surface at reconcile shrinks measurably (fewer, smaller drift items reaching the final
gate) without changing reconcile itself.

## Appetite

Small-to-medium batch. This composes two shipped subsystems; it builds no new machinery. It
reuses observer's per-cycle substrate — observe rides the self-paced `/loop`, reads file changes
since the last cycle, and applies a role bundle from `observer/knowledge/roles.md`
(`observer/skills/observe/SKILL.md:11,37`) — and reuses reconcile's does·only·all conformance
lens (`lsa/skills/reconcile/SKILL.md:30-34`) as the verifier's grading criteria.

The work touches TWO plugins, so both carry the per-plugin CHANGELOG + SemVer + README discipline
(`CLAUDE.md` "Per-plugin SemVer + CHANGELOG") in the same commit:
- **observer** — a new sibling verifier skill that rides the same `/loop` substrate as `observe`
  (a second Actor, per Fork B; kept separate from observe's human-coaching kickoff/stop flow),
  with a does·only·all lens against a fixed spec and a gate voice/cadence (clear/block), not a
  coach's; CHANGELOG + `plugin.json` bump + README delta.
- **lsa** — wire the `paired_verify:` flag into `lsa:delegate` so it dispatches implementer +
  read-only verifier when the flag is `checkpoint` (delegate already carries the `Agent` tool,
  `lsa/skills/delegate/SKILL.md:4`); document the flag in the `.lsa.yaml` schema
  (`lsa/ARCHITECTURE.md §3`) with all three enum values (`off` / `checkpoint` / `async`), `async`
  marked not-yet-implemented (Fork C); CHANGELOG + `plugin.json` bump + README delta.

Out of appetite (built later, not now): the `async` concurrent + SendMessage true-interrupt model
(the enum value ships but selecting it is a no-op that errors with a "not yet implemented"
message); per-red-green checkpoint granularity; making `paired_verify` default to anything but
`off`; and any verifier write/edit capability (see No-gos).

## Solution sketch

- **Key user interactions:** the developer sets `paired_verify: checkpoint` in `.lsa.yaml`
  (default `off`). On the next `lsa:delegate`, the implementer's delegation prompt gains one
  instruction — "after each plan task, stop and await conformance clearance" — a cooperative
  pause at the spec's own F-requirement task boundaries (the list `lsa:specify` already enumerates;
  reconcile grades against that same `F1…` list, `lsa/skills/reconcile/SKILL.md:34`). No
  harness-level interrupt. An independent read-only verifier, seeded with the SAME spec +
  ground-rules as its lens, grades each increment does·only·all and clears or blocks the boundary.
  A **green** checkpoint auto-clears agent-to-agent; the human is interrupted only on drift
  (Fork A) — the final reconcile still holds the human end gate.
- **Main components:** `lsa:delegate` (dispatch two agents, inject the pause instruction); a new
  sibling verifier skill in `observer` that rides the same `/loop` substrate as `observe` (Fork B),
  distinct from observe's human-coaching Actor; the `paired_verify` flag in `.lsa.yaml` and its
  schema doc (all three enum values, `async` not-yet-implemented). `lsa:reconcile` is UNCHANGED —
  it remains the independent, human-facing end gate; per-checkpoint verification is per-increment
  reconcile, and the overall reconcile still runs (`lsa/skills/reconcile/SKILL.md:38-45`).
- **Critical path:** flag = checkpoint → delegate wires implementer + verifier on the same spec →
  implementer completes task K, pauses → verifier grades increment K does·only·all
  (`lsa/skills/reconcile/SKILL.md:30-34`) → clear ⇒ implementer proceeds to K+1 (no human
  interrupt); drift ⇒ surfaced to the human now, before K+1 → … → final `lsa:reconcile` runs as
  today.

## Rabbit holes

1. "Who observes the observer?" — the verifier is itself an agent, so trust looks circular.
   Mitigation: verification is BOUNDED — it judges against a fixed spec + fixed ground-rules and
   generates nothing, so it is cheaper to trust than the generative implementer. This is the exact
   bet reconcile already makes; the human still holds the end gate, unchanged
   (`lsa/skills/reconcile/SKILL.md:35,43`).
2. Token cost of a continuously-watching second agent. Mitigation: model asymmetry — a cheap
   verifier (e.g. Haiku) watching an expensive implementer (Opus) makes continuous-watch cost a
   rounding error against catching drift ~45m before reconcile would [cost figures are user
   estimates, not benchmarked here].
3. Bending observe's human-coaching flow to fit an agent verifier — observe's kickoff/stop steps
   (F1–F5, `observer/skills/observe/SKILL.md:27-41`) and its role bundles address a human
   "candidate"/"user" and coach non-destructively (`observer/knowledge/roles.md:14-40`;
   `observer/skills/observe/SKILL.md:78`). This verifier grades an agent's diff against a spec and
   emits a clear/block verdict — a different flow entirely. Mitigation (Fork B): ship a NEW sibling
   skill riding the same `/loop` substrate rather than a role bundle inside `observe`, so the
   human-session flow is untouched; keep the Actor's no-per-role-branch invariant discipline
   (`observer/skills/observe/SKILL.md:73`).
4. Independence at the checkpoint layer — a mid-flight verifier must not be able to grade work it
   could author. Mitigation: carry reconcile's independence constraint verbatim — separate context,
   no write access to the tests/scenarios/gate-config it grades, verdict as an artifact the
   implementer could not author (`lsa/skills/reconcile/SKILL.md:44-45`).

## No-gos

1. This pitch does NOT build the `async` concurrent + SendMessage true-interrupt model — the enum
   value ships in the schema documented as not-yet-implemented (Fork C), and selecting it errors
   rather than silently degrading; the intervention model actually built is the cooperative
   checkpoint pause only. A harness-level interrupt is a separate, larger appetite.
2. This pitch does NOT build per-red-green (TDD) checkpoint granularity up front — default
   granularity is per-task (per F-requirement); per-red-green is a reserved `.lsa.yaml` sub-setting
   for later, not built now.
3. This pitch does NOT make `paired_verify` default on — default is `off`; opt-in only.
4. This pitch does NOT give the verifier any write/fix capability — it gates and reports, never
   edits, mirroring observe's non-destructive constraint (`observer/skills/observe/SKILL.md:78`)
   and reconcile's "the spec absorbs reality — never revert the code"
   (`lsa/skills/reconcile/SKILL.md:43`).
5. This pitch does NOT modify `lsa:reconcile` — the final reconcile gate stays exactly as-is as the
   independent, human-facing end gate (`lsa/skills/reconcile/SKILL.md:38-45`).
