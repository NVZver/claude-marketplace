# conformance.md — rag-context-engine-and-repo-indexing/reconcile-wiring

Independent grading pass (`lsa:reconcile`) against the diff returned by `delegate` (agent-dispatched implementer, `paired_verify: off`, left uncommitted). Last epic of the `rag-context-engine-and-repo-indexing` pitch. All scenario runs below were executed live against the **real script file** (`bash scripts/rag-query.sh ...`, with a stubbed `docker` binary since this sandbox's Docker daemon is still down) — not taken on the implementer's self-report.

## A methodological note, recorded honestly

My first attempt to independently verify `scripts/rag-query.sh`'s `--sha` filtering logic reproduced the loop *inline* in a Bash tool call rather than invoking the real file — that inline reproduction hit a `command not found: git` error inside the `while read`/process-substitution construct, in what turned out to be an artifact of how this sandbox wraps ad hoc multi-line commands (`eval`), not a defect in the real script. Re-running the same test as `bash scripts/rag-query.sh --sha <sha> "<query>"` (the actual file, invoked as a single top-level command) worked correctly and reproduced the implementer's exact claimed result. Recording this because it nearly produced a false "the implementer's report is wrong" conclusion — the lesson: verify shell scripts in this environment by invoking the real file, not by re-typing their logic inline.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | per-path git-diff filter, keep/discard — `scripts/rag-query.sh` | Live, real script, stubbed `docker`: mixed 3-path query against sha `d424704` → `LICENSE` (unchanged) and `lsa/CORE.md` (unchanged) kept, `CONTRIBUTING.md` (changed) discarded — independently re-verified with fresh `git diff --quiet` calls against the same three paths/sha, matching exactly | ✅ |
| R2 | unresolvable sha / all-discarded → same miss contract — `scripts/rag-query.sh` | Live: `--sha totally-not-a-sha "test"` → `{"results": []}`, exit 0 — same shape as an ordinary miss, not a distinct error or Docker-unreachable's exit 2 | ✅ |
| R3 | `reconcile` Step 4 wiring — `lsa/skills/reconcile/SKILL.md` | `git diff` on the whole file shows exactly one changed line (Step 4); Steps 1, 2, 3, 5 and the entire Constraints section (independent-grader rule, never-routed-down rule, independence-must-be-observable rule) are **absent from the diff** — confirmed byte-for-byte unchanged by direct inspection, not the implementer's claim alone | ✅ |
| R4 | version bump + CHANGELOG + README — `lsa/.claude-plugin/plugin.json`, `lsa/CHANGELOG.md`, `lsa/README.md` | Diffs confirmed directly: `0.34.0` → `0.35.0`, a `[0.35.0]` CHANGELOG entry matching epic 3's established style, `reconcile` README row updated at the same granularity the row already committed to | ✅ |

Orphan hunks: none.

## Additional checks, independently re-run (not taken on the implementer's report)

- `command -v jq` → `/usr/bin/jq`, `jq-1.7.1-apple` — the new dependency the implementer flagged is genuinely present. Worth noting for the record (not a blocker): this is the first `jq` dependency in `scripts/`; every other script in this repo hand-parses with `awk`/`grep`. The implementer's own rationale — the JSON has arbitrary multi-line/quoted `text` fields where hand-rolled parsing would be fragile — is sound and grounded in a real constraint, not a convenience choice.
- No-`--sha` path: live, real script, stubbed `docker` → raw stdout streamed through unmodified (confirmed the code path is a separate, untouched branch, not merely "looks the same" — `git diff` shows the pre-existing `docker run ... ; then ... fi` block moved into an `if [[ -z "${SHA}" ]]` guard with no other changes, and the `--sha` branch is fully separate code below it).
- `--sha` with no value → usage line + exit 1, confirmed live.
- Docker-unreachable is checked before any sha-filtering code runs (confirmed by direct code inspection — the `docker_daemon_reachable` check and the `--sha`/`jq` logic are in disjoint branches with the daemon check strictly first); the implementer's own live test against this sandbox's genuinely-down daemon (`FAULT: Docker daemon unreachable`, exit 2) is consistent with this and not independently re-run here since it's the same daemon-down state already proven correct across epics 1-3.
- `scripts/check-version-changelog.sh`, `check-citations.sh`, `check-links.sh` re-run directly: all `OK`, matching the implementer's report.

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

Same known, non-defective pattern as epics 1–3: `docs-invariants` fails on C20 (this epic's own `conformance.md` didn't exist until this file), resolves below. Both `rag-index-*` checks fail on this sandbox's still-down Docker daemon — unrelated to this epic's changes, already proven correct behavior across all four epics now.

## Verdict

**reconcile: PASS @ 957d02b**

All 4 requirements verified by direct execution of the real script file and direct diff inspection — not the implementer's quoted excerpts. Zero orphan hunks. The safety-critical claim (Constraints section byte-for-byte unchanged) was independently confirmed by `git diff`, not trusted on report alone — this is the last epic and the one touching `reconcile`'s own grading logic, so this check mattered most here. Independence: this grading ran in the orchestrating context, not the dispatched implementer `Agent`; this verdict will be committed separately from the implementation diff, per the reward-hacking defense (`lsa/skills/reconcile/SKILL.md:62`) — the same rule this epic's own diff extends.
