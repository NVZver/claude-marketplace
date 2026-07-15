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
- `<plugin>:<skill>` — e.g. `manager:check`
- `<plugin>:<skill>.<sub>` — a sub-dispatch inside a skill, e.g. `lsa:delegate.verify-checkpoint`
- `<plugin>.<intent>` — a command-intent dispatch, e.g. `prompt-engineer.mechanical`

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

| # | Dispatch surface | Cite | Survives inline rollout? | Tier | Rationale |
|---|------------------|------|--------------------------|------|-----------|
| 1 | `manager:shape` → product-manager | `manager/skills/shape/SKILL.md:26` | No — transitional | inherit | Shaping is judgment-heavy; inline removal beats routing here |
| 2 | `manager:decompose` → project-manager | `manager/skills/decompose/SKILL.md:37` | No — transitional | inherit | Epic boundaries / risk ordering = judgment |
| 3 | `manager:next` → project-manager | `manager/skills/next/SKILL.md:26` | No — transitional; fast-path answers without dispatch | sonnet | Bounded sequencing over one roadmap file |
| 4 | `manager:check` → project-manager | `manager/skills/check/SKILL.md:23` | No — transitional | **haiku** | Mechanical hygiene scan (staleness rows, drift inventory) — the flagship cheapest-tier dispatch |
| 5 | `manager:implement` per-epic fan-out | `manager/skills/implement/SKILL.md:38` | Yes — worktree isolation load-bearing | inherit — **floored** | Writes production artifacts; a downgrade recreates the hallucinated-completion failure the engine exists to prevent |
| 6 | `lsa:delegate` → external implementer | `lsa/skills/delegate/SKILL.md:37` | Yes | inherit — **floored** | Code quality is load-bearing; outside the LSA boundary |
| 7 | `lsa:delegate` → `observer:verify-checkpoint` | `lsa/skills/delegate/SKILL.md:56` | Yes — independent per-increment grader | sonnet | Scoped does·only grading of ONE increment; bounded inputs. NOT haiku — grading is judgment |
| 8 | `lsa:reconcile` independent grader | `lsa/skills/reconcile/SKILL.md:33` | Yes — independence is the point | inherit — **floored, not a downgrade candidate** | The regression harness; grader quality is the safety floor of the whole system |
| 9 | prompt-engineer agent dispatches | `prompt-engineer/agents/prompt-engineer.md` | Per-command | sonnet for mechanical scan intents, inherit for authoring | Direct application of `.lsa/standards/code.md:53` |

Haiku candidates are deliberately few: row 4, plus any future model-side mechanical extraction. As the
inline rollout (`.lsa/roadmap.md:62`) completes, transitional rows 1-4 are **deleted, never re-tiered**
— once inline they inherit the session model. The durable routing surface is exactly rows 5-9.
