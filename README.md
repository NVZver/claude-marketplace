# claude-marketplace

> **Ownership over automation.** A personal, agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**.

**Proven · Owned · No Fluff · Spec First.**

A Claude Code marketplace shipping five composable plugins for spec-first, fact-grounded software development. The point isn't features — it's discipline that keeps you, the human, in the driver's seat while the agent does the typing.

## The five plugins

| Plugin | What it gives you |
|---|---|
| [`core`](./core/) | Always-on discipline: six content rules, seven output rules, flow classification (Quick / Standard / Extended), and the Goal/Input/Steps/Output/Constraints shape every skill follows. |
| [`lsa`](./lsa/) | **L**iving **S**pec **A**rchitecture — spec-first lifecycle: every code change traces to a requirement; hand-edits to code are *absorbed* into the spec instead of forbidden. |
| [`helper`](./helper/) | Friendly fact-grounded assistant: a `/help` slash command and an auto-engaging subagent that answers `what is X?` mid-flow with verifiable file citations (line range, heading anchor, or URL). |
| [`management`](./management/) | Pre-build shaping: turns a vague problem into a structured pitch (problem, appetite, solution sketch, rabbit holes, no-gos) before the build cycle begins. |
| [`prompt-engineer`](./prompt-engineer/) | Plugin-quality discipline: scans your own actors and knowledge files for ground-rule, KISS/DRY, AI over-engineering, and context-budget violations. |

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
/plugin install helper@NVZver           # optional — /help Q&A assistant
/plugin install management@NVZver       # optional — pitch shaping
/plugin install prompt-engineer@NVZver  # optional — prompt-quality audits
/reload-plugins
```

Install `core` first — `lsa` and `management` declare it as a `plugin.json` dependency, and the other two plugins (`helper`, `prompt-engineer`) align with its conventions. Then merge the [`core/CLAUDE.md`](./core/CLAUDE.md) fragment into your project's `CLAUDE.md` to wire up the always-on rules.

**First command.** Run `/lsa:init` in any project to scaffold the spec tree (greenfield or brownfield). Or run `/management:start-feature "<vague idea>"` to shape a pitch before any code lands.

## User flows

One primary flow per plugin. Each example uses an illustrative prompt and a representative output snippet — labeled `[illustrative]` because the snippet is constructed for readability rather than copied from a live run.

### core

The always-on `flow-selector` skill classifies every non-trivial task before work begins. You see the reasoning and confirm a flow type — **Quick** (one-pass change), **Standard** (discover → implement → verify), or **Extended** (full spec lifecycle).

```text
> claude "add a /lint slash command to the prompt-engineer plugin"

[core/flow-selector] Classifying this task.
Signals — adds new surface (slash command), touches 1 plugin, no existing spec.
Verdict — Extended flow: discover → plan → implement → verify.

Approve [Extended], or pick [Quick] / [Standard].
```

`[illustrative]`

### lsa

**LSA** — Living Spec Architecture — is a spec-first lifecycle in which specs are the permanent source of truth and every line of code traces back to a requirement. The Extended build cycle is four commands (Standard flow skips `lsa:plan`).

```text
> /lsa:new "analytics dashboard for spec-vs-code drift"
[lsa:new] Created branch feature/analytics-dashboard.
Handing off to /lsa:discover with the confirmed flow.

> /lsa:discover
[lsa:discover] User Verification 1 — Requirements + contract trigger.
F1 (EARS-Event): WHEN a feature spec is merged, the dashboard SHALL list it within 60 s.
Approve, revise, or add.

> /lsa:plan
[lsa:plan] PROPOSED — 3 epics, each test-first, each ≤ ½ day.
  Epic 1: backend ingest of feature-spec merges.
  Epic 2: drift-detector worker.
  Epic 3: dashboard UI.

> /lsa:implement
[lsa:implement] Dispatching Epic 1 to the developer agent — TDD: RED → GREEN → REFACTOR.

> /lsa:verify
[lsa:verify] PASS — 8 acceptance criteria traced to 8 tests; 0 orphan diffs.
```

`[illustrative]`

When the spec and the code diverge — because you hand-edited code without updating the spec — `/lsa:reconcile` detects the delta and offers to update the spec to match. Drift becomes a conversation, not a violation.

### helper

A cited Q&A assistant. The default reply leads with the answer and the source — never a multiple-choice picker. Auto-engages on friction signals (two consecutive `lsa:discover` User Verification rejections, free-form `what is X?` mid-flow) and on explicit `/help`.

```text
> /help what is LSA?

