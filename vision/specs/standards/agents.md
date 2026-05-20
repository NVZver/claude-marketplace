# Agent Standards — claude-marketplace

The behavioral rules every agent (orchestrator, sub-agent, LSA skill) operating in this repo follows.

## Eight first principles (the constitution)

Verbatim from `vision/VISION.md` §2 (`vision/VISION.md:50`):

1. **Trust is the product.** A fast wrong answer is a defect. A grounded "I cannot verify this" is a feature.
2. **Two groundings, always.** Facts trace to sources. Code traces to specs. No exceptions; only explicit, marked assumptions.
3. **Ceremony scales to weight.** A typo fix does not get a discovery phase. A new module does not skip one. The system *escalates* rigor; it never front-loads it.
4. **Knowledge is not Actor.** Keep what-is-true separate from how-to-act. Boundary violations are the highest-severity defect.
5. **The map is not the territory.** Load registries always; load full definitions only on match. Context is a budget.
6. **Read before you write.** In-repo config → in-repo docs → the code itself → external sources → ask the human. In that order.
7. **The human owns intent; the system absorbs reality.** Specs and gates are human-owned. Code and execution are agent-owned. But a developer may edit code directly — the system's job is then to *reconcile*: detect the divergence and offer to update the spec to match, never to block the edit or silently let the spec rot.
8. **The system improves itself.** Every iteration leaves a trace: a retro, a metric, a changelog entry. Drift is a measured failure mode, not a surprise.

## Gate types

Two gate types govern every human-in-the-loop interaction. Source: `lsa/ARCHITECTURE.md` §5 (Phase 1):

- **Hard Confirm.** Stop completely. Present the artifact. Do not proceed until the human explicitly approves. No implicit approval accepted. Examples: `lsa-specify` Step 4 (requirements.md), `lsa-specify` Step 5 (test-suites.md), every `lsa-reconcile` per-module gate.
- **Soft Confirm.** Present the artifact. Wait for approval or corrections. Human may approve, correct inline, or delegate corrections to agent. Proceed once human is satisfied. Examples: `lsa-specify` Step 6 (contract.yaml), `lsa-specify` Step 7 (design.md).

## Escalation rules (tier selection)

Source: `vision/VISION.md` §4 (`vision/VISION.md:122`): *"The orchestrator picks the tier by chain-of-thought, then states its reasoning and the human confirms or overrides."*

- **Start at the lowest plausible tier.** Default to T1; escalate the moment the work crosses a boundary (`vision/VISION.md:124`): new module · API/contract change · data-model change · ~5 files · no existing spec.
- **The chain-of-thought is visible.** The orchestrator names the signals it weighed. Hidden reasoning is a defect, not a style choice.
- **Human overrides win.** If the human picks a lower tier than the orchestrator proposed, the orchestrator logs the override and proceeds at the human's tier — never silently substitutes its own. Per `core/skills/tier-selector/SKILL.md` Constraints.
- **Corrections become training.** Over time, the human's corrections to the orchestrator's tier calls become few-shot examples in `core/tier-selector` (currently four, from `vision/VISION.md:128`).

## Reconcile is absorptive, not blocking

Per `vision/VISION.md:144`: *"It does NOT block or revert. It reasons about the delta… On confirm: reverse-sync — the spec absorbs reality, drift closes."*

`lsa-reconcile` is the agent that runs the reconcile loop. Its constraints (`lsa/skills/lsa-reconcile/SKILL.md`):
- Never block, revert, or reformat the artifact edits themselves.
- Never leave the spec self-contradictory — class (a) replaces, doesn't append-next-to.
- One module at a time. Hard confirm per module.

## Marker convention

Across this repo, uncertainty is marked **lowercase**:

- `[assumption: <why>]` — claim is inferred; the source for the inference is named in the marker.
- `[cannot verify]` — claim has no available source; total uncertainty.
- `[assumption: inferred from <source>; verify]` — replaces the historical `[INFERRED — verify]` (used in `lsa-init` brownfield mode).

Source: `core/skills/ground-rules/SKILL.md` Rule 1; LSA-side sweep documented in `lsa/CHANGELOG.md` v0.2.0 *"Changed — Marker convention swept to lowercase"*.

## Read-before-write order

When an agent needs context for a task, the read order is **in-repo config → in-repo docs → the artifact itself → external sources → ask the human**. Per `vision/VISION.md:59`. Specifically:

1. `.lsa.yaml` (or LSA defaults) for path config.
2. The configured constitution (`vision/VISION.md` in this repo).
3. `${specs_root}/main.spec.md` + the relevant module spec.
4. The artifact being changed.
5. External docs (library specs via `context7` MCP when available).
6. Ask the human only after the above are exhausted.
