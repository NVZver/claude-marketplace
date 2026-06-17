# Conformance — Epic 3 (Parallel-Agent-Delivery Semi Autonomy)

Verdict: **PASS** (docs-mode)
Convergence branch: `feature/parallel-agent-delivery`

| Requirement | Satisfied by |
|---|---|
| R1 — `autonomy: manual\|semi\|auto`, default manual | `manager/knowledge/autonomy-policy.md` §"The ladder"; `implement/SKILL.md` Step 1 |
| R2 — `.lsa.yaml` schema documents `autonomy:` | `lsa/ARCHITECTURE.md` §3 (schema + bullet); `lsa/README.md` schema block |
| R3 — `semi` auto-merges on green, serialized, tested SHA | autonomy-policy.md §"`semi`"; `serialized-merge.md` §"Autonomy boundary"; `implement/SKILL.md` Step 5 |
| R4 — gate identical at every level | autonomy-policy.md ("The gate never weakens"); `implement/SKILL.md` Step 5 + Constraint |
| R5 — no level auto-merges into `main` | autonomy-policy.md §"`semi`"; serialized-merge.md + parallel-dispatch.md boundary sections |
| R6 — `auto` clamps to `semi` with notice | autonomy-policy.md §"`auto`"; `implement/SKILL.md` Input + Step 1 |
| R7 — SemVer + CHANGELOG + README (manager + lsa) | `manager` 0.12.0 → 0.13.0; `lsa` 0.18.0 → 0.19.0; both CHANGELOGs + READMEs |

## Scope (only · all)
- **Only:** every hunk traces to an R-line or per-plugin discipline. Edits to `serialized-merge.md` / `parallel-dispatch.md` update their forward-looking "manual only" notes now that `semi` is built — in-scope consistency, not over-delivery.
- **All:** R1–R7 each map to a shipped change. `auto` (R6) is intentionally clamped, not built (Epic 4).

## Notes
- Cross-plugin: the `autonomy:` *schema* is documented in `lsa` (owns `.lsa.yaml`); the *semantics* live in `manager` (the consumer) — same split as the Epic 1 `gate:` key.
