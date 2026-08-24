# conformance.md — rag-context-engine-and-repo-indexing/discover-verify-wiring

Independent grading pass (`lsa:reconcile`) against the diff returned by `delegate` (agent-dispatched implementer, `paired_verify: off`, left uncommitted this time — unlike epic 2). This epic edits natural-language instruction files, not executable code, so "proving runs" here means independently re-reading the actual diff (not the implementer's quoted excerpts) and tracing through the edited steps as a fresh agent would, rather than 3x stochastic scenario execution — consistent with the testability note carried from `discover`/`specify`.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | query `rag-query.sh` within project-map scope before fallback — `lsa/knowledge/conventions.md`, `lsa/skills/discover/SKILL.md`, `lsa/skills/verify/SKILL.md` | Independently re-read the full diff (not the implementer's quotes) via `git diff` — confirmed verbatim match to the report in all three files; traced both edited steps as a cold reader, sequence unambiguous: project-map → rag-query.sh → Grep/Read | ✅ |
| R2 | good match used directly, no whole-file read — same three files | Confirmed in the actual diff text: conventions.md explicitly says "use directly, skipping a whole-file Read for that content" | ✅ |
| R3 | fallback on miss/stale/unavailable, one-line notice — same three files | Confirmed in the actual diff text, all three files; `scripts/rag-query.sh` re-read directly (not assumed) — its real contract (`{"results": []}`/exit 0 = miss, exit 2 = daemon unreachable) matches what the prose describes | ✅ |
| R4 | `conventions.md`'s Read protocol documents the 3-stage order | `git diff lsa/knowledge/conventions.md` — confirmed the numbered 1/2/3 list is present in that exact order (project-map.yaml → rag-query.sh → Grep/Read fallback) | ✅ |
| R5 | `discover` Step 1 references the updated protocol | `git diff lsa/skills/discover/SKILL.md` — confirmed Step 1's single sentence extended with the rag-query.sh clause, `git diff` shows no other line touched | ✅ |
| R6 | `verify` Step 2 references RAG; Step 1 unchanged | `git diff lsa/skills/verify/SKILL.md` — confirmed only Step 2's line changed; Step 1's `resolve-refs.sh` line is byte-for-byte absent from the diff (not touched) | ✅ |
| R7 | version bump + CHANGELOG + README — `lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`, `lsa/README.md` | Independently re-ran `scripts/check-version-changelog.sh` → `OK 5 plugin(s) checked`; `lsa/CHANGELOG.md` diff confirms a `[0.34.0]` entry matching the version bump; `lsa/README.md` diff confirms both skill-table rows updated at the same granularity the rows already committed to | ✅ |

Orphan hunks: none.

## A judgment call worth recording, not hiding

The implementer flagged one nuance honestly in their own report: `verify` Step 2's new text says "within the `project-map`-resolved scope" without Step 2 itself re-deriving that scope — it relies on `verify`'s Input (the spec, already carrying `discover`'s file:line-cited facts) rather than re-consulting `project-map.yaml` inline. Checked against pre-epic behavior: `verify` never called `project-map.yaml` directly before this epic either (confirmed via `git diff` — no `project-map` line existed in `verify/SKILL.md` pre- or post-epic). This is not a new ambiguity this epic introduced; it's an existing property of how `verify` receives scope from `discover` upstream. Recorded here rather than silently accepted, per this repo's own fact-grounding discipline — a future epic revisiting `verify`'s Input contract should know this was already true before RAG wiring, not caused by it.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1
  PASS  citations                bash scripts/check-citations.sh → exit 0
  PASS  links                    bash scripts/check-links.sh → exit 0
  PASS  project-map              bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests                    bash scripts/run-tests.sh → exit 0
  PASS  lib-pins                 bash scripts/check-lib-pins.sh → exit 0
  FAIL  rag-index-fresh          bash scripts/check-rag-index-fresh.sh → exit 2
  FAIL  rag-index-matches-head   bash scripts/check-rag-index-matches-head.sh → exit 1

gate: FAIL
```

Same known, non-defective pattern as epics 1–2: `docs-invariants` fails on C20 (this epic's own `conformance.md` didn't exist until this file), resolves below. Both `rag-index-*` checks fail because this sandbox's Docker daemon is still down — unrelated pre-existing environment state, unrelated to this epic's prose-only changes.

Independently re-verified beyond the gate script: `scripts/check-version-changelog.sh` → `OK 5 plugin(s) checked`; `scripts/check-citations.sh` → `OK 89, all resolve`; `scripts/check-links.sh` → `OK 531, all resolve` — all re-run directly in this reconcile pass, not taken on the implementer's report.

## Verdict

**reconcile: PASS @ 18a26c2**

All 7 requirements verified by direct re-reading of the actual diff (not the implementer's quotes) plus independent re-execution of every relevant deterministic check. Zero orphan hunks. One honest nuance recorded (verify Step 2's scope-derivation, pre-existing, not epic-introduced) rather than glossed over. Independence: this grading ran in the orchestrating context, not the dispatched implementer `Agent`; this verdict will be committed separately from the implementation diff, per the reward-hacking defense (`lsa/skills/reconcile/SKILL.md:62`).
