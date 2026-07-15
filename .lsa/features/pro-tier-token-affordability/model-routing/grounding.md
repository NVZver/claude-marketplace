# Grounding — model-routing (verify, before-check, 2026-07-15)

Verdict: **GROUNDED**

## Reference map

| Spec reference | Status |
|---|---|
| Model policy (Pro-safe, `inherit` default, `sonnet` legal on mechanical) | exists @ `.lsa/standards/code.md:47-55` |
| Dispatch-efficiency isolation classes (durable routing surfaces) | exists @ `.lsa/standards/code.md:59-63` |
| `.lsa.yaml` key-read precedent (`gate:`, `reconcile:`, `implement:`, `paired_verify`) | exists @ `.lsa.yaml:15-31`; read protocol `lsa/knowledge/conventions.md:29-39` |
| Cross-plugin knowledge-cite precedent (F1/D1 home) | exists @ `lsa/knowledge/quality-gate-contract.md`, cited by `manager/skills/implement/SKILL.md:24` |
| Surface 1 `manager:shape` → product-manager | exists @ `manager/skills/shape/SKILL.md:26` (Agent tool; NOT via roadmap-orchestration) |
| Surfaces 2-4 `manager:next/decompose/check` → project-manager | exist @ `manager/skills/next/SKILL.md:26`, `decompose`, `check/SKILL.md:23` — all via `manager/knowledge/roadmap-orchestration.md` §contract-1 |
| Surface 5 `manager:implement` per-epic fan-out | exists @ `manager/skills/implement/SKILL.md:38` (`isolation: worktree`) |
| Surface 6 `lsa:delegate` → implementer | exists @ `lsa/skills/delegate/SKILL.md:37,47` |
| Surface 7 `lsa:delegate` → `observer:verify-checkpoint` | exists @ `lsa/skills/delegate/SKILL.md:56`; reader `observer/skills/verify-checkpoint/SKILL.md` per-increment mode (a) |
| Surface 8 `lsa:reconcile` grader | exists @ `lsa/skills/reconcile/SKILL.md:33` (N runs), independence `:57-58` |
| Surface 9 prompt-engineer agent dispatches | exists @ `prompt-engineer/agents/prompt-engineer.md:24` (`tools: … Agent`) |
| lint C8 (no opus/haiku/fable frontmatter pin) | exists @ `scripts/lint.sh` C8 |
| `lsa/knowledge/model-routing.md` (F1 contract + table) | **new** |
| `.lsa.yaml routing:` map (F2, D3) | **new** — repo config, non-`inherit` entries only |
| routing cite in roadmap-orchestration / delegate / reconcile / implement | **new** — additive; absent map ⇒ inherit ⇒ today's behavior (prompt-engineer surface: table row 9 + map entry only, no in-repo dispatcher — resolved at the Agent boundary like `manager:shape`) |

## Feasibility

- Flow 1 (documented table): buildable — table content is verbatim from the pitch (`pro-tier-token-affordability.md:108-127`).
- Flow 2 (resolve + echo): buildable — `.lsa.yaml` key-read is the established pattern (gate/reconcile/implement); dispatch passes `model` at the `Agent` boundary.
- Flow 3 (grader floor): buildable — floor is a contract rule + a named exclusion; no mechanism.
- DRY: manager `next/decompose/check` share `roadmap-orchestration.md` → one wiring point covers three surfaces.

## Gate results (quality-gate-contract; command + exit code)

- `bash scripts/lint.sh` → exit 0 (C1-C12 PASS)
- `bash scripts/check-citations.sh` → exit 0 (74 citations resolve)
- `bash scripts/check-links.sh` → exit 0 (445 links resolve)

## Blockers

None. `manager:shape` (row 1) uses the `product-manager` agent outside `roadmap-orchestration`; it is `inherit`/transitional, so it is documented in the table but needs no wiring (absent key ⇒ inherit ⇒ unchanged behavior).
