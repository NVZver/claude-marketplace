# claude-marketplace

> **Ownership over automation.** A personal, agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**.

**Proven · Owned · No Fluff · Spec First.**

A Claude Code marketplace shipping five composable plugins for spec-first, fact-grounded software development. The point isn't features — it's discipline that keeps you, the human, in the driver's seat while the agent does the typing.

## The five plugins

| Plugin | What it gives you |
|---|---|
| [`core`](./core/) | Always-on discipline: six content rules, seven output rules, flow classification (Quick / Standard / Extended), and the Goal/Input/Steps/Output/Constraints shape every skill follows. |
| [`lsa`](./lsa/) | **L**iving **S**pec **A**rchitecture — technology-agnostic spec layer: authors a grounded spec (EARS + Gherkin), verifies it against the codebase *before* you build and against the diff *after*, then delegates code-writing to any implementer. Not the coder; hand-edits are *absorbed* into the spec instead of forbidden. |
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

The always-on `flow-selector` skill classifies every non-trivial task before work begins. You see the reasoning and confirm a flow type — **Quick** (one-pass change), **Standard** (discover → specify → verify → delegate → reconcile, lightweight), or **Extended** (full spec lifecycle).

```text
> claude "add a /lint slash command to the prompt-engineer plugin"

[core/flow-selector] Classifying this task.
Signals — adds new surface (slash command), touches 1 plugin, no existing spec.
Verdict — Extended flow: discover → specify → verify → delegate → reconcile.

Approve [Extended], or pick [Quick] / [Standard].
```

`[illustrative]`

### lsa

**LSA** — Living Spec Architecture — is a technology-agnostic spec layer: it authors a grounded spec and verifies it *before and after* an external implementer builds it. LSA is not the coder — any agent (Claude Code, Cursor, Copilot) or a human writes the code. The loop is `discover → specify → verify → delegate → reconcile`.

```text
> /lsa:discover "analytics dashboard for spec-vs-code drift"
[lsa:discover] Intent + facts — roadmap.md exists @ .lsa/roadmap.md; one new module.

> /lsa:specify
[lsa:specify] F1 (EARS-Event): WHEN a feature spec is merged, the dashboard SHALL list it within 60 s.
drift.feature: Given a merged feature spec / When the dashboard refreshes / Then it lists the feature within 60 s.

> /lsa:verify
[lsa:verify] GROUNDED — every reference resolves; flow buildable on the existing roadmap reader.

> /lsa:delegate
[lsa:delegate] Spec + drift.feature handed to your implementer. Awaiting the diff.

> /lsa:reconcile
[lsa:reconcile] PASS — drift.feature passes 5/5 runs; every changed hunk traces to F1.
```

`[illustrative]`

When the spec and the code diverge — because you hand-edited code without updating the spec — `/lsa:reconcile` detects the delta and offers to update the spec to match. Drift becomes a conversation, not a violation.

### helper

A cited Q&A assistant. The default reply leads with the answer and the source — never a multiple-choice picker. Auto-engages on friction signals (two consecutive `lsa:discover` User Verification rejections, free-form `what is X?` mid-flow) and on explicit `/help`.

```text
> /help what is LSA?

LSA = Living Spec Architecture: a spec-first development methodology where specs
are the permanent source of truth and every code change traces to a spec
requirement. The loop is `lsa:discover` → `lsa:specify` → `lsa:verify` →
`lsa:delegate` → `lsa:reconcile`; code-writing is delegated to any implementer.

Sources: README.md#lsa (the loop and its five steps), lsa/README.md
(skill table + credo quote).
```

`[illustrative]`

### management

The `management:start-feature` skill drives an interactive shaping conversation that turns a vague problem into a structured pitch. The `product-manager` agent self-selects a domain-expert role per invocation, asks the questions the codebase can't answer, gates on your explicit approval, and hands the approved pitch off to `management:roadmap` for epic decomposition. Each item then enters the LSA loop (`lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`).

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

1. **`core` is always-on.** Every task fires `ground-rules` + `output` automatically. The one hard output rule is *sourced* — every claim carries a source + quote; the rest (structured, minimal, verdict-first, …) is guidance the agent applies when it serves the answer, so simple questions get short prose instead of a six-block template.
2. **Got a vague idea?** `/management:start-feature` shapes it into a pitch with clear scope before you commit to building.
3. **Non-trivial tasks classify first.** `core/flow-selector` proposes Quick / Standard / Extended with chain-of-thought reasoning; you confirm.
4. **Standard and Extended run through LSA.** `lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`. Every line of code traces back to a requirement; code-writing is delegated to your implementer.
5. **Hand-edited code?** `lsa:reconcile` offers to update the spec — it never blocks the edit.

The single test the whole system answers: **what is the minimum ceremony that still guarantees grounded, spec-anchored output for *this* task?**

## Status + substrate

Personal-use first; open-sourced for visibility. Claude Code is the v1 substrate; the discipline (specs, sourcing, flow gating) isn't Claude-specific and the skills are plain Markdown — porting to another agentic IDE is a routing exercise, not a rewrite.

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
- Per-plugin docs — [`core/README.md`](./core/README.md), [`lsa/README.md`](./lsa/README.md), [`helper/README.md`](./helper/README.md), [`management/README.md`](./management/README.md), [`prompt-engineer/README.md`](./prompt-engineer/README.md).
- [`lsa/ARCHITECTURE.md`](./lsa/ARCHITECTURE.md) — directory layout, `.lsa.yaml` schema, branch management.

Licensed under [`LICENSE`](./LICENSE).
