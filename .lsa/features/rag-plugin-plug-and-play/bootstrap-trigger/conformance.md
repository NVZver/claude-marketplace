# conformance.md — rag-plugin-plug-and-play/bootstrap-trigger

Independent grading pass (`lsa:reconcile`), graded against implementation `555749c`. All live verification used a real scratch git repo under `/Users/nvz/tmp-bootstrap-verify/` — not simulated, later deleted.

## Real finding during verification (disclosed, not new, blast radius worth naming)

The first `bootstrap-rag.sh` run against the freshly created scratch repo hit the same pre-existing, already-disclosed transient bug from epic 1's own reconcile (`rc=$?` inside a negated `if` in `rag-index.sh` always shows "(exit 0)" for a genuinely nonzero but transient first-run failure, consistent with a virtiofs mount-settling delay on freshly created repo content). `bootstrap-rag.sh` correctly propagated this as a real failure and aborted — the *right* behavior per its own spec ("don't swallow errors silently"), not a bug in this epic's code. Worth naming explicitly: because bootstrap is multi-step, this pre-existing flakiness has a **larger blast radius** here than in epic 1 (aborts the whole unattended flow, not just one index/query call) — a real, disclosed cost of the pre-existing bug, not a new defect. An immediate retry succeeded cleanly, matching epic 1's own observed pattern exactly.

## Live verification (Flow 1 — detect + offer)

```
$ time bash lsa/hooks/rag-bootstrap-check.sh
RAG search isn't set up for this repo yet. Run the lsa:bootstrap-rag skill to set it up (Docker build + index + git-hook wiring, unattended).
... 0.518 total
exit: 0
```
Real repo, `.lsa.yaml` present with no `rag-index-fresh` entry, Docker reachable — offer fired correctly in 0.5s, well inside the 10s budget.

## Live verification (Flow 2 — silent negative cases)

| Case | Output | Exit |
|---|---|---|
| Already bootstrapped (`rag-index-fresh` present) | `''` | 0 |
| No `.lsa.yaml` at all | `''` | 0 |
| `docker` not on `PATH` (`PATH=/usr/bin:/bin`) | `''` | 0 |

All three confirmed silent, exit 0.

## Live verification (Flow 3 — one invocation bootstraps everything)

After the transient-failure retry (above), a clean run produced, verified by direct inspection of the resulting files — not just the script's own claimed summary:

| Artifact | Verified state |
|---|---|
| `.lsa.yaml` `rag: canonical_paths:` | `- lib/` (correctly seeded from the scratch repo's own `modules: lib: artifact_paths: [lib/**/*.py]`) |
| `.lsa.yaml` `gate:` block | `rag-index-fresh: bash $CLAUDE_PLUGIN_ROOT/scripts/check-rag-index-fresh.sh` and `rag-index-matches-head: bash $CLAUDE_PLUGIN_ROOT/scripts/check-rag-index-matches-head.sh` — literal `$CLAUDE_PLUGIN_ROOT`, unexpanded, per the disclosed scope boundary |
| `.gitignore` | `.lsa/.rag-index/` entry present, with explanatory comment |
| `git config core.hooksPath` | `/Users/nvz/github/claude-marketplace/lsa/hooks` — correct, points at the plugin's own hooks dir |
| Index directory | `lancedb/` present, real content |

## Live verification (Flow 4 — portable git hook)

Added `lib/second.py`, staged it plus the bootstrap-modified `.lsa.yaml`/`.gitignore`, ran a real `git commit`. The hook fired (visible per-file `rag-index.sh` output during the commit, including one instance of the same known transient bug — correctly downgraded to a `WARNING:` on stderr, not a blocked commit: `commit exit: 0`). A subsequent real query (`rag-query.sh "another_helper second file" --path lib/`) returned `lib/second.py:1-3` as the top hit (similarity 0.7854) — direct proof the hook's reindex actually reached the vector store, not just that the hook ran without error.

## No regression (this repo's own setup)

| Check | Result |
|---|---|
| `bash scripts/check-rag-index-fresh.sh` (via `gate.sh`) | PASS |
| `bash scripts/check-rag-index-matches-head.sh` (via `gate.sh`) | PASS |
| `.githooks/pre-commit`, `lsa/hooks/session-start-drift-check.sh`, `.gitignore`, `docker/rag_cli.py` | `git diff --stat`: zero changes |
| `.lsa.yaml` | 1-line diff only — the legitimate R6 `artifact_paths` addition |

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/hooks/hooks.json` (second `SessionStart` entry) | Code-reviewed: additive, existing entry untouched; JSON parses | ✅ |
| R2 | `lsa/hooks/rag-bootstrap-check.sh` | Live: Flow 1 offer fires; all three Flow 2 negative cases confirmed silent | ✅ |
| R3 | `lsa/hooks/rag-bootstrap-check.sh` (every exit path) | Live: exit 0 confirmed in all 4 tested paths (offer + 3 negatives) | ✅ |
| R4 | `lsa/skills/bootstrap-rag/SKILL.md`, `lsa/scripts/bootstrap-rag.sh` | Live: all 5 outcomes directly inspected in the scratch repo (table above), not just the script's own claimed summary | ✅ |
| R5 | `lsa/hooks/pre-commit` | Live: real `git commit` triggered it; reindexed content confirmed findable via a real query | ✅ |
| R6 | `.lsa.yaml` (`lsa/hooks/pre-commit` added to `artifact_paths`) | Code-reviewed: one line, correctly placed before the `.sh` glob it needs to supplement | ✅ |
| R7 | N/A (absence of changes) | `git diff --stat` on the 4 named untouched paths: zero changes; gate checks unchanged PASS | ✅ |

Orphan hunks: none.

## Gate (`bash scripts/gate.sh`)

Same C20-only pre-reconcile pattern as every epic in this initiative — all other checks PASS, including `rag-index-fresh`/`rag-index-matches-head`.

## Verdict

**reconcile: PASS @ 555749c**

All 7 requirements verified live against a real scratch repo through the full pipeline — detection hook, orchestration script, and a genuine git commit exercising the portable hook end to end. One real, disclosed finding: the pre-existing transient exit-code bug from epic 1 has a larger blast radius in a multi-step bootstrap (aborts the whole flow, not just one call) — not a new defect, correctly propagated rather than swallowed, and confirmed to resolve cleanly on retry.
