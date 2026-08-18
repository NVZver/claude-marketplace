# conformance.md — rag-context-engine-and-repo-indexing/path-scoped-query-fix

Independent grading pass (`lsa:reconcile`) against the diff returned by `delegate` (agent-dispatched implementer, `paired_verify: off`, left uncommitted). All verification below was performed live by me in this reconcile context — rebuilt the Docker image myself, re-ran the exact regression case, and read every changed line directly — not taken on the implementer's self-report.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | real pre-filter — `docker/rag_cli.py` (`.where(..., prefilter=True)` before `.limit(TOP_K)`) | Live, rebuilt image myself: `--path scripts` on the exact P9 regression query returns only `scripts/**` results, `scripts/check-lib-pins.sh` now ranked #1 within the filtered set — independently reproduces the implementer's claimed fix | ✅ |
| R2 | unchanged without `--path` — `docker/rag_cli.py` | Live: same query without `--path` reproduces the original eval's exact `0.8842`/`0.8697` near-tie, byte-for-byte — confirmed via direct comparison against `raw-condition-c-vector-only.md`'s recorded P9 result | ✅ |
| R3 | `--path` passthrough — `scripts/rag-query.sh` | `git diff` confirms the argument-parsing loop and array-expansion idiom (`"${path_args[@]+"${path_args[@]}"}"`, needed for bash 3.2 `set -u` safety on an empty array); live-tested via the same real calls above, which go through this script, not a direct container invocation | ✅ |
| R4 | prose correction — `lsa/knowledge/conventions.md`, `lsa/skills/discover/SKILL.md`, `lsa/skills/verify/SKILL.md` | `git diff` confirms each file's "query within resolved scope" workaround language replaced with `rag-query.sh --path <dir>` naming the real mechanism; exactly one line changed per file, nothing else touched | ✅ |
| R5 | empty-scope miss contract — `docker/rag_cli.py`, `scripts/rag-query.sh` | Live: `--path nonexistent-zzz-dir "check-lib-pins"` → `{"results": []}`, exit 0 — same contract as an ordinary miss, no new error shape | ✅ |
| R6 | version/CHANGELOG/README — `lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`, `lsa/README.md` | Independently re-ran `scripts/check-version-changelog.sh` → `OK 5 plugin(s) checked` | ✅ |

Orphan hunks: none.

`scripts/coverage-skeleton.sh`'s untracked-file sweep also surfaced `.lsa/observations/2026-08-17-rag-eval/{probes.md,raw-condition-{a,b,c,d}*.md,report.md}` and root `README.md`. All 7 predate `delegate` entirely — the eval files were written directly by me before this epic's discover/specify even started (they're what *found* the gap this epic fixes), and `README.md` was edited directly by me in this same session turn, before dispatching this epic's implementer (confirmed: the implementer's own report explicitly notes finding this change already present and leaving it untouched). None map to R1-R6. Excluded from the coverage table and the orphan count on that basis, not silently dropped — same treatment as epic 1's pre-existing pitch/research docs.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1
  PASS  citations                bash scripts/check-citations.sh → exit 0
  PASS  links                    bash scripts/check-links.sh → exit 0
  PASS  project-map              bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests                    bash scripts/run-tests.sh → exit 0
  PASS  lib-pins                 bash scripts/check-lib-pins.sh → exit 0
  PASS  rag-index-fresh          bash scripts/check-rag-index-fresh.sh → exit 0
  PASS  rag-index-matches-head   bash scripts/check-rag-index-matches-head.sh → exit 0

gate: FAIL
```

Only `docs-invariants` fails, on the same structural C20 pattern as every prior epic (this epic's own `conformance.md` didn't exist until this file). **Notably, both `rag-index-*` checks now PASS** — the first epic in this build where Docker was reachable for the full gate run at reconcile time, not just individual probes.

## Verdict

**reconcile: PASS @ 2891944**

All 6 requirements verified by live execution against a Docker image I rebuilt myself, not the implementer's report. The safety-critical claim — that this is a real pre-filter, not a post-filter that would silently fail on exactly the case it's meant to fix — was independently reproduced end-to-end against the actual regression query from the original eval, not just read in the diff. Independence: this grading ran in the orchestrating context, not the dispatched implementer `Agent`; this verdict will be committed separately from the implementation diff, per the reward-hacking defense (`lsa/skills/reconcile/SKILL.md:62`).
