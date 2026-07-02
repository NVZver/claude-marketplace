# Changelog

All notable changes to the `observer` plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-07-02

Cross-epic harmonization with `lsa:delegate` (epic 2, `paired-verify/lsa-delegate-wiring`):
reconciles two LOW seams `lsa:reconcile` flagged between the two halves of the `paired-verify`
pitch. No grading behavior (F1–F13) changes.

### Changed

- **`skills/verify-checkpoint/SKILL.md` — invocation model reframed.** The core unit is now stated
  as **grading one signalled increment**, run via **two invocation modes with identical grading**:
  (a) **per-increment dispatch** — the delegating context (`lsa:delegate`) dispatches this Actor once
  per signalled increment via the `Agent` tool (first-class, how `delegate` drives it); and (b) the
  original **standalone `/loop` rider**. The intro, Goal, Input, Step 1 (was "start the /loop"), and
  Step 2 now frame grading as the spine and the mode as the entry point. The `/loop` mode is retained
  in full; the no-scheduler guard still applies to it.
- **`skills/verify-checkpoint/SKILL.md` — checkpoint-note PATH pinned.** The contract section now
  states the note's file **path** is owned by the delegating context and passed as the SAME path to
  both the implementer (writer) and this Actor (reader) at dispatch; the path is **ephemeral**
  (scratchpad / gitignored) and **NOT committed**. The four contract fields (`target` / `since` /
  `spec` / `status`) are unchanged — the path locates the note, the fields are its contents.
- **`README.md` / `.lsa/modules/observer/spec.md`** — reflect the two invocation modes and the
  delegate-owned, shared, ephemeral note path.

## [0.2.0] - 2026-07-01

`observer` becomes a two-Actor module: the existing `observe` coach gains a
sibling **gate**. Implements epic `paired-verify/observer-verifier` (F1–F17).

### Added

- **`observer:verify-checkpoint` Actor skill** ([`skills/verify-checkpoint/SKILL.md`](./skills/verify-checkpoint/SKILL.md))
  — a per-increment grader that rides the self-paced `/loop` (no scheduler) and,
  on a checkpoint signal an implementer emits when it pauses having finished one
  F-requirement, grades that increment on two of `lsa:reconcile`'s three checks:
  **does** (the scenarios mapped to the target F pass; not-yet-built requirements
  are out of scope) and **only** (every changed hunk traces to a requirement;
  untraced = over-delivery). It does NOT apply the whole-plan **all** completeness
  check — that stays with the final `lsa:reconcile`. Pass both → `CLEAR` (auto-clears
  without interrupting the human); fail either → `BLOCK` naming the failing check,
  surfaced to the human before the next task. Read-only to the graded artifacts
  (tests, `.feature`, `.lsa.yaml` `gate:`); the verdict is an artifact the
  implementer could not author. Gate voice, not `observe`'s coaching voice; does
  not read or modify `knowledge/roles.md`.
- **Checkpoint-signal contract** — the skill defines the note the implementer emits
  on pause (`target` F-id, `since` marker, `spec` path, `status` pause marker) that
  the verifier reads each cycle. The writer ships in epic
  `paired-verify/lsa-delegate-wiring`.
- **Surface disambiguation** — the skill and README state `verify-checkpoint` is NOT
  `lsa:verify` (the before-delegation grounding check); it is the after-increment
  gate, the per-increment analogue of `lsa:reconcile`.
- **Adversarial evals** ([`tests/verify-checkpoint-scenarios.md`](./tests/verify-checkpoint-scenarios.md))
  — probes over a synthetic increment carrying the checkpoint signal: seeded-drift
  (scope-creep hunk) → BLOCK, conformant → CLEAR, broken-scenario → BLOCK, and
  unbuilt-future-requirement → NOT flagged (guards the no-`all` decision).

### Changed

- `.claude-plugin/plugin.json` version `0.1.1` → `0.2.0` (new skill = minor) and the
  description now covers both Actors.
- `README.md` — new `observer:verify-checkpoint` skill row, a two-Actor "How it fits"
  note, and the `lsa:verify` disambiguation.
- `.lsa/modules/observer/spec.md` — updated to a two-Actor module description
  (observe + verify-checkpoint); stale `v0.1.0` corrected to `v0.2.0` at both the
  manifest header and the versioning invariant; verify-checkpoint added to the
  role list and invariants.

## [0.1.1] - 2026-06-28

Prompt-hardening from the first behavioral eval (`tests/eval-findings-2026-06-27.md`):
8/8 probes passed, but the judges found the passes rested on model good-will, not
prompt enforcement. These edits convert latent guards into enforced ones (no role's
intended direction changed).

### Changed

- **`knowledge/roles.md` rubber-duck Voice** — questions must stay genuinely open
  (no telegraphing the answer or steering to a technique/complexity class) and stay
  within the user's stated reasoning, not import a performance/reuse/style lens.
- **`knowledge/roles.md` interviewer Lens** — added a one-line gloss defining each
  level (solution / bugs / performance / style) so the ordering is operable; name a
  level only when it has a catch.
- **`knowledge/roles.md` interviewer difficulty** — lowering the bar shrinks the
  TARGET (isolate a sub-case, drop a constraint); the candidate still writes the
  step — never hand over the implementing line.
- **`knowledge/roles.md` pair-programmer Lens** — the project search must be real and
  shown (cite the dependency/file/symbol found); never name an unconfirmed surface.
- **`knowledge/roles.md` pair-programmer Cadence** + **`skills/observe/SKILL.md`
  Step 6(d)** — silence is defined as NO user-facing text (no marker/token/placeholder
  such as `<SILENT>`).
- **`skills/observe/SKILL.md` Non-destructive constraint** — in the interviewer role,
  state the gotcha and the direction of a safer alternative, not the corrected code.

### Fixed (guard-verification re-run)

- **`skills/observe/SKILL.md` Step 6(d) + `roles.md` pair-programmer Cadence** — the
  first silence guard banned tokens but a re-run still leaked a decision-narration
  paragraph and an `(empty)` status line; tightened silence to "zero output" — no
  status line, parenthetical, or narration of the decision to stay silent.
- **`skills/observe/SKILL.md` Example Output** — it still labeled an off-by-one as
  `solution:` and handed a copy-paste fix line (`hi = mid - 1`), contradicting the new
  lens definitions and the non-destructive rule; relabeled to `bugs:` and changed to a
  directional hint. Reconciled `tests/scenarios.md` S4 PASS criteria to the new
  solution-vs-bugs definitions.

## [0.1.0] - 2026-06-27

### Added

- Initial release: live observe-and-coach plugin that rides Claude Code's
  self-paced `/loop` and reacts to file changes through a chosen role.
- `observer:observe` Actor skill — kickoff role confirmation (infer + propose, or
  adopt a named role; custom requires a one-line lens), conditional
  interviewer-only exercise scaffold (problem + placeholder + initially-failing
  test suite), the per-cycle observe loop applying the active role's bundle,
  mid-session role-switch without loop restart, and stop on request /
  self-conclusion / inactivity timeout with a stated reason. Persists the active
  role and interviewer difficulty in a session-state note re-read each cycle,
  since `/loop` is stateless between wakes.
- `roles.md` Knowledge file — the four role bundles (rubber-duck,
  pair-programmer, interviewer, custom) as lens / voice / cadence data, plus the
  interviewer's stateful difficulty-adaptation rules. The Actor reads behavior
  from here and holds no per-role branching (Knowledge ≠ Actor).
- Rides the substrate `/loop` instead of implementing a scheduler.
- Depends on `core` (ground-rules, output).
