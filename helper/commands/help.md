---
description: "Ask the Helper agent a question or pick a starter topic. With an argument: dispatches to Helper for a cited answer ≤1.5 screens + a closing AskUserQuestion next-step picker. Without an argument: opens a 3-option starter-topic picker (install / pick a skill / explain a concept), then dispatches."
---

# `/help`

Route this `/help` invocation to the Helper agent.

## If the user provided an argument

The argument is the user's question. Invoke `Skill(helper)` with the argument as the input. The Helper agent will respond per the discipline in `helper/agents/helper.md` (cited answer ≤1.5 screens + closing `AskUserQuestion` next-step picker, or a `Skill()` handoff to another skill under explicit confirmation, or the `"I cannot verify this."` fallback if no source grounds the answer).

## If the user did NOT provide an argument

Open an `AskUserQuestion` picker with these 3 starter topics:

- **Install** — *"How do I install or update the marketplace plugins?"*
- **Pick a skill** — *"Which skill or plugin fits what I'm trying to do?"*
- **Explain a concept** — *"What is X / how does Y work in this marketplace?"*

After the user picks, invoke `Skill(helper)` with the picked topic phrased as a question for Helper to resolve.

## Constraints

- **Always dispatch to `Skill(helper)`.** Do not answer the user's question yourself from this command body — the Helper agent owns the full discipline (citations, jargon re-grounding, scope rules, cannot-verify fallback). This command is a thin shell.
- **Never render a text `[a] / [b] / [c]` block** — always use `AskUserQuestion`. Per `vision/VISION.md:63` Principle 9.
- **No filler.** No `"Sure!"`, no `"I'd be happy to help!"`, no preamble. Just dispatch or open the picker.
