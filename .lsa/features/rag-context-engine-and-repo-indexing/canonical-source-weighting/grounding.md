# grounding.md — rag-context-engine-and-repo-indexing/canonical-source-weighting

## Reference map

Primary grounding is direct `Read` of `docker/rag_cli.py` (line numbers below), cross-checked with `bash scripts/resolve-refs.sh` (output second column — the script resolves to the *first* grep hit repo-wide, which for widely-documented symbols is often a `conformance.md`/observation doc rather than the definition site; still a real, existing reference, just not always the most useful one — a pre-existing script property, out of this epic's scope):

| Symbol | Direct-read location | `resolve-refs.sh` output |
|---|---|---|
| `TOP_K` | `docker/rag_cli.py:549` (`TOP_K = 5`) | `exists @ .lsa/features/.../path-scoped-query-fix/conformance.md:9` |
| `CANDIDATE_K` | does not exist — new constant this epic introduces | `new` |
| `MIN_SIMILARITY` | `docker/rag_cli.py:548` (`MIN_SIMILARITY = 0.65`) | `exists @ .lsa/metrics.md:29` |
| `RRFReranker` | `docker/rag_cli.py:575` (import), `:613` (usage) | `exists @ .lsa/features/.../hybrid-retrieval/conformance.md:10` |
| `cmd_query` | `docker/rag_cli.py:562-639` | `exists @ .lsa/features/.../hybrid-retrieval/grounding.md:5` |
| `get_or_create_table` | `docker/rag_cli.py:402-417` (schema definition) | `exists @ docker/rag_cli.py:402` |
| `SKIP_DIR_NAMES` | `docker/rag_cli.py:118` | `exists @ .lsa/features/.../hybrid-retrieval/conformance.md:22` |
| `ARCHIVE_PATH_PREFIX` | `docker/rag_cli.py:126` | `exists @ .lsa/features/.../index-lsa-content/conformance.md:11` |
| `FTS_OVERFETCH_LIMIT` | `docker/rag_cli.py:559` (def), `:603` (usage) | `exists @ docker/rag_cli.py:64` (docstring mention) |
| `CHUNK_SCHEMA_VERSION` | `docker/rag_cli.py:91` | `exists @ .lsa/observations/2026-08-17-rag-eval/stress-probes.md:13` |

**R7's "no schema change" claim confirmed directly:** `docker/rag_cli.py:404-414`'s `pa.schema([...])` definition has exactly 9 fields (`id`, `path`, `start_line`, `end_line`, `content_hash`, `embed_model`, `chunk_schema`, `text`, `vector`) — no `doc_class` field exists today. `doc_class` (R1) is therefore necessarily query-time-only, matching the spec's design constraint rather than requiring it as an assumption.

## Feasibility per flow

- **Flow 1 (canonical-aware ranking):** buildable. `hits` (post-RRF, pre-slice, `docker/rag_cli.py:614`) is the exact insertion point for a classify-then-boost step before `combined.slice(0, TOP_K)`. No new dependency.
- **Flow 2 (widened candidate pool):** buildable. Two call sites need `TOP_K` → `CANDIDATE_K`: the vector `.limit()` at `:594` and the FTS post-fetch trim at `:608-609` (the FTS *fetch* itself already uses `FTS_OVERFETCH_LIMIT=100000`, `:559`, so only the trim threshold moves — no new LanceDB call needed).
- **Flow 3 (determinism + no regression):** buildable and directly testable — `rag-query.sh` is a real, already-existing CLI entrypoint; re-running it twice with the same query against an unchanged index is a live, no-new-tooling test.

## Assumptions

None flagged `[ASSUMPTION]` — every requirement traces to a direct-read line number or an existing, already-verified epic artifact (`hybrid-retrieval`/`path-scoped-query-fix` conformance docs).

## Gate

`bash scripts/gate.sh` — `docs-invariants` FAILs on **C20 only** (`canonical-source-weighting` has `requirements.md` but no `conformance.md` yet — reconcile writes it). Every other check PASSes: `citations` ✓, `links` ✓, `project-map` ✓, `tests` ✓, `lib-pins` ✓, `rag-index-fresh` ✓, `rag-index-matches-head` ✓. This is the same expected, owner-approved pre-reconcile pattern documented in every prior epic of this initiative (`index-query-pipeline` through `index-freshness`) — not a new or unexpected defect.

## Verdict

**GROUNDED.** All named symbols resolve to real, existing code; no infeasible flow; R7's no-schema-change claim independently confirmed against the live schema definition, not assumed from the pitch/spec alone; the one gate FAIL is the expected pre-reconcile C20 gap, consistent with this initiative's established, owner-approved precedent.
