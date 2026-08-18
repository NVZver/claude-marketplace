# Condition B — project-map.yaml only (no vector search)

Protocol: for each probe, mechanically match probe text against real directory names in `project-map.yaml` (no ground-truth knowledge) — if a match resolves, `grep -rn` scoped to that directory only; if no directory name matches, fall back to root-level files only (`find . -maxdepth 1 -type f`), not a full recursive unscoped search. All matched files within scope are read in full (small candidate counts made this always tractable here — unlike condition A).

| # | Resolved scope | Term | Grep bytes | Files in scope hit | Read bytes | Total bytes | Accuracy | Notes |
|---|---|---|---|---|---|---|---|---|
| P1 | `lsa/skills/reconcile` | `reconcile.runs` | 2,271 | SKILL.md (1) | 10,056 | 12,327 | **1** | Directory name matched probe text directly ("reconcile") — clean, precise hit |
| P2 | ROOT_FILES (no dir match) | `paired_verify` | 0 | none | 0 | 0 | **0** | No directory name matches "paired_verify"; root fallback correctly empty (this repo's own `.lsa.yaml` doesn't set the key — it relies on the documented default, which lives in `lsa/skills/delegate/` and `lsa/ARCHITECTURE.md`, neither reachable from this scope guess) |
| P3 | `lsa/skills/verify` | "named symbols" | 0 | none | 0 | 0 | **0** | **Scope was right, term wasn't**: current `verify/SKILL.md` says "named-symbol resolution" (hyphenated singular), not "named symbols." The literal phrase that *would* match lives in a historical requirements doc under `.lsa/features/`, outside this scope — condition A found it (by accident, being unscoped); condition B's precision excludes it |
| P4 | `scripts` | `rag-index.sh` | 1,172 | 4 files | 15,176 | 16,348 | **1** | Ground-truth file (`scripts/rag-index.sh`) is one of only 4 candidates in scope — mount-point fact found directly |
| P5 | `lsa/skills/reconcile` | "only all" | 0 | none | 0 | 0 | **0** | Same class of miss as P3 — scope correct, but the repo's actual text uses middle-dot typography ("does · only · all"), which the naive term can't match |
| P6 | `.githooks` | "pre-commit hook" | 0 | none | 0 | 0 | **0** | Scope excludes the file that *does* explain the rationale (`scripts/check-rag-index-matches-head.sh`, which condition A happened to find) — a real case where directory scoping actively hides the useful answer |
| P7 | ROOT_FILES | "embedding model" | 183 | Dockerfile (1) | 2,376 | 2,559 | **1** | Clean hit |
| P8 | `scripts` | `rag-query.sh` | 847 | 3 files | 12,128 | 12,975 | **1** | Ground-truth file in scope, one of only 3 candidates |
| P9 | `scripts` | `check-lib-pins.sh` | 677 | 3 files | 11,734 | 12,411 | **1** | Ground-truth file in scope, one of only 3 candidates |
| P10 | `lsa/skills/reconcile` | "independence rule" | 1,114 | SKILL.md (1) | 10,056 | 11,170 | **1** | Same file as P1 (re-read independently, no cross-probe caching modeled) |
| P11 | ROOT_FILES | `GraphQL` | 0 | none | 0 | 0 | **1** | Correct miss-bait recognition, free |
| P12 | ROOT_FILES | `Redis` | 0 | none | 0 | 0 | **1** | Correct miss-bait recognition — and never even looks at the `.lsa/plans/` illustrative-trap file condition A stumbled into, since "plans" doesn't mechanically match the probe text |

## Totals

- **Accuracy:** 8/12 = 67%
- **Completeness:** identical to accuracy here (all ground-truth in this probe set that condition B found was single-location)
- **Token usage:** grep bytes 6,264 + read bytes 61,526 = **67,790 bytes ≈ 16,948 tokens** — a **90.4% reduction** vs. condition A's 176,554 tokens, on 9pp *better* accuracy, not traded away
- **Performance:** 12 grep calls (all under 0.015s, ≈0.09s total) + reads only where matches existed — wall clock still under 1 second total, but far fewer read bytes moved
- **Real, non-obvious pattern found:** project-map's directory scoping is not uniformly better than nothing. It fixes the "buried in noise" failure mode (P4, P8, P9 — the correct file existed in the unscoped hit list too, just lost among dozens of historical-doc mentions) but does nothing for term-phrasing fragility (P3, P5 miss for the identical reason in both conditions), and can actively **remove** a correct answer that unscoped search happened to stumble onto from a directory outside the "obvious" one (P6). Scoping trades recall in the wrong directory for precision in the right one — a real tradeoff, not a strict improvement.
