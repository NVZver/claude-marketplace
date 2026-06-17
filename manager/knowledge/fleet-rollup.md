> **Trace.** On load, print first: `=============== [manager/knowledge/fleet-rollup.md] [manager] ===============`

# Fleet roll-up — knowledge

The end-of-run report a parallel `manager:implement` run emits: one screen that makes the gate output *be* the report, so a run never ends with "Done, you can check." Owned by `manager`; the net-new layer over per-epic gate artifacts.

Source: pitch `.lsa/pitches/parallel-agent-delivery.md:21` (success #3), `:42` (rabbit-hole 7 — one report contract); solution-design `.lsa/research/parallel-agent-delivery-solution-design.md:46-50, 78`.

## One report contract (no new table)

The roll-up invents **no new change-table format**. Its files section reuses the [`core/output`](../../core/skills/output/SKILL.md) Rule 7 **compressed inspection table** verbatim (`| # | file:line | type | summary |`), and groups files by **Conventional Commits `type(scope)`** — both already exist. This is the "one report contract" the pitch's rabbit-hole 7 requires.

**Relationship to `lsa-stage-reports`.** That backlog feature (`.lsa/pitches/lsa-stage-reports.md`) defines a per-LSA-stage *single-loop* exit report, also built on Rule 7's table. The fleet roll-up and the stage report therefore share the same primitive (Rule 7) — they are consistent by construction, not duplicative. The fleet roll-up consumes each epic's **`conformance.md` + gate artifacts** (which already exist after a run), so it does **not** block on the standalone per-stage feature; that feature remains separately scoped for single-loop runs.

## Roll-up shape (≤ one screen)

```
Fleet run — <N> epics, <waves> waves · autonomy: <level>

Per epic:
| epic | agent | wave | gate | state | proof |
|------|-------|------|------|-------|-------|
| <slug> | <agent-id> | 1 | reconcile PASS · gate green | merged @ <sha> | CI <run>, conformance.md |
| <slug> | <agent-id> | 1 | reconcile FAIL | attempted | gate output |
| <slug> | <agent-id> | 2 | gate green | pending | PR #<n> (human merge) |

Files changed (grouped by type(scope), Rule 7 inspection table):
| # | file:line | type | summary |
...

Proven facts:   <checks passed>, <SHAs>, <healthcheck results>
Open items:     <failed epics, un-torn-down worktrees, pending merges, deploy gaps>
```

## Rules

- **Per-agent attribution.** Every epic row names the agent that ran it and its wave — who did what is explicit.
- **Per-epic gate verdict.** Each row carries the independent `lsa:reconcile` verdict + the `.lsa.yaml` `gate:` result. No epic appears without a verdict.
- **Proven facts only.** The `state` column obeys `core/ground-rules` Rule 7: `merged @ <sha>` only when the serialized merge landed and the gate proved it (cite the artifact); `attempted` (gate failed) / `pending` (gate green, not yet merged) / `deployed` (only when the healthcheck passed) otherwise. Evidence is cited, never asserted.
- **Open items are surfaced, not buried.** Failed epics, un-torn-down worktrees, pending human merges, and any deploy/healthcheck gap appear in the Open items line (zero-tech-debt posture).
- **One screen.** The roll-up honors the 1–1.5-screen budget; grouping by `type(scope)` is the compression, not extra prose.
