# Quality-gate script contract

> **Trace.** On load, print first: `=============== [lsa/knowledge/quality-gate-contract.md] [lsa] ===============`

The repo-local contract that turns a "done" claim into a gate-proven fact. It is the configuration side of [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 7 *"Done is a gate-proven, cited predicate"*: the rule says a completion state needs a deterministic, agent-inaccessible gate that ran and passed; this contract is *which commands are that gate* for a given repo.

It is the gate-script half of the parallel-agent-delivery safety core (`.lsa/features/2026-06-17-parallel-agent-delivery-epic-1/requirements.md` R7–R8). The independent grader half is [`reconcile`](../skills/reconcile/SKILL.md).

## Schema — `.lsa.yaml` `gate:` block

```yaml
gate:                          # optional; the quality-gate script contract (default: {} — no scripted gate)
  lint: <command>              # each key is a check name; each value is the project's real command
  typecheck: <command>
  test: <command>
  migration-applied: <command>
  build: <command>
```

- **Each key is a check name; each value is a shell command the repo already owns.** LSA hardcodes no lint/test/migration/deploy tool — the repo plugs in its real commands (per pitch rabbit-hole 5, `.lsa/pitches/parallel-agent-delivery.md:40`). Absent keys = that check is not part of the gate.
- **A check passes iff its command exits `0`.** Nothing else counts as proof.
- **The state may be reported only with the command + its exit/output cited** as the gate artifact — the Rule 7 obligation. "tests pass" with no quoted command is not a gate-proven claim.

## Semantics

- **Required-check slots.** In a parallel run the configured checks map to GitHub branch-protection required status checks (the merge gate). Run locally, they are the same commands; the merge step re-runs them against the up-to-date base before landing (serialized merge — `manager`, Epic 1 S3).
- **No tool is assumed.** A `migration-applied` check is whatever command proves the migration ran in *this* repo (e.g. a status query exiting non-zero when pending); LSA neither ships nor names a migration tool.

## Independence rule (the grader is unwritable by the work)

The `gate:` block and the acceptance `.feature` scenarios are **not editable within the same epic's change they grade.** The agent that writes the implementation cannot, in the same change, edit the checks or scenarios that judge it. This is the reward-hacking defense — models will otherwise edit "the test file so that the tests don't catch it" (`.lsa/pitches/parallel-agent-delivery.md:39`, no-go #5 `:51`; arxiv 2406.10162v3 *Sycophancy to Subterfuge*). `reconcile` enforces it by running in a context with no write access to those artifacts.

## docs-mode repos

A `mode: docs` repo (like this marketplace) has no compiler or test runner, so its gate is not lint/typecheck/build. Its deterministic checks are the LSA checks themselves (`verify` before, `reconcile` after) plus structural probes the repo already maintains — JSON validity of every `plugin.json`, cross-reference and rule-count consistency, and the repo-anchored test suites (`core/tests/`, `prompt-engineer/tests/`). A docs-mode repo MAY omit `gate:` entirely and rely on those.

**Example** (a code-mode repo):

[illustrative — the commands below are placeholders for a hypothetical Node service, not this repo]

```yaml
gate:
  lint: npm run lint
  typecheck: npm run typecheck
  test: npm test
  build: npm run build
```
