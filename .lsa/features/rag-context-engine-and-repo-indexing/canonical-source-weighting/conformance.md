# conformance.md — rag-context-engine-and-repo-indexing/canonical-source-weighting

Independent grading pass (`lsa:reconcile`), graded against implementation `88682c0`. All numbers below are from real, live queries against a real Docker-backed index (rebuilt via `bash scripts/rag-index.sh .` — 383 files seen, 13 chunks re-embedded, 2617 unchanged skipped, 4 stale deleted, FTS index rebuilt) — not simulated, not taken from the implementer's self-report without independent re-verification.

## Environment note (not a code defect, disclosed for the record)

Live verification hit real infrastructure instability before it could run: Docker Desktop's VM cycled unprompted twice mid-build (documented pattern from `index-freshness`'s own reconcile), and after switching to Colima (a lighter, more stable Docker Desktop replacement — now installed on this machine), image pulls from Docker Hub itself hung with `DeadlineExceeded`, reproducing identically under both backends. Root-caused to Colima's `containerd-snapshotter` pull/build path not working through the host-forwarded Unix socket on this machine, while `docker run` (used by `rag-query.sh`) works fine through that same socket, and `docker build`/`pull` work fine when run directly inside the VM (`colima ssh`). The image was built and the corpus reindexed via `colima ssh`; all subsequent verification below used the normal host-side `scripts/rag-query.sh`, unmodified, once confirmed working. A `registry-mirrors` workaround (`mirror.gcr.io`) is now configured in Colima's config for future builds. None of this affected the actual query results below — all queries ran through the real, unmodified `scripts/rag-query.sh`.

## Drift found and resolved (per Step 4 — spec absorbs reality)

`flow-1-canonical-aware-ranking.feature` originally asserted three scenarios (SP3, SP4, SP9) as certain passing outcomes. Live re-testing found only SP4 actually passes; SP3 and SP9 do not, for reasons that are honest properties of the chosen design (a bounded-window *boost*, not a hard canonical-first *partition* — the partition approach was explicitly rejected during spec review). Presented to the owner as a drift (not silently marked PASS); owner approved "accept as partial, revise spec to match reality." The `.feature` file and `requirements.md` were revised accordingly (see their own diffs, this commit) before this verdict was written — R1-R7 are unchanged; only the Flow 1 acceptance scenarios and the disclosed-limitations section moved to match what live testing actually showed.

## Live stress-probe re-test (full re-run, not partial)

| Probe | Pre-epic-9 | Post-epic-9 | Evidence |
|---|---|---|---|
| SP1 (`MIN_SIMILARITY`) | HIT | HIT (no regression) | `docker/rag_cli.py:541-600` contains the constant (now at line 548 post-diff) |
| SP2 (paraphrase, non-goal) | MISS | MISS (as disclosed) | No false positive; unrelated meta-docs only |
| SP3 (arrow notation) | MISS | **Still MISS** | Top hit is now the correct *file* (`lsa/skills/discover/SKILL.md:1-11`, canonical) but the wrong *chunk* (frontmatter, not the Steps section with the notation) — content-checked directly, not assumed from the citation alone |
| SP4 (RRF) | MISS | **HIT — fixed** | Two returned chunks (`docker/rag_cli.py:631-690`, `:721-780`) both content-verified to contain real `RRFReranker` usage/explanation |
| SP5 (GraphQL miss-bait) | correct miss | correct miss (no regression) | Only self-referential eval-doc mentions, no false claim |
| SP6 (pitch appetite, non-goal) | MISS | MISS (as disclosed) | Historical-vs-historical; boost doesn't differentiate within the bucket, as predicted |
| SP7 (chunk schema version) | HIT | HIT (no regression) | `docker/rag_cli.py:91-150` contains `CHUNK_SCHEMA_VERSION` |
| SP8 (roadmap priority) | HIT (rank 2) | HIT (rank 1, no regression) | `.lsa/roadmap.yaml:586-645` covers the ground-truth line |
| SP9 (VISION principle 10) | MISS | **Still MISS** | `.lsa/VISION.md` never enters the unscoped top-5; a `--path .lsa/VISION.md`-scoped rerun confirms the chunk is indexed and relevant (similarity 0.654) but that's below what made the unscoped `CANDIDATE_K=20` cut this query |
| P9-regression-guard (`check-lib-pins.sh`) | 0.8697 top hit | 0.8681 (rank 3, no regression) | Ground-truth range `114-121` covered by returned `1-121` chunk |

**Net: 5/9 on the adversarial stress-probe set, up from 4/9.** One clear fix (SP4), not the three targeted — an honest, disclosed partial result.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `docker/rag_cli.py`: `CANONICAL_PATH_PREFIXES`, `classify_doc_class` | Code-reviewed directly (17-entry prefix table matches requirements.md exactly); live: SP4's canonical hit correctly classified, SP3's correct-file-wrong-chunk also confirms the classifier itself works on the right file | ✅ |
| R2 | `docker/rag_cli.py`: `CANDIDATE_K = 20`, replacing `TOP_K` at the vector `.limit()` and FTS post-fetch trim | Code-reviewed: both call sites confirmed changed, no other call site touched | ✅ |
| R3 | `docker/rag_cli.py`: `_boost_canonical_ranking(...)[:TOP_K]` | Live: every query above still returns exactly 5 results | ✅ |
| R4 | `docker/rag_cli.py`: `_boost_canonical_ranking`, `CANONICAL_BOOST_WINDOW = TOP_K` | Code-reviewed: bounded-window mechanism confirmed, not a hard partition; live: SP4 hit, SP3/SP9 honestly did not (documented above, not silently dropped) — R4's own wording ("favor... at near-equal relevance") does not promise every case, and the live result is consistent with that wording, not a violation of it | ✅ (spec's own scoped promise held; the *aspirational* .feature scenarios that overstated the promise were the drift, corrected above) |
| R5 | `docker/rag_cli.py`: `_boost_canonical_ranking`'s deterministic sort key | Live: identical repeated query (SP4's) produced byte-identical output twice | ✅ |
| R6 | `cmd_query`'s argument parsing, output shape, `MIN_SIMILARITY` gate, unchanged | Live: `--path docker/` returns only `docker/`-prefixed results; `--sha HEAD` runs without error and returns the same top result; output JSON shape unchanged | ✅ |
| R7 | `get_or_create_table`'s schema, `CHUNK_SCHEMA_VERSION` | Code-reviewed directly: schema still exactly 9 fields, `CHUNK_SCHEMA_VERSION` still `"1"`, `git diff` confirms neither touched | ✅ |

Orphan hunks: none.

`docker/rag_cli.py` is the sole implementing file; every hunk in it traces to R1, R2/R3, or R4/R5 above.

## Gate (`bash scripts/gate.sh`)

Same structural C20-only pattern as every prior epic in this initiative (this `conformance.md` not yet existing at gate-check time) — all other checks pass, including `rag-index-fresh` and `rag-index-matches-head` against the real rebuilt index.

## Verdict

**reconcile: PASS @ 88682c0**

R1-R7 are all correctly, verifiably implemented — confirmed by direct code review, not the implementer's self-report. Flow 1's Gherkin scenarios were found to overstate what a deliberately bounded (not partitioned) boost can promise; presented as drift, owner-approved, and corrected in place before this verdict — the epic delivers a real, disclosed, partial improvement (5/9 vs 4/9 on the adversarial probe set, one of three targeted misses genuinely fixed), not the aspirational full fix originally hoped for. No regressions found on any previously-passing probe, `--path`/`--sha` behavior, or determinism.
