---
name: actor-ground-rules
description: Eleven ground rules for agents and commands, plus the actor format template
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
11. Example Output matches the declared Output spec — same format and length. A mismatched demonstration teaches the model the wrong shape.

## Why examples: in-context learning

Rules 4, 10, and 11 apply in-context learning — few-shot prompting (Brown et al. 2020, "Language Models are Few-Shot Learners"): the synthetic example is a demonstration the model learns the task shape from at inference time. Demonstration cost and bias are managed by the example checks in [quality-checks.md](./quality-checks.md) (AI Over-Engineering 4, Context Budget 3). The ladder: zero-shot (instruction only — the leaner contracts in §Scope), one-shot (the template default: one synthetic example), few-shot (escalation governed by AI Over-Engineering 4: extra demonstrations only for distinct cases).

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

The template refines the four standard prompt elements (instruction, context, input data, output indicator — [Prompt Engineering Guide](https://www.promptingguide.ai/introduction/elements)): Goal + Steps + Constraints carry the instruction, Role and cited knowledge files carry the context (per [separation-of-concerns.md](./separation-of-concerns.md), context is referenced, never inlined), Input carries the input data, Output + Example Output carry the output indicator. The Steps arrow notation (`[action] → [observable result]`) adapts chain-of-thought prompting ([Wei et al. 2022](https://www.promptingguide.ai/techniques/cot)): intermediate reasoning steps made explicit and checkable.

## Scope — actors under a leaner contract

Rules 4, 10, and 11 (Output spec + Example Output) describe the default actor template above; rule 11 applies only where an Example Output section exists. Review an actor against the contract it actually follows:

- `core/actor-template` — Goal / Input / Steps / Output / Constraints. No Example Output section.
- `lsa/CORE.md` §4 — Role · Goal · Inputs · Steps · Output (every LSA skill and agent).

Do NOT flag a missing Example Output (rule 10) — or any other template-only section — when the actor conforms to a cited leaner contract. Flag it only for standalone actors that declare no contract.
