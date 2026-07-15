> **Trace.** On load, print first: `=============== [lsa/knowledge/model-routing.md] [lsa] ===============`

# Model routing — knowledge

The single source of truth for **which model each Agent dispatch runs on**. Routing exists only at
Agent-dispatch boundaries — skills and slash commands run in the MAIN thread and inherit the session
model; there is no per-skill override (`code.claude.com/docs/en/sub-agents`). So routing is a table
over the marketplace's actual dispatch surfaces plus a `.lsa.yaml` map read at dispatch time.

This complements the two model rules in [`.lsa/standards/code.md`](../../.lsa/standards/code.md): the
**Model policy** (§"Model policy" — `inherit` default, `sonnet` legal only on mechanical sub-agents,
`opus`/`haiku`/`fable` never pinned in frontmatter) and **Dispatch efficiency** (§"Dispatch efficiency"
— the three isolation classes that survive the inline-dispatch rollout). Dispatch surfaces cite this
file; they do not restate the table.

## The `.lsa.yaml` `routing:` map (Fork E — decided)

Routing policy lives as a `routing:` map in `.lsa.yaml`, read at dispatch time — **zero `model:`
pins ship in any plugin's Actor frontmatter** (the map is repo config, not frontmatter, so lint C8
stays green). Shape:

```yaml
routing:
  <surface-key>: <tier>   # tier ∈ inherit | sonnet | haiku
```

Surface-key format:
- `<plugin>:<skill>` — e.g. `manager:next`
- `<plugin>:<skill>.<sub>` — a sub-dispatch inside a skill, e.g. `lsa:delegate.verify-checkpoint`
- `<plugin>.<intent>` — a command-intent dispatch, e.g. `prompt-engineer.mechanical`

**Wiring rule — the map lists only surfaces a dispatcher actually reads.** A tier is
real only when the dispatching skill resolves this map and passes the result as the
`Agent` `model` parameter. Three surfaces do so today: `manager:next` and `manager:check`
via the shared roadmap-orchestration contract (`../../manager/knowledge/roadmap-orchestration.md`
§"The contract" item 1 — cited by both skills, one wiring point for all roadmap dispatches),
and `lsa:delegate.verify-checkpoint` via `../skills/delegate/SKILL.md` §5. Every other surface
runs `inherit` — either floored by design, or scoped but not wired (e.g. `prompt-engineer.mechanical`,
whose agent-side resolver was reverted). Do not add a key for a surface no dispatcher reads:
that is dead config that reads as a saving which never happens.

## Resolution algorithm

A dispatcher resolves a surface's tier as follows:

1. **Floored surface?** If the surface is in the **floored set** — the `lsa:reconcile` independent
   grader, the `lsa:delegate` external implementer, or the `manager:implement` per-epic fan-out —
   resolve **`inherit`** and stop. A map entry naming a lower tier for a floored surface is ignored
   (these are the safety/quality floor of the system; routing them down saves tokens by weakening the
   only checks that catch everything else — pitch rabbit hole 3).
2. **Map lookup.** Otherwise read `.lsa.yaml` `routing:<surface-key>`.
3. **Absent or unavailable ⇒ `inherit`.** If the key is absent, or names a model the active plan
   lacks, resolve **`inherit`** — never a hard error, never a block (`.lsa/standards/code.md:52`;
   pitch rabbit hole 1). An absent map ⇒ every surface `inherit` ⇒ byte-for-byte today's behavior.
4. **Pass + echo.** Pass the resolved tier as the `Agent` tool `model` parameter, and **echo the
   resolved tier in the dispatch line** (`Dispatching <agent> (… tier: <tier>)`) so the owner sees
   which tier each dispatch ran on. `inherit` needs no map entry; echoing it is optional.

## Per-dispatch tier table (inventory verified 2026-07-15)

Durable routing surface = the three isolation classes of `.lsa/standards/code.md:59-63` (external
implementer · independent graders · worktree fan-out). Transitional = slated for inline removal by
`.lsa/roadmap.md:62`; once inline, the surface inherits the session model and has no routing lever.

The **Tier** column is the tier each surface runs on *today* — not an aspiration. A surface
is `inherit` unless a dispatcher reads the map for it (per the wiring rule above). The
**Wired?** column says whether that resolution actually exists.

| # | Dispatch surface | Cite | Wired? | Tier today | Notes |
|---|------------------|------|--------|-----------|-------|
| 1 | `manager:shape` → product-manager | `manager/skills/shape/SKILL.md:26` | — | inherit | Transitional (inline rollout); judgment-heavy — not a routing candidate |
| 2 | `manager:decompose` → project-manager | `manager/skills/decompose/SKILL.md:24` | — | inherit | Transitional; epic boundaries = judgment |
| 3 | `manager:next` → project-manager | `manager/skills/next/SKILL.md:26` | **Yes** | **sonnet** | Transitional (inline rollout), but wired now via the roadmap-orchestration contract. Bounded sequencing over one roadmap file. Fast-path answers plain "what's next" with no dispatch at all |
| 4 | `manager:check` → project-manager | `manager/skills/check/SKILL.md:23` | **Yes** | **haiku** | Transitional, but wired via the same contract. Mechanical hygiene scan (staleness rows, drift inventory) — the cheapest-tier dispatch |
| 5 | `manager:implement` per-epic fan-out | `manager/skills/implement/SKILL.md:38` | Floored | inherit | Writes production artifacts; a downgrade recreates the hallucinated-completion failure the engine exists to prevent |
| 6 | `lsa:delegate` → external implementer | `lsa/skills/delegate/SKILL.md:37` | Floored | inherit | Code quality is load-bearing; outside the LSA boundary |
| 7 | `lsa:delegate` → `observer:verify-checkpoint` | `lsa/skills/delegate/SKILL.md:56` | **Yes** | **sonnet** | A live down-route. Scoped does·only grading of ONE increment; bounded inputs. NOT haiku — grading is judgment |
| 8 | `lsa:reconcile` independent grader | `lsa/skills/reconcile/SKILL.md:33` | Floored | inherit | The regression harness; grader quality is the safety floor of the whole system — never a downgrade candidate |
| 9 | prompt-engineer agent dispatches | `prompt-engineer/agents/prompt-engineer.md` | — | inherit | A `sonnet` mechanical-scan route was reverted (kept at 0.8.3); re-add only if actually wired |

Live down-routes today: rows 3 (`manager:next` → sonnet), 4 (`manager:check` → haiku), and 7
(`verify-checkpoint` → sonnet). Rows 3–4 are **transitional** — slated for deletion (not re-tiering)
as the inline rollout (`.lsa/roadmap.md:62`) removes their dispatch; the durable surface is the three
isolation classes of `.lsa/standards/code.md:59-63` (external implementer · independent graders ·
worktree fan-out), of which row 7 is the one live down-route and the rest are floored to `inherit`.
New down-route = wire the dispatcher first, then add the map key — never the reverse.
