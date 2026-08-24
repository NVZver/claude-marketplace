# requirements.md — rag-context-engine-and-repo-indexing/index-freshness

Epic 8 of `rag-context-engine-and-repo-indexing` (discovered via stress-testing epics 6-7, not pre-planned). Generalizes two pragmatic one-off patches from epic 7 (`dist/`, `.remember/` hardcoded into `SKIP_DIR_NAMES`) into the real mechanism, and fixes the Docker build-cache staleness incident epic 7's own verification hit.

- R1. `scripts/rag-index.sh` and `scripts/rag-query.sh` SHALL compute a content hash of
  `Dockerfile` + `docker/rag_cli.py` on the host and compare it against a `source-hash`
  label baked into the current `rag-index:local` image (`docker image inspect --format
  '{{ index .Config.Labels "source-hash" }}'`).
- R2. When the hash differs (or the label is absent), SHALL rebuild — see the
  **revision** below for the exact strategy — and re-tag the resulting image with the
  current hash as a label.
- R3. When the hash matches, SHALL skip the rebuild entirely — no performance regression
  for the common, already-fresh case (most invocations, most of the time).

**Revision, made during this epic's own verification, not the original design:** the
first implementation of R2 rebuilt unconditionally with `--no-cache` on every detected
mismatch — reasoning that Docker's own layer-cache invalidation had already silently
failed once (epic 7's `.remember/` incident). Live-tested and rejected: `--no-cache`
discards the expensive `pip install`/embedding-model-download layers on *every* source
edit, not just the one that actually changed, and it **failed outright** under real
network pressure this session (`ERROR: DeadlineExceeded: context deadline exceeded`
during `pip install`). Docker's normal COPY-layer cache invalidation is reliable in the
common case for this specific Dockerfile shape (only the final `COPY docker/rag_cli.py`
+ `ENTRYPOINT` layers depend on the file that changes; the pip/model layers precede it
and are correctly reused). **Corrected design:** try a plain cached `docker build`
first; verify the resulting label actually matches the computed hash; only escalate to
`--no-cache` as a fallback if the cached path still didn't pick up the change. This
keeps the safety net R2 exists for, without paying (or risking failure on) a full
rebuild for the common case.
- R4. `scripts/rag-index.sh` SHALL compute the set of gitignored paths within the given
  `--scope` on the host (`git ls-files --others --ignored --exclude-standard --directory`,
  which returns a mix of whole-directory and individual-file entries — verified directly,
  not assumed) and pass them to the container as a dynamic exclusion list, checked
  in addition to (not replacing) the existing `SKIP_DIR_NAMES`/`.lsa/archive`
  hardcoded safety-net exclusions.
- R5. Re-running the index after this change SHALL produce the same excluded set the
  current hardcoded `dist`/`.remember` patches already achieve, plus additional real
  gitignored content neither patch covered (`.claude/worktrees/`, `.DS_Store`,
  `.claude/settings.local.json`, confirmed present via direct `git ls-files` output) —
  verify no accidental new exclusions or inclusions beyond this.
- R6. Both scripts' existing exit-code/fault contracts (Docker-unreachable = exit 2, the
  `--sha`/`--path` behaviors from prior epics) SHALL be preserved unchanged — the new
  hash-check/rebuild logic must not introduce a new failure mode that's silently
  swallowed or miscategorized.
- R7. No plugin surface touched, no version bump.

## Traceability

| Requirement | Verification |
|---|---|
| R1-R3 | Edit `docker/rag_cli.py` (a real source change), run `rag-index.sh`, confirm a `--no-cache` rebuild triggers; run again unchanged, confirm it's skipped (timed, should be near-instant) |
| R4-R5 | Re-index, confirm `.claude/worktrees/`, `.DS_Store`, `.claude/settings.local.json` are absent from the index alongside the already-known exclusions |
| R6 | Re-run the epic 5/6 regression probes (`--path`, `--sha`, Docker-unreachable) |
