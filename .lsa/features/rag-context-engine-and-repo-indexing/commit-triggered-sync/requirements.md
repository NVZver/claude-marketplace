# requirements.md — rag-context-engine-and-repo-indexing/commit-triggered-sync

Epic: [rag-context-engine-and-repo-indexing/commit-triggered-sync](../../../pitches/rag-context-engine-and-repo-indexing.md). Hard dependency: `index-query-pipeline` (commit `7a22662`, reconciled `acf5c4b`) — `scripts/rag-index.sh` already exists and works.

- R1. While `core.hooksPath` is configured to `.githooks`, when a commit is made, the
  system SHALL run `scripts/rag-index.sh` scoped to the commit's changed files as part
  of the pre-commit hook.
- R2. When the pre-commit hook's `rag-index.sh` invocation fails for any reason
  (Docker unreachable or otherwise), the system SHALL NOT block the commit — it SHALL
  print a warning and let the commit proceed; the hook is best-effort local
  convenience, not the enforcement point (R3 is).
- R3. When a commit lands whose changed files are not fully reflected in the index
  (hook skipped, bypassed with `--no-verify`, failed, or never installed), the CI
  check SHALL fail that PR/push.
- R4. When the CI check runs and every changed file's current content is reflected in
  the index, the system SHALL exit 0.
- R5. `SECURITY.md` SHALL document the new pre-commit hook — what it runs, its
  trigger, its least-privilege scope (reads the repo, writes only to the gitignored
  index volume), and how to opt out (`git config --unset core.hooksPath`) — per
  `CONTRIBUTING.md:33`'s same-PR requirement for any new hook surface.

## Traceability

| Requirement | Flow | Feature file |
|---|---|---|
| R1, R2 | Pre-commit hook updates the index | `flow-1-precommit-hook.feature` |
| R3, R4 | CI check catches a skipped/bypassed hook | `flow-2-ci-check.feature` |
| R5 | (doc requirement, no dedicated scenario — same pattern as epic 1's R6) | — |

## Open assumption carried from discover (needs confirmation at verify/delegate time)

`[ASSUMPTION]` GitHub Actions `ubuntu-latest` runners ship Docker pre-installed — the CI check (R3, R4) depends on this. Not verified this session (no web access in the discover pass).
