# Changelog

All notable changes to the `observer` plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2026-07-02

Fixes from the repo-wide prompt review (run with `prompt-engineer` 0.8.0 discipline; 5 MEDIUM findings in this plugin — anchor drift + silence-definition duplication, no behavior change).

### Added

- **`knowledge/roles.md`** — §"Silence — the zero-output rule": the single source for what *silent / emits nothing* means (no marker, token, placeholder, status line, parenthetical, or narration). Previously enumerated in full in four places.

### Fixed

- **`skills/verify-checkpoint/SKILL.md`** — seven stale line-anchors into `lsa/skills/reconcile/SKILL.md` corrected (`:32`→`:33`, `:33`→`:34`, `:34`→`:35` — off-by-one drift — and `:44-45`→`:58` ×2, which pointed at the coverage-table example instead of the independence constraint); the *Silence on no signal* constraint now references Step 2's definition instead of re-enumerating (the skill keeps one self-contained copy because constraint F13 forbids it reading `roles.md`).
- **`skills/observe/SKILL.md`** — step 8(d) references `roles.md` §"Silence — the zero-output rule" instead of enumerating; **`knowledge/roles.md`** pair-programmer cadence likewise.

## [0.3.0] - 2026-07-02

Observer remediation (epic `eval-coverage-tracks-complexity/observer-remediation`):
ships the five MEDIUM findings the 2026-06-27 eval left open (M1–M5,
[`tests/eval-findings-2026-06-27.md`](./tests/eval-findings-2026-06-27.md) — each now
carries a Resolution line) and folds in the `sonnet-robustness-consistency-sweep`
pitch's observer thresholds, so a Pro-tier model resolves every threshold without
inventing one. Re-verified by a fresh 8-probe adversarial run
([`tests/eval-findings-2026-07-02.md`](./tests/eval-findings-2026-07-02.md)).

### Changed

- **`skills/observe/SKILL.md` kickoff split + signal→role table (M3, M4).** The bundled
  kickoff step is now three one-action steps, each with an `Observable result:` line
  (verify-checkpoint house style): read context / adopt a named role → infer one candidate
  from a **signal→role table** (failing tests + stub → interviewer; feature-in-progress
  with tests → pair-programmer; exploratory, no tests → rubber-duck; user names a role →
  that role) → propose via `AskUserQuestion`. Pre-confirmation output is bounded to the
  one-line matched-signal reason — no diagnosing bugs or naming fixes before confirmation.
  The Example Output is reconciled with the table: its failing-pytest-plus-stub context
  now proposes **interviewer**, not pair-programmer (the self-contradiction M3 caught).
- **`skills/observe/SKILL.md` inactivity limit defined (was "the timeout").** Stop
  condition F5.2 is now **2 consecutive `/loop` cycles with no file changes** since the
  last-cycle marker (cycle-based — the loop is self-paced, no wall clock), overridable at
  kickoff (escape hatch) and recorded in the session-state note. Input, Step 5, Step 10,
  and the Example Output carry the same figure.
- **`skills/observe/SKILL.md` scaffold decline mandates the recovery path (M5).** A
  scaffold request in a non-interviewer role now forces: decline + stated reason + a
  switch offer via `AskUserQuestion`; on switch, the language/topic gate (F2.2) runs
  before any scaffolding.
- **`knowledge/roles.md` interviewer "persistently stuck" quantified.** Persistently
  stuck = **3 consecutive cycles** with no forward progress on the same blocker (the
  figure `tests/scenarios.md` S5 already used, now in the data file the Actor reads).
- **`knowledge/roles.md` pair-programmer lens order disambiguated (M2).** The lens order
  is recommendation priority, not scan order: recommend the single highest-ranked target
  (dependency outranks local code); lower-ranked targets are named only as an explicit
  fallback, never an unranked menu.
- **`knowledge/roles.md` custom role gains a Scope field (M1).** Emit only in-lens
  findings — whether or not the lens line says "only"; out-of-lens findings are dropped,
  not deferred; the non-destructive backstop is stated; in-lens-empty cycles emit nothing.
- **`skills/verify-checkpoint/SKILL.md`** — the three `../observe/SKILL.md` line citations
  updated for the renumbered steps (session-state note now Step 5 @ :45; silence discipline
  now step 8d @ :51).
- **`tests/scenarios.md` PASS criteria tightened** (the 06-27 "Suite gaps to harden" list):
  S3 requires a *shown* search artifact (was "stated or shown") and the single
  highest-ranked recommendation; S7 names the signal→role table route (interviewer) and
  bans pre-confirmation diagnosis; S8 makes the switch offer mandatory (was "may offer")
  with the F2.2 fall-through.

### Added

- **`tests/eval-findings-2026-07-02.md`** — fresh adversarial re-run of all 8 probes
  against the 0.3.0 prompts (per `.lsa/standards/testing.md` "Guards must be
  prompt-forced"), with per-scenario forced/generous verdicts.
- **`tests/eval-findings-2026-06-27.md`** — Resolution lines for H1–H5 (shipped in 0.1.1)
  and M1–M5 (shipped in 0.3.0), closing the open findings loop.

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
