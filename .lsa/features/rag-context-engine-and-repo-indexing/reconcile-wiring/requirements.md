# requirements.md — rag-context-engine-and-repo-indexing/reconcile-wiring

Epic: [rag-context-engine-and-repo-indexing/reconcile-wiring](../../../pitches/rag-context-engine-and-repo-indexing.md). Last epic of this pitch. Hard dependency: `index-query-pipeline` (`scripts/rag-query.sh` exists). Soft-sequenced after `discover-verify-wiring` (done). Touches `lsa/skills/reconcile/SKILL.md` (`lsa` plugin `artifact_path`) — version bump required, same as epic 3.

- R1. When `scripts/rag-query.sh` is invoked with `--sha <sha>`, for each candidate
  result the system SHALL keep it only if that path is unchanged between `<sha>`
  and HEAD (`git diff --quiet <sha> HEAD -- <path>`), discarding it otherwise —
  per path, not per call.
- R2. When `<sha>` does not resolve to a valid commit, or every candidate path
  fails the check, the system SHALL report the same empty-result contract as an
  ordinary miss (epic 1's R4) — not Docker-unreachable's distinct fault, since
  this is a verification outcome, not an infrastructure fault.
- R3. `lsa/skills/reconcile/SKILL.md` Step 4's semantic-mapping judgment SHALL
  query `rag-query.sh --sha <graded-sha>` (the same sha the final verdict
  names) for exploratory search beyond the diff+spec, falling back to
  `Grep`/`Read` per-path per R1/R2, with zero change to reconcile's
  does-only-all logic, coverage-table mechanics, or independent-grader
  constraints (`lsa/skills/reconcile/SKILL.md:62,64`, unchanged).
- R4. `lsa/.claude-plugin/plugin.json` version SHALL be bumped (MINOR —
  `0.34.0` → `0.35.0`), with a corresponding `lsa/CHANGELOG.md` entry and
  `lsa/README.md` update.

## Traceability

| Requirement | Flow | Feature file |
|---|---|---|
| R1, R2 | Sha-pinned query filtering | `flow-1-sha-pinned-query.feature` |
| R3 | reconcile Step 4 queries the graded sha | `flow-2-reconcile-wiring.feature` |
| R4 | (doc/version requirement, no dedicated scenario) | — |

## Design note (grounded at discover time)

`docker/rag_cli.py`'s chunk schema (`docker/rag_cli.py:232-239`) has no `sha` field — identity is `(path, content_hash, embed_model, chunk_schema)`, `content_hash` per-chunk. R1's mechanism deliberately avoids any schema or chunking-logic change: it's a host-side `git diff` check layered on top of existing query results, relying on epic 2's pre-commit hook keeping the index synced to HEAD.
