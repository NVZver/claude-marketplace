# conformance.md — rag-context-engine-and-repo-indexing/index-lsa-content

Independent grading pass (`lsa:reconcile`). The dispatched implementer stalled mid-verification (600s watchdog, no Docker/code fault — the code diff it left was correct); I took over verification directly rather than re-dispatch from scratch, and in doing so found two more real gaps beyond the epic's original scope, both fixed and disclosed below, not smoothed over.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `SKIP_DIR_NAMES` basename check retained — `docker/rag_cli.py` (`_is_excluded_dir`) | Live, direct index inspection: `.git/`, `.rag-index/`, `node_modules/`, `__pycache__/` all confirmed absent from 373 indexed paths | ✅ |
| R2 | blanket dot-directory exclusion removed — `docker/rag_cli.py` (`_is_excluded_dir`) | Live: `.lsa/`, `.githooks/`, `.github/`, `.claude/` content confirmed present among the 373 indexed paths | ✅ |
| R3 | `.lsa/archive/` path-prefix exclusion — `docker/rag_cli.py` (`ARCHIVE_PATH_PREFIX`) | Live: confirmed absent from the index; the path-prefix (not basename) design confirmed by code inspection — no unrelated "archive"-named directory exists elsewhere in this tree to cross-check against, but the logic itself is exact-path, not name-based | ✅ |
| R4 | `.lsa/.rag-index/` self-exclusion, still covered by R1's `.rag-index` basename skip | Live: confirmed absent | ✅ |
| R5 | previously-invisible content now findable — `docker/rag_cli.py` | Live: `.githooks/pre-commit` and `.lsa/` content (237 non-archive paths) both confirmed indexed and returned as real query candidates | ✅ |
| R6 | build timing measured honestly | Live, three real timed rebuilds: 4:15.76 (dist/.remember still present) → 3:14.58 (after --no-cache rebuild with both fixes, one file count still creeping from concurrent stress-test file additions) → **2:04.83 final** (up from the pre-epic 88s baseline — a real ~1.4x increase after final exclusions, not the ~2.9x the first, dist/.remember-polluted measurement suggested) | ✅ |
| R7 | no plugin surface touched | `git diff --stat` (once staged): `docker/rag_cli.py` only | ✅ |
| R8 | `dist/` exclusion, found during this epic's own verification | Live: re-indexed with the fix, confirmed 0 `dist/`-prefixed paths in the index (was contaminating results with duplicate content before) | ✅ |
| R9 | `.remember/` exclusion, found the same way | Live: re-indexed, confirmed 0 `.remember/`-prefixed paths — **required a second pass**: the first attempted fix silently failed to take effect due to a Docker build-cache staleness issue (confirmed: `docker build -q` without `--no-cache` kept baking in the pre-fix `SKIP_DIR_NAMES` despite the source file being correct on disk; `--no-cache` resolved it). Recorded as a real incident, not silently retried past. | ✅ |

Orphan hunks: none.

`.lsa/observations/2026-08-17-rag-eval/stress-probes.md` predates this epic's `delegate` call (written during discover/spec-adjacent stress-test design, before the implementer was dispatched) — excluded from the count on that basis, same treatment as prior epics' pre-existing artifacts.

## Findings beyond this epic's original scope, disclosed not fixed

1. **`scripts/rag-index.sh`/`rag-query.sh` only build the image if absent, never if stale.** The `docker image inspect` check that gates a rebuild has no content-hash or mtime comparison against the current `Dockerfile`/`docker/rag_cli.py` — routine usage after editing either would silently keep using an old cached image. This session's own R9 incident (a stale image silently serving pre-fix behavior) is a live demonstration of this exact gap. Not fixed here — a real design decision (add a source hash check, or always rebuild) for a human to make.
2. **The indexer does not consult `.gitignore` at all.** `dist/` and `.remember/` are two concrete instances of the same root cause, patched individually (`SKIP_DIR_NAMES` entries) rather than fixed generically. A third gitignored directory would need the identical one-line patch again. The generic fix (host-side `git ls-files --others --exclude-standard`, since the container has no `git` CLI) is a real architecture change, flagged for a human decision, not built unilaterally in this epic.
3. **Retrieval precision degrades on some queries as the corpus grows more historical-content-heavy** — documented in the stress-test report (`.lsa/observations/2026-08-17-rag-eval/stress-report.md`), not this epic's to fix; this epic only controls what's *eligible* to be indexed, not ranking quality.

## Gate (`bash scripts/gate.sh`)

Same structural C20-only pattern as epics 1-6; all `rag-index-*` checks pass.

## Verdict

**reconcile: PASS @ 7545a4b**

All 9 requirements verified live, including two discovered and fixed mid-verification. One real operator incident (Docker build-cache staleness) encountered, diagnosed, and resolved rather than worked around silently. Two further findings disclosed as explicitly out of this epic's scope for a human decision, not fixed unilaterally.
