# Deterministic-work-is-scripted — codify the principle

## Summary

Promote the already-practiced doctrine "deterministic work of meaningful complexity
is scripted, not computed by the model at inference time" to a first-class
constitutional principle (§2 principle 10), surface it on the core always-on card,
and guard its presence with a C6-style lint probe. Codification only — this epic
adds NO new deterministic-work scripts (those are the reconcile / verify / hygiene
epics that follow); it establishes the named principle those epics are verified
against.

- Source: discover handoff 2026-07-17 (deterministic-work-→-script sweep, epic 1 of 4).
- Doctrine already scattered (to be unified): `.lsa.yaml:13`
  ("Pro-safe, local bash, zero model calls"),
  `core/knowledge/fast-path-source-of-truth.md:5`,
  `manager/agents/project-manager.md:33` ("deterministically (zero model tokens)").
- Probe shape reused (not invented): `scripts/lint.sh:153-164` (C6 presence guard).
- Constitution gap confirmed: `.lsa/VISION.md:56-66` (§2 has principles 1–9; none states this).

## User Flows

1. **Reading the constitution.** A contributor opens `.lsa/VISION.md` §2 and finds
   principle 10 stating deterministic-work-is-scripted as a first-class rule with a
   meaningful-complexity boundary and cross-references — not scattered enforcement prose.
2. **Every-session load.** The `core/CLAUDE.md` always-on card carries a one-line
   pointer to the principle, so it loads every session alongside the other disciplines.
3. **Regression guard (`lint.sh`).** A contributor runs `bash scripts/lint.sh`; a new
   check (C15) passes on the current tree, and FAILs if the principle is later deleted
   from `.lsa/VISION.md` or dropped from the card.
4. **Grading payoff (judgment, not automated).** When `reconcile` / a reviewer grades
   a later epic, the "only what's needed" check can now CITE principle 10 as the named
   criterion for flagging model-side inline determinism.

## Functional requirements (EARS)

### Constitution
- R1. `.lsa/VISION.md` §2 SHALL gain principle 10 stating: any deterministic step of
  meaningful complexity — enumeration, set-difference, lookup, tally, format transform —
  is performed by a script whose output the model CITES, never recomputed by the model
  at inference time; the model spends tokens on judgment, not on work a script does
  identically for free.
- R2. Principle 10 SHALL state the **meaningful-complexity boundary** — a trivial
  one-item check is not forced into a script (ceremony scales to weight, §3) — so the
  rule is not read as "script everything."
- R3. Principle 10 SHALL cross-reference the existing enforcement surfaces it unifies
  (`.lsa.yaml` gate contract; `core/knowledge/fast-path-source-of-truth.md`), and
  `.lsa/VISION.md` §Changelog SHALL gain a v0.13 entry recording the addition.

### Core card
- R4. `core/CLAUDE.md` SHALL gain a one-line pointer to principle 10 (its own short
  entry or an existing discipline section), citing `.lsa/VISION.md` §2 by link — the
  card RESTATES no rule text it does not own (packaging-only, per the card's own header).

### Lint probe
- R5. `scripts/lint.sh` SHALL gain check C15 that PASSES iff a stable marker for
  principle 10 is present in `.lsa/VISION.md` AND `core/CLAUDE.md` references it;
  it FAILS (exit 1, one line per missing surface) if either is absent — a
  silent-deletion / regression guard, mirroring C6 (`lint.sh:153-164`).
- R6. C15 SHALL be a presence guard only. Detecting whether a *new* skill reintroduced
  inline determinism is explicitly OUT of C15's scope (a judgment, not a grep — fragile
  matching is banned per the doc-lint gate's own R2). That judgment stays with
  reconcile / human review.
- R7. C15 SHALL match `lint.sh` style — bash 3.2-safe, `pass_line`/`fail_line`, grep+git
  only, no new deps — and SHALL pass clean on the current tree after R1–R4 land.

### Versioning + hygiene
- R8. `core` SHALL bump SemVer (MINOR — new always-on discipline pointer on the card;
  target read from `core/.claude-plugin/plugin.json`) with a CHANGELOG entry, and the
  relevant README(s) SHALL update if the user-visible discipline surface changed.
- R9. `.lsa/VISION.md` (constitution) and `scripts/lint.sh` (repo-level gate, outside
  every plugin's `artifact_paths` per `.lsa.yaml:52-104`) SHALL trigger NO plugin
  SemVer bump on their own — only the `core/CLAUDE.md` edit drives the core bump (R8).

## Acceptance scenarios (Gherkin)

```gherkin
Feature: Codify deterministic-work-is-scripted

  Scenario: The principle is present and the gate passes
    Given ".lsa/VISION.md" §2 contains principle 10 "deterministic work is scripted"
    And "core/CLAUDE.md" references principle 10
    When "bash scripts/lint.sh" runs
    Then check C15 passes
    And "bash scripts/lint.sh" exits 0

  Scenario: Deleting the principle trips the guard
    Given the principle-10 marker is removed from ".lsa/VISION.md"
    When "bash scripts/lint.sh" runs
    Then C15 prints a FAIL line naming ".lsa/VISION.md" as the missing surface
    And "bash scripts/lint.sh" exits 1

  Scenario: The card carries the principle every session
    Given "core/CLAUDE.md" is the merged always-on card
    When a contributor loads it
    Then it shows a one-line pointer to principle 10 citing ".lsa/VISION.md" §2
```

## Out of Scope

- Any new deterministic-work script (coverage-skeleton / resolve-refs / hygiene
  classes) — those are the three following epics; this epic only names the principle.
- A probe that detects new inline determinism in skills (R6 — fragile; stays judgment).
- Retro-editing the scattered enforcement prose (`.lsa.yaml:13`, fast-path, etc.) to
  point back at principle 10 — one-line cross-refs may be added later, not required here.
