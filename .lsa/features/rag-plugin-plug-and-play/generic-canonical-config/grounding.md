# grounding.md — rag-plugin-plug-and-play/generic-canonical-config

## Reference map

Primary grounding is direct `Read`/`grep` of `lsa/docker/rag_cli.py`, `lsa/scripts/rag-query.sh`, `.lsa.yaml`, and `scripts/lint.sh` during discover (line numbers cited in `requirements.md`'s Grounding facts), cross-checked with `bash scripts/resolve-refs.sh`:

| Symbol | `resolve-refs.sh` output |
|---|---|
| `classify_doc_class` | `exists @ .lsa/features/.../canonical-source-weighting/conformance.md:34` (primary citation: `lsa/docker/rag_cli.py:614-635`, direct-read) |
| `CANONICAL_PATH_PREFIXES` | `exists @ .lsa/features/.../canonical-source-weighting/conformance.md:34` (primary citation: `lsa/docker/rag_cli.py:592-611`, direct-read, 17-entry count confirmed) |
| `cmd_query` | `exists @ .lsa/features/.../canonical-source-weighting/conformance.md:39` (primary citation: `lsa/docker/rag_cli.py` `p_query` argparse block, direct-read — confirmed no `--repo-root`) |
| `cmd_index` | `exists @ .lsa/features/.../hybrid-retrieval/grounding.md:5` (primary citation: `lsa/docker/rag_cli.py:429`, direct-read — has `args.repo_root`) |
| `artifact_paths` | `exists @ .claude/hooks/commit-discipline-check.sh:155` (primary citation: `.lsa.yaml:64-115`, direct-read) |
| `LIBS_CAP` | `exists @ scripts/lint.sh:540` — direct hit on the primary citation itself, confirms `LIBS_CAP=5` |

## Feasibility per flow

- **Flow 1 (config-driven classification):** buildable. `cmd_index` already mounts `/repo` and has `--repo-root` — reading `/repo/.lsa.yaml` there is a straightforward addition. Persisting to `/index/.canonical-paths.txt` follows the exact precedent `load_ignored_list`/`.ignored-list.txt` already established in this same file (epic 8).
- **Flow 2 (safe default + notice):** buildable — an empty/absent block is a simple falsy check; a stderr `print` is trivial.
- **Flow 3 (auto-seed):** buildable — `.lsa.yaml`'s `modules.*.artifact_paths` is plain, predictably-indented YAML (confirmed via direct read of `.lsa.yaml:64-115`); a line-based bash parser matching `scripts/lint.sh`'s existing `libs:`-block-parsing style (`scripts/lint.sh:540-551`, direct-read) is a proven pattern in this exact repo.
- **Flow 4 (existing dogfood path unaffected):** buildable and directly testable — `bash scripts/gate.sh` baseline already captured this session (both `rag-index-fresh`/`rag-index-matches-head` PASS).

## Assumptions

None flagged `[ASSUMPTION]` in the requirements beyond the one explicitly named and user-approved in discover (R5's merge-preserve behavior for the seed script, confirmed via the "seed from artifact_paths only, stay human-editable" gate answer).

## Gate

`bash scripts/gate.sh` — same expected C20-only pre-reconcile pattern as every epic in this initiative. All other checks PASS, including `rag-index-fresh`/`rag-index-matches-head` (Flow 4's own baseline).

## Verdict

**GROUNDED.** All named symbols resolve to real, existing code; every flow is buildable on what exists or on proven patterns already present in this exact repo (`.ignored-list.txt`, `libs:`-block parsing); the one gate FAIL is the expected pre-reconcile C20 gap.
