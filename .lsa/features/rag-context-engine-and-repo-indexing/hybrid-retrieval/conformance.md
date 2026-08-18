# conformance.md — rag-context-engine-and-repo-indexing/hybrid-retrieval

Independent grading pass (`lsa:reconcile`) against the diff returned by `delegate` (agent-dispatched implementer, `paired_verify: off`, left uncommitted). All verification below was performed live by me in this reconcile context — rebuilt the whole-repo index myself, re-ran the fix targets and the regression guard, and independently confirmed a significant correction the implementer surfaced to an earlier claim in this initiative's own eval report.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | FTS index build — `docker/rag_cli.py` (`create_fts_index("text", replace=True)` after upsert) | Live, rebuilt myself: `bash scripts/rag-index.sh .` → `"fts_index_built": true` in the real output | ✅ |
| R2 | hybrid query as default — `docker/rag_cli.py` (manual vector+FTS fusion via `RRFReranker().rerank_hybrid`, not `LanceHybridQueryBuilder` directly — see design note below) | Live: P5 and P10 (previously `{"results": []}`) now return real, correct results | ✅ |
| R3 | `--path` + empty-miss contract preserved | Live: `--path does/not/exist "anything"` → `{"results": []}`, exit 0 | ✅ |
| R4 | regression guard — no `lsa/` files touched, dense-only wins preserved | Live: re-ran P9 myself — `scripts/check-lib-pins.sh` still top-ranked at `0.8697`, unchanged from pre-epic | ✅ |
| R5 | fix target | Live: P5 → top hit `lsa/skills/reconcile/SKILL.md:1-11` (frontmatter description literally reads "does it work, only what's needed, and all of the plan"), sim 0.64; P10 → top hit `lsa/skills/reconcile/SKILL.md:59-68` (the Independence rule itself), sim 0.64 — both below the original 0.65 dense-only floor, both surfaced correctly via the new lexical OR-gate path | ✅ |
| R6 | no plugin surface touched | `git diff --stat` confirms exactly one file changed: `docker/rag_cli.py` | ✅ |

Orphan hunks: none.

## A correction to this initiative's own prior claim — surfaced by the implementer, independently verified here

The original eval report (`.lsa/observations/2026-08-17-rag-eval/report.md`, Finding 5) claimed RAG "correctly avoided" an incidental lexical false-positive (an `[illustrative]`-tagged "Redis" mention in `.lsa/plans/2026-05-20-credo-rollout-plan.md`) via semantic discrimination. **That causal claim was wrong.** Verified directly: `docker/rag_cli.py`'s directory walk (`iter_scope_files`, unchanged since epic 1) excludes every dot-prefixed directory, including `.lsa/` — so that file, and everything else under `.lsa/`, was never indexed by either signal, dense or lexical. `grep -rli redis .` (excluding `.git`) confirms **every** occurrence of "redis" in this repo lives under `.lsa/` — zero occurrences exist in the actually-indexed corpus. The eval's "semantic correctly judged this as unrelated" framing was actually "the file was never a candidate at all." Recorded here plainly rather than left standing; the eval report itself will need a correction (tracked separately, not silently patched into the historical record without a note).

**A materially larger, newly surfaced finding, out of scope for this epic:** `.lsa/` is **9.0 MB** — larger than `core/`+`lsa/`+`manager/`+`scripts/`+`docker/` combined (≈1 MB). The entire directory has been excluded from RAG indexing since epic 1's original `SKIP_DIR_NAMES` + blanket dot-directory exclusion, silently, this whole initiative. This is not this epic's to fix (out of the approved scope for `hybrid-retrieval`) — flagged for the human to decide on next, not fixed unilaterally here.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1   (C20, expected)
  PASS  citations / links / project-map / tests / lib-pins
  PASS  rag-index-fresh / rag-index-matches-head
```

## Verdict

**reconcile: PASS @ 7122606**

All 6 requirements verified live, not on the implementer's report alone. One genuine self-correction to this initiative's own prior published claim surfaced and disclosed, not smoothed over. One materially larger new finding (`.lsa/` entirely unindexed, 9x the size of everything currently indexed) explicitly flagged as out of this epic's scope, for a human decision next.
