# Epic pro-tier-token-affordability/model-routing — Requirements

Parent: ../../../pitches/pro-tier-token-affordability.md (WS4) · Status: approved · Date: 2026-07-15
Modules: lsa (routing contract + delegate/reconcile), manager (roadmap-orchestration + implement), prompt-engineer (table row 9 only — no artifact change; resolved at the Agent boundary). Grounding: lsa:discover 2026-07-15.

## Functional requirements (EARS)

- **F1** (Ubiquitous) A shipped knowledge file `lsa/knowledge/model-routing.md` shall carry the
  per-dispatch tier table — one row per Agent-dispatch surface in the marketplace — each row naming
  the surface, its cite, its tier (`inherit` / `sonnet` / `haiku`), the rationale, and whether the
  surface survives the inline-dispatch rollout (`.lsa/roadmap.md:62`).
- **F2** (Ubiquitous) Routing policy shall be expressed as a `.lsa.yaml` `routing:` map (surface-key
  → tier), read at dispatch time; **zero `model:` pins ship in any plugin's Actor frontmatter**
  (lint C8 stays green — the map is repo config, not frontmatter).
- **F3** (Event) When a dispatching skill spawns an Agent for a routable surface, the system shall
  resolve the tier from `.lsa.yaml` `routing:<surface-key>` and pass it as the `Agent` `model`
  parameter, per the resolution contract in `lsa/knowledge/model-routing.md`.
- **F4** (Unwanted) If the `routing:` key is absent for a surface, or names a model the active plan
  lacks, then the dispatch shall degrade to `inherit` — never a hard error (`.lsa/standards/code.md:52`).
- **F5** (State) While resolving a floored surface — the `lsa:reconcile` independent grader, the
  `lsa:delegate` external implementer, and the `manager:implement` per-epic fan-out — the system
  shall never resolve below `inherit`, even if the map names a lower tier (rabbit hole 3).
- **F6** (Event) When a dispatch resolves a tier, the dispatcher shall echo the resolved tier in the
  dispatch line, so the owner sees which tier each dispatch ran on (solution sketch).
- **F7** (Ubiquitous) The tier table shall mark transitional surfaces (the inline-rollout rows,
  `.lsa/roadmap.md:62`) distinctly from the three durable isolation classes (external implementer,
  independent graders, worktree fan-out) per `.lsa/standards/code.md:59-63`.
- **F8** (Event) When the routing knowledge file is loaded, the system shall print its file-load
  trace line.

## Acceptance criteria (journey-shaped)

- **AC1** (F1, F7) Open `lsa/knowledge/model-routing.md` → every marketplace Agent-dispatch surface
  appears as a row with tier + cite + rationale + a transitional/durable marker.
- **AC2** (F3, F6) A `manager:check` dispatch → resolves `manager:check` → `haiku` from `.lsa.yaml`,
  passes `model: haiku` at the `Agent` boundary, and the dispatch line names `tier: haiku`.
- **AC3** (F4) Remove the `routing:` key (or set a model the plan lacks) → the dispatch runs on
  `inherit`; no hard error, no block.
- **AC4** (F5) Set `lsa:reconcile: haiku` in the map → the reconcile grader dispatch still resolves
  `inherit` (floor holds), with the refusal documented in the contract.
- **AC5** (F2) `bash scripts/lint.sh` C8 stays green — no `opus`/`haiku`/`fable` pin in any shipped
  Actor frontmatter; the haiku/sonnet tiers live only in `.lsa.yaml`.

## Design decisions (resolved at the 2026-07-15 spec gate)

- **D1** Knowledge-file home: `lsa/knowledge/model-routing.md` — same cross-plugin-cite pattern as
  `lsa/knowledge/quality-gate-contract.md` (already cited by `manager`). LSA owns `.lsa.yaml`.
- **D2** Surface-key format: `<plugin>:<skill>` (e.g. `manager:check`); sub-dispatches keyed
  `<plugin>:<skill>.<sub>` (e.g. `lsa:delegate.verify-checkpoint`); command-intent dispatches keyed
  `<plugin>.<intent>` (e.g. `prompt-engineer.mechanical`).
- **D3** This repo's `.lsa.yaml` ships the routing map (dogfood) with **non-`inherit` entries only**:
  `manager:next: sonnet`, `manager:check: haiku`, `lsa:delegate.verify-checkpoint: sonnet`,
  `prompt-engineer.mechanical: sonnet`. All other surfaces absent ⇒ `inherit`.
- **D4** Floored set (F5) = `lsa:reconcile` grader + `lsa:delegate` implementer + `manager:implement`
  per-epic fan-out. DRY: manager `next`/`decompose`/`check` resolve routing once via
  `manager/knowledge/roadmap-orchestration.md`; the three skills cite, never restate.

## Non-functional

- Packaging/wiring only — no rule, gate, or behavior profile added or weakened (pitch No-go 4, 5).
- Absent routing map ⇒ byte-for-byte today's behavior (`inherit` everywhere). Backward-compatible.
- Per-plugin SemVer + CHANGELOG + README in the same commit (`.lsa/standards/code.md:18-22`).
