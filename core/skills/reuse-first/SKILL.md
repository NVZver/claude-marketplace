---
name: reuse-first
description: Apply on any coding task before writing code — implement a feature, fix a bug, refactor, add code, write a function, wire up a component. Walks a 7-rung reuse ladder (understand the flow → YAGNI → existing code → stdlib → native platform → installed dependency → shortest working diff), stopping at the first rung that holds, so the change reuses over rewrites and adds only the minimum. Stays silent on prose, analysis, explanation, and review tasks that author no code.
---

> **Trace.** On load, print first: `=============== [core/skills/reuse-first/SKILL.md] [core] ===============`


# Reuse First

The reuse ladder catches reinvention and over-delivery *before* the diff exists, not after — the authoring-time reflex between the spec ("what") and [`lsa:reconcile`'s after-the-fact "only" check](../../../lsa/skills/reconcile/SKILL.md). On prose/analysis tasks (no code to author) this skill stays silent.

## Goal

Stop at the first ladder rung that holds — so the change reuses existing capability and adds only the minimum: shortest working diff, or no code at all.

## Input

- A coding task: implement / fix / refactor / add code / write a function / wire up a component.
- The current repo state (read as needed to trace the flow and grep for existing capability).

## Steps

Evaluate the rungs in order. **Stop at the first rung that holds** — a higher rung that answers the need makes every lower rung moot.

1. **Understand the real end-to-end flow first.** Trace the actual path the change touches — callers, data, and the code already on that path — per [`ground-rules` Rule 3 *Read the real source*](../ground-rules/SKILL.md). Observable result: the end-to-end flow the change touches is named (entry point → the code on the path → effect) before any rung below is chosen.

2. **Does it need to exist at all (YAGNI)?** Question whether the code is needed before asking how to write it. Observable result: an explicit keep-or-drop decision on the proposed code, with the reason it is (or is not) required by the task.

3. **Reuse existing in-codebase capability.** Grep the repo for a helper, util, type, or pattern that already provides the behavior, and reuse it rather than reimplement. Observable result: the grep is run and either the existing symbol (`file:line`) is named and reused, or a no-match is recorded before descending.

4. **Use the standard library or language builtin.** Where a stdlib function or language builtin provides the behavior, use it rather than hand-roll an equivalent. Observable result: the stdlib/builtin API is named and used, or its absence for this need is recorded before descending.

5. **Prefer a native platform feature.** Where the platform covers the need natively — CSS over JS, a DB constraint over app-code validation, a framework primitive over custom wiring — prefer it over custom code. Observable result: the native feature is named and used, or its absence for this need is recorded before descending.

6. **Use an already-installed dependency.** Where a dependency already in the manifest solves the need, use it; never add a new dependency for what a few lines cover. Observable result: the installed dependency is named and used, or the decision to write a few lines instead of adding a new dependency is recorded.

7. **Otherwise, the shortest working diff.** When no higher rung holds, write the minimum: prefer deletion over addition and boring over clever, and show the resulting change inline per [`core/output`](../output/SKILL.md) Rule 7. Observable result: the diff is the smallest change that makes the task work, with any available deletion taken over an addition.

**Root cause, not symptom (bug fixes).** When fixing a bug, grep every caller of the function you are about to touch and fix it once in the shared path, not per-symptom. Observable result: the callers of the target function are enumerated (`grep`) and the fix lands once in the shared path they route through, not repeated at each symptom site.

## Output

The ladder applied — rungs evaluated in order with the holding rung named — and the resulting change: a reuse of existing capability, the shortest working diff, or no code at all. Human-readable.

## Constraints

- Deliver only the minimum the task requires, per [`ground-rules` Rule 4 *Deliver only what was asked*](../ground-rules/SKILL.md); the after-the-fact scope check is [`lsa:reconcile`'s "only" check](../../../lsa/skills/reconcile/SKILL.md) — this skill is the before-the-diff reflex, not a restatement of either.
- Do not touch test strategy — test discipline defers to TDD. This skill governs product code, not what or when to test.
- Outputs follow [`../output/SKILL.md`](../output/SKILL.md) — citation by link, never restated.

---

On a prose/analysis task with no code to author, this skill does not fire. Every output an agent produces still obeys `core/ground-rules` (content) and `core/output` (format).
