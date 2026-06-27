# Observer

Live observe-and-coach for the NVZver marketplace. `observer` rides Claude Code's self-paced **`/loop`** — the substrate's built-in repeat-this-prompt cycle — and reacts to your file changes through a chosen **role**, the persona whose lens, voice, and cadence shape the feedback. One Actor skill (`observer:observe`) drives the session; all per-role behavior is data read from one Knowledge file ([`knowledge/roles.md`](./knowledge/roles.md)), so the Actor holds zero per-role branching. Kickoff confirms a role before any observing begins; an interviewer session first scaffolds a runnable, initially-failing exercise; each cycle emits role-appropriate feedback (or stays silent); roles switch mid-session without restarting the loop; and the session ends with a stated reason.

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
observer:observe → confirm role (kickoff) → [interviewer: scaffold red exercise]
                 → ride /loop → per-cycle feedback or silence (active role's bundle)
                 → role-switch (next cycle, no restart) → stop (stated reason)
```

`observer` rides the substrate `/loop` rather than implementing its own scheduler, and keeps all role lens/voice/cadence in `roles.md` rather than in the Actor — per [`../.lsa/VISION.md`](../.lsa/VISION.md) principles 9 (substrate-native first) and 4 (Knowledge ≠ Actor).
