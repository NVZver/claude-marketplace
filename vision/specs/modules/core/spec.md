# Module Spec — `core`

The domain-neutral discipline plugin. Ships three skills + one always-on `CLAUDE.md` fragment.

**Plugin manifest:** [`core/.claude-plugin/plugin.json`](../../../../core/.claude-plugin/plugin.json) (v0.2.0)
**Plugin README:** [`core/README.md`](../../../../core/README.md)
**Verification probes:** [`core/VERIFICATION.md`](../../../../core/VERIFICATION.md) and [`core/tests/repo-anchored.md`](../../../../core/tests/repo-anchored.md)

## Role in the marketplace

`core` is the spine for any pack — domain-neutral discipline that applies regardless of whether `/src/` exists. Per `vision/VISION.md:73`: *"core/ (domain-neutral — always loaded; the spine for any pack)"*.

Three rules every Actor in this repo follows (`core/actor-template`): Goal / Input / Steps / Output / Constraints, with every Step producing an observable result. Three discipline behaviors every output follows (`core/ground-rules`): source every claim, never hedge in place of sourcing, read the real source, deliver only what was asked. One pre-task orchestration step every non-trivial task fires through (`core/tier-selector`): classify T1/T2/T3 by chain-of-thought and wait for human confirmation.

## Skills

### `core/ground-rules`

| | |
|---|---|
| **Role** | Always-on discipline that gates every substantive output. |
| **Behavioral contract** | Every factual claim carries a source + searchable quote; no fake-confidence hedging; read the real source before answering; deliver only what was asked. Per `core/skills/ground-rules/SKILL.md`. |
| **Surface** | On-demand skill + always-on via `core/CLAUDE.md` fragment (the user merges into their `/CLAUDE.md` or the configured constitution). |
| **Invariants** | Four rules apply together — no skipping a rule. Marker convention is lowercase `[assumption: <why>]` / `[cannot verify]`. Consumed by every LSA skill (`lsa/ARCHITECTURE.md` §2 P4, §7). |

### `core/actor-template`

| | |
|---|---|
| **Role** | The shape any Actor (skill, slash command, workflow) in this repo follows. |
| **Behavioral contract** | Five required sections, in order, no renames, no merges: Goal · Input · Steps · Output · Constraints. Every Step produces an observable result. Knowledge content does not appear in an Actor file. Per `core/skills/actor-template/SKILL.md`. |
| **Surface** | On-demand skill, fired when authoring or editing an Actor. |
| **Invariants** | Knowledge vs Actor separation (`vision/VISION.md:40`). All 8 LSA skills (`lsa/skills/*/SKILL.md`) match this shape as of `lsa` v0.2.0. |

### `core/tier-selector` — NEW in core v0.2.0

| | |
|---|---|
| **Role** | Pre-task chain-of-thought tier classifier — T1 / T2 / T3 with visible reasoning. |
| **Behavioral contract** | Apply Vision §4 boundary signals (new module · API/contract change · data-model change · ~5 files · no existing spec); match the four-row classification table; propose tier + 2–4-sentence rationale; **stop and wait for human confirmation** before any LSA ceremony fires. On confirm: T1 returns; T2 invokes `lsa-discover`; T3 invokes `lsa-discover` then `lsa-specify`. Per `core/skills/tier-selector/SKILL.md`. |
| **Surface** | On-demand skill **and** always-on via the `core/CLAUDE.md` fragment ("invoke before any non-trivial task"). Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §4.1 *"Tier firing: always-on CLAUDE.md fragment + on-demand skill"*. |
| **Invariants** | No LSA ceremony fires before tier confirmation; no inventing boundary signals not present in the task; human downward overrides win — log them, don't substitute. |

## CLAUDE.md fragment (always-on)

[`core/CLAUDE.md`](../../../../core/CLAUDE.md) is the opt-in always-on fragment for projects that install `core`. It declares two always-on rules:

1. Apply `core/ground-rules` to every substantive task.
2. Invoke `core/tier-selector` before any non-trivial task.

For this repo specifically, the slimmed `/CLAUDE.md` embeds these rules verbatim. Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §11.

## Cross-references

Downstream of `core`:

- `lsa/ARCHITECTURE.md` §2 P4 and §7 cite `core/ground-rules` for fact-grounding policy.
- `lsa/skills/lsa-discover/SKILL.md` is invoked downstream of `core/tier-selector` for every T2 / T3 task (per `core/CLAUDE.md` *"Tier outcomes"*).
- `lsa/skills/lsa-specify/SKILL.md` is invoked downstream of `core/tier-selector` confirmation for T3 (after `lsa-discover` hands off `discovery.md`).
- Every `lsa/skills/*/SKILL.md` body follows `core/actor-template`'s five-section shape.

## Invariants

- **Versioning.** `core` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.2.0; v0.3.0 is the next planned release (introduces `registry` skill if a second pack motivates it).
- **Markdown-only.** No `/src/` directory; skills are pure Markdown. Per `vision/specs/standards/code.md` *"Markdown-only"*.
- **Always-loadable on Claude.ai.** Skills upload one-by-one as zips per `core/README.md` *"Install on Claude.ai"*. Per Anthropic docs `platform.claude.com/docs/en/agents-and-tools/agent-skills/overview` (cited in `core/README.md`): *"Custom Skills do not sync across surfaces."*
