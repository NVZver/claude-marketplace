> **Trace.** On load, print first: `=============== [.lsa/modules/lsa/spec.md] [vision] ===============`

# Module Spec — `lsa`

The Living Spec Architecture plugin — a technology-agnostic spec layer. Skills + an orchestrator agent + a SessionStart hook + a config schema. LSA authors and verifies the spec; it does **not** implement — code-writing is delegated to an external implementer.

**Plugin manifest:** [`lsa/.claude-plugin/plugin.json`](../../../lsa/.claude-plugin/plugin.json) (v0.20.2)
**One-page contract** (the loop, rules, standards, templates): [`lsa/CORE.md`](../../../lsa/CORE.md)
**Plugin README** (skill table, install, configuration): [`lsa/README.md`](../../../lsa/README.md)
**Architecture** (directory structure, `.lsa.yaml` schema, branch management): [`lsa/ARCHITECTURE.md`](../../../lsa/ARCHITECTURE.md)
**Per-skill behavior** (source of truth per skill): [`lsa/skills/*/SKILL.md`](../../../lsa/skills/)

## Role in the marketplace

`lsa` is the spec-first methodology pack — humans write and own specs; an external implementer writes the code; LSA runs the two grounding checks (`verify` before delegation, `reconcile` after). The reconcile loop absorbs direct code edits rather than blocking them (Level 2.5, `.lsa/VISION.md:156`). Depends on `core` for:

- `core/ground-rules` — fact-grounding policy.
- `core/flow-selector` — flow classification (Quick / Standard / Extended) upstream of the loop.
- `core/actor-template` — the shape every LSA skill body matches (named Role/Goal/Inputs/Steps/Output in `CORE.md` §4).

## The loop

`discover → specify → verify → delegate → reconcile`, driven by the `orchestrator` agent. Code-writing happens at `delegate`, outside LSA. Ceremony scales to weight (`CORE.md` §2).

## State files

| File | Owner | Purpose |
|---|---|---|
| `.lsa.yaml` | Human (or `init`) | Path + mode + module config. |
| `${specs_root}/features/<name>/requirements.md` | `specify` | EARS requirements + user flows. |
| `${specs_root}/features/<name>/<flow>.feature` | `specify` | Gherkin acceptance scenarios. |
| `${specs_root}/features/<name>/grounding.md` | `verify` | Per-reference grounding result (`exists @ file:line` / `new` / `[ASSUMPTION]`). |
| `${specs_root}/features/<name>/conformance.md` | `reconcile` | Requirement → satisfying change/test (does · only · all). |

Baseline SHA per module (consumed by the SessionStart drift hook and `reconcile`'s diff base) is recovered on demand from `git log -1 --format=%H -- <spec-path>`; no separate state file is written.

## Invariants

- **Markdown + small JSON / YAML / bash surface.** No `/src/`. Plugin manifest is JSON; config is YAML; hook is bash. Per `.lsa/standards/code.md`.
- **Technology-agnostic; not the implementer.** LSA authors EARS + Gherkin specs and runs the two checks; code-writing is delegated to any implementer (`.lsa/VISION.md` §4 *"The implementer is external"*). Standards adopted: EARS + Gherkin (Specification by Example) — interoperable with Spec Kit / Kiro / Cursor.
- **One uniform instruction pattern.** Every skill and agent body is Role / Goal / Inputs (each sourced `user` / `discover` / `self`) / Steps (1:1 input → CoT → output) / Output. Per `CORE.md` §4.
- **`discover` is the universal input-resolver.** Context inputs for any skill are gathered by `discover`; only free text comes from the user (`CORE.md` §4).
- **The two checks are the product.** `verify` grounds the spec against the codebase before delegation and blocks an ungrounded spec; `reconcile` checks the returned diff **does · only · all** (scenarios pass ×N ≥95%; every hunk traces; every requirement covered), emits `conformance.md`, and absorbs drift. Per `CORE.md` §6.
- **Reconcile is absorptive, not blocking** (`.lsa/VISION.md:144`). The `reconcile` skill never blocks, reverts, or reformats the code; it edits the spec to match reality.
- **`orchestrator` routes; it never implements.** It reads each sub-agent's `## Inputs`, resolves them via `discover`, delegates, and collects output. Per `lsa/agents/orchestrator.md`.
- **Gate-delivery — show → approve → write (lsa v0.17.0).** Adopts `core` v0.13.0 (`.lsa/modules/core/spec.md`, Rule 7 *Authorization boundary* / *Delivery test*, Rule 5 *Self-contained gates*). `specify` now **drafts** requirements + `.feature` scenarios, shows the full draft, takes approval, and writes `requirements.md` + `<flow>.feature` **only on approve** — nothing on disk before the gate. The `orchestrator` surfaces each sub-agent's `## Output` **verbatim to the human** before any gate (a sub-agent transcript is invisible) and, when it runs as a subagent itself, returns pending gates to the dispatcher rather than attempting `AskUserQuestion`. The convention is recorded once in `lsa/knowledge/conventions.md` § AskUserQuestion convention and cited by skills.
- **Depends on `core`** for `flow-selector`, `ground-rules`, `output`, `actor-template`. Documented in `lsa/.claude-plugin/plugin.json: description` and `lsa/README.md` *"Depends on"*.
- **Spec source-of-truth.** Each skill's behavior is owned by its `SKILL.md`; the shared contract is `CORE.md`; this module spec carries module-level invariants only.
- **Versioning.** `lsa` evolves with its own SemVer + CHANGELOG. Currently v0.20.2.