LSA = Living Spec Architecture: a spec-first development methodology where specs
are the permanent source of truth and every code change traces to a spec
requirement. The build cycle is `lsa:discover` → `lsa:plan` → `lsa:implement` →
`lsa:verify`.

Sources: README.md#lsa (build cycle and the four-command flow), lsa/README.md
(skill table + credo quote).
```

`[illustrative]`

### management

The `management:start-feature` skill drives an interactive shaping conversation that turns a vague problem into a structured pitch. The `product-manager` agent self-selects a domain-expert role per invocation, asks the questions the codebase can't answer, gates on your explicit approval, and hands the approved pitch off to `management:roadmap` for epic decomposition. Each epic then enters the LSA build cycle (`lsa:discover` → `lsa:plan` → `lsa:implement` → `lsa:verify`).

```text
> /management:start-feature "users complain onboarding takes too long"

[product-manager] Shaping into a pitch.
Adopting role — onboarding-funnel product manager.
Signal: friction reported, no quantified evidence yet.

Q1 — what's the most-recent concrete onboarding complaint you've heard?
Q2 — how long is "too long" (in minutes), and who measured it?

(… interactive Q&A grounded in the codebase and existing specs …)

PROPOSED — pitch at .lsa/pitches/onboarding-friction.md.
Appetite: small batch (~1 week).
Approve to hand off to /management:roadmap for epic decomposition, or reshape.
```

`[illustrative]`

### prompt-engineer

Audit your own plugin prompts against the marketplace's quality rules. The agent enforces actor structure (Goal / Input / Steps / Output / Constraints), Knowledge-vs-Actor separation, KISS/DRY hygiene, an AI-over-engineering sweep, a context-budget ceiling, and a warning-only show-changes-inline check that flags any step writing/editing/marking an artifact without a directive to quote the change.

```text
> /prompt-engineer:prompt-review helper/agents/helper.md

| Severity | Rule                            | Finding                                                |
|----------|---------------------------------|--------------------------------------------------------|
| HIGH     | Actor rule 10 (Example Output)  | Section missing — actors must show their output shape. |
| MED      | KISS rule 2 (no duplication)    | Step 3 restates Step 1's input check.                  |
| LOW      | Context budget                  | Low-density framing paragraph adds no actionable info. |

Apply auto-fixes with /prompt-engineer:prompt-optimize.
```

`[illustrative]`

## The problem and the solution

Agents make silent decisions. Hedged claims (*"probably"*, *"typically"*, *"based on convention"*) pass for facts. Code drifts from intent. Specs rot the moment the code lands. Six months in, nobody — human or agent — knows why the system is the way it is. The system that was supposed to make you faster turned you into a passenger.

The solution is discipline, not magic. `core` constrains output to grounded, sourced, decision-first prose on every task. `lsa` chains every code line to a human-owned requirement and absorbs drift instead of forbidding it. `helper` and `management` keep you from typing yourself into a corner before the code starts. `prompt-engineer` keeps the discipline files themselves honest.

## How it works in 30 seconds

1. **`core` is always-on.** Every task fires `ground-rules` + `output` automatically: sources, no hedging, no padding, verdict-first.
2. **Got a vague idea?** `/management:start-feature` shapes it into a pitch with clear scope before you commit to building.
3. **Non-trivial tasks classify first.** `core/flow-selector` proposes Quick / Standard / Extended with chain-of-thought reasoning; you confirm.
4. **Standard and Extended run through LSA.** `lsa:discover` → (Extended adds `lsa:plan` →) `lsa:implement` → `lsa:verify`. Every line of code traces back to a requirement.
5. **Hand-edited code?** `lsa:reconcile` offers to update the spec — it never blocks the edit.

The single test the whole system answers: **what is the minimum ceremony that still guarantees grounded, spec-anchored output for *this* task?**

## Status + substrate

Personal-use first; open-sourced for visibility. Claude Code is the v1 substrate; the discipline (specs, sourcing, flow gating) isn't Claude-specific and the skills are plain Markdown — porting to another agentic IDE is a routing exercise, not a rewrite.

## Further reading

- [`.lsa/VISION.md`](./.lsa/VISION.md) — the full design rationale (the constitution).
- [`knowledge/index.md`](./knowledge/index.md) — flat topic-to-path index across every knowledge file in every plugin.
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — how to build, contribute, verify.
- Per-plugin docs — [`core/README.md`](./core/README.md), [`lsa/README.md`](./lsa/README.md), [`helper/README.md`](./helper/README.md), [`management/README.md`](./management/README.md), [`prompt-engineer/README.md`](./prompt-engineer/README.md).
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory layout, `.lsa.yaml` schema, branch management.

Licensed under [`LICENSE`](./LICENSE).
