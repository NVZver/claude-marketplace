# grounding.md — rag-plugin-plug-and-play/dogfood-migration

## Reference map

| Symbol | `resolve-refs.sh` output |
|---|---|
| `seed-canonical-paths.sh` | `exists @ .lsa/features/.../bootstrap-trigger/grounding.md:12` (primary: `lsa/scripts/seed-canonical-paths.sh`, epic 2, shipped `9253977`) |
| `check-rag-index-fresh.sh` | `exists @ .github/workflows/lint.yml:26` — direct hit confirming the exact CI line R4 changes |
| `check-rag-index-matches-head.sh` | `exists @ .githooks/pre-commit:15` — direct hit confirming R5's removal target references it |
| `CANONICAL_PATH_PREFIXES` | `exists @ .lsa/features/.../canonical-source-weighting/conformance.md:34` (primary: `docker/rag_cli.py:592-611`, root-level, pre-migration — R1's coverage floor) |
| `core.hooksPath` | `exists @ .githooks/pre-commit:4` — confirms the documented opt-in mechanism R6 repoints |

## Feasibility per flow

- **Flow 1:** buildable — `seed-canonical-paths.sh`'s merge-preserve behavior (already shipped, epic 2) is exactly what's needed: manually add the 12 non-derivable entries first, then run the script to add the ~23 module-derived ones on top, none lost.
- **Flow 2:** buildable and directly testable — `bash scripts/gate.sh` baseline captured this session (both PASS); a before/after diff is a live, no-new-tooling test.
- **Flow 3:** buildable — plain `git rm` + `git config core.hooksPath`.
- **Flow 4:** buildable — every reference site was located by direct grep during discover, with exact line numbers cited in `requirements.md`.

## Assumptions

None flagged `[ASSUMPTION]` — every requirement traces to a direct grep/read finding from discover, including the corrected "23 entries, not 5" fact (sourced from epic 2's own already-shipped `conformance.md`, not assumed).

## Gate

`bash scripts/gate.sh` pre-cutover baseline (captured this session): `rag-index-fresh` PASS, `rag-index-matches-head` PASS. `docs-invariants` FAILs on the expected C20 gap (this epic's `conformance.md` doesn't exist yet).

## Verdict

**GROUNDED.** All named symbols resolve to real, existing code or CI config; every flow is buildable on already-shipped epic output; the pre-cutover baseline is captured for Flow 2's before/after proof.
