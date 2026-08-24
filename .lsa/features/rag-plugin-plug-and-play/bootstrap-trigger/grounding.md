# grounding.md — rag-plugin-plug-and-play/bootstrap-trigger

## Reference map

Primary grounding is direct `Read` of `lsa/hooks/hooks.json`, `lsa/hooks/session-start-drift-check.sh`, `.githooks/pre-commit`, `.lsa.yaml`, `.gitignore`, and `lsa/scripts/rag-index.sh` during discover, cross-checked with `bash scripts/resolve-refs.sh`:

| Symbol | `resolve-refs.sh` output |
|---|---|
| `hooks.json` | `exists @ .lsa.yaml:81` (primary citation: `lsa/hooks/hooks.json`, direct-read — confirmed `SessionStart` is an array, one entry today) |
| `session-start-drift-check.sh` | `exists @ .claude/hooks/commit-discipline-check.sh:22` (primary citation: `lsa/hooks/session-start-drift-check.sh`, direct-read — confirmed the exit-0-always, bounded-scope pattern) |
| `docker_daemon_reachable` | `exists @ .lsa/features/.../reconcile-wiring/conformance.md:25` (primary citation: `lsa/scripts/rag-index.sh:86-101`, direct-read — confirmed the 5s bounded-poll pattern) |
| `seed-canonical-paths.sh` | `exists @ .lsa/features/.../generic-canonical-config/conformance.md:25` (primary citation: `lsa/scripts/seed-canonical-paths.sh`, epic 2, already shipped `9253977`) |
| `artifact_paths` | `exists @ .claude/hooks/commit-discipline-check.sh:155` (primary citation: `.lsa.yaml:75-89`, direct-read) |

## Feasibility per flow

- **Flow 1/2 (detect + offer / silent negative cases):** buildable — a new bash script following `session-start-drift-check.sh`'s own established shape (`set -uo pipefail`, `trap 'exit 0' ERR`, silent no-op on any missing prerequisite) is a proven pattern already live in this exact file tree.
- **Flow 3 (one invocation bootstraps everything):** buildable — every piece it orchestrates already exists and works: `lsa/scripts/rag-index.sh` (epic 1), `lsa/scripts/seed-canonical-paths.sh` (epic 2), `git config core.hooksPath` (existing manual precedent, `CONTRIBUTING.md:66-70`), `.lsa.yaml gate:`/`.gitignore` edits (plain text writes, same shape as `manager:shape`'s own file-writing pattern).
- **Flow 4 (portable git hook):** buildable — `${BASH_SOURCE[0]}`-relative sibling self-location is the exact, already-proven pattern from epic 1's `check-rag-index-matches-head.sh`.

## Assumptions

One flagged `[ASSUMPTION]` in requirements.md R1: that Claude Code runs each `SessionStart` array entry independently-timed. Not verifiable against Claude Code's own internals from within this repo — a standard hook-runner assumption, disclosed rather than silently made.

## Gate

`bash scripts/gate.sh` — same expected C20-only pre-reconcile pattern (`docs-invariants` FAILs; this epic's `conformance.md` doesn't exist yet). All other checks PASS, including `rag-index-fresh`/`rag-index-matches-head` (Flow 3/4's own regression baseline, unaffected since this epic touches neither script).

## Verdict

**GROUNDED.** All named symbols resolve to real, existing code or already-shipped epic output; every flow is buildable on proven patterns already present in this exact repo; the one flagged assumption is disclosed, not hidden; the one gate FAIL is the expected pre-reconcile C20 gap.
