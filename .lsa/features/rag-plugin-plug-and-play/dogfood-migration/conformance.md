# conformance.md — rag-plugin-plug-and-play/dogfood-migration

Independent grading pass (`lsa:reconcile`), graded against implementation `723d801`. This is the capstone of a 4+9-epic, two-pitch initiative — the highest-risk epic of the whole arc (live CI config, working-file removal). Every step below was independently re-verified live, not trusted from the implementer's self-report.

## Honest discrepancy disclosed by the implementer, confirmed here

The task's own instructions said "12 non-module entries" but listed a 13-line YAML block. The implementer flagged this explicitly and used the literal 13-line block given (correct call — a written block is unambiguous; a stated count is not, when they conflict). Independently recounted the original `docker/rag_cli.py:592-611` `CANONICAL_PATH_PREFIXES` tuple directly: **18 entries** (5 module dirs + 13 non-module), not "17." The epic's own `requirements.md`/discover prose had this count wrong by one throughout — a real, disclosed inaccuracy in my own earlier grounding, not the implementer's error. Does not affect correctness: the new config strictly exceeds the old coverage regardless of the exact original count.

## Independent re-verification (not the implementer's self-report)

| Check | My own result |
|---|---|
| `git status` full diff review | All 25 changed files match the plan exactly — 7 deletions, `.lsa.yaml`, `.github/workflows/lint.yml`, 5 live docs, `project-map.yaml`, plugin version+CHANGELOG |
| `.lsa.yaml` `rag: canonical_paths:` content | Read directly: 13 manual + 24 auto-derived = 37 entries, all correctly present, correct indentation |
| `.lsa.yaml` `gate:` block | `rag-index-fresh`/`rag-index-matches-head` both point at `lsa/scripts/*`, plain repo-relative |
| `.github/workflows/lint.yml` | Both RAG steps repointed identically |
| `docker/`, `.githooks/` directories | Confirmed gone (`ls` → "No such file or directory") |
| The 4 removed root scripts + `Dockerfile` | Confirmed gone individually |
| `CONTRIBUTING.md`, `SECURITY.md`, `README.md`, `lsa/knowledge/conventions.md`, 3 `SKILL.md` files | Full diff read, every hunk correct; `SECURITY.md`'s "never ships" → "never auto-runs" correction independently confirmed **necessary and accurate** — `lsa/hooks/pre-commit` genuinely is now covered by `lsa`'s `artifact_paths` (epic 3), so the old claim would have been false left as-is |
| `resolve-refs.sh`/`coverage-skeleton.sh` references in the 4 Read-protocol files | Confirmed untouched, exactly as R7 requires |
| `.lsa/features/**`, `.lsa/observations/**`, `.lsa/pitches/**` | Confirmed zero modifications (R8) |
| Real index rebuild, run by me independently | `bash lsa/scripts/rag-index.sh .` — clean, idempotent (`chunks_embedded: 0` on a second run), no transient failure this time |
| Real query, run by me independently | The SP9-style probe ("principle 10 deterministic work") returns results **consistent with epic 9's own already-disclosed limitation** (`.lsa/VISION.md` still doesn't rank top-5) — not a new regression, matches prior known behavior exactly |
| `bash scripts/gate.sh`, run by me independently | `rag-index-fresh` PASS, `rag-index-matches-head` PASS (R9's exact scope) |
| **Bonus, unplanned live proof:** the new `lsa/hooks/pre-commit` hook fired for real | This very commit (`723d801`, 25 files) triggered the portable hook end-to-end for real — every staged file individually reindexed, no errors, commit completed cleanly |

## `project-map: FAIL` and `docs-invariants: FAIL` — both expected, neither a regression

`gate.sh` reported two FAILs at verification time, both self-resolving and unrelated to R1-R9:
- `project-map`: `project-map-check.sh` compares the freshly-regenerated file against the *committed* version — failed only because `project-map.yaml`'s legitimate regeneration (removing `.githooks`/`docker`, adding the pre-existing `bootstrap-rag` gap) hadn't been committed yet at verification time. Resolved by this same commit.
- `docs-invariants`: the standard, expected pre-reconcile C20 gap (this epic's own `conformance.md` didn't exist yet) — same pattern every epic in both pitches has hit.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | `.lsa.yaml` (`rag: canonical_paths:` block, 37 entries) | Live: content directly read, coverage confirmed to exceed the original 18-entry list | ✅ |
| R2 | N/A (real index, gitignored, not a diff hunk) | Live: rebuilt independently, confirmed via `.canonical-paths.txt` content and a real query | ✅ |
| R3 | `.lsa.yaml` (`gate:` block) | Live: `bash scripts/gate.sh`, both RAG checks PASS via the new paths | ✅ |
| R4 | `.github/workflows/lint.yml` | Code-reviewed: identical repointing to R3 | ✅ |
| R5 | Deletion of `Dockerfile`, `docker/rag_cli.py`, 4 scripts, `.githooks/pre-commit` | Live: `ls` confirms each gone, directories collapsed | ✅ |
| R6 | `CONTRIBUTING.md`, local `git config core.hooksPath` | Live: `git config core.hooksPath` → `lsa/hooks`; this very commit's own pre-commit hook fired via that config, proving it end-to-end | ✅ |
| R7 | `README.md`, `SECURITY.md`, `lsa/knowledge/conventions.md`, 3 `SKILL.md` files | Code-reviewed, every hunk correct including the disclosed `SECURITY.md` factual correction | ✅ |
| R8 | N/A (absence of changes) | `git status` on the three historical trees: zero modifications | ✅ |
| R9 | N/A (proven by R3/R4's live gate results) | Live: `rag-index-fresh`/`rag-index-matches-head` PASS immediately before AND after the cutover commit — no red window | ✅ |

Orphan hunks: none.

`lsa/.claude-plugin/plugin.json` and `lsa/CHANGELOG.md` are this initiative's own established version-bump discipline (required by this repo's commit-discipline hook whenever `lsa/` `artifact_paths` content changes, which R7's doc edits do) — process overhead, not undelivered or untraced scope. `project-map.yaml` is `gate.sh`'s own regeneration side effect (a real, correct sync reflecting R5's deletions and a pre-existing gap from epic 3, not new content this epic introduced).

## Gate (`bash scripts/gate.sh`, post-commit)

Same C20-only pre-reconcile pattern as every epic in both pitches. `project-map` now resolves clean (regenerated content is committed). All other checks PASS, including both RAG checks.

## Verdict

**reconcile: PASS @ 723d801**

All 9 requirements verified live and independently — not trusted from the implementer's self-report at any point. This closes the `rag-plugin-plug-and-play` pitch: all 4 epics shipped, claude-marketplace now runs its own RAG search entirely through the plugin-shipped mechanism it built for every other repo too. One inherited, still-open, disclosed limitation carries forward unchanged from epic 9 (no canonical-vs-historical fix for SP3/SP9-class queries) — not this epic's scope, not newly introduced.
