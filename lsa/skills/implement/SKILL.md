---
name: implement
description: Execute TDD implementation of a planned feature. Input: approved tasks.md from lsa:plan. Output: all epics implemented with passing tests, ready for lsa:verify.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent, AskUserQuestion
---

> **Trace.** On load, print first: `=============== [lsa/skills/implement/SKILL.md] [lsa] ===============`


# LSA Implement

## Goal

Execute the approved `tasks.md` epic-by-epic using strict Test-Driven Development: write a failing test, implement the minimum code to pass it, refactor while green. Every epic's acceptance criteria must be satisfied before moving to the next.

## Input

- Approved `${specs_root}/features/<feature-name>/tasks.md` (from `lsa:plan`).
- The feature spec at `${specs_root}/features/<feature-name>/` (requirements, test-suites, design, optional contract).
- `.lsa.yaml` for `constitution`, `specs_root`, and `mode` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/features/<feature-name>/tasks.md`
   - `${specs_root}/features/<feature-name>/requirements.md`
   - `${specs_root}/features/<feature-name>/test-suites.md`
   - `${specs_root}/features/<feature-name>/design.md`
   - `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   - The project's constitution (for test commands, code standards, project structure)

   Detect the project's test, typecheck, and lint commands from the constitution and project config. Observable result: per-source one-liner printed per the protocol; tooling commands recorded.

2. **Execute epics in order.** For each epic in the Epic Overview table from `tasks.md`:

   Print: *"Starting Epic [N]: [Name] — [1-sentence description from tasks.md]."*

   **TDD cycle — per subtask within the epic:**

   **RED** — Write a failing test that encodes the expected behavior from the epic's acceptance criteria. Run tests → **must FAIL**. If it passes without implementation, the test is wrong.

   **GREEN** — Write only enough code to make the failing test pass. Run tests → **must PASS**. Run type checker → **must PASS**.

   **REFACTOR** — Clean up while green. Run full test suite → **must STILL PASS**.

   Observable result: test output quoted inline per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7 at each phase.

   After all subtasks in the epic pass, confirm tests + typecheck + lint are green. If any check fails → fix before proceeding.

   **Human gate.** Present via `AskUserQuestion` per `core/CLAUDE.md` operational checkpoint #1. **Prompt:** *"Epic [N]: [Name] — all tests passing. Proceed to Epic [N+1]?"*

   - `[a]` proceed → start next epic
   - `[b]` adjust → user provides feedback, fix and re-checkpoint
   - `[c]` stop → pause implementation

   Do not start the next epic until human approves. Observable result: human approval logged.

3. **Done.** After all epics complete, print which epics were completed and their test counts. Hand off to `lsa:verify`.

## Output

All epics from `tasks.md` implemented with passing tests. Ready for `lsa:verify`.

## Constraints

- **Test first, always.** Never write implementation before a failing test. The RED→GREEN→REFACTOR cycle is non-negotiable.
- **Minimum code only.** Write only what is needed to pass the test. No speculative features, no premature abstractions.
- **One epic at a time.** Complete and get approval before starting the next.
- **Follow the plan.** Implement what `tasks.md` says. If the plan is wrong, pause and discuss — do not silently deviate.
- Outputs follow [`core/output`](../../../core/skills/output/SKILL.md) — citation by link, never restated.

---

`/lsa:implement` — manual invocation.
