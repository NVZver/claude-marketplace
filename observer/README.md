# Observer

Live observe-and-coach for the NVZver marketplace. `observer` rides Claude Code's self-paced **`/loop`** — the substrate's built-in repeat-this-prompt cycle — through two Actor skills. **`observer:observe`** reacts to your file changes through a chosen **role**, the persona whose lens, voice, and cadence shape the feedback; all per-role behavior is data read from one Knowledge file ([`knowledge/roles.md`](./knowledge/roles.md)), so the Actor holds zero per-role branching. **`observer:verify-checkpoint`** gates an implementer's work: on a checkpoint signal it grades one finished F-requirement **does·only** and emits `CLEAR` (auto-clears) or `BLOCK` (surfaced to you). One coaches, one gates; both ride the same substrate `/loop` and build no scheduler.

Spec: [`.lsa/modules/observer/spec.md`](../.lsa/modules/observer/spec.md).

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install observer@NVZver
/reload-plugins
```

Install `core` first — `observer` cites `core/ground-rules` for fact-grounding and `core/output` for format discipline.

## Depends on

- **`core`** — `core/ground-rules` (fact-grounding policy), `core/output` (format discipline). Declared in [`./.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) `dependencies` field.

## Skills

| Skill | What it does |
|---|---|
| `observer:observe` | Start a live observe-and-coach session. Confirms a role at kickoff (proposes an inferred one, or adopts the one you name), gates a custom role on a one-line lens, optionally scaffolds an interviewer exercise (problem + placeholder + a failing test suite), then rides the self-paced `/loop`: each cycle it reads your changes and emits feedback — or silence — shaped by the **active role's** lens/voice/cadence read from [`knowledge/roles.md`](./knowledge/roles.md). Switches role mid-session without restarting the loop, and stops on request / self-conclusion / inactivity timeout with a stated reason. |
| `observer:verify-checkpoint` | Gate an implementer's increment. Rides the self-paced `/loop`; each cycle it watches for a **checkpoint signal** the implementer emits when it pauses having finished one F-requirement (no signal → silent no-op). On a signal it scopes to the changes since the previous checkpoint and grades **does·only**: do the scenarios mapped to the target F pass (treating not-yet-built requirements as out of scope), and does every changed hunk trace to a requirement (untraced = over-delivery). It does **not** apply the whole-plan **all** completeness check — that stays with `lsa:reconcile`. Pass both → `CLEAR` (auto-clears without interrupting you); fail either → `BLOCK` naming the failing check, surfaced before the next task. Read-only to the graded artifacts. **Not `lsa:verify`** — that is the *before*-delegation grounding check; this is the *after*-increment gate, the per-increment analogue of `lsa:reconcile`. |

## Roles

Role behavior is data in [`knowledge/roles.md`](./knowledge/roles.md), not logic in the Actor:

| Role | Lens | Voice | Cadence |
|---|---|---|---|
| `rubber-duck` | Your own reasoning, mirrored back; near-zero context, stateless | Reflective, asks rather than tells; never prescribes | Responsive each cycle |
| `pair-programmer` | simpler > stdlib > reuse-dep > reuse-code > project-view > refactor > realistic-tests; searches the project before flagging | Peer to peer | Quiet — speaks only on a genuine catch |
| `interviewer` | solution > bugs > performance > style; non-destructive | Non-breaking gotcha + objective encouragement | Responsive; adapts difficulty across cycles |
| `custom` | A one-line lens/voice you supply at kickoff | As supplied | As supplied (responsive by default) |

## How it fits

```
observer:observe          → confirm role (kickoff) → [interviewer: scaffold red exercise]
                          → ride /loop → per-cycle feedback or silence (active role's bundle)
                          → role-switch (next cycle, no restart) → stop (stated reason)

observer:verify-checkpoint → ride /loop → per-cycle: checkpoint signal? no → silent no-op
                          → yes → scope to increment for target F → grade does·only
                          → CLEAR (auto-clear) | BLOCK (named check, surfaced to human)
```

`observer` rides the substrate `/loop` rather than implementing its own scheduler, keeps all role lens/voice/cadence in `roles.md` rather than in the `observe` Actor — per [`../.lsa/VISION.md`](../.lsa/VISION.md) principles 9 (substrate-native first) and 4 (Knowledge ≠ Actor) — and grades increments read-only through `verify-checkpoint`, whose verdict is an artifact the implementer could not author. The two Actors are independent: `verify-checkpoint` never reads or writes `roles.md`, and applies only the **does·only** checks (the **all** whole-plan completeness check stays with [`lsa:reconcile`](../lsa/skills/reconcile/SKILL.md)).
