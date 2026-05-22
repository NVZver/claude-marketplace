---
name: actor-template
description: Use when authoring or editing an actor — a Skill, slash command, or workflow that prescribes how to act (not just what is true). Enforces the Goal/Input/Steps/Output/Constraints shape, separates Knowledge from Actor, and demands every step produce an observable result.
---

> **Trace.** On load, print first: `=============== [core/skills/actor-template/SKILL.md] [core] ===============`


# Actor Template

An Actor prescribes *how to act* (the Goal/Input/Steps/Output/Constraints shape below). It is distinct from Knowledge, which encodes *what is true* (rules, patterns, references). The two never mix in one file — see `ground-rules` for the truth half.

## The five required sections

Every Actor file must contain exactly these five sections, in this order, no renames, no merges:

1. **Goal** — what success looks like, in one sentence. Failure mode without it: the actor wanders.
2. **Input** — what the actor needs from the caller. Failure mode without it: the actor invents data.
3. **Steps** — numbered, in order. Each Step produces an *observable result* (a written file, a returned value, a confirmed message). Failure mode without it: a Step without observable result hides ambiguity.
4. **Output** — what the actor returns when done. Failure mode without it: callers cannot tell success from in-progress.
5. **Constraints** — what the actor must not do; the boundary. Failure mode without it: the actor over-reaches.

## One worked example — Summarize a pull request

**Goal:** Produce a 3-bullet summary of a pull request so a reviewer can decide whether to dig deeper in under 30 seconds.

**Input:** The PR number; the repository (`owner/name`).

**Steps:**
1. Fetch the PR title, description, and changed-files list via `gh pr view <number> --repo <owner/name>`. Observable result: the title and description are quoted verbatim in the working scratchpad.
2. Identify the largest changed file by diff size via `gh pr diff <number> --repo <owner/name> | diffstat`. Observable result: filename + diff-line count noted.
3. Write three bullets: (a) what the PR claims to do, (b) the largest mechanical change, (c) any test changes. Observable result: three bullets written to the output, each ≤ 1 line.

**Output:** Three bullets, ≤ 1 line each, prefixed with the PR number (e.g., `#123:`).

**Constraints:** Do not approve, merge, or comment on the PR. Do not summarize PRs in draft state — return "PR is in draft" instead.

## Copy-paste template

```
---
name: <kebab-case-name>
description: <one-paragraph trigger: when to use this actor; the specific verbs and nouns that should activate it>
---

# <Title>

## Goal
<one sentence>

## Input
- <item>
- <item>

## Steps
1. <action>. Observable result: <artifact>.
2. <action>. Observable result: <artifact>.

## Output
<what is returned>

## Constraints
- <hard limit>
- <hard limit>
```

---

Every output an actor produces must still obey `ground-rules`.
