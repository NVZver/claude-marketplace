# Observer

Live observe-and-coach for the NVZver marketplace. `observer` rides Claude Code's self-paced **`/loop`** — the built-in repeat-this-prompt cycle — through two skills. **`observer:observe`** watches you code and reacts to your file changes through a chosen **role**, the persona whose lens, voice, and cadence shape the feedback (rubber-duck, pair-programmer, interviewer, or custom); all per-role behavior is data read from one Knowledge file ([`knowledge/roles.md`](./knowledge/roles.md)), so the skill holds zero per-role branching. **`observer:verify-checkpoint`** gates an implementer's work: when the implementer signals it has finished one requirement, the skill grades that increment on two checks — *does* the work pass its acceptance scenarios, and does it change *only* what the requirement covers (**does·only**) — and emits `CLEAR` (auto-clears) or `BLOCK` (surfaced to you). One coaches, one gates; both ride the same `/loop` and build no scheduler.

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
| `observer:observe` | Start a live observe-and-coach session. Confirms a role at kickoff — adopts the one you name, or infers a candidate from a **signal→role table** (failing tests + stub → interviewer; feature-in-progress with tests → pair-programmer; exploratory, no tests → rubber-duck) and proposes it for confirmation. Gates a custom role on a one-line lens, optionally scaffolds an interviewer exercise (problem + placeholder + a failing test suite; in any other role it declines and offers a switch), then rides the self-paced `/loop`: each cycle it reads your changes and emits feedback — or silence — shaped by the **active role's** lens/voice/cadence read from [`knowledge/roles.md`](./knowledge/roles.md). Switches role mid-session without restarting the loop, and stops on request / self-conclusion / the inactivity limit — **2 consecutive no-change `/loop` cycles** by default, overridable at kickoff — with a stated reason. |
| `observer:verify-checkpoint` | Gate an implementer's increment. Its core unit is **grading one signalled increment**, run in either of two invocation modes with identical grading: **per-increment dispatch** (how [`lsa:delegate`](../lsa/skills/delegate/SKILL.md) drives it — dispatched once per increment) or a standalone **self-paced `/loop` rider** (each cycle it watches for a **checkpoint signal** the implementer emits when it pauses having finished one F-requirement; no signal → silent no-op). The note's file path is owned by the delegating context and shared by writer + reader (ephemeral, not committed). On a signal it scopes to the changes since the previous checkpoint and grades **does·only**: do the scenarios mapped to the target F pass (treating not-yet-built requirements as out of scope), and does every changed hunk trace to a requirement (untraced = over-delivery). It does **not** apply the whole-plan **all** completeness check — that stays with `lsa:reconcile`. Pass both → `CLEAR` (auto-clears without interrupting you); fail either → `BLOCK` naming the failing check, surfaced before the next task. Read-only to the graded artifacts. **Not `lsa:verify`** — that is the *before*-delegation grounding check; this is the *after*-increment gate, the per-increment analogue of `lsa:reconcile`. |

## Example

An observe session — the snippet is `[illustrative]` (constructed for readability, not copied from a live session):

```text
> /observer:observe

[observer] Kickoff — no role named; context is a Python file with a failing test.
Proposed role: pair-programmer (override: rubber-duck / interviewer / custom) > interviewer
Language / topic? > Python / binary search
Wrote a red exercise (problem + placeholder + 3 failing tests).

cycle 1 — solution: off-by-one — `hi = mid` drops the upper half; safer is `hi = mid - 1`.
cycle 2 — no edits for the timeout.
Stopped: inactivity timeout.
```

## Roles

Role behavior is data in [`knowledge/roles.md`](./knowledge/roles.md), not logic in the Actor:

| Role | Lens | Voice | Cadence |
|---|---|---|---|
| `rubber-duck` | Your own reasoning, mirrored back; near-zero context, stateless | Reflective, asks rather than tells; never prescribes | Responsive each cycle |
| `pair-programmer` | simpler > stdlib > reuse-dep > reuse-code > project-view > refactor > realistic-tests (recommendation priority — one top pick, fallback named explicitly); searches the project before flagging, search shown | Peer to peer | Quiet — speaks only on a genuine catch |
| `interviewer` | solution > bugs > performance > style; non-destructive | Non-breaking gotcha + objective encouragement | Responsive; lowers the bar after **3 consecutive stuck cycles**, rebuilds once unblocked |
| `custom` | A one-line lens/voice you supply at kickoff; scoped to that lens only (out-of-lens findings dropped) | As supplied | As supplied (responsive by default) |

## How it fits

```
observer:observe          → confirm role (kickoff) → [interviewer: scaffold red exercise]
                          → ride /loop → per-cycle feedback or silence (active role's bundle)
                          → role-switch (next cycle, no restart) → stop (stated reason)

observer:verify-checkpoint → grade ONE signalled increment (the core unit), via either:
                          (a) per-increment dispatch by lsa:delegate, OR (b) self-paced /loop rider
                          → checkpoint signal? no → silent no-op
                          → yes → scope to increment for target F → grade does·only
                          → CLEAR (auto-clear) | BLOCK (named check, surfaced to human)
                          (note path: delegate-owned, shared by writer + reader, ephemeral)
```

`observer` rides the substrate `/loop` rather than implementing its own scheduler, keeps all role lens/voice/cadence in `roles.md` rather than in the `observe` Actor — per [`../.lsa/VISION.md`](../.lsa/VISION.md) principles 9 (substrate-native first) and 4 (Knowledge ≠ Actor) — and grades increments read-only through `verify-checkpoint`, whose verdict is an artifact the implementer could not author. The two Actors are independent: `verify-checkpoint` never reads or writes `roles.md`, and applies only the **does·only** checks (the **all** whole-plan completeness check stays with [`lsa:reconcile`](../lsa/skills/reconcile/SKILL.md)).
