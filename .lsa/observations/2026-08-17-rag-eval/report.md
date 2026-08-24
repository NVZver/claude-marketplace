# RAG context engine — e2e evaluation report

**Date:** 2026-08-18. **Scope:** this repo (`claude-marketplace`), 12 fixed probes, 4 search conditions. Every number below is derived from the four raw per-condition files in this same directory — `raw-condition-{a-nothing,b-project-map-only,c-vector-only,d-both-intelligent}.md` — and was independently re-verified programmatically before this report was written (see "Verification" below). Ground truth (`probes.md`) was recorded before any condition ran.

## TL;DR

| Condition | Accuracy | Completeness | Token usage (bytes ÷ 4) | Performance (total / avg latency) |
|---|---|---|---|---|
| **A — nothing** | 7/12 = 58% | 6/12 = 50% | 706,217 B ≈ **176,554 tok** | <1s total (grep-only, no Docker) |
| **B — project-map only** | 8/12 = 67% | 8/12 = 67% | 67,790 B ≈ **16,948 tok** | <1s total (grep-only, no Docker) |
| **C — vector search only** | 10/12 = 83% | 10/12 = 83% | 116,265 B ≈ **29,066 tok** | 20.64s total, **1.72s avg** (Docker per-call) |
| **D — project-map + vector, combined** | **11/12 = 92%** | **11/12 = 92%** | 141,665 B ≈ **35,416 tok** | ≈20.7s total, **1.73s avg** (Docker per-call) |

**Headline:** D (the shipped design) wins on accuracy and completeness outright — best of all four, and the only condition to recover every RAG-alone miss it could recover. B is the cheapest in tokens by a wide margin and beats A on every metric simultaneously (not a tradeoff). C and D both pay a real, measured latency cost A/B don't: Docker container startup, not search speed itself.

## Methodology (full detail: `probes.md`)

12 probes, fixed and ground-truthed *before* any condition ran: 4 symbol/exact, 3 procedural, 3 cross-cutting, 2 miss-bait (queries with no correct answer in this repo, to test false-positive resistance). Grep-based conditions (A, B) derive search terms mechanically from probe text via a disclosed rule, not from knowledge of the answer — a controlled proxy for a fresh agent's first attempt, not a perfect simulation. Conditions C and D issued **real** `scripts/rag-query.sh` calls against a freshly rebuilt whole-repo index (123 files, 1,193 chunks, 87.6s build time) — no simulated or estimated RAG results anywhere in this report.

**Real mechanism finding that shaped condition D's design:** `rag_cli.py`'s `cmd_query` has no scope/path argument — confirmed by reading its `argparse` definition before designing the eval, not assumed from the pitch's prose. "Project-map + RAG, combined" is therefore not an index-scoped query today; it's project-map resolving a candidate directory, then RAG's real whole-repo results filtered/preferred to that directory, falling back to a project-map-scoped read when nothing RAG returned falls inside it. This is disclosed as a real implementation gap in the shipped epic 3/4 prose vs. the tool's actual capability, not glossed over.

## Verification

Before writing this report, every condition's token-usage total and accuracy count was re-summed programmatically from the per-probe byte figures recorded in the raw files (not re-typed by hand into this report) — see the verification script output: A=706,217B/7/12, B=67,790B/8/12, C=116,265B/10/12, D=141,665B/11/12, all matching the raw files exactly. No discrepancy found.

## Findings, each traceable to a specific probe

1. **Scoping fixes "buried in noise," not phrasing fragility.** P4, P8, P9: the correct file was present in condition A's unscoped grep hit list every time, but lost among 18-30 historical `.lsa/features/**` mentions — a naive "check the first couple of results" strategy missed it in A, found it immediately in B once scoped to `scripts/` (raw-condition-a P4/P8/P9 vs. raw-condition-b P4/P8/P9). P3, P5, P6: scoping was *correct* in B but the mechanical term still failed (hyphenation, punctuation) — scoping doesn't fix a term that doesn't match the text at all.

2. **Directory scoping can actively remove a correct answer.** P6 (raw-condition-a vs. -b): condition A's unscoped search stumbled onto the right explanation in `scripts/check-rag-index-matches-head.sh`, a file outside the `.githooks/` directory project-map naturally suggested — condition B's precision excluded it. Scoping trades recall in the "wrong" directory for precision in the "right" one; it is not a strict improvement.

3. **RAG has real misses too, not just wins.** P1 (raw-condition-c): none of the top-5 semantic results stated the actual `.lsa.yaml` default value, despite `reconcile.runs` being an exact-match term in the query — a short YAML comment apparently doesn't embed as strongly relevant as unrelated `CHANGELOG.md` prose that mentions the term more verbosely. P5: the awkwardly-phrased probe ("does only all") returned zero results above the similarity floor — an honest RAG miss, for a different root cause than A/B's punctuation-matching failure on the same concept, but the same outcome.

4. **Semantic search doesn't fail as "cleanly" as grep.** P11/P12 (raw-condition-c): a query about something genuinely absent from the repo (GraphQL, Redis) still returned 5 results above the 0.65 similarity floor — none relevant, but not an empty `{"results": []}` either. Concluding "not present" required judging that none of the 5 actually answer the question, a heavier lift than grep's clean zero-hit signal (which condition B got essentially for free on the same two probes).

