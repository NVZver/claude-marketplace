# Condition A — nothing (no project-map.yaml, no vector search)

Protocol: for each probe, derive a grep term mechanically from probe text (documented in `probes.md`), `grep -rn` the **whole repo unscoped**, then apply a disclosed file-selection rule — exclude `.lsa/features/**`/`.lsa/pitches/**`/`.lsa/research/**` (historical/process noise) from the hit list, read the first 2 remaining files alphabetically (fall back to the first 2 of the original list if filtering empties it) — and check whether the ground-truth fact is actually present in what was read. Full-file reads (no chunk citations — this condition has no scoping aid at all).

| # | Term | Grep bytes | Files read | Read bytes | Total bytes | Accuracy | Completeness | Notes |
|---|---|---|---|---|---|---|---|---|
| P1 | `reconcile.runs` | 12,066 | core/CHANGELOG.md, core/CLAUDE.md | 80,737 | 92,803 | **1** | 1 | `core/CLAUDE.md:46` states "default 3" directly — not the ground-truth file (`.lsa.yaml`) but the same fact, correctly found |
| P2 | `paired_verify` | 14,455 | .lsa/roadmap.yaml, lsa/ARCHITECTURE.md | 145,032 | 159,487 | **1** | 1 | `lsa/ARCHITECTURE.md:118,136` states "default: off" directly |
| P3 | "named symbols" | 506 | .../resolve-refs/requirements.md (only hit) | 5,239 | 5,745 | **1** | 1 | Single hit, on-topic |
| P4 | `rag-index.sh` | 10,394 | .githooks/pre-commit, .gitignore | 2,702 | 13,096 | **0** | 0 | Ground truth (mount points) is in `scripts/rag-index.sh` itself, which appeared in the 19-file hit list but wasn't in the first 2 alphabetically |
| P5 | "only all" | 284 | pitch (only hit) | 12,587 | 12,871 | **0** | 0 | **False positive**: matched unrelated "...or only allow/deny..." text in a rabbit hole, not the "does·only·all" concept (the repo's typography uses middle-dots, which the mechanical term didn't anticipate) |
| P6 | "pre-commit hook" | 6,702 | CONTRIBUTING.md, check-rag-index-matches-head.sh | 19,844 | 26,546 | **1** | 0 | Fact correctly found via a sibling script's comment explaining the same rationale — but none of the 3 ground-truth lines in `.githooks/pre-commit` itself were among the files read |
| P7 | "embedding model" | 179 | Dockerfile (only hit) | 2,376 | 2,555 | **1** | 1 | Clean hit |
| P8 | `rag-query.sh` | 30,781 | .lsa/metrics.md, Dockerfile | 12,150 | 42,931 | **0** | 0 | Ground truth is in `scripts/rag-query.sh` itself, which appeared in the 28-file hit list but far down alphabetically |
| P9 | `check-lib-pins.sh` | 14,696 | .lsa.yaml, .lsa/libs/actions-checkout.md | 6,534 | 21,230 | **0** | 0 | Same pattern as P4/P8 — ground truth in `scripts/check-lib-pins.sh` itself, present in the 30-file hit list, not in the alphabetically-first 2 |
| P10 | "independence rule" | 7,889 | .lsa/metrics.md, lsa/CHANGELOG.md | 128,285 | 136,174 | **0** | 0 | CHANGELOG only says "independence rules are unchanged" — names the concept without defining it |
| P11 | `GraphQL` | 0 | (none — 0 hits) | 0 | 0 | **1** | 1 | Correctly, cheaply concludes "not present" |
| P12 | `Redis` | 454 | plans/credo-rollout-plan.md, roadmap.yaml | 192,325 | 192,779 | **1** | 1 | Real trap: "Redis" appears but tagged `[illustrative — Q1 resolution is a placeholder]` in an unrelated historical planning doc. A full-file read surfaces that tag and correctly concludes no real Redis usage — but this depended on actually parsing the placeholder tag, not guaranteed for a shallower pass |

## Totals

- **Accuracy:** 7/12 = 58%
- **Completeness** (mean across all 12, single-fact probes count as accuracy): (1+1+1+0+0+0+1+0+0+0+1+1)/12 = 6/12 = 50%
- **Token usage:** grep bytes 98,406 + read bytes 607,811 = **706,217 bytes ≈ 176,554 tokens** (÷4 heuristic)
- **Performance:** 12 grep calls (~0.01s each, ≈0.12s total) + ~20 file reads (near-instant local `cat`) — **wall clock ≈ under 1 second total**, but 32 tool calls and 176K tokens of context consumed
- **Real pattern found here, not assumed:** when the correct source file *did* appear in the unscoped grep hit list (P4, P8, P9 — `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-lib-pins.sh` were all present), a naive "read the first couple of results" strategy still missed it, because this repo's `.lsa/features/**` history generates many more incidental mentions than the canonical source file itself. The failure mode isn't "grep can't find it" — it's "grep finds it buried among noise."
