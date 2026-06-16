# Epic 4 — Split `manager:roadmap` 3-in-1 → `next` / `decompose` / `check`

## Summary
Replace the single `manager:roadmap` skill (one noun bundling three verbs) with three
function-named entry points, each dispatching the SAME `project-manager` agent with a distinct
intent. Realizes the convention the `command-naming.md` anti-pattern flags. Pre-1.0 breaking
change → **minor** bump (0.8.0 → 0.9.0).
Parent: `.lsa/pitches/function-command-naming-and-manager-rename.md` (Epic 4)

## Functional requirements (doc-mode — about the artifacts)
- R1. A new `manager/knowledge/roadmap-orchestration.md` SHALL hold the shared contract (dispatch the
  `project-manager` agent → run returned gates self-contained via `AskUserQuestion` → re-render the
  invisible agent payload → agent owns roadmap writes), extracted from the current roadmap skill's
  Steps 2 + Constraints (DRY — the three skills cite it, never restate).
- R2. `manager/skills/next/SKILL.md` (`manager:next`) SHALL recommend what to work on next: the Step 0
  fast-path ("what's next" → cited roadmap row, per `core/knowledge/fast-path-source-of-truth.md`)
  plus agent dispatch (intent = recommend/sequence) for "what should I pick" / "sequence the backlog".
- R3. `manager/skills/decompose/SKILL.md` (`manager:decompose <pitch>`) SHALL dispatch the agent to
  decompose a pitch into epics and run the staged `lsa:discover` handoff on epic approval.
- R4. `manager/skills/check/SKILL.md` (`manager:check`) SHALL dispatch the agent for roadmap hygiene
  (stale/inconsistent rows) and gate the proposed row diffs.
- R5. `manager/skills/roadmap/` SHALL be removed (clean break, no alias).
- R6. The ONE `project-manager` agent SHALL be preserved and shared; each skill passes an explicit
  intent so the agent runs the right mode. The agent's behavior is unchanged.
- R7. All live references to `manager:roadmap` SHALL be updated to the correct new verb:
  `manager/skills/shape/SKILL.md` handoff → `manager:decompose`; README, `.lsa/modules/manager/spec.md`,
  `marketplace.json` description, `knowledge/index.md`, `helper/knowledge/onboarding-fast-path.md`,
  `core/knowledge/fast-path-source-of-truth.md` caller table — each to the verb that matches its context.
- R8. `manager/knowledge/command-naming.md` SHALL update the worked anti-pattern: the `manager:roadmap`
  noun is now actually split, so present it as the realized before→after (resolved), not a pending example.
- R9. Per-plugin CHANGELOG `[0.9.0]` entry + README delta in the same commit; version 0.8.0 → 0.9.0.

## Acceptance
- `manager:next` dispatches the agent and (fast-path) quotes the next backlog row; `manager:decompose <pitch>`
  returns an epic list + stages `lsa:discover`; `manager:check` returns hygiene diffs — each verified by reading the skill.
- Zero live `manager:roadmap` references remain (history excluded). `scripts/lint.sh` PASS C1–C6.

## Out of scope
- `manager:implement` stub (Epic 3). No change to the project-manager agent's reasoning/knowledge.
