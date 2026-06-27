# Changelog

All notable changes to the `observer` plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
