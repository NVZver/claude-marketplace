> **Trace.** On load, print first: `=============== [.lsa/modules/helper/spec.md] [vision] ===============`

# Module Spec — `helper`

The fact-grounded assistant plugin. A subagent + a slash command + knowledge files.

**Plugin manifest:** [`helper/.claude-plugin/plugin.json`](../../../helper/.claude-plugin/plugin.json) (v0.5.0)
**Plugin README** (install, default flow, status): [`helper/README.md`](../../../helper/README.md)
**Per-agent behavior** (source of truth): [`helper/agents/helper.md`](../../../helper/agents/helper.md)
**Per-command behavior** (source of truth): [`helper/commands/help.md`](../../../helper/commands/help.md)
**Knowledge** (rules, scope, friction signals): [`helper/knowledge/`](../../../helper/knowledge/)

## Role in the marketplace

`helper` is the user-facing assistance surface — answers free-form questions about the marketplace with file citations (line range, heading anchor, or URL) and hands off to other skills under explicit confirmation. Depends on `core` ([`helper/README.md`](../../../helper/README.md) *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (every claim cited; cannot-verify fallback rather than fabrication).
- `core/output` — the format golden rules every response inherits (`core/skills/output/SKILL.md` is the canonical source for the count and names; `helper/knowledge/output-discipline.md` re-grounds + extends with Helper-specific rules).
- `core/actor-template` — the Goal/Input/Steps/Output/Constraints shape `helper/agents/helper.md` matches.

Observes `lsa:discover` User Verification rejects in main-agent context (auto-engage signal a).

## Invariants

- **Versioning.** `helper` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.5.0.
- **Gate-delivery — agent proposes, dispatcher delivers + gates (helper v0.5.0).** Adopts `core` v0.13.0 (`.lsa/modules/core/spec.md`, Rule 7 *Delivery test*, Rule 5 *Self-contained gates*). The `helper` agent's tools no longer include `AskUserQuestion` or `Skill` — it returns its cited answer body plus any pending gates (signal-a re-explain offer, handoff confirmation, closing fork) and a staged `lsa:discover` seed in its payload. The **dispatcher** (the `/help` command body, which dispatches via the `Agent` tool, or the main agent) re-renders the answer through a rendered channel (the agent payload is invisible) and runs the `AskUserQuestion` pickers / invokes the handoff `Skill()`. Picker content the user was never shown is a contract violation.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Depends on `core` v0.5.2+** for `output`, `ground-rules`, `actor-template`. Documented in `helper/.claude-plugin/plugin.json: description` and `helper/README.md` *"Depends on"*.
- **Spec source-of-truth.** Behavior is owned by `helper/agents/helper.md` (Actor) and `helper/knowledge/*.md` (rules and scope); this module spec carries module-level invariants only — not a per-step catalog (that's the agent body).
- **Three friction signals.** Helper auto-engages on (a) two consecutive `lsa:discover` User Verification rejections, (b) free-form `?` / `what is X?` mid-flow, (c) explicit `/help`. Cooldown per signal-type — declined auto-engages stay declined until a different signal fires or the user pulls with `/help`. Per `helper/knowledge/friction-signals.md`.
- **Knowledge scope.** Helper reads in scope order: this repo → installed-plugin caches → `context7` MCP (external libraries) → cannot-verify. Bounded — one round, then stop. Per `helper/knowledge/knowledge-scope.md`.
- **No conversation-state persistence.** Helper does not store per-user / per-session state beyond the active turn's cooldown derivation. Absorbed from the original helper-agent spec (v0.2.0).
- **Persona-free.** No greeting, no sign-off, no avatar. Substrate-native — `AskUserQuestion` is the only picker primitive, run by the dispatcher per the gate-delivery invariant above (the agent itself no longer holds the tool). Per `helper/agents/helper.md` Constraints.
- **Answer-first default.** Helper's default first-turn reply leads with a cited prose answer, not an `AskUserQuestion` picker. The picker is the outcome of help (a closing offer when a genuine fork remains), not the substance. Per `helper/agents/helper.md` Step 3 and `helper/knowledge/output-discipline.md` § *"Closing picker"*.
- **Goal-restatement opening.** Every response opens with a one-sentence goal restatement (or a half-sentence prefix for one-word factual questions). Per `helper/agents/helper.md` Step 1 + Step 3 and `helper/knowledge/output-discipline.md` § *"Goal-restatement opening"*.
- **Genuine fork — operating definition.** `AskUserQuestion` is offered only on a genuine fork: (1) destructive or irreversible action, (2) two architecturally equivalent options, (3) missing required input the agent cannot infer, or (4) per-row triage at scale. If none fire, the turn ends cleanly. Per `helper/knowledge/output-discipline.md` § *"Genuine fork — operating definition"*.
- **Bare `/help` prompts inline.** A no-argument `/help` invocation dispatches the `helper` agent (via the `Agent` tool) with an empty argument; the agent's Step 1 returns a one-sentence inline prompt in Helper's voice, surfaced verbatim by the command — it does not open a multi-option starter-topic picker. Per `helper/commands/help.md` Step 2.
- **Onboarding fast-path (Step 1.5).** On a user question matching an onboarding pattern (*install / start / what-is-X / how-do-I-run*), Helper consults the catalog at `helper/knowledge/onboarding-fast-path.md` and responds directly from the cited README excerpt — no `Grep`, no `Glob`, no `context7`. Falls through to Step 2 (scope-order read) on no-match or excerpt-missing. Insertion-style — Steps 2/3/4/5 keep their numbers and bodies. Per `helper/agents/helper.md` Step 1.5 and `helper/knowledge/onboarding-fast-path.md`.
- **Latency target — ≤5s for fast-path responses.** Target, not a hard gate (LLM tool-loop floors are non-deterministic). Catalog-matched answers use ≤3 `Read` calls. Measured manually via Journey 1 probe; >5s with otherwise-correct response body is recorded but does not block merge. Per `.lsa/features/2026-05-22-helper-onboarding-fast-path/requirements.md` NF1.
