---
name: help
description: "Ask the Helper agent a question. Dispatches to Helper; if no argument, Helper prompts inline for the question. With an argument: dispatches to Helper for a cited answer ≤1.5 screens, closing cleanly (or with a follow-up `AskUserQuestion` only when a genuine fork remains)."
---

> **Trace.** On load, print first: `=============== [helper/commands/help.md] [helper] ===============`


# `/help`

Goal: Route a `/help` invocation to the Helper agent, which owns the full answer discipline.

Input: `$ARGUMENTS` — an optional question (may be empty).

Constraints:
- **Always dispatch to the `helper` agent via the `Agent` tool** (it is an agent, not a skill) — do not answer the question from this command body; the Helper agent owns the discipline (citations, jargon re-grounding, scope rules, cannot-verify fallback). This shell owns **delivery and gating**: the agent's payload is invisible to the user ([`core/output`](../../core/skills/output/SKILL.md) Rule 7 *Delivery test*), so this command re-renders it.
- **Never render a text `[a] / [b] / [c]` block** — every returned pending gate runs via `AskUserQuestion`. Per `.lsa/VISION.md` §2 Principle 9 and `core/output` Rule 5 *Self-contained gates*.
- **No filler.** No `"Sure!"`, no `"I'd be happy to help!"`, no preamble. Just dispatch, deliver, gate.

## Steps

1. **`$ARGUMENTS` present** → dispatch the `helper` agent (`Agent` tool) with the argument as input. (→ Helper payload: answer body + pending gates / staged handoff)
2. **`$ARGUMENTS` empty** → dispatch the `helper` agent with an empty (or `"general"`) argument; Helper's Step 1 returns a one-sentence inline prompt in Helper's voice inviting the user to state their question. Do **not** open an `AskUserQuestion` picker from this body — the starter-topic phrasings live in [`../knowledge/output-discipline.md`](../knowledge/output-discipline.md) § *Starter-topic examples* as illustrative content, not runtime forks. (→ inline prompt, surfaced verbatim)
3. **Deliver, then gate.** Surface Helper's answer body verbatim through a rendered channel — as the turn-final message, or carried inside the gate below (`preview`). If the payload contains pending gates, run them via `AskUserQuestion`; on a confirmed staged handoff, invoke the staged `Skill()` seed (e.g. `lsa:discover …`) and name its concrete effect inline. On No, end cleanly. (→ answer delivered; gates resolved; any confirmed handoff running)

## Output

Helper's cited answer (≤1.5 screens, opening with a goal restatement) delivered through a rendered channel, plus any resolved gates — a clean close, a confirmed `Skill()` handoff, the bare-`/help` inline prompt, or the `"I cannot verify this."` fallback. This command adds no content of its own; it only delivers, gates, and dispatches.

## Example Output

[illustrative]

```
> /help how do I install the marketplace?

(dispatches via Agent tool to helper; answer surfaced verbatim)
You want to install the marketplace plugins. Per `README.md#install`: run `/plugin marketplace add NVZver/claude-marketplace`, then `/plugin install core@NVZver` (install `core` first). …
```
