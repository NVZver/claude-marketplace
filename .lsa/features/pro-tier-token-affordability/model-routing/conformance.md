# Conformance — `pro-tier-token-affordability/model-routing`

**Graded by:** `lsa:reconcile` (this session's context — separate from the implementer).
**Graded @:** working tree on `feature/pro-tier-always-on-card` (uncommitted at grading; human owns the merge).

Verdict: the after-check that the diff satisfies the spec and only the spec. **reconcile: PASS.**

## does · only · all

- **does** — the three `flow-*.feature` scenarios map to authored behavior; all are docs-mode
  (structure/prose) scenarios graded by inspection + the deterministic C8 gate. No runtime agent
  dispatch is exercised here (no live Pro session); the dogfood token-delta measurement is the
  remaining human-owned validation named in the pitch success criteria.
- **only** — every changed hunk traces to a requirement or a standing discipline (SemVer + CHANGELOG;
  READMEs-are-living-documents; schema-doc consistency). No orphan hunk.
- **all** — every F/AC/D maps to a change.

## Requirement → satisfying change

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 (shipped tier-table knowledge file) | `lsa/knowledge/model-routing.md` (contract + 9-row table) | flow-1 (inspection) | ✅ |
| F2 (`.lsa.yaml routing:` map; zero frontmatter pins) | `.lsa.yaml` `routing:` block; lint **C8 PASS** | flow-2 §3, AC5 — C8 green | ✅ |
| F3 (resolve tier, pass as Agent `model`) | `manager/knowledge/roadmap-orchestration.md` §1; `lsa/skills/delegate/SKILL.md:56`; `prompt-engineer/agents/prompt-engineer.md` Constraints | flow-2 §1 (inspection) | ✅ |
| F4 (absent/unavailable ⇒ inherit, no hard error) | `lsa/knowledge/model-routing.md` §resolution 3; each wiring cite | flow-2 §2, AC3 | ✅ |
| F5 (floored graders/implementer/fan-out) | `model-routing.md` §resolution 1; `reconcile/SKILL.md` Constraints; `delegate` Step 3; `implement` Step 4a | flow-3 §1-2, AC4 | ✅ |
| F6 (echo resolved tier in dispatch line) | `roadmap-orchestration.md` §1; `delegate/SKILL.md:56` | flow-2 §1 (inspection) | ✅ |
| F7 (transitional vs. durable markers) | `model-routing.md` table "Survives inline rollout?" column + closing para | flow-1, AC1 | ✅ |
| F8 (knowledge file prints trace line) | `lsa/knowledge/model-routing.md:1`; lint **C4 PASS** | C4 gate | ✅ |
| AC1 (every surface a row w/ tier+cite+rationale+marker) | `model-routing.md` 9-row table | flow-1 | ✅ |
| AC2 (`manager:check` → haiku, echoed) | `.lsa.yaml` `manager:check: haiku` + `roadmap-orchestration.md` §1 | flow-2 §1 | ✅ |
| AC3 (absent key → inherit) | `model-routing.md` §resolution 3 | flow-2 §2 | ✅ |
| AC4 (`lsa:reconcile: haiku` still inherit) | `model-routing.md` §resolution 1 + `reconcile` Constraints | flow-3 §1 | ✅ |
| AC5 (C8 green) | `bash scripts/lint.sh` C8 PASS | gate | ✅ |
| D1 (home `lsa/knowledge/model-routing.md`) | file present | — | ✅ |
| D2 (surface-key format) | `model-routing.md` §map + keys in `.lsa.yaml` | — | ✅ |
| D3 (repo `.lsa.yaml` non-inherit entries) | `.lsa.yaml` 4 entries | — | ✅ |
| D4 (floored set; DRY via roadmap-orchestration) | `roadmap-orchestration.md` §1 (one point, 3 skills) | — | ✅ |

## Consequential + discipline hunks (traced, not orphan)

- `lsa/.claude-plugin/plugin.json` (0.26.0), `manager/...` (0.17.0), `prompt-engineer/...` (0.9.0);
  `lsa/CHANGELOG.md`, `manager/CHANGELOG.md`, `prompt-engineer/CHANGELOG.md`; `README.md` version column —
  per-plugin SemVer + CHANGELOG + "READMEs are living documents" (`.lsa/standards/code.md:18-22`).
- `lsa/README.md` (`routing:` in the schema block + paragraph), `lsa/ARCHITECTURE.md` §3 (`routing:` key +
  bullet) — living-doc consistency for the new `.lsa.yaml` key.
- `knowledge/index.md` (count 18→19 + new row) — lint C10 registration for the new knowledge file.
- `.lsa/features/pro-tier-token-affordability/model-routing/*` — the epic spec itself.

Orphan hunks: none.

Gate: `bash scripts/lint.sh` ✓ (exit 0, C1–C12) · `bash scripts/check-citations.sh` ✓ (exit 0, 75) · `bash scripts/check-links.sh` ✓ (exit 0, 455).

## Remaining (pitch-level, not this epic)

- **Dogfood token-delta measurement** — pitch success criterion "a dogfood session shows mechanical
  dispatches measurably running on the cheapest tier" requires a live Pro session; it is human-owned
  validation, not a code deliverable, and is not gated here.
- **WS2 (project-index)** and **WS3 (script-offload)** remain (lever order WS1→WS4→WS2→WS3).
