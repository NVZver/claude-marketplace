# RAG eval probes — ground truth

Written and ground-truth-verified **before** running any of the 4 conditions, to avoid circularity. Methodology reused from this repo's own prior-art pitch (`.lsa/pitches/rag-retrieve-before-read.md` §"Evaluation harness" — probe mix a/b/c/d, fixed text, frozen before measurement).

Mix: 4 symbol/exact, 3 procedural, 3 cross-cutting, 2 miss-bait (12 total).

| # | Type | Probe text | Ground truth (file:line, verified directly) |
|---|---|---|---|
| P1 | symbol | "What does reconcile.runs default to when the key is absent?" | `.lsa.yaml:25` — "Default when the key is absent: 3" |
| P2 | symbol | "What is the default paired_verify mode in .lsa.yaml?" | `lsa/skills/delegate/SKILL.md:31` — "Absent ⇒ `off`" |
| P3 | procedural | "How does lsa:verify resolve named symbols instead of using Grep?" | `lsa/skills/verify/SKILL.md:30` — `scripts/resolve-refs.sh` |
| P4 | procedural | "What does scripts/rag-index.sh mount and where?" | `scripts/rag-index.sh:10-11` — repo read-only at `/repo`, index volume read-write at `/index` |
| P5 | cross-cutting | "What does 'does only all' mean in reconcile?" | `lsa/skills/reconcile/SKILL.md:33-35` — three numbered steps: does it work / only what's needed / all of the plan |
| P6 | cross-cutting | "Why does the pre-commit hook never block a commit?" | `.githooks/pre-commit:14,16,42` — best-effort local convenience; CI (`rag-index-matches-head`) is the real enforcement point |
| P7 | symbol | "What embedding model does the RAG pipeline use?" | `Dockerfile:18,43` — `BAAI/bge-small-en-v1.5` (fastembed) |
| P8 | symbol | "What exit code does rag-query.sh use when the Docker daemon is unreachable?" | `scripts/rag-query.sh:94,99` — exit 2 |
| P9 | procedural | "How does check-lib-pins.sh distinguish STALE/BROKEN from [cannot verify]?" | `scripts/check-lib-pins.sh:114-121` — precedence: STALE/BROKEN (1) outranks `[cannot verify]` (2) outranks OK (0) |
| P10 | cross-cutting | "What is reconcile's independence rule and why does it exist?" | `lsa/skills/reconcile/SKILL.md:62` — no write access to what it grades; reward-hacking defense, full rationale in `lsa/knowledge/quality-gate-contract.md` §"Independence rule" |
| P11 | miss-bait | "What GraphQL API does this repo expose?" | **None** — this repo has no GraphQL API. Correct answer is "not present," not a hallucinated match. |
| P12 | miss-bait | "Where is the Redis caching layer configured?" | **None** — this repo has no Redis. Correct answer is "not present." |

## Scoring rules (fixed before running any condition)

- **Accuracy** (per probe): 1 if the condition's final cited answer includes at least one ground-truth `file:line` (or, for P11/P12, correctly reports no match rather than fabricating one); 0 otherwise. A confident wrong citation scores 0, same as a miss — accuracy penalizes hallucination exactly as hard as failure to find.
- **Completeness** (per probe, only meaningful for probes with multi-part ground truth — P5, P6, P9, P10 each cite more than one supporting line/file): fraction of the cited ground-truth locations actually surfaced. P1-P4, P7-P8, P11-P12 have single-location ground truth, so completeness = accuracy for those.
- **Token usage**: bytes of search-phase tool output (grep stdout + read file bodies + rag-query.sh stdout) ÷ 4, per probe — the byte÷4 heuristic already used in this repo's own `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md`.
- **Performance**: real wall-clock seconds per probe (measured via `time`), plus tool-call count as a secondary efficiency proxy.

## Disclosed methodology limitation

All 4 conditions are run by the same operator (me) rather than 4 independent blind agents, for cost reasons. To bound my own prior-knowledge bias on the grep-based conditions (A, B), search terms are derived **mechanically** from each probe's literal text (lowercase, strip stopwords, take the 1-2 most distinctive remaining terms) rather than chosen from knowledge of the actual answer — documented per-probe in each condition's raw log. This is a controlled proxy for a fresh agent's first reasonable grep attempt, not a perfect simulation of real agent variance.
