---
name: implement
description: Execute TDD implementation of a planned feature. Input: approved tasks.md from lsa:plan (or discovery context from lsa:discover Standard flow). Output: all epics implemented with passing tests, ready for lsa:verify. Dispatches each epic to the developer agent for principal-engineer-level execution.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent, AskUserQuestion
---

> **Trace.** On load, print first: `=============== [lsa/skills/implement/SKILL.md] [lsa] ===============`


# LSA Implement

Orchestrator skill. Walks epics in order, dispatches each to the `developer` agent for principal-engineer-level implementation, manages inter-epic human gates. Does not contain implementation logic — that lives in `lsa/agents/developer.md`.

## Goal

Execute the approved `tasks.md` (or Standard-flow discovery context) epic-by-epic, dispatching each to the `developer` agent for design-then-test-then-implement execution, with human approval between epics.

## Input

- Approved `${specs_root}/features/<feature-name>/tasks.md` (from `lsa:plan` — Extended flow).
- Or: discovery context (module, change, acceptance criterion) from `lsa:discover` (Standard flow). In this case, treat the entire change as a single epic.
- The feature spec at `${specs_root}/features/<feature-name>/` (requirements, test-suites, design, optional contract) when available.
- `.lsa.yaml` for `constitution`, `specs_root`, and `mode` (defaults per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"`.lsa.yaml` defaults").

## Steps

1. **Read sources.** Apply the Read Protocol per [`../knowledge/conventions.md`](../knowledge/conventions.md) §"Read protocol". Skill-specific sources beyond the protocol's standard prefix:
   - `${specs_root}/features/<feature-name>/tasks.md` (if Extended flow)
   - `${specs_root}/features/<feature-name>/requirements.md` (if exists)
   - `${specs_root}/features/<feature-name>/test-suites.md` (if exists)
   - `${specs_root}/features/<feature-name>/design.md` (if exists)
   - `${specs_root}/features/<feature-name>/contract.yaml` (if exists)
   - The project's constitution (for test commands, code standards, project structure)

   Detect the project's test, typecheck, and lint commands from the constitution and project config. Observable result: per-source one-liner printed per the protocol; tooling commands recorded.

2. **Execute epics in order.** For each epic in the Epic Overview table from `tasks.md` (or the single-epic derived from Standard-flow discovery):

   Print: *"Starting Epic [N]: [Name] — [1-sentence description]."*

   **Dispatch to developer agent.** Invoke the `developer` agent (`lsa/agents/developer.md`) via the `Agent` tool with:
   - The epic's name, subtasks, acceptance criteria, and `**Covers:**` line.
   - The feature spec context (requirements, test-suites, design, contract).
   - The project's test/lint/typecheck commands.
   - The `.lsa.yaml` configuration.

   The agent executes all four phases (Design → Test Strategy → TDD → Self-review) and returns a structured summary.

   **Handle agent results by status:**

   - **`blocked`**: The agent could not complete — spec/plan divergence, stuck implementation, or unresolvable issue. Present the agent's blocked reason and proposed adjustment to the human via `AskUserQuestion`. Options: `[a]` accept adjustment → re-dispatch with the adjustment; `[b]` override → human provides guidance, re-dispatch; `[c]` stop → pause implementation.
   - **`complete`**: Proceed to human gate. Review the agent's returned design brief for reasonableness before presenting — if the brief is thin relative to the epic's complexity, re-dispatch with feedback.

   **Human gate.** Present via `AskUserQuestion` per [conventions.md](../../knowledge/conventions.md) §"AskUserQuestion convention". Include from the agent's summary: design brief (so the human audits the contract, not just the code), test counts by type, files changed, trade-offs made, pre-existing failures if any. Quote the agent's changes inline — a compressed inspection table (`file:line` / type / summary per changed file) before the verdict, not a bare "files changed" list — write, show, comment per [`../../../core/skills/output/SKILL.md`](../../../core/skills/output/SKILL.md) Rule 7. Never tell the human to "go check the diff".

   **Prompt:** *"Epic [N]: [Name] — [test count] tests passing ([unit/integration/e2e breakdown]). Proceed to Epic [N+1]?"*

   - `[a]` proceed → start next epic
   - `[b]` adjust → provide feedback, re-dispatch to developer agent with corrections
   - `[c]` stop → pause implementation

   Do not start the next epic until human approves. Observable result: human approval logged.

3. **Done.** After all epics complete, print which epics were completed, their test counts by type (unit / integration / e2e), and the total suite status. Hand off to `lsa:verify`.

## Output

All epics from `tasks.md` (or the Standard-flow single epic) implemented with passing tests. Each epic was designed before coded, test types were justified via testing-pyramid reasoning, and results were self-reviewed by the developer agent. Ready for `lsa:verify`.

## Constraints

- **Orchestrator only.** This skill dispatches to the `developer` agent — it does not contain implementation, design, or test-strategy logic. If you find yourself writing code or designing user flows in this skill, stop: that belongs in the agent.
- **Test first, always.** The developer agent enforces RED→GREEN→REFACTOR. This skill verifies by checking the agent's self-review summary — if the summary indicates tests were not written first, reject and re-dispatch.
- **One epic at a time.** Complete and get human approval before starting the next.
- **Follow the plan.** Implement what `tasks.md` says. When the developer agent returns `blocked`, escalate to the human — do not resolve silently.
- Outputs follow [conventions.md](../../knowledge/conventions.md) §"Output discipline".

---

`/lsa:implement` — manual invocation.
