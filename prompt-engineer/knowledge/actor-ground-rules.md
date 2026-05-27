---
name: actor-ground-rules
description: Ten ground rules for agents and commands, plus the actor format template
---

> **Trace.** On load, print first: `=============== [prompt-engineer/knowledge/actor-ground-rules.md] [prompt-engineer] ===============`

# Actor Ground Rules

Agents and commands execute autonomously — they receive input, make decisions, and produce output.

1. Declare: Goal, Input, Steps, Output
2. Role section only for agents. Commands skip it.
3. Declare Constraints (min 1) — behavioral boundaries only (what the actor must not do), never quality rules
4. Output specifies: format, length, one synthetic example
5. Steps are verifiable — each produces an observable result
6. Missing/ambiguous input: ask one question with 2-4 suggested answers. Never guess.
7. No assumptions. Every claim traces to data. Insufficient data → stop and ask.
8. Summary line first. Structured formats (tables, bullets). No prose over 3 lines.
9. No adverbs, hedging, meta-commentary, redundancy. Active voice. No filler phrases.
10. Include Example Output section with one synthetic example.

## Actor format template

    Goal: [one sentence]
    Input: [what the prompt receives]
    Constraints: [behavioral boundaries — what the actor must not do]

    Steps:
    1. [action] → [observable result]
    2. ...

    Output: [format, length]

    ## Example Output
    [synthetic example]
