> **Trace.** On load, print first: `=============== [.lsa/modules/observer/spec.md] [vision] ===============`

# Module Spec — `observer`

Live observe-and-coach discipline. Rides Claude Code's self-paced `/loop` and reacts to the user's file changes through a chosen role, emitting role-appropriate feedback (or silence) each cycle until stopped.

**Plugin manifest:** [`observer/.claude-plugin/plugin.json`](../../../observer/.claude-plugin/plugin.json) (v0.1.0)
**Plugin README** (install, dependencies, roles): [`observer/README.md`](../../../observer/README.md)
**Feature requirements** (EARS + Gherkin, flows F1–F5): [`../../features/observer/requirements.md`](../../features/observer/requirements.md)
**Knowledge** (the four role bundles — lens / voice / cadence, plus interviewer difficulty rules): [`observer/knowledge/roles.md`](../../../observer/knowledge/roles.md)

## Role in the marketplace

`observer` is an optional pack. It owns one phase: live, in-the-loop coaching while the user works. It exposes a single Actor and a single Knowledge file:

1. **`observe` Actor** ([`observer/skills/observe/SKILL.md`](../../../observer/skills/observe/SKILL.md)) — confirms a role at kickoff, conditionally scaffolds an interviewer exercise, rides the self-paced `/loop`, applies the active role's bundle each cycle, supports mid-session role-switch, and stops with a stated reason. Persists the active role + interviewer difficulty in a session-state note re-read each cycle.
2. **`roles.md` Knowledge** ([`observer/knowledge/roles.md`](../../../observer/knowledge/roles.md)) — the four role bundles (rubber-duck, pair-programmer, interviewer, custom) as data the Actor reads and applies generically.

Depends on `core` ([`observer/README.md`](../../../observer/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — format discipline every response inherits.

## Invariants

- **Versioning.** `observer` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.1.0.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Depends on `core`.** Documented in `observer/.claude-plugin/plugin.json` `dependencies` field and `observer/README.md` *"Depends on"*.
- **Knowledge ≠ Actor.** All per-role lens/voice/cadence/difficulty lives in `observer/knowledge/roles.md`; the `observe` Actor reads it and never hard-codes per-role branches. Per `.lsa/VISION.md:61` (principle 4). Highest-severity invariant for this module.
- **Substrate-native.** Rides the existing self-paced `/loop`; implements no scheduler. Per `.lsa/VISION.md:66` (principle 9).
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
