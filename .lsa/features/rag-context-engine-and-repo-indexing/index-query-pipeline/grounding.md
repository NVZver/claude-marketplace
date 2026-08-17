# grounding.md — rag-context-engine-and-repo-indexing/index-query-pipeline

## Reference map (`bash scripts/resolve-refs.sh`)

| Symbol | Resolution |
|---|---|
| `scripts/rag-index.sh` | new |
| `scripts/rag-query.sh` | new |
| `Dockerfile` | new |
| `.lsa/.rag-index/` | new |
| `scripts/check-lib-pins.sh` | exists @ `scripts/check-lib-pins.sh` (style precedent for the new gate script) |
| `.lsa.yaml` | exists (gate contract host; direct-read confirmed at discover time, `.lsa.yaml:14-20`) |
| `.gitignore` | exists (direct-read confirmed at discover time) |

## Feasibility per flow

- **Flow 1 (build index):** buildable — all four new artifacts are genuinely new, no naming collision with anything existing, no conflicting mechanism found.
- **Flow 2 (query index):** buildable — same basis.
- **Flow 3 (`rag-index-fresh` gate check):** buildable — direct structural precedent exists and resolves (`scripts/check-lib-pins.sh`), including its three-outcome exit-code contract.

## Assumptions carried forward from the pitch (visible, not silently resolved)

- `[ASSUMPTION]` embedding library — `fastembed`-class, local CPU-only. Not verified against current docs this session.
- `[ASSUMPTION]` vector store — LanceDB-class, embedded/file-based. Not verified against current docs this session.
- `[ASSUMPTION]` Docker daemon availability is an environmental precondition of every scenario in this spec, not a code fact — cannot be resolved by `resolve-refs.sh`.

## Gate (`bash scripts/gate.sh`)

```
  FAIL  docs-invariants  bash scripts/lint.sh → exit 1
  PASS  citations        bash scripts/check-citations.sh → exit 0
  PASS  links            bash scripts/check-links.sh → exit 0
  PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests            bash scripts/run-tests.sh → exit 0
  PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0

gate: FAIL
```

`docs-invariants` fails on one check, `scripts/lint.sh` C20:

```
  FAIL  C20 feature dirs with requirements.md but no conformance.md (reconcile skipped):
        .lsa/features/rag-context-engine-and-repo-indexing/index-query-pipeline
```

C20's own header comment (`scripts/lint.sh:600-611`) states its purpose: catching an epic that *shipped* with `lsa:reconcile` skipped — the 2026-07-20 incident where 8 epics merged on a green `gate:` block with no independent grading. Its exemption list (`scripts/baselines/conformance-exempt.txt`) is explicitly for dirs that are "pre-contract, or dropped at specify and never implemented" — permanent non-implementation, not "in progress." This epic's dir is neither: it's a freshly-approved spec awaiting `delegate`, not an abandoned one, so adding it to that exemption list would misrepresent it.

## Verdict

**NOT-GROUNDED**, strictly by `verify`'s own constraint ("a non-zero `gate:` check BLOCKS the GROUNDED verdict... never asserted", `lsa/skills/verify/SKILL.md`). But flagged plainly: this specific failure is not a defect in the spec or codebase — it is a structural property of C20 checked at this exact position in the loop. C20 can only ever read PASS for a feature dir once `conformance.md` exists, and `conformance.md` is only ever written by `reconcile`, which runs *after* `delegate`, which `verify` itself gates. Taken literally, no freshly-specified epic can ever pass `gate:` at `verify` time — this isn't specific to this spec.

**Owner decision (2026-08-17):** proceed to `delegate` anyway. Every other configured `gate:` check passes; only this structural, position-in-loop artifact fails. Not silently overridden — surfaced via `AskUserQuestion`, owner chose to proceed rather than pause to fix C20's timing or add a (likely-inappropriate) exemption-list entry. `reconcile` will resolve this same C20 line once it writes this dir's `conformance.md`. The C20/verify-timing mismatch itself remains unfixed and is a legitimate small finding for this repo's own tooling, not addressed here.
