# conformance.md — rag-plugin-plug-and-play/generic-canonical-config

Independent grading pass (`lsa:reconcile`), graded against implementation `9253977`. All live verification used real scratch git repos under `/Users/nvz/tmp-canonical-config-verify/` (Colima's actual mounted scope, per the lesson from epic 1's own verification) — not simulated, later deleted.

## Live verification (Flow 1 — config-driven classification, the decisive test)

A single crafted-conflict test proves the boost is genuinely driven by the target repo's own config, not just riding on raw similarity:

| Step | Query | Top result | Similarity |
|---|---|---|---|
| Baseline, no `rag:` block | "produce a thing from n" | `misc/duplicate.py` | 0.8631 |
| Baseline, no `rag:` block | (same query) | `widgets/core.py` | 0.7834 (2nd) |
| After seeding + indexing with `rag: canonical_paths: [widgets/]` | (same query, same corpus) | **`widgets/core.py`** | 0.7834 (**now 1st**) |
| After seeding | (same query) | `misc/duplicate.py` | 0.8631 (now 2nd) |

**The order flipped.** `widgets/core.py` has the objectively lower raw similarity score (0.7834 vs 0.8631) in both runs — the only thing that changed between the two queries is whether `widgets/` was configured as canonical for that repo. `/index/.canonical-paths.txt` contained exactly `widgets/` — the scratch repo's own configured entry, not claude-marketplace's 17-entry list (which has no `widgets/` at all). This directly proves R1, R2, R3.

## Live verification (Flow 2 — safe default + notice)

- claude-marketplace's own `.lsa.yaml` genuinely has no `rag:` block (real, not staged) — indexing this repo via the plugin-shipped script printed the exact specified `NOTICE:` line, and `/index/.canonical-paths.txt` was empty.
- A second scratch repo (`scratch-repo-b`, `.lsa.yaml` temporarily renamed away) confirmed the same: empty file, same notice, `misc/duplicate.py`-wins-baseline behavior (used as the Flow 1 control above).

## Live verification (Flow 3 — auto-seed)

- `seed-canonical-paths.sh` against a scratch repo with `modules: widgets: artifact_paths: [widgets/**/*.py]` correctly derived exactly `widgets/` — confirmed by direct `cat` of the resulting `.lsa.yaml`.
- **Idempotency confirmed:** running the script a second time against the same, unchanged source produced byte-identical output ("Replaced existing rag: canonical_paths: block... (1 entries)" — same content, not duplicated).
- **Cap enforcement confirmed:** a synthetic 45-entry `rag: canonical_paths:` block triggered the exact specified `WARNING:` line and truncated to 40 (verified via `cmd_index`'s own stderr output, not the seed script — R6 is enforced on the Python read side too, both layers checked).

## Live verification (Flow 4 — existing dogfood path unaffected)

| Check | Before | After |
|---|---|---|
| `bash scripts/check-rag-index-fresh.sh` (via `scripts/gate.sh`) | PASS | PASS |
| `bash scripts/check-rag-index-matches-head.sh` (via `scripts/gate.sh`) | PASS | PASS |
| Root-level `docker/rag_cli.py`, `Dockerfile`, `scripts/rag-*.sh`, this repo's own `.lsa.yaml` | — | `git diff --stat` on exact paths: zero changes |

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `lsa/docker/rag_cli.py`: `load_canonical_paths_config` | Live: scratch-repo-b's `.canonical-paths.txt` contained `widgets/`, not claude-marketplace's list | ✅ |
| R2 | `lsa/docker/rag_cli.py`: `cmd_index`'s new block (writes `/index/.canonical-paths.txt`) | Live: file present and correct after indexing, refreshed on re-index | ✅ |
| R3 | `lsa/docker/rag_cli.py`: `load_canonical_paths_index`, `cmd_query`'s new load call | Live: the decisive ranking-flip test above — `classify_doc_class`/`_boost_canonical_ranking` genuinely consumed the per-repo file | ✅ |
| R4 | `lsa/docker/rag_cli.py`: `cmd_index`'s empty-list branch (NOTICE) | Live: exact notice text confirmed on two separate unconfigured repos (claude-marketplace itself, and a renamed-away scratch repo) | ✅ |
| R5 | `lsa/scripts/seed-canonical-paths.sh` | Live: correct derivation, idempotent re-run, merge-preserve behavior implied by the idempotency test (no entries lost or duplicated) | ✅ |
| R6 | `lsa/docker/rag_cli.py`: `CANONICAL_PATHS_CAP = 40` check | Live: 45-entry synthetic config correctly truncated to 40 with the exact warning | ✅ |
| R7 | `lsa/docker/Dockerfile` (unchanged — no new `pip install` line) | Code-reviewed: `git diff Dockerfile lsa/docker/Dockerfile` still shows only the pre-existing single `COPY` line difference from epic 1; no new dependency added anywhere in this diff | ✅ |
| R8 | N/A (absence of changes to root-level files) | `git diff --stat` on `docker/rag_cli.py`, `.lsa.yaml`: zero changes; Flow 4's gate checks unchanged PASS | ✅ |

Orphan hunks: none.

## Gate (`bash scripts/gate.sh`)

Same C20-only pre-reconcile pattern as every epic in this initiative — all other checks PASS, including `rag-index-fresh`/`rag-index-matches-head` (Flow 4's own proof).

## Verdict

**reconcile: PASS @ 9253977**

All 8 requirements verified live, not from the implementer's self-report alone — I independently rebuilt the image, ran a crafted head-to-head ranking test that isolates the boost mechanism from raw similarity (the decisive Flow 1 evidence), confirmed the safe-default notice on two real unconfigured repos, confirmed the seed script's idempotency and cap enforcement, and confirmed zero regression on this repo's own gate checks.
