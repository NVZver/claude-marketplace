---
name: next
description: "Recommend what to work on next. Input: none (or a plain 'what's next' / 'recommend an order' question). Output: a plain 'what's next' gets a fast-path answer — the highest-priority backlog/not-started roadmap item quoted with a file:line citation, no agent dispatch; 'what should I pick' / 'sequence the backlog' dispatches the project-manager agent for dependency/risk/value sequencing and runs its returned pick gate. Reads ${specs_root}/roadmap.yaml on demand via scripts/roadmap-row.sh (whole-file read is fallback only)."
---

> **Trace.** On load, print first: `=============== [manager/skills/next/SKILL.md] [manager] ===============`


# Next

Recommend the next backlog item to work on. A plain "what's next" returns the highest-priority `backlog`/`not started` roadmap row directly (fast-path, no dispatch); a "recommend an order" / "what should I pick" question dispatches the `project-manager` agent for dependency/risk/value sequencing and runs its returned pick gate. Does not contain recommendation logic — that lives in the agent and [`../../knowledge/sequencing-heuristics.md`](../../knowledge/sequencing-heuristics.md). The dispatch → gate → re-render loop is the shared contract at [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).

## Goal

Tell the user what to build next — instantly for a plain "what's next", with dependency/risk/value reasoning when they ask for an ordering or selection — without manually reading roadmap state or invoking the agent directly.

## Input

- None required. The roadmap is the entry point; the agent reads ambient state (roadmap, pitches, branches, specs) internally.
- The fast-path contract at [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) — governs the Step 0 branch that answers a plain "what's next" directly from the roadmap before dispatch.

## Steps

0. **Fast-path branch: "what's next" → cited roadmap item (before dispatch).** When the question shape is a plain "what's next" / "what's the next backlog item" (per [`../../../core/knowledge/fast-path-source-of-truth.md`](../../../core/knowledge/fast-path-source-of-truth.md) §"Question-shape detection"), do NOT dispatch the agent. Get the highest-priority `backlog`/`not_started` item of the `${specs_root}/roadmap.yaml` ledger and quote it inline with its `file:line` citation per the shared knowledge file's §"Citation format", then exit cleanly. **Run the roadmap-row extractor** (this repo: `bash scripts/roadmap-row.sh`, which prints that item + its `path:line` deterministically from the YAML — Pro-safe, zero model tokens) and quote its output — do not whole-file-read the ledger on this happy path. Only if the extractor exits non-zero (no ledger / no backlog item — its fallback contract) do you fall through to a model-side `Read` of `${specs_root}/roadmap.yaml`. **Reserve the full agent dispatch in Step 1 for explicit "recommend an order" / "what should I pick" / "sequence the backlog" questions** — those need the agent's dependency/risk/value reasoning. **Fall through to Step 1** — with an observable note — if the extractor reports no backlog item, the ledger is empty, or the question carries the ordering/sequencing intent above. Observable result: either the highest-priority backlog item is quoted with its `file:line` citation and the skill exits, or an observable fall-through note and Step 1 dispatches the agent.

1. **Dispatch the project-manager and run its gate — per the shared contract.** Dispatch the `project-manager` agent with an explicit intent (`intent: recommend-next` for "what should I pick", `intent: sequence-backlog` for "sequence the backlog") and run the returned pick gate per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md). The agent returns the sequenced candidate list as a pending gate (each candidate + re-sequence / exit, top-ranked as the recommended default); this skill presents it via `AskUserQuestion`. No `lsa:discover` handoff — selecting a pick to decompose is `manager:decompose`'s job. Observable result: sequenced recommendation delivered, pick gate resolved by the user.

## Output

Either the highest-priority backlog row is quoted inline with a `file:line` citation (fast-path), or the agent's sequenced recommendation is delivered and the user's pick gate is resolved. No file writes — recommendation is read-only.

### Example Output

[illustrative]

```
> what's next
.lsa/roadmap.yaml:21 — onboarding-checklist | Onboarding checklist | Should | backlog
(fast-path: highest-priority backlog item via scripts/roadmap-row.sh, no agent dispatch)

> what should I pick and why
Dispatching project-manager (intent: recommend-next)...
Sequenced (2 candidates): 1. onboarding-checklist (no deps, unblocks scaffold) / 2. plugin-scaffold (blocked).
Gate — pick next item: [1] onboarding-checklist (recommended) / [2] plugin-scaffold / re-sequence / exit
```

## Constraints

- **Orchestrator only — per [`../../knowledge/roadmap-orchestration.md`](../../knowledge/roadmap-orchestration.md).** Dispatch with an explicit intent, run the gate, re-render. No recommendation logic here.
- **Recommend-only.** This verb never writes the roadmap or hands off to `lsa:discover`. Use `manager:decompose` to break a pick into epics; `manager:check` for hygiene writes. Once a pick is decomposed into epics, [`manager:implement`](../implement/SKILL.md) is the parallel build-execution entry point — it runs the epics in parallel (wave plan → isolated worktrees → gated PRs). Surfacing it here keeps the parallel engine findable from the recommend step (observation log C1 — entry-point discoverability, [`../../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md:83`](../../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md) *"C1 — entry-point discoverability. `manager:implement` hard to find."*).
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/manager:next` — manual invocation.
