# Cross-model verdict — record the model axis on reconcile's verdict

> ## ⛔ DROPPED 2026-07-19 — DO NOT IMPLEMENT
>
> This spec is **retained as a record, not as work**. It is internally correct and every
> requirement below is grounded — but the feature it specifies cannot work.
>
> `lsa:delegate` and `lsa:reconcile` are both in the floored set
> (`lsa/knowledge/model-routing.md` §"Resolution algorithm" step 1 — each "resolve `inherit` and
> stop"), so they never differ in tier. **`cross-model: yes` is therefore unreachable**: an
> Agent-dispatched implementer always yields `no`, an external one always yields `unknown`.
> Implementing R1–R14 faithfully would produce a three-valued field where one value can never
> occur, and R5/R6's `require` mode would fail every agent-dispatched run.
>
> Kept because the analysis is the deliverable: it documents *why* cross-model grading is
> architecturally unreachable here, so a future session does not re-derive it. See
> `.lsa/pitches/observable-grader-independence.md` for the revival path (pitch Fork 3b) and
> `.lsa/roadmap.yaml` slug `observable-grader-independence`.

## Summary

`lsa:reconcile` already runs in an independent context; it never records *which model*
graded versus which model implemented. This epic makes that fact observable on the verdict
line, adds one opt-in `.lsa.yaml` key that turns it blocking, and states explicitly that the
grader's routing floor beats any cross-model preference. Docs/prompt text only — no new
skill, no new script, no new dispatch surface, no change to the routing resolution algorithm.

- Source: `.lsa/pitches/observable-grader-independence.md` (approved 2026-07-19; Fork 1
  `observe` default + opt-in `require`; Fork 2 the **implementer** axis carries the
  comparison; Fork 3 unobservable implementer ⇒ `unknown`).
- Applies: `lsa/skills/reconcile/SKILL.md:59` — *"Independence must be observable, not
  asserted."* This epic extends that existing principle from the context/commit axis to the
  model axis.
- Target surface: `lsa/skills/reconcile/SKILL.md` (verdict line :40, Constraints :56-59),
  `lsa/skills/delegate/SKILL.md` (Steps 3/6, Constraints :77),
  `lsa/knowledge/quality-gate-contract.md` §"Independence rule",
  `lsa/knowledge/model-routing.md` §"Resolution algorithm", `lsa/README.md`,
  `lsa/ARCHITECTURE.md` §3, `lsa/CHANGELOG.md`, `lsa/.claude-plugin/plugin.json`.
- Style precedent: the `reconcile.runs` knob — one optional key, documented in the same three
  places (`lsa/ARCHITECTURE.md:109-117` schema block + `:127` bullet, `lsa/README.md:143-144`
  schema block + `:155` prose, `lsa/skills/reconcile/SKILL.md:27` Inputs row).

## User Flows

1. **Pro user, nothing configured.** The user runs a normal cycle. `.lsa.yaml` has no
   `reconcile.cross_model` key. The verdict line now carries three extra fields; the
   PASS/FAIL outcome is otherwise identical to today. The user is never blocked.
2. **Rigor opt-in.** A user sets `reconcile.cross_model: require` in `.lsa.yaml`. A run whose
   implementer resolved to the same tier as the grader now yields `reconcile: FAIL` with a
   literal stated reason instead of a silent pass.
3. **Non-Agent-dispatched implementer.** The user builds with a human / Cursor / Copilot
   implementer. `delegate` declares `implementer: external`; `reconcile` records
   `cross-model: unknown` with the reason, and — per delegate's existing *No silent
   enforcement claim* constraint (`lsa/skills/delegate/SKILL.md:77`) — makes no claim either
   way, and does not FAIL on it even under `require`.
4. **Auditor reading the record.** Someone reads `conformance.md` for a past epic and reads
   the cross-model status off the file, without reconstructing the run from memory.

## Functional requirements (EARS)

- R1. **Verdict-line grammar.** `lsa/skills/reconcile/SKILL.md` SHALL extend the verdict line
  from `reconcile: PASS|FAIL @ <graded-sha>` to exactly:
  `reconcile: PASS|FAIL @ <graded-sha> (implementer: <declared>, grader: <tier>, cross-model: yes|no|unknown)`
  — same order, same separators, three fields, always all three present. The existing prefix
  (`reconcile: `, the verdict token, ` @ `, the SHA) SHALL be byte-for-byte unchanged so the
  format stays a superset of today's. `<tier>` SHALL be the tier string `lsa:reconcile`
  resolved through `lsa/knowledge/model-routing.md` §"Resolution algorithm" — for a floored
  surface always the literal `inherit` (R7).
- R2. **Implementer declaration (delegate).** `lsa/skills/delegate/SKILL.md` SHALL require
  delegate to emit, with the returned diff (Step 6) and in the handoff, exactly one
  declaration line in one of two literal forms:
  - `implementer: agent:<tier>` — when delegate dispatched the implementer via the `Agent`
    tool; `<tier>` ∈ `inherit | sonnet | haiku`, the tier resolved for surface-key
    `lsa:delegate` (always `inherit` today — that surface is floored).
  - `implementer: external` — when the implementer was NOT dispatched via the `Agent` tool
    (human / Cursor / Copilot, per `lsa/skills/delegate/SKILL.md:26`).

  No other value SHALL be legal. The declaration SHALL name no model — only the
  `inherit | sonnet | haiku` vocabulary (R8).
- R3. **Comparison algorithm (reconcile).** `lsa/skills/reconcile/SKILL.md` SHALL specify this
  exact three-branch resolution, evaluated in order, and no other:
  1. declaration is `external` ⇒ `cross-model: unknown`;
  2. declaration is `agent:<tier>` and `<tier>` is the same string as the grader's resolved
     tier ⇒ `cross-model: no`;
  3. declaration is `agent:<tier>` and `<tier>` is a different string from the grader's
     resolved tier ⇒ `cross-model: yes`.

  The comparison SHALL be string equality over resolved tier names only — never a model
  name, never a capability judgment.
- R4. **Missing declaration is not a free `unknown`.** When the handoff carries no `implementer:`
  declaration at all, reconcile SHALL record `cross-model: unknown` AND SHALL write, in
  `conformance.md`, the literal line
  `cross-model: unknown — no implementer declaration in the handoff (illegal for an Agent-dispatched implementer)`.
  Under `observe` this SHALL NOT change the PASS/FAIL verdict; under `require` it SHALL FAIL
  (R6). `unknown` SHALL be legal — i.e. reason-free — only for the `external` branch of R3.
- R5. **`observe` is record-only.** `.lsa.yaml` `reconcile.cross_model: observe` (and the key
  being absent, which SHALL mean `observe`) SHALL cause the three fields to be recorded on
  the verdict line and in `conformance.md` and SHALL NOT change the PASS/FAIL outcome by even
  one run. `require` SHALL NEVER be the default; a user who sets nothing SHALL never be
  blocked by this check (`README.md` §"Plans & models" — the repo runs 100% on Claude Pro,
  where only one capable tier exists).
- R6. **`require` semantics.** Under `reconcile.cross_model: require`:
  - `cross-model: no` ⇒ the verdict SHALL be `FAIL`, with the literal reason line
    `cross-model: no — implementer and grader resolved to the same tier; cross_model: require`
    recorded in `conformance.md` and shown alongside the verdict.
  - a missing declaration (R4) ⇒ `FAIL`, with R4's literal reason line.
  - `cross-model: unknown` from the `external` branch ⇒ SHALL NOT FAIL; reconcile SHALL
    record the literal line
    `cross-model: unknown — implementer not Agent-dispatched; independence unobservable, not asserted`.
    Failing here would be exactly the silent enforcement claim
    `lsa/skills/delegate/SKILL.md:77` forbids — LSA must not block on a fact it cannot observe.
  - `cross-model: yes` ⇒ no effect on the verdict.

  A `require` FAIL SHALL be an ordinary reconcile FAIL with a stated reason — the same shape
  as any other failing check, overridable by the human, not a new class of block
  (`.lsa/VISION.md` §4, Level 2.5 absorb-don't-forbid).
- R7. **The grader floor wins.** `lsa/knowledge/model-routing.md` §"Resolution algorithm"
  SHALL gain an explicit statement that the floored-surface rule (step 1) takes precedence
  over any cross-model preference: `lsa:reconcile` SHALL always resolve `inherit` and SHALL
  NEVER be re-tiered, down-routed, or unfloored to manufacture a `cross-model: yes`. The
  statement SHALL record the inversion — the competitive report's suggested fix ("route
  reconcile to a different model") is unimplementable and is superseded by observing the
  implementer axis — so it is not re-proposed. The adversarial scenario at
  `.lsa/features/pro-tier-token-affordability/model-routing/flow-3-grader-floor.feature`
  SHALL continue to hold unchanged. A consequence SHALL be stated plainly: while both
  `lsa:delegate` and `lsa:reconcile` are floored, an Agent-dispatched run always records
  `cross-model: no`; `yes` is defined for the case where the declared implementer tier
  differs, and no implementation may reach it by re-tiering either floored surface.
- R8. **No model names anywhere.** No artifact changed by this epic SHALL contain a hardcoded
  model name (`opus`, `haiku` as a *model pin*, `fable`, or any `claude-*` id) — per
  `.lsa/standards/code.md:52` *"Never hardcode `opus`, `haiku`, or `fable`. A hardcoded model
  a plan lacks is a hard error, not a fallback."* Only the tier vocabulary
  `inherit | sonnet | haiku` (as routing tier values) and tier-relative comparison SHALL be
  used. Zero `model:` pins SHALL be added to any plugin frontmatter (lint C8 stays green).
- R9. **Independence rule extended to the model axis.**
  `lsa/knowledge/quality-gate-contract.md` §"Independence rule" SHALL gain a paragraph
  extending its existing observable-not-asserted rule to the model axis: the verdict records
  the implementer/grader tier relationship as data, the relationship is never asserted in
  prose, and recording it is mandatory while requiring a particular value is opt-in. It SHALL
  cite `lsa/skills/reconcile/SKILL.md:59` verbatim (*"Independence must be observable, not
  asserted."*).
- R10. **`.lsa.yaml` schema key.** The new key SHALL be `cross_model`, nested inside the
  existing `reconcile:` block alongside `runs: 3` (`.lsa.yaml` lines 27-28) — i.e.:

  ```yaml
  reconcile:
    runs: 3
    cross_model: observe   # observe | require. default: observe
  ```

  Legal values SHALL be exactly `observe` and `require`. Absent key, absent `reconcile:`
  block, or absent `.lsa.yaml` ⇒ `observe`. Any other value SHALL be reported as a
  configuration error naming the key and the two legal values, and SHALL be treated as
  `observe` for the run (never a block — matching `routing:`'s never-a-hard-error posture,
  `lsa/knowledge/model-routing.md` §"Resolution algorithm" step 3).
- R11. **Schema documented in both places.** `lsa/README.md` SHALL add `cross_model` to its
  `.lsa.yaml` schema block (under the existing `reconcile:` entry at `lsa/README.md:143-144`)
  plus one prose paragraph next to the existing `reconcile.runs` paragraph (`:155`), and
  `lsa/ARCHITECTURE.md` §3 SHALL add the key to its schema block (`:94-117`) plus one bullet
  in the key-by-key list (`:119-130`). Both SHALL state the default (`observe`), the two legal
  values, that `require` is never the default, and that the grader floor wins (R7).
- R12. **Reconcile Inputs + conformance.md.** `lsa/skills/reconcile/SKILL.md` §Inputs SHALL
  gain two rows: `.lsa.yaml reconcile.cross_model` (default `observe` when absent) and the
  implementer declaration (source: `delegate`). `conformance.md` SHALL carry the cross-model
  line below the coverage table, next to the orphan-hunk list and gate results, and the
  §Output synthetic example SHALL show it. Existing `conformance.md` files under
  `.lsa/features/*/` SHALL NOT be retro-edited — this is a human-facing format extension and
  no script parses the verdict line (verified: no match for `reconcile: PASS` or `graded-sha`
  under `scripts/` or `lsa/scripts/`).
- R13. **Versioning trail.** `lsa` SHALL bump `0.28.1 → 0.29.0` (MINOR — new observable
  behavior on reconcile + a new config key) in `lsa/.claude-plugin/plugin.json`, with a
  matching `lsa/CHANGELOG.md` entry (Keep a Changelog) and the `lsa/README.md` delta of R11,
  all in the same commit — per `/CLAUDE.md` §Discipline.
- R14. `bash scripts/gate.sh` SHALL exit 0 after the change.

## Acceptance scenarios (Gherkin)

See [`cross-model-verdict.feature`](./cross-model-verdict.feature).

## Out of Scope

- Any change to the routing **resolution algorithm** itself, or to the floored set (R7 adds a
  precedence statement, not a rule change). No-go #4.
- Any cross-vendor grader adapter (RepoPrompt / Codex / Copilot as reconcile). No-go #2.
- Any telemetry, eval harness, or judge instrumentation. Pitch rabbit hole 5.
- `lsa:verify` (the before-check) and `observer:verify-checkpoint` (per-increment verdicts) —
  extending the same observability there is a separate, later decision. No-go #5.
- Making cross-model grading required by default, or any second-vendor integration. No-gos #1-3.
