---
name: help
description: "Ask the Helper agent a question. Dispatches to Helper; if no argument, Helper prompts inline for the question. With an argument: dispatches to Helper for a cited answer ≤1.5 screens, closing cleanly (or with a follow-up `AskUserQuestion` only when a genuine fork remains)."
---

> **Trace.** On load, print first: `=============== [helper/commands/help.md] [helper] ===============`


# `/help`

Goal: Route a `/help` invocation to the Helper agent, which owns the full answer discipline.

Input: `$ARGUMENTS` — an optional question (may be empty).

Constraints:
- **Always dispatch to `Skill(helper)`** — do not answer the question from this command body; the Helper agent owns the discipline (citations, jargon re-grounding, scope rules, cannot-verify fallback). This is a thin shell.
- **Never render a text `[a] / [b] / [c]` block** — always use `AskUserQuestion`. Per `.lsa/VISION.md` §2 Principle 9.
- **No filler.** No `"Sure!"`, no `"I'd be happy to help!"`, no preamble. Just dispatch or open the picker.

## Steps

1. **`$ARGUMENTS` present** → invoke `Skill(helper)` with the argument as input. (→ Helper's cited response)
2. **`$ARGUMENTS` empty** → invoke `Skill(helper)` with an empty (or `"general"`) argument; Helper's Step 1 emits a one-sentence inline prompt in Helper's voice inviting the user to state their question. Do **not** open an `AskUserQuestion` picker from this body — the starter-topic phrasings live in [`../knowledge/output-discipline.md`](../knowledge/output-discipline.md) § *Starter-topic examples* as illustrative content, not runtime forks. (→ inline prompt)

## Output

Whatever Helper returns — a cited answer (≤1.5 screens, opening with a goal restatement, closing cleanly or with a genuine-fork `AskUserQuestion`), a `Skill()` handoff under explicit confirmation, the bare-`/help` inline prompt, or the `"I cannot verify this."` fallback. This command renders nothing of its own.

## Example Output

[illustrative]

```
> /help how do I install the marketplace?

(dispatches to Skill(helper))
You want to install the marketplace plugins. Per `README.md#install`: run `/plugin marketplace add NVZver/claude-marketplace`, then `/plugin install core@NVZver` (install `core` first). …
```
