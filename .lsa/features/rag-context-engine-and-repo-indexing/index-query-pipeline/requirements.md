# requirements.md — rag-context-engine-and-repo-indexing/index-query-pipeline

Epic: [rag-context-engine-and-repo-indexing/index-query-pipeline](../../../pitches/rag-context-engine-and-repo-indexing.md) — foundation epic (Docker-packaged index-and-query pipeline). No other epic in the parent pitch is testable before this one ships.

- R1. While the Docker daemon is reachable, when `scripts/rag-index.sh` is invoked against a
  scope, the system SHALL build or update the local vector index for that scope using
  structural chunking (Markdown H2/H3 boundaries, bash function/block boundaries, fixed-size
  overlapping window elsewhere) and local, no-network embedding.
- R2. When a chunk's content-hash already exists in the index at the current embed-model and
  chunk-schema version, the system SHALL skip re-embedding that chunk.
- R3. While the Docker daemon is reachable and the index is present, when
  `scripts/rag-query.sh` is invoked with a query, the system SHALL return the top-ranked
  matching chunks, each with a `path:start-end` citation.
- R4. When no chunk in the index is a good match for the query, the system SHALL return an
  empty result distinguishable from both an error and a low-confidence match.
- R5. If the Docker daemon is unreachable, when `scripts/rag-index.sh` or
  `scripts/rag-query.sh` is invoked, the system SHALL exit with a status distinct from both
  success and an ordinary retrieval miss, and SHALL report the fault as "Docker daemon
  unreachable" — never presented as a search miss (`.lsa/pitches/rag-context-engine-and-repo-
  indexing.md` Rabbit hole 2).
- R6. While this epic's artifacts (`Dockerfile`, `scripts/rag-index.sh`,
  `scripts/rag-query.sh`, the `rag-index-fresh` gate script) are outside every plugin's
  `artifact_paths` (`.lsa.yaml:62-113`), the system SHALL require no plugin version bump or
  CHANGELOG entry, per the `scripts/check-lib-pins.sh:15-16` precedent.
- R7. When the `rag-index-fresh` gate check is run, the system SHALL exit 0 if the Docker
  daemon is reachable and the index is structurally present, and SHALL otherwise exit
  non-zero following the `scripts/check-lib-pins.sh` three-outcome contract (1 =
  STALE/BROKEN, 2 = `[cannot verify]`).

## Traceability

| Requirement | Flow | Feature file |
|---|---|---|
| R1, R2, R5 | Build/update the index | `flow-1-build-index.feature` |
| R3, R4, R5 | Query the index | `flow-2-query-index.feature` |
| R7 | `rag-index-fresh` gate check | `flow-3-gate-check.feature` |
| R6 | (cross-cutting — no dedicated scenario; verified structurally at reconcile time against `.lsa.yaml:62-113`) | — |
