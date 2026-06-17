> **Trace.** On load, print first: `=============== [manager/knowledge/autonomy-policy.md] [manager] ===============`

# Autonomy policy — knowledge

The `.lsa.yaml` `autonomy:` knob that decides how much human-in-the-loop a parallel `manager:implement` run uses at the merge/deploy boundary. Three levels, **default `manual`**; each binds to a concrete SDLC outcome. The gate is identical at every level — autonomy changes only *who pushes the button after green*, never *whether the gate must be green*.

Source: pitch `.lsa/pitches/parallel-agent-delivery.md:22` (success #4), `:26` (slicing — `semi`/`auto` later, gated on `manual` proving safe), `:41` (full-auto still gated); solution-design `.lsa/research/parallel-agent-delivery-solution-design.md:38-44`. Mental model borrowed from Claude Code's graduated mode ladder + Anthropic's HITL-by-default posture (prior-art C4).

## The ladder

| Level | At the merge boundary | At the deploy boundary | Status |
|---|---|---|---|
| `manual` *(default)* | the human performs the merge after seeing the gate-green PR + SHA | n/a — no deploy | **built + validated default** |
| `semi` | **auto-merge on green** — the serialized-merge step lands the tested SHA without a human prompt | the human still owns deploy | **built, not yet enabled** (see Enablement gate) |
| `auto` | auto-merge on green | full SDLC: deploy + healthcheck, still gated by the same green gate + a defined rollback | **built, not yet enabled** (see Enablement gate) |

- **Default is `manual`.** Absent or unrecognized `autonomy:` → `manual`. Full-auto is never the silent default (pitch success #4).
- **The gate never weakens.** `semi`/`auto` only remove the human *prompt* after the gate is green; a red gate blocks the merge at every level (pitch `:41`).
- **Enablement gate — `semi`/`auto` are built but not yet validated.** The pitch ships `manual` first and gates the higher levels on *"the first slice proving safe in dogfooding"* (`.lsa/pitches/parallel-agent-delivery.md:26`). Until `manual` has run on real parallel work and proven safe, the config SHOULD stay `manual`; `semi` is enabled only after that, and `auto` only after `semi`. Setting a higher level beforehand enables un-dogfooded behavior — `manager:implement` surfaces a one-line caution when it resolves a non-`manual` level.

## Unattended multi-PR churn — per-level scope + checkpoint

A single `manager:implement` run can produce **many PRs back-to-back** — one per epic, and across waves the engine auto-advances to the next epic with no pause. Observed live: after one PR merged, the next opened immediately with no human gate between features (observation log C5, [`../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md:46`](../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md) *"Engine continues fully autonomously — no human gate between PRs... churning the backlog PR-after-PR with no pause"*; flagged at `:63` *"C5 — no human checkpoint between forks"*). Whether that churn is in scope, and where the human checkpoint sits, depends on the level. **The intended default is `manual`: the human is the checkpoint at every merge, so unattended multi-PR churn is out of scope by default.**

| Level | Unattended multi-PR / multi-feature churn | Where the human checkpoint sits |
|---|---|---|
| `manual` *(default)* | **Out of scope.** The run stops at each gate-green PR and waits; it does not auto-advance the merge. The agents *build* the wave in parallel without pause, but no PR merges and no next wave starts until the human merges. | **At every merge.** The human reviews the gate-green PR (SHA + gate artifact) and performs each merge; the run cannot churn PR-after-PR into the integration branch unattended. |
| `semi` | **In scope, into the integration branch only.** Once enabled, the engine auto-merges each gate-green PR and advances to the next epic/wave without a per-merge prompt — multi-PR churn *is* the intended behavior at this level. | **At the integration → `main` merge.** The human owns the final merge of the integration branch to `main` (no-go #2); that is the single remaining checkpoint after a `semi` churn. |
| `auto` | **In scope, through deploy.** `semi`'s churn plus deploy + healthcheck per merge — the fullest unattended mode. | **At the integration → `main` merge** (still human-owned) and at any **healthcheck failure** (rollback + `failed` report halts the churn). |

- **The checkpoint is the merge prompt, not the build.** At `manual`, the parallel *build* still runs unattended within a wave; what `manual` reserves for the human is every **merge** — so no feature reaches the integration branch without a human button-press, and the engine cannot silently churn the whole backlog. The plan-proposal gate ([`../skills/implement/SKILL.md`](../skills/implement/SKILL.md) Step 3) is an additional, earlier human checkpoint at every level, before any dispatch.
- **Multi-PR churn is opt-in, never the silent default.** Because the default is `manual` and `semi`/`auto` sit behind the Enablement gate above, an unattended PR-after-PR run only happens after the human has explicitly raised the level past `manual`. A bare run on the default config checkpoints at every merge.

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
