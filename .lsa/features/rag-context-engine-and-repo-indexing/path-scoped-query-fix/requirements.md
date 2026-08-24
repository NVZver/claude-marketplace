# requirements.md — rag-context-engine-and-repo-indexing/path-scoped-query-fix

Epic 5 of `rag-context-engine-and-repo-indexing` (discovered, not pre-planned): the e2e eval (`.lsa/observations/2026-08-17-rag-eval/report.md`) found that `docker/rag_cli.py cmd_query` has no `--path` argument, contradicting epic 3's own shipped prose ("query within that resolved scope"). This epic makes the prose literally true.

- R1. When `rag_cli.py query` is invoked with `--path <prefix>`, the vector search SHALL
  consider only chunks whose path starts with `<prefix>`, ranked among that subset — a
  true pre-filter, not a post-filter applied to an already-limited top-K of the whole
  corpus.
- R2. When invoked without `--path`, behavior SHALL be unchanged — byte-for-byte identical
  results to before this epic for the same query.
- R3. `scripts/rag-query.sh` SHALL accept an optional `--path <prefix>` flag (alongside the
  existing `--sha` flag) and pass it through to the container's `query --path` argument.
- R4. `lsa/knowledge/conventions.md`'s Read protocol, `lsa/skills/discover/SKILL.md` Step 1,
  and `lsa/skills/verify/SKILL.md` Step 2 SHALL be updated to pass the `project-map`-resolved
  directory as `rag-query.sh --path <dir>` directly — replacing the "whole-repo query, then
  prefer in-scope results" workaround the eval used with a real query-time filter.
- R5. When `--path` resolves to zero results (nothing under that prefix, or nothing clears
  the similarity floor), the system SHALL report the same empty-miss contract as an
  ordinary miss (epic 1 R4) — no new error shape.
- R6. Version bump (lsa 0.35.0 → 0.36.0, MINOR), CHANGELOG entry, README update.

## Traceability

| Requirement | Verification |
|---|---|
| R1 | Re-run eval probes P3, P9 (where an out-of-scope result outranked an in-scope one pre-fix) with `--path` set to the resolved scope; confirm the in-scope result now ranks by its own merit within the filtered set, and confirm chunks outside the path never appear |
| R2 | Re-run a probe without `--path`; diff against the pre-fix eval's raw output for the same probe — must be identical |
| R3 | `scripts/rag-query.sh --path <dir> "<query>"` invoked directly |
| R4 | `git diff` on the three prose files — content check |
| R5 | `--path` set to a directory with no relevant content; confirm `{"results": []}`, exit 0 |
| R6 | `scripts/check-version-changelog.sh` |
