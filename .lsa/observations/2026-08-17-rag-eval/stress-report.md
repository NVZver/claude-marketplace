# Stress-test report — hybrid retrieval + expanded index

**Date:** 2026-08-18. Covers epics 6 (`hybrid-retrieval`), 7 (`index-lsa-content`), and the 10 adversarial probes in `stress-probes.md`. Every result below is a real, live query against the actual index — no simulated data.

## TL;DR

The original two misses (P5, P10) are fixed for real. Two real, previously-unknown gaps were found and fixed during verification (`dist/`, `.remember/` leaking into the index). One found-and-fixed operational incident (Docker build-cache staleness). But **the new adversarial probe set — designed specifically to challenge the fix, not confirm it — scores 4/9 (44%)**, well below the original eval's 92%. This isn't a regression in what was already working; it's the corpus growing ~2.6x larger and more historical-content-heavy exposing a real precision problem the original 12 probes never had reason to find.

## Part 1 — required verification (epics 6/7's own acceptance criteria)

| Check | Result |
|---|---|
| P5 ("does only all") | ✅ Fixed — was `{"results": []}`, now returns `lsa/skills/reconcile/SKILL.md`'s frontmatter/Constraints, both correctly explaining the concept |
| P10 (independence rule, scoped) | ✅ Fixed — top hit is the exact Constraints-section chunk |
| P9 regression guard | ✅ Unchanged, `0.8697` top hit, same as pre-hybrid |
| `dist/` exclusion | ✅ Confirmed absent via direct index inspection |
| `.remember/` exclusion | ✅ Confirmed absent (after diagnosing and fixing a Docker build-cache staleness incident) |
| `.lsa/archive/` exclusion | ✅ Confirmed absent |
| `.lsa/` inclusion | ✅ 237 real paths indexed |
| `.githooks/pre-commit` inclusion | ⚠️ Indexed, but doesn't rank in the top 3 for its own rationale query — the answer is still found, via `commit-triggered-sync`'s spec docs and `SECURITY.md`, which are more verbose and arguably clearer, but this isn't what R5 literally asked for |
| Redis re-test (corrected P12) | ⚠️ No false positive, but no clean resolution either — see Part 3 |

## Part 2 — adversarial stress probes (`stress-probes.md`)

| # | Probe | Result | Why |
|---|---|---|---|
| SP1 | `MIN_SIMILARITY` value | ✅ HIT | `docker/rag_cli.py` chunk containing the constant, confirmed by content check |
| SP2 | Pure paraphrase, zero literal overlap | ❌ MISS | Top 3 are `prompt-engineer/tests/repo-anchored.md`, this eval's own `stress-probes.md`, `core/skills/output/SKILL.md` — none relate to commit-triggered sync at all |
| SP3 | Arrow notation `(→ ...)` | ❌ MISS | Top hit (`2026-05-22-show-changes-inline/requirements.md`) content-checked directly — it does not explain the notation's meaning, just happens to score high on unrelated "Inputs & Outputs" formatting |
| SP4 | Reciprocal rank fusion | ❌ MISS | Top 3 are an unrelated dropped feature (`observable-grader-independence/cross-model-verdict`) and a bare conformance-table header fragment — the actual `RRFReranker` usage doesn't appear |
| SP5 | GraphQL (miss-bait) | ✅ HIT | Correctly no false claim, though top 3 are this initiative's own docs (self-referential, not a real trap) |
| SP6 | Pitch appetite | ❌ MISS | Top hit is the prior-art research doc, not the pitch's own Appetite section |
| SP7 | "chunk schema version" (minimal query) | ✅ HIT | Confirmed by content check — `docker/rag_cli.py:406-465` contains `CHUNK_SCHEMA_VERSION` |
| SP8 | Roadmap priority lookup | ✅ HIT (rank 2) | `.lsa/roadmap.yaml:586-645` — the range covers the actual entry |
| SP9 | VISION.md principle 10 | ❌ MISS | Top 2 are historical *implementation* docs (`2026-07-17-deterministic-work-scripted-codify`) about when the principle was added — `VISION.md`'s own principle statement, though indexed, doesn't rank |

**4/9 (44%)** — designed to be hard, and it was.

## Part 3 — the real pattern behind the misses

Every miss shares the same shape: **a historical or process document about a topic now outranks the topic's own canonical, current source.** `.lsa/features/` alone holds 30+ historical epic specs going back to May 2026 — many of them discuss the same underlying concepts (principles, conventions, formats) that the current source files define once, cleanly. Similarity scoring has no notion of "this is the authoritative definition" vs. "this is a historical document that happens to discuss the same thing at length" — a verbose spec that walks through a concept in detail can out-embed (and, now, out-lexical-match) the concept's own terse, canonical statement.

This is a real, structural finding about corpus composition, not a bug in the hybrid-retrieval or `--path` mechanisms — both work exactly as designed. It's the direct, honest cost of indexing 2.6x more content without any signal for "this is current/canonical" vs. "this is historical record."

**A related, smaller effect, also real:** this eval's own documentation (`probes.md`, `stress-probes.md`, and now this file) discusses test cases like the Redis query in enough detail that it became a candidate result *for that exact query*, once `.lsa/observations/` was indexed. Not a defect — genuinely searchable, genuinely on-topic content — but a self-referential wrinkle worth naming.

## Part 4 — what's fixed vs. disclosed

**Fixed, verified, shipped (epics 6-7, commits `7122606`, `7545a4b`, `f9a07b8`):**
- Hybrid dense+lexical retrieval (native LanceDB FTS + RRF fusion)
- `.lsa/` indexing (2.4 MB, real project content)
- `dist/` and `.remember/` exclusions

**Disclosed, not fixed — real decisions for you:**
1. **The indexer doesn't consult `.gitignore`.** Two real instances found and patched individually this session; a third gitignored directory will need the identical one-line fix again. The generic fix (host-side `git ls-files --others --exclude-standard`, since the container has no `git` CLI) is a real architecture change.
2. **`rag-index.sh`/`rag-query.sh` never detect a stale Docker image**, only a missing one. This session's own `.remember/` fix silently failed on the first attempt because of exactly this gap.
3. **No signal for "canonical vs. historical" content.** This is the biggest, hardest finding — it's what's actually behind SP2/SP3/SP4/SP6/SP9's misses. Real options, not evaluated in depth here: exclude `.lsa/features/` (throws away real, sometimes-useful historical context, and would have been the wrong call for probes that legitimately need epic history); weight/boost recently-modified or `git log`-recent files; or accept this as a known precision ceiling and lean harder on the `Grep`/`Read` fallback for canonical-fact lookups specifically.
4. **Build time**: 88s → ~2:05 for a full rebuild. `check-rag-index-matches-head.sh` runs this on every CI check.

## Verification note

Every number in this report was produced by running the actual `rag-query.sh`/`rag-index.sh` scripts live against a real Docker-backed index rebuilt from a clean state — not estimated, not taken from any agent's self-report without independent re-verification.
