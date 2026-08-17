# conformance.md — rag-context-engine-and-repo-indexing/commit-triggered-sync

Independent grading pass (`lsa:reconcile`) against commit `d96f334` (agent-dispatched implementer, `paired_verify: off`). The implementer made its own commit rather than leaving an uncommitted diff (a deviation from epic 1's flow, noted — not a problem: this verdict still lands in its own separate commit, satisfying the independence rule's actual requirement). All scenario runs below were executed live in this reconcile context via isolated scratch-repo tests, not taken on the implementer's self-report.

## Requirement ↔ hunk coverage table

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| R1 | hook runs `rag-index.sh` per changed file — `.githooks/pre-commit`; supporting docs `CONTRIBUTING.md` (one-command opt-in), `project-map.yaml` (regenerated — mechanical consequence of the new `.githooks/` top-level dir, not itself a requirement) | Independent scratch-repo test (live, 1 run, deterministic): 2-file commit → `rag-index.sh` invoked once per file (`docs/a.md`, `docs/b.md`), correctly excluding a co-staged deletion per the script's own `--diff-filter=ACMR` | ✅ |
| R2 | hook never blocks — `.githooks/pre-commit` | Independent scratch-repo test — 3/3 (live: stubbed `rag-index.sh` exit 2 on every run, commit still landed with exit 0 each time, warning printed) | ✅ |
| R3 | CI fails when stale — `scripts/check-rag-index-matches-head.sh`, `.lsa.yaml` (`gate:` entry), `.github/workflows/lint.yml` (CI step) | Independent scratch-repo test — 3/3 for `rag-index.sh` exit 1 (→ CI exit 1) and 3/3 for exit 2/Docker-unreachable (→ CI exit 1, correctly treated as a hard failure, not `[cannot verify]`) | ✅ |
| R4 | CI passes when fresh — same files as R3 | Independent scratch-repo test — 3/3 (`rag-index.sh` exit 0 → CI exit 0) | ✅ |
| R5 | `SECURITY.md` documents the hook — `SECURITY.md` §"The RAG-index pre-commit hook" (confirmed present, `SECURITY.md:314`) | No dedicated scenario (structural/doc requirement, per `requirements.md`'s own traceability table) — verified directly: section exists, covers trigger/scope/opt-out per the requirement text | ✅ |

Orphan hunks: none.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants          bash scripts/lint.sh → exit 1
  PASS  citations                bash scripts/check-citations.sh → exit 0
  PASS  links                    bash scripts/check-links.sh → exit 0
  PASS  project-map              bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests                    bash scripts/run-tests.sh → exit 0
  PASS  lib-pins                 bash scripts/check-lib-pins.sh → exit 0
  FAIL  rag-index-fresh          bash scripts/check-rag-index-fresh.sh → exit 2
  FAIL  rag-index-matches-head   bash scripts/check-rag-index-matches-head.sh → exit 1

gate: FAIL
```

Three FAILs, all expected and non-defective, same class of reasoning as epic 1's `grounding.md`/`conformance.md`:
- `docs-invariants` — `lint.sh` C20, this epic's own `conformance.md` didn't exist until this file was written; resolves below.
- `rag-index-fresh` and `rag-index-matches-head` — both fail because this sandbox's Docker daemon is genuinely down (unrelated pre-existing environment state, first observed during epic 1's reconcile and never recovered despite two ~90s+ restart attempts this session). Both checks are **doing exactly what they were built to do**: `rag-index-fresh` reports `[cannot verify]`/exit 2 (dev-convenience, non-blocking-of-gate-verdict framing already established in epic 1), `rag-index-matches-head` correctly escalates the same underlying fact to a hard exit 1 (CI-enforcement framing, per R3/R4) — independently confirmed live above (Docker-unreachable → CI exit 1, 3/3).

## Verdict

**reconcile: PASS @ d96f334**

All 5 requirements verified. R1's scoping behavior and the deletion-exclusion edge case were checked in a single deterministic run (not stochastic — no reason to expect variance across repeats of a fixed-input scoping test); R2, R3, R4 verified 3/3 as `reconcile.runs: 3` requires. Zero orphan hunks. Independence: this grading ran in the orchestrating context, not the dispatched implementer `Agent` that authored `d96f334` — this verdict lands in a separate commit from that implementation commit, per the reward-hacking defense (`lsa/skills/reconcile/SKILL.md:62`).
