# requirements.md — rag-plugin-plug-and-play/generic-canonical-config

Epic 2 of 4 of the `rag-plugin-plug-and-play` pitch. No hard dependency — can run in parallel with `relocate-and-run-in-place` (already shipped). Soft dependency for `bootstrap-trigger` (which can ship first against the safety-default + notice if this epic isn't done yet).

## Design note (grounded at discover time)

`cmd_query` currently has **no `/repo` mount at all** — only `/index` (`lsa/scripts/rag-query.sh:202-220`). Rather than adding a new mount just to read one YAML file at query time, this epic reuses the established pattern from epic 8 (`index-freshness`): resolve config once at *index* time (when `/repo` is already mounted) and persist it into `/index`, so query time needs no new mount or argument — the same shape as `.ignored-list.txt`.

## User flows

| Flow | Success | I/O | Test |
|---|---|---|---|
| 1. Config-driven classification, index-time resolved | A target repo's own configured canonical paths — not claude-marketplace's — drive its ranking boost | In: `.lsa.yaml`'s `rag: canonical_paths:`. Out: `/index/.canonical-paths.txt`, used at query time | Second scratch repo with its own distinct config |
| 2. Safe default + visible notice when unconfigured | No config → everything defaults to historical (unchanged safety), but loudly, not silently | In: absent/empty block. Out: empty persisted list + stderr notice | Third scratch repo, no `rag:` block |
| 3. Auto-seed from a repo's own module structure | A real, correct starting config, derived not guessed | In: target `modules.*.artifact_paths`. Out: `rag: canonical_paths:` written into that repo's `.lsa.yaml`, existing hand-added entries preserved | Scratch repo with its own `modules:` block |
| 4. Existing dogfood path unaffected | This repo's own root-level setup and gate checks stay untouched | In: existing gate commands. Out: unchanged pass/fail | `bash scripts/gate.sh` before/after |

## Requirements

- R1. While building an index, `cmd_index` shall resolve canonical-path classification from the target repo's own `.lsa.yaml` `rag: canonical_paths:` block (read from the already-mounted `/repo/.lsa.yaml`), replacing the hardcoded `CANONICAL_PATH_PREFIXES` tuple.
- R2. While building an index, `cmd_index` shall persist the resolved list into `/index/.canonical-paths.txt` (one prefix per line), refreshed on every index run.
- R3. While querying, `classify_doc_class` shall classify each candidate using the list loaded from `/index/.canonical-paths.txt` — no new mount, no new required argument on `cmd_query`.
- R4. Where `/repo/.lsa.yaml` has no `rag: canonical_paths:` block (or an empty one), the system shall persist an empty list (every chunk defaults to "historical," unchanged safety) and `cmd_index` shall emit an explicit one-line stderr notice naming the seed script.
- R5. The system shall provide `lsa/scripts/seed-canonical-paths.sh <target-repo>`, deriving a starting `rag: canonical_paths:` block from that repo's own `modules.*.artifact_paths` (one entry per unique top-level path segment before the first wildcard, deduplicated), merged into that repo's `.lsa.yaml` without deleting existing hand-added entries.
- R6. The `rag: canonical_paths:` block shall be capped at **40** entries (corrected from the pitch's mismatched "5, like `libs:`" suggestion — this repo's own real classification already needs 17, confirmed by direct count).
- R7. The system shall add no new external dependency — the `rag:` block is parsed with a minimal, dependency-free line-based parser, matching this repo's existing `libs:`/`modules:` block-parsing convention (`scripts/lint.sh`'s awk-based approach).
- R8. This epic shall modify only the plugin-shipped copy (`lsa/docker/rag_cli.py`, new `lsa/scripts/seed-canonical-paths.sh`) — the root-level `docker/rag_cli.py` and this repo's own `.lsa.yaml` stay unchanged.

## Grounding facts (from discover)

- `lsa/docker/rag_cli.py:592-611` `CANONICAL_PATH_PREFIXES` hardcodes 17 claude-marketplace-specific entries.
- `lsa/docker/rag_cli.py:614-635` `classify_doc_class(path)` — the function modified.
- `lsa/docker/rag_cli.py` `cmd_query` (`p_query`, line ~799-802) has no `--repo-root` argument; `cmd_index` does (`--repo-root`, default `/repo`, line 429).
- `lsa/scripts/rag-query.sh:202-220` mounts only `-v "${INDEX_DIR}:/index:ro"` — no `/repo` mount.
- Epic 8 (`index-freshness`) precedent: `.ignored-list.txt` computed on the host/at-index-time, passed via a mounted file inside `/index`, not recomputed at query time.
- `.lsa.yaml:59-61` `libs:` block + `scripts/lint.sh:534-551` C18 check, `LIBS_CAP=5` — the capped-block precedent cited by the pitch. Direct count confirms this repo's own real classification needs 17 entries, more than 3x a 5-entry cap.
- `.lsa.yaml:64-115` `modules.*.artifact_paths` — auto-seed source. Confirmed: only covers the 5 plugin module directories, not the 12 remaining real canonical entries (root docs, `.lsa/` meta-files) — auto-seed is a floor, not a complete solution (user-approved, no scope expansion to guess at root-doc heuristics).
- `lsa/docker/Dockerfile`'s pip installs (`fastembed`, `lancedb`, `pyarrow`, `numpy`) — no YAML parser available; adding one would be a new external dependency, against this repo's established minimal-dependency convention.
- Epic 1 (`relocate-and-run-in-place`, shipped, `20ee294`) precedent: modifies only the plugin-shipped copy, root-level files untouched until `dogfood-migration`.

## Scope

`lsa/docker/rag_cli.py`, new `lsa/scripts/seed-canonical-paths.sh`. No third-party library delegation (researched and rejected earlier this session).
