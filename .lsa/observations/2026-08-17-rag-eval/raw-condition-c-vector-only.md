# Condition C — vector search only (no project-map.yaml)

Protocol: for each probe, `bash scripts/rag-query.sh "<probe text verbatim>"` — whole-repo index (freshly rebuilt: 123 files, 1,193 chunks, 87.6s build time), no directory scoping. Top-5 results returned per query (`MIN_SIMILARITY` floor per epic 1's implementer). Accuracy scored consistently with conditions A/B: did the full returned set (not just rank 1) contain the ground-truth fact — a real, all-real-Docker run, not simulated.

| # | Query (verbatim probe text) | Bytes | Latency | Top similarity | Accuracy | Notes |
|---|---|---|---|---|---|---|
| P1 | "What does reconcile.runs default to..." | 4,764 | 2.33s | 0.72 | **0** | All 5 results are `lsa/CHANGELOG.md`/`CORE.md` passages that mention `reconcile.runs` in passing — none state the actual default value. A genuine RAG miss, not glossed over. |
| P2 | "What is the default paired_verify mode..." | 19,626 | 1.66s | 0.84 | **1** | Top hit `lsa/skills/delegate/SKILL.md:29-65` states "Absent ⇒ `off`" directly |
| P3 | "How does lsa:verify resolve named symbols..." | 7,527 | 1.70s | 0.84 | **1** | Top hit `scripts/resolve-refs.sh:1-56` — the actual implementation, arguably a better answer than the ground-truth citation |
| P4 | "What does scripts/rag-index.sh mount..." | 15,001 | 1.67s | 0.85 | **1** | Top hit is `scripts/rag-index.sh` itself, mount points visible directly |
| P5 | "What does does only all mean in reconcile?" | 15 | 1.66s | — | **0** | `{"results": []}` — nothing scored above the similarity floor for this awkwardly-phrased probe. RAG's own honest miss, distinct in *cause* from A/B's punctuation-matching failure on the same concept, but the same *outcome*. |
| P6 | "Why does the pre-commit hook never block..." | 19,146 | 1.68s | 0.81 | **1** | Top hit (SECURITY.md, the *other* hook) is a false lead, but rank 4/5 is `scripts/check-rag-index-matches-head.sh` (sim 0.76), which does explain the rationale — found, but not top-ranked |
| P7 | "What embedding model..." | 10,457 | 1.62s | 0.77 | **1** | Top hit `docker/rag_cli.py:1-60` states `BAAI/bge-small-en-v1.5` directly |
| P8 | "What exit code...Docker daemon unreachable?" | 9,683 | 1.66s | 0.83 | **1** | Top hit is `scripts/rag-query.sh` itself |
| P9 | "How does check-lib-pins.sh distinguish..." | 9,215 | 1.72s | 0.88 | **1** | Top hit `lsa/knowledge/pinned-library-specs.md:50-72` states the exact 3-outcome precedence table directly — arguably clearer than the script's own comment |
| P10 | "What is reconcile's independence rule..." | 3,129 | 1.65s | 0.69 | **1** | Top hit `lsa/knowledge/quality-gate-contract.md:38-43` — the exact "why it exists" doc named in ground truth |
| P11 | "What GraphQL API..." | 12,643 | 1.65s | 0.69 | **1** | All 5 results (Dockerfile, test scripts, migration docs) are clearly unrelated to GraphQL — correct conclusion reachable, but unlike a grep miss (0 bytes, instant), this needed 12,643 bytes and active judgment that none of the 5 actually answer the question |
| P12 | "Where is the Redis caching layer..." | 5,059 | 1.66s | 0.68 | **1** | **Notable positive finding:** none of the 5 results are the `.lsa/plans/credo-rollout-plan.md` "[illustrative] Redis" mention that fooled condition A's naive read — semantic similarity correctly judged an illustrative Gate-3 placeholder example as unrelated to "where is Redis configured," where literal keyword grep matched on the surface word regardless of context |

## Totals

- **Accuracy:** 10/12 = 83%
- **Completeness:** matches accuracy (all found facts here were single-location in the returned set)
- **Token usage:** **116,265 bytes ≈ 29,066 tokens** — smaller than condition A (176,554), larger than condition B (16,948)
- **Performance:** 12 real Docker-backed calls, **20.66s total, ≈1.72s average per query** — dominated by per-call container startup (no persistent daemon amortizing cost across queries), not by the search itself. This is the real cost condition A/B's near-instant local grep doesn't pay, and it's the actual number, not a guess.
- **Two genuine limitations found, not glossed over:** (1) RAG missed P1 outright — a short YAML-comment fact didn't embed well enough to rank in the top 5 for that phrasing; (2) unlike a clean grep miss, a semantically-unrelated query still returns *something* above the similarity floor (P11, P12) — the system doesn't signal "nothing here" as cleanly as `{"results": []}` suggests it can (it does emit that shape when nothing clears the floor, as P5 shows, but P11/P12 both cleared it with unrelated content).
- **One clear win, not assumed:** P12 shows semantic matching correctly avoiding a lexical false-positive trap that fooled the naive-grep condition — a real, concrete instance of the thing this whole initiative is supposed to deliver.
