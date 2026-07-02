> **Trace.** On load, print first: `=============== [manager/knowledge/parallel-rollup.md] [manager] ===============`

# Parallel-implementation roll-up — knowledge

The end-of-run report a parallel `manager:implement` run emits: one screen that makes the gate output *be* the report, so a run never ends with "Done, you can check." Owned by `manager`; the net-new layer over per-epic gate artifacts.

Source: pitch `.lsa/pitches/parallel-agent-delivery.md:21` (success #3), `:42` (rabbit-hole 7 — one report contract); solution-design `.lsa/research/parallel-agent-delivery-solution-design.md:46-50, 78`.

## One report contract (no new table)

The roll-up invents **no new change-table format**. Its files section reuses the [`core/output`](../../core/skills/output/SKILL.md) Rule 7 **compressed inspection table** verbatim (`| # | file:line | type | summary |`), and groups files by **Conventional Commits `type(scope)`** — both already exist. This is the "one report contract" the pitch's rabbit-hole 7 requires.

**Relationship to `lsa-stage-reports`.** That backlog feature (`.lsa/pitches/lsa-stage-reports.md`) defines a per-LSA-stage *single-loop* exit report, also built on Rule 7's table. This roll-up and the stage report therefore share the same primitive (Rule 7) — they are consistent by construction, not duplicative. The roll-up consumes each epic's **`conformance.md` + gate artifacts** (which already exist after a run), so it does **not** block on the standalone per-stage feature; that feature remains separately scoped for single-loop runs.

## Roll-up shape (≤ one screen)

```
Parallel run — <N> epics, <waves> waves · autonomy: <level>

Per epic:
| epic | agent | wave | gate | state | proof |
|------|-------|------|------|-------|-------|
| <slug> | <agent-id> | 1 | reconcile PASS · gate green | merged @ <sha> | CI <run>, conformance.md |
| <slug> | <agent-id> | 1 | reconcile FAIL | attempted | gate output |
| <slug> | <agent-id> | 2 | gate green | pending | PR #<n> (human merge) |
| <slug> | <agent-id> | 2 | not gated | not gated | agent self-report only — no reconcile / `gate:` evidence |

Files changed (grouped by type(scope), Rule 7 inspection table):
| # | file:line | type | summary |
...

Proven facts:   <required checks passed>, <SHAs>, <healthcheck results>
Open items:     <failed epics, un-torn-down worktrees, pending merges, deploy gaps>
Non-blocking:   <infra/deploy checks that failed but do not gate correctness, with reason>
```

## Rules

- **Per-agent attribution.** Every epic row names the agent that ran it and its wave — who did what is explicit.
- **Per-epic gate verdict.** Each row carries the independent `lsa:reconcile` verdict + the `.lsa.yaml` `gate:` result. No epic appears without a verdict — an epic whose gate never ran carries `not gated`, never a blank or an improvised label. The reconcile verdict is the independently-authored gate artifact (`conformance.md` + `reconcile: PASS|FAIL @ <graded-sha>` from a separate context) — see [`lsa` quality-gate-contract](../../lsa/knowledge/quality-gate-contract.md) §"Independence rule".
- **Blocking vs. non-blocking checks are distinct.** A check failure is reported by its class (`lsa` gate contract: required-correctness vs. non-required-infra/deploy). Only a **required (correctness)** failure marks an epic's `gate` as failed / blocks the `merged` state; a **non-required (infra/deploy)** failure — e.g. a deploy-permission ✗ — appears on the **Non-blocking** line with its reason, never as a failed gate. A green-looking required matrix with a red infra check still reports `gate green` for the epic. (Prevents the TripAnchor-1 mis-read where a Vercel permissions ✗ — `"Git author NVZver must have access … to create deployments"`, correctly non-blocking but noisy — read as a failed gate at a human glance: `.lsa/observations/2026-06-17-tripanchor-manager-implement.md:40,45`.)
- **Proven facts only.** The `state` column obeys `core/ground-rules` Rule 7 and has five values: `merged @ <sha>` only when the serialized merge landed and the gate proved it (cite the artifact); `attempted` (the gate **ran and failed**); `not gated` (the gate **never ran** — no independent `lsa:reconcile` verdict and no `.lsa.yaml` `gate:` output exists for the epic, e.g. an epic agent's unverified self-report of completion); `pending` (gate green, not yet merged); `deployed` (only when the healthcheck passed). `attempted` and `not gated` are distinct: the first is disproven, the second is unproven. Evidence is cited, never asserted.
- **Open items are surfaced, not buried.** Failed epics, `not gated` epics, un-torn-down worktrees, pending human merges, and any deploy/healthcheck gap appear in the Open items line (zero-tech-debt posture).
- **One screen.** The roll-up honors the 1–1.5-screen budget; grouping by `type(scope)` is the compression, not extra prose.
