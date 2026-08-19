# requirements.md — rag-context-engine-and-repo-indexing/canonical-source-weighting

Epic 9 of the `rag-context-engine-and-repo-indexing` pitch, same branch (`feature/rag-context-engine-index-query-pipeline`). Closes disclosed item #3 from `.lsa/observations/2026-08-17-rag-eval/stress-report.md` Part 4: no signal for "canonical vs. historical" content, the root cause behind most of the 44% (4/9) adversarial stress-probe score.

## User flows

| Flow | Success | I/O | Test |
|---|---|---|---|
| 1. Canonical-aware ranking | A canonical source (e.g. `docker/rag_cli.py`) ranks above a historical document discussing the same concept, when both clear the relevance floor | In: query text. Out: ranked results, canonical favored at near-equal relevance | Re-run SP3, SP4, SP9 |
| 2. Widened pre-fusion candidate pool | A canonical chunk that previously fell outside the naive top-5 pre-fusion window is now considered | In: query text. Out: candidate set of size `CANDIDATE_K` per sub-query, fused, then trimmed to `TOP_K` for output | Re-run SP4 |
| 3. Determinism + no regression | Same query + same index → same order, every time; everything already passing stays passing | In: repeated identical query. Out: identical ordering | Re-run SP1/SP5/SP7/SP8/P9-regression-guard, confirm unchanged |

**Two explicit non-goals, disclosed up front:**
- **SP2** (pure paraphrase, zero literal overlap) is a semantic-understanding gap, not a ranking-order gap. Not expected to be fixed by this design.
- **SP6** (pitch Appetite section vs. prior-art research doc) is a **historical-vs-historical** mis-ranking under the approved classification (pitches → historical). The canonical boost does not differentiate within the historical bucket. Not expected to be fixed by this epic.

## Requirements

- R1. While handling a query request, the system shall classify each pre-fusion candidate chunk's `doc_class` as "canonical" when its stored `path` matches an approved canonical path prefix (`lsa/`, `core/`, `manager/`, `prompt-engineer/`, `observer/`, `.lsa/VISION.md`, `.lsa/main.spec.md`, `.lsa.yaml`, `.lsa/roadmap.yaml`, `.lsa/standards/`, `.lsa/modules/`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, `docker/`, `scripts/`), and "historical" otherwise (unmatched defaults to historical, not canonical).
- R2. While handling a query request, the system shall widen the number of candidates fetched from each of the vector and full-text sub-queries, before RRF fusion, from `TOP_K` to a new `CANDIDATE_K` constant greater than `TOP_K`.
- R3. While handling a query request, the system shall return exactly `TOP_K` final results to the caller — unchanged from current behavior; the widened pool (R2) affects only the pre-fusion working set.
- R4. While ranking fused candidates, the system shall apply a deterministic boost favoring canonical-classified (R1) chunks over historical-classified chunks at equal or near-equal fused relevance, without letting the boost exclude a historical chunk that clears the existing similarity/lexical gate by a clear relevance margin over any canonical alternative.
- R5. While ranking fused candidates, the system shall produce identical result ordering for repeated identical queries against an unchanged index — no randomness introduced.
- R6. The system shall preserve `cmd_query`'s existing CLI contract unchanged: argument list, output JSON shape, `--path`/`--sha` filtering behavior, and the `MIN_SIMILARITY` OR-gate semantics.
- R7. The system shall not modify the LanceDB chunk schema, `CHUNK_SCHEMA_VERSION`, or require a reindex — `doc_class` is computed at query time only, from the already-stored `path` field.

## Grounding facts (from discover)

- `docker/rag_cli.py:406` chunk schema has no `doc_class` field; `path` is already stored per row.
- `docker/rag_cli.py:118` `SKIP_DIR_NAMES`, `:126` `ARCHIVE_PATH_PREFIX` — existing precedent for path-prefix classification logic in this file.
- `docker/rag_cli.py:594` vector sub-query capped at `TOP_K=5` (`:549`) before RRF fusion (`:613`).
- `docker/rag_cli.py:600-609` FTS sub-query overfetches (`FTS_OVERFETCH_LIMIT=100000`, `:559`) but is trimmed to `TOP_K=5` before fusion — same premature-truncation shape as the vector side.
- `docker/rag_cli.py:618-636` final loop builds `results` from `hits` (`combined.slice(0, TOP_K)` at `:614`) — boost must apply before this slice.
- `.lsa/observations/2026-08-17-rag-eval/stress-report.md` Part 3 (root cause), `stress-probes.md` (SP2/SP3/SP4/SP6/SP9 exact text).
- `.lsa.yaml:28` `reconcile.runs = 3`. `.lsa.yaml:6` `specs_root = .lsa/`.

## Scope

`docker/rag_cli.py` only. No `lsa` plugin `artifact_path` touched — no version bump (same as epics 1/2/5/6/7/8).
