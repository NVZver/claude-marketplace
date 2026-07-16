# claude-marketplace

[![lint](https://github.com/NVZver/claude-marketplace/actions/workflows/lint.yml/badge.svg)](https://github.com/NVZver/claude-marketplace/actions/workflows/lint.yml)

> **Ownership over automation.** A personal, agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**.

**Proven · Owned · No Fluff · Spec First.**

A Claude Code marketplace shipping five composable plugins for spec-first, fact-grounded software development. The point isn't features — it's discipline that keeps you, the human, in the driver's seat while the agent does the typing.

## Scripts do the deterministic work

Most agent systems dump whole files into the model and hope it finds the needle. This marketplace does the opposite: **deterministic work is delegated to scripts; the AI works only on what is relevant and already pre-processed** — the slice a question needs, not the ledger it came from.

Same roadmap work, context loaded (tokens = bytes÷4). Before = whole-file read of the ~92 KB markdown ledger; after = script stdout only:

| Situation | Before | After | Saves |
|---|---:|---:|---:|
| "What's next" (Mode 0) | ~39 tok* | ~32 tok | ≈ flat |
| Sequence the backlog | ~22,958 tok | ~176 tok | **~22,780 tok (~99% / ~130×)** |
| Get one item's status | ~22,958 tok | ~70 tok | **~22,890 tok (~99% / ~328×)** |
| Roadmap hygiene scan | ~22,958 tok | ~185 tok | **~22,770 tok (~99% / ~124×)** |

\*Mode 0 was already a one-row script slice — the win is extending that pattern to the operations that previously paid the full ledger. Full methodology: [`manager/CHANGELOG.md`](./manager/CHANGELOG.md) §`[0.18.0]` *Notes — measured context win*.

## The five plugins

| Plugin | Version | What it gives you |
|---|---|---|
| [`core`](./core/) | 0.18.0 | Always-on discipline: eight content rules, one hard output rule plus six pieces of output guidance, flow classification (Quick / Standard / Extended), the `/core:doctor` install self-check, and the Goal/Input/Steps/Output/Constraints shape every skill follows. |
| [`lsa`](./lsa/) | 0.25.1 | **L**iving **S**pec **A**rchitecture — technology-agnostic spec layer: authors a grounded spec (EARS + Gherkin), verifies it against the codebase *before* you build and against the diff *after*, then delegates code-writing to any implementer. Not the coder; hand-edits are *absorbed* into the spec instead of forbidden. |
| [`manager`](./manager/) | 0.18.0 | Pre-build shaping: turns a vague problem into a structured pitch (problem, appetite, solution sketch, rabbit holes, no-gos) before the build cycle begins. |
| [`prompt-engineer`](./prompt-engineer/) | 0.8.3 | Plugin-quality discipline: scans your own actors and knowledge files for ground-rule, KISS/DRY, AI over-engineering, and context-budget violations. |
| [`observer`](./observer/) | 0.3.2 | Live observe-and-coach + increment gate: `observe` rides Claude Code's self-paced `/loop` and coaches your file changes through a chosen role (rubber-duck, pair-programmer, interviewer, or custom); `verify-checkpoint` gates delegation increments — grades one finished requirement **does·only** and emits `CLEAR` or `BLOCK`. |

## Install

**Prerequisites.** [Claude Code](https://code.claude.com/docs/en/overview) on any plan (see [Plans & models](#plans--models) below — nothing is gated behind a specific model). The `plugin.json` `dependencies` field the install order relies on is functional since Claude Code v2.1.110 (per the [plugins reference](https://code.claude.com/docs/en/plugins-reference)); on older versions, installing in the listed order achieves the same result.

1. Add the marketplace and install the plugins — `core` first, because `lsa`, `manager`, and `observer` declare it as a `plugin.json` dependency, and `prompt-engineer` aligns with its conventions:

   ```
   /plugin marketplace add NVZver/claude-marketplace
   /plugin install core@NVZver
   /plugin install lsa@NVZver
   /plugin install manager@NVZver          # optional — pitch shaping
   /plugin install prompt-engineer@NVZver  # optional — prompt-quality audits
   /plugin install observer@NVZver         # optional — live observe-and-coach
   /reload-plugins
   ```

2. Merge the [`core/CLAUDE.md`](./core/CLAUDE.md) fragment into your project's `CLAUDE.md`. This is the step that activates the always-on rules — skip it and the discipline layer silently never engages.

3. Run [`/core:doctor`](./core/skills/doctor/SKILL.md) to verify the wiring: four read-only checks (required plugins installed, fragment merged, plugin versions consistent, gate scripts) reported as a per-check PASS / WARN / FAIL / SKIP table with evidence and a one-line fix per failure. A healthy install looks like (`[illustrative]`):

   ```text
   | Check                          | Verdict | Evidence                                  |
   |--------------------------------|---------|-------------------------------------------|
   | Required plugins (core + lsa)  | PASS    | both listed by /plugin                    |
   | CLAUDE.md fragment merged      | PASS    | all four rule anchors found               |
   | Plugin versions consistent     | PASS    | installed == source manifests             |
   | Gate scripts                   | SKIP    | not the marketplace source repo           |
   ```

**First command.** Run `/lsa:init` in any project to scaffold the spec tree (greenfield or brownfield). Or run `/manager:shape "<vague idea>"` to shape a pitch before any code lands.

## Troubleshooting

Symptom → fix; when in doubt, [`/core:doctor`](./core/skills/doctor/SKILL.md) diagnoses all four wiring checks with evidence.

- **Install failed** — re-run install step 1; `/plugin` lists what actually landed, then `/reload-plugins`.
- **A skill won't trigger** — run `/reload-plugins`, then invoke it explicitly (e.g. `/core:doctor`, `/lsa:discover`); if it's still missing, step 1 didn't complete.
- **Always-on rules not applying** — the `core/CLAUDE.md` fragment isn't merged: do install step 2, then `/core:doctor` reports which rule anchors are still missing.
- **`NOT-GROUNDED` from `lsa:verify`** — not a breakage: fix the flagged spec references before building, per [`lsa/README.md` § Quick start step 4](./lsa/README.md#quick-start).
- **Lint red** — run the failing gate locally: `scripts/lint.sh`, `scripts/check-citations.sh`, `scripts/check-links.sh`, `scripts/check-version-changelog.sh`, `lsa/scripts/project-map-check.sh` — each prints the offending line. A `lint.sh` C12 failure means a stale constitution digest: regenerate with `bash scripts/build-vision-digest.sh`. A `project-map-check.sh` failure means a stale repo atlas: regenerate with `bash lsa/scripts/project-map-build.sh`, then commit `project-map.yaml`.

## Quick start

The core loop, one slash command per step. `core` has no command of its own — its ground-rules/output/flow-selector discipline runs underneath every step below:

```text
(core: always-on)
  /manager:shape "<vague idea>"    -> approved pitch
  /manager:decompose <pitch>       -> epics

  /lsa:discover -> /lsa:specify -> /lsa:verify   (per epic)
  /lsa:delegate         -> (delegation) an external implementer writes the code
  /lsa:reconcile        -> verify the diff against the spec; absorb drift

  /manager:next         -> what's next on the roadmap
```

`prompt-engineer` audits the marketplace's own prompt files; `observer` rides alongside as a live pairing coach (`observer:observe`) or a per-increment gate (`observer:verify-checkpoint`). Per-plugin detail and skill tables: [`core`](./core/README.md), [`lsa`](./lsa/README.md), [`manager`](./manager/README.md), [`prompt-engineer`](./prompt-engineer/README.md), [`observer`](./observer/README.md).

## The problem and the solution

Agents make silent decisions. Hedged claims (*"probably"*, *"typically"*, *"based on convention"*) pass for facts. Code drifts from intent. Specs rot the moment the code lands. Six months in, nobody — human or agent — knows why the system is the way it is. The system that was supposed to make you faster turned you into a passenger.

The solution is discipline, not magic. `core` constrains output to grounded, sourced, decision-first prose on every task. `lsa` chains every code line to a human-owned requirement and absorbs drift instead of forbidding it. `manager` keeps you from typing yourself into a corner before the code starts. `prompt-engineer` keeps the discipline files themselves honest.

## How it works in 30 seconds

1. **`core` is always-on.** Every task applies the `ground-rules` + `output` discipline automatically, straight from the merged [`core/CLAUDE.md`](./core/CLAUDE.md) card (full skill files load only on the card's escalation triggers). The one hard output rule is *sourced* — every claim carries a source + quote; the rest (structured, minimal, verdict-first, …) is guidance the agent applies when it serves the answer, so simple questions get short prose instead of a six-block template.
2. **Got a vague idea?** `/manager:shape` shapes it into a pitch with clear scope before you commit to building.
3. **Non-trivial tasks classify first.** `core/flow-selector` proposes Quick / Standard / Extended with chain-of-thought reasoning; you confirm.
4. **Standard and Extended run through LSA.** `lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`. Every line of code traces back to a requirement; code-writing is delegated to your implementer.
5. **Hand-edited code?** `lsa:reconcile` offers to update the spec — it never blocks the edit.

The single test the whole system answers: **what is the minimum ceremony that still guarantees grounded, spec-anchored output for *this* task?**

## Status + substrate

Personal-use first; open-sourced for visibility. Claude Code is the v1 substrate; the discipline (specs, sourcing, flow gating) isn't Claude-specific and the skills are plain Markdown — porting to another agentic IDE is a routing exercise, not a rewrite.

## Plans & models

**Runs 100% on Claude Pro.** Every plugin is model-agnostic: no agent or skill hardcodes a model, so each one inherits your session's model ([`.lsa/standards/code.md`](./.lsa/standards/code.md) §"Model policy"). "Works natively on Sonnet, excels on Opus" is the default, not a setting:

| Plan | Session model | What runs |
|---|---|---|
| **Pro** | Sonnet 5 | The full marketplace — every plugin, every loop; nothing is gated behind Opus. |
| **Max** | Opus 4.8 | The same artifacts — the reasoning-heavy stages (spec reconciliation, decomposition) get sharper for free. |

One caveat for Pro users watching usage: the deeper flows spawn sub-agents (each a fresh context), so a full Extended LSA cycle or a parallel `manager:implement` run is token-heavy. For everyday work prefer the **Quick / Standard** flows (`core/flow-selector` picks them by task weight); the multi-agent parallel engine (`manager:implement`) is Max-oriented. Everything remains functional on Pro — this is about pacing usage, not access. Everyday roadmap questions already stay cheap via the [script-first load path](#scripts-do-the-deterministic-work) above.

## Security

The trust boundary is small by design: five **pure-Markdown** plugins plus **one** transparent `SessionStart` shell hook ([`lsa/hooks/session-start-drift-check.sh`](./lsa/hooks/session-start-drift-check.sh)) that runs read-only Git (`rev-parse` / `log` / `diff`), writes nothing, makes no network calls, and always exits 0. No server, no secrets, no PII.

- **Indirect prompt injection** — untrusted content (web fetches, library docs, analyzed repo files, tool output) is treated as data, never instructions, per `core/ground-rules`. Residual risk is real and acknowledged ([OWASP LLM01](https://genai.owasp.org/llmrisk/llm01-prompt-injection/)); human review backs every gated decision.
- **Install safely** — review the source first, and prefer pinning the marketplace to a reviewed tag/commit (`/plugin marketplace add <git-url>#<ref>`, per [Claude Code docs](https://code.claude.com/docs/en/discover-plugins)) over tracking `main`.

Full threat model, reporting channel, and hook transparency: [`SECURITY.md`](./SECURITY.md).

## Further reading

- [`SECURITY.md`](./SECURITY.md) — threat model, vulnerability reporting, and SessionStart-hook transparency.
- [`.lsa/VISION.md`](./.lsa/VISION.md) — the full design rationale (the constitution).
- [`knowledge/index.md`](./knowledge/index.md) — flat topic-to-path index across every knowledge file in every plugin.
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — how to build, contribute, verify.
- Per-plugin docs — [`core/README.md`](./core/README.md), [`lsa/README.md`](./lsa/README.md), [`manager/README.md`](./manager/README.md), [`prompt-engineer/README.md`](./prompt-engineer/README.md), [`observer/README.md`](./observer/README.md).
- Changelogs — [`core`](./core/CHANGELOG.md), [`lsa`](./lsa/CHANGELOG.md), [`manager`](./manager/CHANGELOG.md), [`prompt-engineer`](./prompt-engineer/CHANGELOG.md), [`observer`](./observer/CHANGELOG.md).
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory layout, `.lsa.yaml` schema, branch management.

Licensed under [`LICENSE`](./LICENSE).
