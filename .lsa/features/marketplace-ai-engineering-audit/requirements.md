# Marketplace AI-Engineering Audit

## Intent

Audit all five marketplace modules (`core`, `lsa`, `manager`, `prompt-engineer`, and `observer`) for token efficiency, execution performance, small-model reliability, and top-tier-model leverage.

The audit is read-only: it produces evidence-backed recommendations and does not implement repository changes.

## Grounding

- `.lsa.yaml` defines all five modules and their behavior-bearing artifact paths.
- `README.md` states: “deterministic work is delegated to scripts; the AI works only on what is relevant and already pre-processed”.
- `.lsa/VISION.md` states: “The map is not the territory. Load registries always; load full definitions only on match. Context is a budget.”
- User request, 2026-07-19: “usefull for small models AND bust for Top tier models”.

## Functional Requirements

- **R1 — Complete surface inventory.** When the audit runs, it shall inventory behavior-bearing prompts, agent boundaries, knowledge surfaces, scripts, gates, and model-routing paths across all five modules.
- **R2 — Evidence and impact.** When the audit reports a material finding, it shall cite a file and searchable quote, explain the token or performance impact, and distinguish measured evidence from estimates.
- **R3 — Small-model robustness.** When the audit evaluates each module, it shall assess instruction density, ambiguity, hidden state, long-context dependence, branching, output schemas, error recovery, and deterministic validation.
- **R4 — Top-tier leverage.** When the audit evaluates each module, it shall assess parallelism, adaptive depth, context reuse, critique independence, uncertainty calibration, and tool or script delegation.
- **R5 — Actionable prioritization.** When the audit recommends a change, it shall rank expected impact, effort, risk, and validation method without implementing the change.
- **R6 — Standalone delivery.** When the audit is complete, it shall produce a standalone Cursor Canvas and a concise chat summary.

## Artifacts

| File | Purpose |
|---|---|
| [`report.md`](./report.md) | Frozen audit findings (as delivered) for later fix sessions |
| [`discover.md`](./discover.md) | Discover enrichment: `file:line` quotes + suggested improvements per recommendation |
| [`critique.md`](./critique.md) | Dual adversarial critique of findings/suggestions (read before remediation) |
| [`grounding.md`](./grounding.md) | Reference map + preparation verdict |

## Out of Scope

- Editing marketplace prompts, scripts, specs, or plugin versions **as audit remediation in the preparation turn**.
- Running behavioral model evaluations that consume paid external model capacity.
- Claiming token or latency improvements without measurements or clearly marked estimates.
