# grounding.md — rag-plugin-plug-and-play/relocate-and-run-in-place

## Reference map

Primary grounding is direct `Read` of `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-rag-index-fresh.sh`, `scripts/check-rag-index-matches-head.sh`, `Dockerfile`, `docker/rag_cli.py`, `lsa/skills/init/SKILL.md`, and `.lsa.yaml` during discover (line numbers cited in `requirements.md`'s Grounding facts section), cross-checked with `bash scripts/resolve-refs.sh`:

| Symbol | `resolve-refs.sh` output |
|---|---|
| `repo_root` | `exists @ .claude/hooks/commit-discipline-check.sh:65` (confirms the pattern is used elsewhere in this codebase too, not invented; primary citation is `scripts/rag-index.sh:49-51`, direct-read) |
| `IMAGE_NAME` | `exists @ .lsa/features/rag-context-engine-and-repo-indexing/index-freshness/grounding.md:7` (primary citation: `scripts/rag-index.sh:53`, direct-read) |
| `SOURCE_HASH` | `exists @ scripts/rag-index.sh:95` — direct hit on the primary citation itself |
| `CLAUDE_PLUGIN_ROOT` | `exists @ .lsa/2026-05-20-lsa-v0.2.0-design.md:103` (primary citation: `lsa/skills/init/SKILL.md:41`, direct-read, the established dual-mode precedent) |
| `artifact_paths` | `exists @ .claude/hooks/commit-discipline-check.sh:155` (primary citation: `.lsa.yaml:75-88`, direct-read) |

## Feasibility per flow

- **Flow 1 (standalone against an arbitrary repo):** buildable. The container-side `docker/rag_cli.py` already takes `--scope`/`--index-dir`/`--repo-root` as CLI args (confirmed via direct read of `scripts/rag-index.sh`'s `docker run` invocation) — it has no repo-specific assumptions to remove. Only the two host-side wrapper scripts' own `docker build`/`SOURCE_HASH` logic (currently reading `${repo_root}/Dockerfile`) needs the build-context/target-repo split.
- **Flow 2 (existing dogfood path unaffected):** buildable and directly testable — `bash scripts/gate.sh` is a real, already-existing aggregate runner; a before/after diff is a live, no-new-tooling test. Baseline already captured this session: `rag-index-fresh` PASS, `rag-index-matches-head` PASS (only `docs-invariants` FAILs, pre-existing and unrelated — C20 gap for this epic's own `conformance.md`, expected before reconcile).

## Assumptions

None flagged `[ASSUMPTION]` — every requirement traces to a direct-read line number in the existing codebase.

## Gate

`bash scripts/gate.sh` — same pattern as every epic in this initiative: `docs-invariants` FAILs on C20 only (this epic's `conformance.md` doesn't exist yet — reconcile writes it). All other checks PASS, including `rag-index-fresh` and `rag-index-matches-head` (the two Flow 2 must keep passing).

## Verdict

**GROUNDED.** All named symbols resolve to real, existing code; both flows are buildable on what exists; the one gate FAIL is the expected pre-reconcile C20 gap.
