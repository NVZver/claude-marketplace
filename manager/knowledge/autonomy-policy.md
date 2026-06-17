> **Trace.** On load, print first: `=============== [manager/knowledge/autonomy-policy.md] [manager] ===============`

# Autonomy policy — knowledge

The `.lsa.yaml` `autonomy:` knob that decides how much human-in-the-loop a parallel `manager:implement` run uses at the merge/deploy boundary. Three levels, **default `manual`**; each binds to a concrete SDLC outcome. The gate is identical at every level — autonomy changes only *who pushes the button after green*, never *whether the gate must be green*.

Source: pitch `.lsa/pitches/parallel-agent-delivery.md:22` (success #4), `:26` (slicing — `semi`/`auto` later, gated on `manual` proving safe), `:41` (full-auto still gated); solution-design `.lsa/research/parallel-agent-delivery-solution-design.md:38-44`. Mental model borrowed from Claude Code's graduated mode ladder + Anthropic's HITL-by-default posture (prior-art C4).

## The ladder

| Level | At the merge boundary | At the deploy boundary | Status |
|---|---|---|---|
| `manual` *(default)* | the human performs the merge after seeing the gate-green PR + SHA | n/a — no deploy | **built** (Epic 1/2) |
| `semi` | **auto-merge on green** — the serialized-merge step lands the tested SHA without a human prompt | the human still owns deploy | **built** (this epic) |
| `auto` | auto-merge on green | full SDLC: deploy + healthcheck, still gated by the same green gate + a defined rollback | **built** (Epic 4) |

- **Default is `manual`.** Absent or unrecognized `autonomy:` → `manual`. Full-auto is never the silent default (pitch success #4).
- **The gate never weakens.** `semi`/`auto` only remove the human *prompt* after the gate is green; a red gate blocks the merge at every level (pitch `:41`).
- **Escalation is gated on evidence.** `semi` is intended for use only once `manual` has proven safe in dogfooding (pitch `:26`); `auto` likewise after `semi`.

## `semi` — auto-merge on green (this epic)

Under `semi`, when an epic's PR passes the gate (independent `lsa:reconcile` + the `.lsa.yaml` `gate:` checks) against the up-to-date base, the serialized-merge step ([`serialized-merge.md`](./serialized-merge.md)) lands the tested SHA **without asking the human** — one PR at a time, still serialized, still merging only the tested SHA. Only the serialized-merge step writes roadmap status (the roadmap-write lock is unchanged). The human is not prompted per-merge but still:

- owns the **final merge of the integration branch to `main`** (pitch no-go #2 — `semi` auto-merges *into the integration branch*, not into `main`);
- owns **deploy** (that is `auto`, Epic 4);
- can set `autonomy: manual` to restore the per-merge prompt at any time.

A `semi` run still reports each merge `merged @ <sha>` with its cited gate artifact (`core/ground-rules` Rule 7) — auto-merge does not mean unreported.

## `auto` — full SDLC: deploy + healthcheck (Epic 4)

`auto` extends `semi`: after a PR auto-merges on green, the engine runs the project's **deploy** command and then a **healthcheck**, and may report `deployed` only after the healthcheck passes (`core/ground-rules` Rule 7 — e.g. `/healthz` returns 200). Like `gate:`, no deploy/healthcheck tool is hardcoded — the repo supplies the commands (a `deploy` and a `healthcheck` entry alongside the `gate:` checks, run only at `auto`).

- **Still gated.** Deploy runs only after the same green gate that every level requires; a red gate blocks before deploy is reached (pitch `:41`).
- **Rollback is defined.** If the healthcheck fails, the engine runs the configured **rollback/revert** step and reports the deploy `failed` with the healthcheck output — never `deployed` (pitch rabbit-hole 6 `:41`).
- **`main` still belongs to the human.** `auto` operates on the integration branch + the deploy target; it does not change the human-owned integration → `main` merge (pitch no-go #2).
- **Default stays `manual`.** `auto` is opt-in and intended only after `semi` has proven safe (pitch `:26`).