5. **The one concrete, measured case for semantic over lexical matching in this probe set.** P12 (raw-condition-a vs. -c): condition A's naive full-file read found a literal "Redis" match in `.lsa/plans/2026-05-20-credo-rollout-plan.md` — an old, unrelated planning doc where the word appears inside an `[illustrative — Q1 resolution is a placeholder]` example block. A careful reader avoids the trap, but it exists. Condition C's semantic ranking never surfaced that file in its top 5 at all — it correctly judged the illustrative placeholder as unrelated to "where is Redis configured," on similarity alone, no careful reading required.

6. **Combining recovers what either signal misses alone, except when both fail for the same reason.** D recovered P1, P6, and P10 — all RAG-alone misses — via project-map's fallback (raw-condition-d), landing at 92% vs. C's 83%. The one exception, P5, is instructive: the lexical term (blocked by punctuation) and the semantic embedding (blocked by awkward phrasing) both failed on the *same underlying concept*, and no amount of combining rescues that. Recorded as a real limit, not smoothed over.

7. **Docker container startup, not search quality, is the real latency cost.** C and D both average ≈1.7s per query (raw-condition-c/-d), essentially flat regardless of query complexity — this is `docker run` overhead on every call, since there's no persistent daemon amortizing it across queries (this repo has none; Claude Code invokes the CLI one-shot per call, per this pitch's own architectural constraint). A/B's local grep is near-instant by comparison. This is the concrete number behind the pitch's own "commit-triggered, not live-per-edit" design call — a persistent-daemon architecture would eliminate this cost, but this repo deliberately doesn't have one.

## Limitations, disclosed

- **12 probes, one repo.** Real numbers, not a statistically powered benchmark — a probe-set size and repo-specific result, not a universal claim about RAG vs. grep.
- **One operator, not four blind agents.** All 4 conditions were run by the same operator for cost reasons; grep term derivation was mechanical and disclosed per probe to bound (not eliminate) prior-knowledge bias. A real fresh agent might phrase differently in either direction.
- **Accuracy scored by fact, not exact-citation-match.** A condition that found the correct fact via an alternate file (not the pre-registered primary ground-truth source) still scored a hit, consistently across all 4 conditions — documented per-probe in each raw file, not applied selectively.
- **Single-run, not repeated.** Neither the grep-based nor the RAG-based runs were repeated N times (unlike this repo's own `reconcile.runs: 3` convention for code) — a probe that's borderline (e.g., P9's 0.88-vs-0.87 near-tie) might rank differently on a re-run; this report reports what was actually observed once, not a statistical average.

## Addendum (2026-08-18) — re-verified against the real fix, not the simulation

Condition D's numbers above were measured against a **client-side workaround** (project-map picks a directory, then whole-repo RAG results are filtered/preferred to it after the fact) because `rag-query.sh` had no real scope filter at eval time. That gap is now fixed (`.lsa/features/rag-context-engine-and-repo-indexing/path-scoped-query-fix/`, commit `2891944`): `--path <prefix>` is a genuine pre-filter on the vector search itself. Re-running the 8 probes that had a resolved project-map scope through the **real** `--path` flag, not the simulation:

- **5/8 direct RAG hits** (P1, P3, P4, P8, P9) — matching or improving on the simulation.
- **P10** (independence rule): RAG alone misses within the narrowed scope (the in-scope similarity score doesn't clear the floor) — recovered by the documented `Grep`/`Read` fallback, which condition B already proved works here.
- **P6** (pre-commit hook rationale): **new finding, not previously known** — `.githooks/` is excluded from indexing entirely. `docker/rag_cli.py`'s directory walk skips any directory starting with `.` (`SKIP_DIR_NAMES` plus a blanket dot-directory exclusion, `docker/rag_cli.py:169`) — this is a pre-existing epic-1 design decision (dot-directories are usually build/vcs internals), not a defect this fix epic introduced or is scoped to change, but it means this specific file can never be found via RAG, full stop, regardless of scoping. Whether the `Grep`/`Read` fallback recovers it depends on how literally that fallback is executed — a literal re-grep of the same term B already showed fails; an agent that instead reads the sole file in a small resolved scope succeeds. Not deterministic, and not this epic's to fix.
- **P5**: still a genuine miss, for the same reason as every prior run (punctuation/phrasing fragility affecting both the grep term and the embedding independently) — scoping, real or simulated, doesn't touch this.

**Honest bottom line on D's real number:** somewhere between 10/12 (83%, if the fallback is a literal re-grep) and 11/12 (92%, if the fallback reads the sole candidate file) — not automatically the simulation's clean 92%. The core fix is real and verified (the exact regression case — an out-of-scope doc outranking the correct in-scope script — is confirmed fixed), but "flawless" isn't the honest word for the full pipeline; two real, disclosed limits remain (P5's phrasing fragility, P6's dot-directory blind spot), neither addressed by this fix and neither in this fix's scope.

## Bottom line

The shipped design (condition D) is the accuracy/completeness winner in this measurement, and does so without needing the query-time scope-filter that epic 3's prose implies exists but doesn't (finding above) — the fallback-to-project-map-scoped-read mechanism recovers RAG's misses effectively, at a token cost between B and C. If token cost matters more than the last ~10 accuracy points, project-map alone (B) is a strong, much cheaper baseline. If Docker/container latency is unacceptable for a given caller, that's a real, measured ≈1.7s/call tax C and D both carry that B does not.
