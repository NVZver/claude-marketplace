Shaped by: Nikita Zverev
Date: 2026-07-19
Status: DROPPED (2026-07-19, at the specify gate — see the block below before re-shaping)

> **DROPPED — the premise below is false.** This pitch rests on the claim that *"in any run where
> the implementer is not the session model, cross-model grading already holds"* — that LSA simply
> fails to record an already-true property. Specifying it disproved that. `lsa:delegate` and
> `lsa:reconcile` are **both** in the floored set (`lsa/knowledge/model-routing.md` §"Resolution
> algorithm" step 1: each "resolve `inherit` and stop"), so they never differ in tier. An
> Agent-dispatched implementer therefore always yields `cross-model: no`; an external one is
> unobservable and yields `unknown`; **`cross-model: yes` is unreachable.** The feature would ship
> a three-valued field where one value can never occur, and `require` mode would fail *every*
> agent-dispatched run — "forbid agent-dispatched implementation", not "opt into rigor". Routing up
> cannot help: the vocabulary is `inherit | sonnet | haiku` with nothing above `inherit`, and
> hardcoding `opus` is banned (`.lsa/standards/code.md:52`).
>
> The full 14-requirement spec is retained at
> `.lsa/features/observable-grader-independence/cross-model-verdict/` as the record — it is
> internally correct and its R7 already forbids "fixing" this by breaking the floor.
>
> **To revive:** the only path to a reachable `yes` is Fork 3(b), rejected below — having
> `delegate` ask the user to declare an external implementer's model. That reopens the pitch, not
> just the spec. The competitive gap vs Flow-Next stays open and is documented in
> `.lsa/observations/2026-07-19-sdd-competitive-pulse-check.md` §5.2.
Role lens: AI-agent-infrastructure product manager (eval / model-governance lens)
Gate decisions:
- Fork 1 (enforcement posture): `observe` default + opt-in `require` — records the fact always, blocks only on explicit opt-in. Preserves the Pro-tier promise and the Level 2.5 advisory posture.
- Fork 2 (which axis carries "different model"): the **implementer** axis (delegate declares; the grader stays floored). The only axis that can vary without violating the grader floor.
- Fork 3 (unobservable implementer): record `cross-model: unknown`, legal only for non-Agent-dispatched implementers.
Why now: the 2026-07-19 competitive pulse check named cross-model review as the one concrete
rigor gap where our closest architectural peer (Flow-Next) is ahead, and it sits on the exact
dimension LSA competes hardest on — the blocking reconcile gate.

# Observable grader independence — record the model axis, don't mandate it

`reconcile` already runs in an independent context; it just never records *which model* graded
versus which model implemented. Make that fact observable on the verdict, and let a user who
wants it blocking opt in — without hardcoding a model or breaking the Pro-tier promise.

## Problem

The repo owner (and any future user) relies on `lsa:reconcile` as the blocking after-build
correctness gate. Its independence today is real but partial: `lsa/skills/reconcile/SKILL.md`
guarantees a context with no write access to the tests, acceptance `.feature` scenarios, or
quality-gate config, and requires the verdict be authored in a separate context and commit
("Independence must be observable, not asserted"). Neither says anything about the *model*. So in
the default configuration the same model can write the diff and then grade its own work — the
known self-evaluation weakness.

Evidence this is a live competitive gap:
`.lsa/observations/2026-07-19-sdd-competitive-pulse-check.md` §5.2 — "LSA's `reconcile` is
'independent' only in the sense of a fresh context with no write access to the artifacts it
grades … nothing records or requires that it run on a different model than `delegate` used."
Flow-Next requires a different model to issue SHIP before work proceeds.

**Evidence the obvious fix does not work.** `lsa/knowledge/model-routing.md` §"Resolution
algorithm" step 1 places the `lsa:reconcile` grader in a **floored set** — it resolves `inherit`
and stops, and "a map entry naming a lower tier for a floored surface is ignored" (these are the
safety/quality floor of the system). That floor is spec-locked by an adversarial scenario at
`.lsa/features/pro-tier-token-affordability/model-routing/flow-3-grader-floor.feature`
("Given .lsa.yaml routing maps lsa:reconcile to haiku # adversarial … Then the resolved tier is
inherit, not haiku"). On Pro only one capable tier exists (`README.md` §"Plans & models",
Sonnet 5). On Max the session model is Opus, so forcing reconcile to *differ* means routing the
grader down to Sonnet — the exact downgrade the floor forbids. A "reconcile must differ from
delegate" policy is therefore unimplementable as stated on both plans.

**What is actually true today and unrecorded.** `lsa/skills/delegate/SKILL.md` — "LSA writes no
production code" — and the implementer is listed as "Claude Code / Cursor / Copilot / human". In
any run where the implementer is not the session model, cross-model grading already holds. LSA has
no field anywhere that says so, so the property is invisible to the user, to `conformance.md`, and
to anyone auditing the gate.

Current workaround: none. The user infers cross-model status from memory of how they ran delegate,
or does not think about it at all. Nothing in `conformance.md` or the verdict line records it.

Definition of success: after a reconcile run, the user can read off the verdict artifact whether
the grading was cross-model, same-model, or unknown — without reconstructing the run from memory
— and a user who wants same-model grading to block can turn that on in `.lsa.yaml` without any
model name appearing anywhere in the repo.

## Appetite

Small batch, docs-only — this is a `mode: docs` repo, so the whole change is prompt-and-config
text plus the standard versioning trail. The boundary: **one new `.lsa.yaml` key, one extended
verdict line, and the policy prose that defines both.** No new skill, no new script, no new
dispatch surface, no change to the routing resolution algorithm.

Out of appetite: any second-vendor integration (a RepoPrompt/Codex/Copilot grader adapter),
any telemetry or eval instrumentation, and any change to the floored-surface rule itself. If the
work starts requiring a new machine-readable artifact or a new agent, it has left the appetite.

## Solution sketch

- **Key user interactions:**
  1. The user runs a cycle as they do today and reads one extra field on the verdict —
     `reconcile: PASS @ <graded-sha> (implementer: <declared>, grader: <tier>, cross-model: yes|no|unknown)`.
     Default behavior is otherwise byte-for-byte unchanged.
  2. A user who wants rigor sets one key — `reconcile.cross_model: observe | require` (default
     `observe`) — and under `require` a same-model run yields an explicit `FAIL` with the reason,
     not a silent pass.
  3. A user on Pro sets nothing, sees `cross-model: no`, and is never blocked.

- **Main components:** `lsa/skills/reconcile/SKILL.md` (the verdict line + a new constraint
  defining the three values); `lsa/skills/delegate/SKILL.md` (declare the implementer identity so
  reconcile has something to compare against); `lsa/knowledge/quality-gate-contract.md`
  §"Independence rule" (extend the existing observable-not-asserted rule to the model axis);
  `lsa/knowledge/model-routing.md` (state explicitly that the floor takes precedence over any
  cross-model preference, closing the contradiction); the `.lsa.yaml` schema in `lsa/README.md`
  and `lsa/ARCHITECTURE.md` §3; plus the plugin CHANGELOG + SemVer bump per `/CLAUDE.md`
  §Discipline.

- **Critical path:** delegate records the implementer identity → reconcile reads it, compares
  against its own resolved tier, and emits one of three values → under `require`, a `no` becomes a
  FAIL; under `observe`, it is recorded and the verdict is unaffected.

## Rabbit holes

1. **The floor collision** — "make reconcile a different model" contradicts the shipped floor
   (`lsa/knowledge/model-routing.md` §"Resolution algorithm") and its adversarial scenario.
   Mitigation: the pitch never re-tiers reconcile. Cross-model status is *observed* on the
   implementer axis; the grader stays floored, and the routing doc gains one sentence saying the
   floor wins over any cross-model preference. This is the finding that made the competitive
   report's own suggested fix (§6 item 2) unworkable as written — record that inversion in the
   spec so it is not re-proposed.
2. **`unknown` swallowing everything** — for a human or IDE implementer, LSA cannot observe the
   model, so `unknown` could become the universal answer and the field pure theater. Mitigation:
   `unknown` is only legal when the implementer was not Agent-dispatched, and delegate must state
   it in the handoff (matching its existing "no silent enforcement claim" constraint); an
   Agent-dispatched implementer always yields `yes` or `no`.
3. **Coercion drift** — a blocking `require` sits uneasily with LSA's Level 2.5 advisory posture
   (`.lsa/VISION.md` §4, absorb don't forbid). Mitigation: `require` is opt-in, never the default,
   and its failure is a reconcile FAIL with a stated reason the user can override — the same shape
   as any other failing check, not a new class of block.
4. **Verdict-line consumers** — the line is cited in `.lsa/standards/code.md` and appears across
   `.lsa/features/*/conformance.md`. Mitigation: grep confirms no script parses it (the `gate:`
   block runs lint/citations/links/project-map/tests only), so this is a human-facing format
   extension; existing conformance files stay valid as-is.
5. **Scope creep into an eval subsystem** — "adversarial review" invites building judge harnesses.
   Mitigation: no-go #2 below; statistical eval rigor is already deliberately deferred
   (`.lsa/VISION.md` §6 Adjust #3).

## No-gos

1. This pitch does NOT hardcode, name, or pin any model — per `.lsa/standards/code.md` §"Model
   policy", a hardcoded model a plan lacks is a hard error. Only tier-relative comparison and the
   existing `inherit | sonnet | haiku` vocabulary are used.
2. This pitch does NOT build a cross-vendor grader adapter (RepoPrompt / Codex / Copilot as
   reconcile). That is Flow-Next's architecture, requires external service integration, and would
   break the "zero external service" property (`README.md` §Security).
3. This pitch does NOT make cross-model grading required by default — that would break "Runs 100%
   on Claude Pro" (`README.md` §"Plans & models"), where a second capable tier does not exist.
4. This pitch does NOT re-tier or unfloor `lsa:reconcile`. The floor
   (`lsa/knowledge/model-routing.md` §"Resolution algorithm") is preserved and made explicitly
   dominant.
5. This pitch does NOT touch `verify` (the before-check) or `observer:verify-checkpoint`. Extending
   the same observability to per-increment verdicts is a separate, later decision.
