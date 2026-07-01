> **Trace.** On load, print first: `=============== [.lsa/modules/observer/spec.md] [vision] ===============`

# Module Spec — `observer`

Live observe-and-coach + checkpoint-gate discipline. Rides Claude Code's self-paced `/loop` through two Actors: `observe` reacts to the user's file changes through a chosen role, emitting role-appropriate feedback (or silence) each cycle until stopped; `verify-checkpoint` grades an implementer's increment does·only on a checkpoint signal, emitting a CLEAR or BLOCK verdict.

**Plugin manifest:** [`observer/.claude-plugin/plugin.json`](../../../observer/.claude-plugin/plugin.json) (v0.2.0)
**Plugin README** (install, dependencies, roles): [`observer/README.md`](../../../observer/README.md)
**Feature requirements** (EARS + Gherkin, flows F1–F5): [`../../features/observer/requirements.md`](../../features/observer/requirements.md)
**Feature requirements** (`verify-checkpoint`, F1–F17): [`../../features/2026-07-01-paired-verify-observer-verifier/requirements.md`](../../features/2026-07-01-paired-verify-observer-verifier/requirements.md)
**Knowledge** (the four role bundles — lens / voice / cadence, plus interviewer difficulty rules): [`observer/knowledge/roles.md`](../../../observer/knowledge/roles.md)

## Role in the marketplace

`observer` is an optional pack. It owns live, in-the-loop work while the user codes — coaching *and* gating. It exposes two Actors and a single Knowledge file:

1. **`observe` Actor** ([`observer/skills/observe/SKILL.md`](../../../observer/skills/observe/SKILL.md)) — confirms a role at kickoff, conditionally scaffolds an interviewer exercise, rides the self-paced `/loop`, applies the active role's bundle each cycle, supports mid-session role-switch, and stops with a stated reason. Persists the active role + interviewer difficulty in a session-state note re-read each cycle.
2. **`verify-checkpoint` Actor** ([`observer/skills/verify-checkpoint/SKILL.md`](../../../observer/skills/verify-checkpoint/SKILL.md)) — rides the self-paced `/loop` and, on a checkpoint signal an implementer emits when it pauses having finished one F-requirement, grades that increment on two of `lsa:reconcile`'s three checks — **does** (target-scoped scenarios pass; not-yet-built requirements out of scope) and **only** (every changed hunk traces to a requirement) — and emits `CLEAR` (auto-clears without interrupting the human) or `BLOCK` (names the failing check, surfaced before the next task). It does NOT apply the whole-plan **all** completeness check — that stays with the final `lsa:reconcile`. Read-only to the artifacts it grades; the verdict is an artifact the implementer could not author. Not `lsa:verify` (the before-delegation grounding check) — it is the after-increment gate, the per-increment analogue of `lsa:reconcile`. Reads the checkpoint-signal contract it defines; the signal *writer* ships in epic `paired-verify/lsa-delegate-wiring`.
3. **`roles.md` Knowledge** ([`observer/knowledge/roles.md`](../../../observer/knowledge/roles.md)) — the four role bundles (rubber-duck, pair-programmer, interviewer, custom) as data the `observe` Actor reads and applies generically. `verify-checkpoint` does not read it.

Depends on `core` ([`observer/README.md`](../../../observer/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — format discipline every response inherits.

## Invariants

- **Versioning.** `observer` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.2.0.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Depends on `core`.** Documented in `observer/.claude-plugin/plugin.json` `dependencies` field and `observer/README.md` *"Depends on"*.
- **Knowledge ≠ Actor.** All per-role lens/voice/cadence/difficulty lives in `observer/knowledge/roles.md`; the `observe` Actor reads it and never hard-codes per-role branches. Per `.lsa/VISION.md:61` (principle 4). Highest-severity invariant for this module.
- **Substrate-native.** Both Actors ride the existing self-paced `/loop`; neither implements a scheduler, timer, or poll. Per `.lsa/VISION.md:66` (principle 9).
- **Per-increment grader is does·only, never all.** `verify-checkpoint` applies only the **does** and **only** checks per increment; the whole-plan **all** completeness check stays with the final `lsa:reconcile` (`lsa/skills/reconcile/SKILL.md:33-34`). Not-yet-built requirements are out of scope for a given increment.
- **Independent, read-only grader.** `verify-checkpoint` never writes to the artifacts it grades (tests, `.feature` scenarios, `.lsa.yaml` `gate:` config); its verdict is an artifact the implementer could not author (`lsa/skills/reconcile/SKILL.md:44-45`). It is distinct from `lsa:verify` (the before-delegation grounding check).
- **Actor separation.** `verify-checkpoint` does not read or modify `observer/knowledge/roles.md`; its behavior is independent of `observe`'s role bundles. Per `.lsa/VISION.md:61` (principle 4).
- **Role confirmed before observing.** Kickoff resolves to one confirmed role before the loop starts; no role, no observing (F1.5).
- **Scaffold is interviewer-only.** No exercise is generated in any non-interviewer role (F2.3).
- **State across stateless wakes.** The active role and interviewer difficulty are persisted in a session-state note the Actor writes and re-reads each cycle, because `/loop` does not remember state between wakes (grounding design note).

## Artifact paths

```yaml
- observer/skills/**/SKILL.md
- observer/knowledge/**/*.md
- observer/.claude-plugin/plugin.json
- observer/README.md
- observer/CHANGELOG.md
```
