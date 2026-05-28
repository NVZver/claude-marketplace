---
description: "Ask the Helper agent a question. Dispatches to Helper; if no argument, Helper prompts inline for the question. With an argument: dispatches to Helper for a cited answer ≤1.5 screens, closing cleanly (or with a follow-up `AskUserQuestion` only when a genuine fork remains)."
---

> **Trace.** On load, print first: `=============== [helper/commands/help.md] [helper] ===============`


# `/help`

Route this `/help` invocation to the Helper agent.

## If the user provided an argument

The argument is the user's question. Invoke `Skill(helper)` with the argument as the input. The Helper agent will respond per the discipline in `helper/agents/helper.md` (cited answer ≤1.5 screens opening with a goal-restatement sentence, closing cleanly or — only when a genuine fork remains — with an `AskUserQuestion` follow-up picker; or a `Skill()` handoff to another skill under explicit confirmation; or the `"I cannot verify this."` fallback if no source grounds the answer).

## If the user did NOT provide an argument

Invoke `Skill(helper)` with an empty (or `"general"`) argument. The Helper agent's Step 1 will emit a one-sentence inline prompt in Helper's voice inviting the user to state their question (e.g., *"What would you like help with? — install, a concept, picking a skill, or starting a flow are all common."*). Do **not** open an `AskUserQuestion` picker from this command body — the starter-topic phrasings live in `helper/knowledge/output-discipline.md` § *Starter-topic examples* as illustrative examples of questions Helper can answer, not as runtime forks.

## Constraints

- **Always dispatch to `Skill(helper)`.** Do not answer the user's question yourself from this command body — the Helper agent owns the full discipline (citations, jargon re-grounding, scope rules, cannot-verify fallback). This command is a thin shell.
- **Never render a text `[a] / [b] / [c]` block** — always use `AskUserQuestion`. Per `.lsa/VISION.md:63` Principle 9.
- **No filler.** No `"Sure!"`, no `"I'd be happy to help!"`, no preamble. Just dispatch or open the picker.
