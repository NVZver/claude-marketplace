# grounding.md — rag-context-engine-and-repo-indexing/hybrid-retrieval

## Reference map

`docker/rag_cli.py` — exists, `cmd_index`/`cmd_query` confirmed present, no FTS/hybrid wiring yet (this epic's target). `lancedb==0.25.0` — installed version confirmed directly inside the running container: `LanceQueryBuilder.create`'s real source (not the public docstring, which is incomplete) confirms `query_type="hybrid"` dispatches to `LanceHybridQueryBuilder`, RRF reranker by default. `create_fts_index` exists on `LanceTable`, default backend is non-tantivy (no new pip dependency).

## Gate

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1   (C20, expected)
  PASS  citations / links / project-map / tests / lib-pins
  PASS  rag-index-fresh / rag-index-matches-head
```

Same structural C20-only pattern as every prior epic.

## Verdict

**NOT-GROUNDED** on the same single structural artifact as epics 1-5. Proceeding to `delegate` on the same established precedent.
