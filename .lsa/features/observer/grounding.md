# Grounding — observer

Verdict: **GROUNDED**

## Reference map

| Reference (spec names it) | Status |
|---|---|
| Self-paced `/loop` cycle primitive (F3, F5) | exists @ substrate — Claude Code `/loop` skill (omit interval → self-pace) + `ScheduleWakeup` (dynamic-mode wake). Observer rides it; does not rebuild scheduling. |
| `AskUserQuestion` role-confirmation gate (F1) | exists @ substrate — Claude Code native picker tool. |
| Plugin manifest shape (`name/description/version/author/dependencies`) | exists @ `manager/.claude-plugin/plugin.json:1-11` (pattern to copy). |
| `marketplace.json` plugin registration | exists @ `.claude-plugin/marketplace.json:5-31` (5 plugins; add 6th). |
| `.lsa.yaml` module entry (`spec` + `artifact_paths`) | exists @ `.lsa.yaml` modules block (pattern to copy). |
| Actor shape Goal/Input/Steps/Output/Constraints | exists @ `core/skills/actor-template/SKILL.md:13-21`. |
| Knowledge ≠ Actor invariant (roles=Knowledge, observe=Actor) | exists @ `.lsa/VISION.md:61` (principle 4). |
| `observer/.claude-plugin/plugin.json` | **new** |
| `observer/skills/observe/SKILL.md` (Actor) | **new** |
| `observer/knowledge/roles.md` (Knowledge) | **new** |
| `observer/README.md`, `observer/CHANGELOG.md` | **new** |
| `.lsa/modules/observer/spec.md` | **new** |
| Root `README.md` plugin count 5→6 | edit existing @ `README.md` |

No existing `observer/` dir, no `observ*` token in `marketplace.json`/`.lsa.yaml`, no `name: observe` skill — the new surfaces are legitimately new (verified via grep/ls).

## Feasibility

| Flow | Buildable? |
|---|---|
| F1 Kickoff | yes — `AskUserQuestion` gate + context inference |
| F2 Scaffold | yes — `Write` an exercise file with failing tests |
| F3 Observe cycle | yes — read diff per `/loop` self-paced wake |
| F4 Role-switch | yes — see state-continuity note below |
| F5 Stop | yes — stop on user request; inactivity → self-conclude wake |

## Design note for delegate (non-blocking)
`/loop` re-fires the same prompt each cycle. Mutable session state — the **active
role** (F4) and the interviewer's **difficulty level** (F3.5) — must be carried
across wakes explicitly. The implementer must persist/read this state (e.g., a
small session-state note the Actor writes and re-reads each cycle), since the loop
itself is stateless between wakes. Feasible; flagged so the implementer handles it
deliberately rather than assuming the loop remembers.
