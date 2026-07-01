# Requirements — `reuse-first`

**Epic:** `reuse-first/skill`
**Module:** `core`
**Pitch:** [`.lsa/pitches/reuse-first.md`](../../pitches/reuse-first.md)
**Flow:** Extended (user-directed full LSA cycle)
**Date:** 2026-07-01

An always-on `core` skill that walks a 7-rung reuse ladder on coding tasks before code is
written — closing the gap between the spec ("what") and `lsa:reconcile`'s after-the-fact
"only" check (`lsa/skills/reconcile/SKILL.md:33`).

## User flow — `reuse-ladder`

- **Flow:** Agent receives a coding task → traces the real flow end-to-end → climbs the ladder,
  stopping at the first rung that holds → produces the shortest working diff (or no code).
  On a prose/analysis task the skill stays silent.
- **Success:** the change reuses existing capability where available and adds only the minimum;
  `lsa:reconcile`'s "only" check surfaces fewer untraced hunks.
- **I/O:** input = a coding task (implement / fix / refactor / add code); output = the ladder
  applied (rungs evaluated in order) and the resulting code.
- **Test:** E1 — a coding-task prompt triggers the ladder; E2 — a prose/analysis prompt does not.

## EARS requirements

- **F1** — When a coding task (implement / fix / refactor / add code) is received, the system
  shall evaluate the reuse-ladder rungs in order before writing code.
- **F2** — While selecting a rung, the system shall first trace the real end-to-end flow the
  change touches (cross-ref `ground-rules` R3, `core/skills/ground-rules/SKILL.md:67`).
- **F3** — When a needed behavior already exists as an in-codebase helper/util/type/pattern,
  the system shall reuse it rather than reimplement.
- **F4** — When the standard library or language builtin provides the behavior, the system
  shall use it rather than hand-roll.
- **F5** — When a native platform feature covers the need, the system shall prefer it over
  custom code.
- **F6** — When an already-installed dependency solves the need, the system shall use it, and
  shall not add a new dependency for what a few lines cover.
- **F7** — Where no higher rung holds, the system shall produce the shortest working diff,
  preferring deletion over addition and boring over clever.
- **F8** — When fixing a bug, the system shall locate the root cause across all callers and fix
  it once in the shared path, not per-symptom.
- **F9** — When the task is prose/analysis (non-coding), the system shall not trigger the ladder.
- **F10** — The skill shall follow the actor-template shape (Goal / Input / Steps / Output /
  Constraints), each Step carrying an observable result (`core/skills/actor-template/SKILL.md:14-21`).
- **F11** — The skill shall cross-reference `ground-rules` R3/R4
  (`core/skills/ground-rules/SKILL.md:67`, `:77`) and `lsa:reconcile`'s "only" check
  (`lsa/skills/reconcile/SKILL.md:33`) by markdown link, and shall not restate them.
- **F12** — The skill shall not introduce metaphor naming (ponytail/lazy/caveman), an intensity
  dial (lite/full/ultra), a debt-comment ledger or `-debt`/`-audit`/`-gain`/`-review` commands,
  or test-discipline rules (test discipline defers to TDD).

## Non-functional / packaging

- **N1** — `core` version 0.14.1 → 0.15.0 (MINOR: new skill), with a `core/CHANGELOG.md` entry
  (Keep a Changelog), README deltas (`README.md` six-plugins area + `core/README.md` skill list
  bullet + invoke line + stale "Two…skills" count fix at `core/README.md:3`), and the module
  spec update (`.lsa/modules/core/spec.md:5,17` "four skills" → five) — all in the same commit
  (`.claude/rules/plugin-development.md` §Version Management).
- **N2** — The skill is wired always-on via one cross-reference line in the `core/CLAUDE.md`
  always-on block (`core/CLAUDE.md:24-33`, currently three rules).
- **N3** — A behavioral gate (`Set E`) is added to `core/tests/repo-anchored.md`: **E1** a
  coding-task prompt triggers the ladder; **E2** a prose/analysis prompt stays silent. Falsifiable
  threshold model per `core/tests/repo-anchored.md:209`.

## Traceability

Acceptance scenarios in [`reuse-ladder.feature`](./reuse-ladder.feature) cover F3, F4, F8, F9, F11.
Non-scenario requirements (F1, F2, F5, F6, F7, F10, F12, N1–N3) are covered by structural checks
at `lsa:reconcile` and by Set E in `core/tests/repo-anchored.md`.
