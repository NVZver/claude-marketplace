# requirements.md — rag-context-engine-and-repo-indexing/hybrid-retrieval

Epic 6 of `rag-context-engine-and-repo-indexing` (discovered via stress-testing epic 5's fix, not pre-planned). The eval's real-fix re-verification found dense-vector-only search misses queries whose relevant text is present in exact literal form but doesn't embed with high similarity (P5: mid-dot typography; P10: a literal phrase in a chunk whose overall embedding score didn't clear the floor). Fixed by adding a lexical signal via LanceDB's native hybrid search, not a one-off patch — closes an open question flagged during this pitch's own prior-art research (`.lsa/research/rag-context-engine-and-repo-indexing-prior-art.md` O4: no production RAG system studied relies on dense vectors alone).

- R1. `docker/rag_cli.py cmd_index` SHALL build/maintain a full-text search index on the
  chunk text alongside the existing vector index, using LanceDB's native FTS capability
  (`create_fts_index`, default non-tantivy backend — no new pip dependency).
- R2. `docker/rag_cli.py cmd_query` SHALL perform hybrid (vector + full-text) search by
  default (`query_type="hybrid"`), using LanceDB's default reciprocal-rank-fusion
  reranker, replacing pure-vector-only search as the query path.
- R3. Hybrid search SHALL still honor the existing `--path` pre-filter
  (`path-scoped-query-fix`) and the existing empty-miss contract (`{"results": []}`,
  exit 0) — no new error shape.
- R4. **Regression guard**: every probe the original eval's dense-only search already won
  on SHALL still pass under hybrid search — P1, P3, P4, P8, P9 (direct hits) and P12
  (correctly judging an incidental lexical match as unrelated) are not allowed to regress.
  Hybrid must be additive to dense search's existing strengths, not a trade against them.
- R5. P5 and P10 — the two probes dense-only search missed — SHALL now be found, verified
  live against the real index, not assumed from the design alone.
- R6. No plugin surface touched (internal to `docker/rag_cli.py`; `discover`/`verify`'s
  prose already just says "query `rag-query.sh`," not the internal search mechanism) —
  no version bump needed, matching the `check-lib-pins.sh:15-16` "repo-internal" precedent
  from epics 1-2.

## Traceability

| Requirement | Verification |
|---|---|
| R1, R2 | Rebuild the index for real, confirm an FTS index exists alongside the vector index |
| R3 | Re-run the `--path`/empty-scope tests from `path-scoped-query-fix` under hybrid search |
| R4 | Re-run P1, P3, P4, P8, P9, P12 live — all must still hit |
| R5 | Re-run P5, P10 live — both must now hit |
| R6 | No `lsa/` file in the diff |

## Design note — the real API, verified before writing this spec

`lancedb==0.25.0` (pinned, `Dockerfile`) has a native `LanceHybridQueryBuilder`
(`lancedb.query`), reached via `table.search(query, query_type="hybrid")` — confirmed by
reading `LanceQueryBuilder.create`'s actual source inside the running container, not
assumed from general LanceDB knowledge (the public `search()` docstring is stale/
incomplete on this point — a real, disclosed gap in the library's own documentation for
this pinned version, not this repo's mistake). Default reranker is RRF (reciprocal rank
fusion) over the vector and FTS result sets. `create_fts_index`'s own docstring calls the
FTS API itself "highly experimental and... likely to change" — a real, disclosed
upstream caveat to carry forward, not smoothed over.
