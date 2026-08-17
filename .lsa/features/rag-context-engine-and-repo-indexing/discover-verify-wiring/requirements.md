# requirements.md — rag-context-engine-and-repo-indexing/discover-verify-wiring

Epic: [rag-context-engine-and-repo-indexing/discover-verify-wiring](../../../pitches/rag-context-engine-and-repo-indexing.md). Hard dependency: `index-query-pipeline` (`7a22662`/`acf5c4b`) — `scripts/rag-query.sh` already exists and works. **Touches lsa plugin `artifact_paths`** (`lsa/knowledge/conventions.md`, `lsa/skills/{discover,verify}/SKILL.md`) — unlike epics 1–2, this needs a version bump + CHANGELOG + README update.

- R1. While a search-heavy step in `lsa:discover` or `lsa:verify` needs to find
  content, when `project-map.yaml` has resolved a directory scope, the system
  SHALL query `scripts/rag-query.sh` within that scope before falling back to
  `Grep`/`Read`.
- R2. When `rag-query.sh` returns a fresh, good match, the system SHALL use the
  cited chunk(s) directly, skipping a whole-file `Read` for that content.
- R3. When `rag-query.sh` returns no good match, is stale, or is unavailable
  (Docker unreachable), the system SHALL fall back to `Grep`/`Read` exactly as
  before this epic, with a one-line observable notice that the fallback path
  was used.
- R4. `lsa/knowledge/conventions.md`'s Read protocol section SHALL document this
  order: `project-map.yaml` (directory scope, unchanged) → `rag-query.sh` (rank
  within scope) → `Grep`/`Read` (fallback).
- R5. `lsa/skills/discover/SKILL.md` Step 1 SHALL reference querying
  `rag-query.sh` within the `project-map`-resolved scope for its search step.
- R6. `lsa/skills/verify/SKILL.md`'s buildability/feasibility step SHALL
  reference `rag-query.sh` for broader exploratory search — distinct from Step
  1's `scripts/resolve-refs.sh` named-symbol resolution, which is unchanged.
- R7. `lsa/.claude-plugin/plugin.json` version SHALL be bumped (MINOR — new
  documented capability), with a corresponding `lsa/CHANGELOG.md` entry and
  `lsa/README.md` update.

## Traceability

| Requirement | Flow | Feature file |
|---|---|---|
| R1, R2, R3 | RAG queried within project-map scope before falling back | `flow-1-rag-first-fallback.feature` |
| R4, R5, R6 | The three files document the right order and references | `flow-2-doc-content.feature` |
| R7 | (doc/version requirement, no dedicated scenario) | — |
