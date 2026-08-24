# Stress-test probes — hybrid retrieval + expanded (.lsa/-inclusive) index

Written and ground-truth-verified **before** running against the post-epic-7 index, same discipline as the original 12 probes. Designed specifically to challenge the hybrid fix and the newly-expanded corpus, not to re-confirm what's already known.

| # | Type | Probe text | Ground truth |
|---|---|---|---|
| SP1 | exact identifier (lexical-critical) | "What is MIN_SIMILARITY set to?" | `docker/rag_cli.py:461` — `MIN_SIMILARITY = 0.65` |
| SP2 | pure paraphrase, zero literal overlap (dense-critical) | "How do we make sure nobody has to remember a manual step to keep search results current?" | `.githooks/pre-commit` + `scripts/check-rag-index-matches-head.sh` (epic 2's whole design point — no literal "manual step" or "remember" phrasing in either file) |
| SP3 | unusual notation, different instance than the original P5 | "What does the arrow notation like '(→ codebase facts)' mean in LSA skill files?" | `lsa/skills/discover/SKILL.md:29-31` — marks each step's Observable result, used throughout every `SKILL.md` |
| SP4 | compound/hyphenated technical term | "What is reciprocal rank fusion and where is it implemented?" | `docker/rag_cli.py:39,488` — `RRFReranker` |
| SP5 | miss-bait, re-tested against the expanded corpus | "What GraphQL API does this repo expose?" | None — must remain a correct miss even with `.lsa/` now indexed |
| SP6 | newly-indexed content, direct retrieval | "What is the pitch appetite for the RAG context engine initiative?" | `.lsa/pitches/rag-context-engine-and-repo-indexing.md:24` — `## Appetite` section, never indexed before epic 7 |
| SP7 | minimal/vague query (near-bare keywords) | "chunk schema version" | `docker/rag_cli.py:91` — `CHUNK_SCHEMA_VERSION = "1"` |
| SP8 | newly-indexed YAML content | "What priority is the cursor-equal-support roadmap item?" | `.lsa/roadmap.yaml:582-586` — `priority: Must` |
| SP9 | newly-indexed constitution | "What does principle 10 say about deterministic work?" | `.lsa/VISION.md:67` — the actual principle statement (line 270 is an acceptable alternate, a changelog echo of the same fact) |
| SP10 | the corrected P12, now genuinely testable for the first time | "Where is the Redis caching layer configured?" (verbatim reuse of P12) | None — real caching layer. Must distinguish from `.lsa/plans/2026-05-20-credo-rollout-plan.md`'s `[illustrative]`-tagged placeholder mention, which is now, for the first time, a genuine index candidate rather than absent by omission |

Same scoring rules as `probes.md`: accuracy = ≥1 ground-truth location found in the full returned set (not just rank 1); a confident wrong/misleading citation scores 0, same as a miss.
