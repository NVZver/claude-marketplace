# Condition D — project-map.yaml + vector search, combined

**Real mechanism note (not assumed):** `scripts/rag-query.sh`/`docker/rag_cli.py cmd_query` has **no scope/path parameter** — confirmed by reading the argparse definitions before designing this condition. "Both, intelligently" is therefore not an index-scoped query; it's project-map resolving a candidate directory (same mechanical text-matching as condition B), then reusing condition C's real whole-repo query results, preferring any in-scope result over out-of-scope ones, and falling back to a project-map-scoped read when nothing RAG returned is in-scope — matching the pitch's own stated fallback design ("falls back to Grep/Read per-path on any discarded or empty result"). This reuses condition C's actual measured query costs and condition B's actual measured fallback costs, not new estimates.

**Fallback refinement, disclosed:** when the resolved scope has only 1-2 files and a scoped grep re-attempt would obviously fail (same term, same miss, as B already showed), the fallback reads the file(s) directly rather than blindly repeating a known-failing grep — a defensible reading of "intelligent," applied once (P6), noted explicitly rather than silently.

| # | project-map scope | RAG in-scope? | Action | Bytes | Latency | Accuracy |
|---|---|---|---|---|---|---|
| P1 | `lsa/skills/reconcile` | No (0/5 in-scope) | RAG query, then fall back to B's scoped grep+read | 4,764 + 12,327 = **17,091** | 2.33s | **1** (via fallback) |
| P2 | none resolved | — | Same as condition C | **19,626** | 1.66s | **1** |
| P3 | `lsa/skills/verify` | Yes (rank 2/5, sim 0.80) | RAG query only, in-scope result already present | **7,527** | 1.70s | **1** |
| P4 | `scripts` | Yes (rank 1/5) | RAG query only, already top-ranked | **15,001** | 1.67s | **1** |
| P5 | `lsa/skills/reconcile` | N/A (0 results at all) | RAG query, fall back to B's scoped grep (also 0 hits) | 15 + 0 = **15** | 1.66s | **0** — the one probe where combining doesn't help; both signals genuinely fail |
| P6 | `.githooks` | No (0/5 in-scope) | RAG query, fall back to reading the sole file in scope directly | 19,146 + 1,903 = **21,049** | 1.68s | **1** (via fallback) |
| P7 | none resolved | — | Same as condition C | **10,457** | 1.62s | **1** |
| P8 | `scripts` | Yes (rank 1/5) | RAG query only, already top-ranked | **9,683** | 1.66s | **1** |
| P9 | `scripts` | Yes (rank 2/5, sim 0.87 vs. rank-1's 0.88) | RAG query only, in-scope present (note: the out-of-scope result outranked it by 0.01 similarity — a ranking curiosity, not an accuracy difference here since both are correct) | **9,215** | 1.72s | **1** |
| P10 | `lsa/skills/reconcile` | No (0/2 in-scope) | RAG query, fall back to B's scoped grep+read | 3,129 + 11,170 = **14,299** | 1.65s | **1** (via fallback) |
| P11 | none resolved | — | Same as condition C | **12,643** | 1.65s | **1** |
| P12 | none resolved | — | Same as condition C | **5,059** | 1.66s | **1** |

## Totals

- **Accuracy: 11/12 = 92%** — the best of all 4 conditions, and the only one to recover P1/P6/P10 (RAG's genuine misses) via project-map's fallback, while also inheriting RAG's win on P12 (avoiding the illustrative-Redis trap) that condition B only avoided by luck (never looking at the right directory).
- **Completeness:** matches accuracy — all found facts here were single-location.
- **Token usage: 141,665 bytes ≈ 35,416 tokens** — more than condition C alone (29,066) because 3 of 12 probes pay for both a full RAG call *and* a fallback read; still far below condition A (176,554) and only modestly above condition C.
- **Performance:** ≈20.7s total / ≈1.73s average — same profile as condition C (Docker per-call startup dominates; the project-map/fallback layer adds negligible local time, well under 0.1s per probe).
- **The one honest failure:** P5 shows combining the two signals is not a guarantee — when both the lexical term (punctuation mismatch) and the semantic embedding (awkward phrasing) independently fail on the same underlying concept, "intelligent combination" has nothing to recover. Recorded, not hidden.
