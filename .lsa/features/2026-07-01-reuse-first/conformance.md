# Conformance — `reuse-first`

**Graded by:** `lsa:reconcile` (orchestrator context — separate from the `prompt-engineer` implementer).
**Graded @:** working tree on `feature/reuse-first` (uncommitted at grading time; the PASS verdict lands in a commit separate from the implementation commit per the independence rule).

Verdict: this is the after-check that the diff satisfies the spec and only the spec; a FAIL would send it back before any commit. **reconcile: PASS.**

## does · only · all

- **does** — the 5 `reuse-ladder.feature` scenarios each map to authored behavior; the repeatable runtime gate is `core/tests/repo-anchored.md` Set E (E1/E2), run in fresh sessions.
- **only** — every changed hunk traces to a requirement below; no untraced hunk (no over-delivery). `README.md` root left unchanged by design (its `core` row describes disciplines, not a skill count/list, so nothing there is stale).
- **all** — every F- and N- requirement maps to a change (no under-delivery).

## Requirement → satisfying change

| Req | Satisfied by |
|-----|--------------|
| F1 (coding-task trigger, ladder in order) | `core/skills/reuse-first/SKILL.md:3` (description) + `:22-24` (Steps, "evaluate in order") |
| F2 (understand flow first, x-ref R3) | `SKILL.md:26` — links `ground-rules` Rule 3, not restated |
| F3 (reuse in-codebase) | `SKILL.md:30` (rung 3, grep) |
| F4 (stdlib/builtin) | `SKILL.md:32` (rung 4) |
| F5 (native platform) | `SKILL.md:34` (rung 5) |
| F6 (installed dep, no new dep) | `SKILL.md:36` (rung 6) |
| F7 (shortest diff, deletion/boring) | `SKILL.md:38` (rung 7) |
| F8 (root-cause across callers) | `SKILL.md:40` |
| F9 (silent on prose) | `SKILL.md:3,11,54` + Set E E2 (`core/tests/repo-anchored.md:200-208`) |
| F10 (actor-template shape) | `SKILL.md:13-50` — Goal/Input/Steps/Output/Constraints, each Step has Observable result |
| F11 (x-ref never restate) | `SKILL.md:26,48` links; D2 grep zero uncited hits |
| F12 (no-gos) | F12 grep zero forbidden tokens in `SKILL.md` |
| N1 (version/changelog/readme/spec, same commit) | `plugin.json:4` 0.15.0; `CHANGELOG.md` [0.15.0]; `README.md`/`core/README.md`; `.lsa/modules/core/spec.md:5,17,23` |
| N2 (always-on wiring) | `core/CLAUDE.md:35-38` + intro count `:5` |
| N3 (behavioral gate Set E) | `core/tests/repo-anchored.md:186-208` (E1/E2) |

## Invariant checks

- **D2 canonical-invariant** — recipe (1) zero hits; recipe (2) no uncited hits. PASS.
- **F12 no-gos** — `ponytail|caveman|lazy|lite/full|intensity|debt|-audit|-gain` absent from `SKILL.md`. PASS.

No drift. The spec required no revision to match reality.
