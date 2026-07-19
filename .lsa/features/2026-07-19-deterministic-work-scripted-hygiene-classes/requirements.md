# Hygiene classes — close the model-side roadmap scan

## Summary

Close the last two model-side conditions in the roadmap hygiene scan. `roadmap-query.sh
hygiene` today emits 3 deterministic hint classes; `project-manager.md` Step 6 lists 4
conditions, so conditions 3–4 (merged-but-not-shipped, no-activity) are still model
judgment. This epic scripts both — the agent then applies judgment over hints only.

- Source: discover handoff 2026-07-17 (deterministic-work sweep, epic 4 of 4).
- Applies: `.lsa/VISION.md` §2 principle 10.
- Target surfaces: `scripts/roadmap-query.sh` (`hygiene` awk block, classes 1–3) and
  `manager/agents/project-manager.md:49-53` (Step 6's four conditions).
- Grounded schema: items carry `slug · title · priority · status · status_detail · notes`
  — **no date/updated field** (see R3).

## User Flows

1. **Roadmap hygiene check (`manager:check`).** The user runs `manager:check`; the
   project-manager starts from `roadmap-query.sh hygiene`, which now emits all five hint
   classes deterministically. The agent applies judgment over the hints and proposes row
   diffs; the skill gates each one.
2. **Author runs it directly.** `bash scripts/roadmap-query.sh hygiene` prints every hint
   with a `roadmap:line — slug — HINT: …` citation; exit 0 when the ledger loads.

## Functional requirements (EARS)

### New hint classes
- R1. `hygiene` SHALL add class **merged-not-shipped**: when a branch `feature/<slug>` is
  merged into the default branch (`git branch --merged`) and the item's status is not
  `shipped`, it SHALL emit a hint naming `roadmap:line`, the slug, the merged branch, and
  the current status.
- R2. `hygiene` SHALL add class **no-artifacts**: for an actionable item (`backlog`,
  `not_started`, or `in_progress`) where NONE of `feature/<slug>` branch,
  `${specs_root}/features/*<slug>*` directory, or `${specs_root}/pitches/<slug>.md` exists,
  it SHALL emit a hint to classify the item as deferred or active.
- R3. True recency ("no recent activity", `manager/agents/project-manager.md:53`) is
  **OUT OF SCOPE** — the item schema carries no date/updated field, so staleness is not
  deterministically derivable. Class 5 is the artifact-existence proxy; the deferred/active
  call stays the human's. This limitation SHALL be stated in the script header AND in the
  agent's Step 6, so no reader mistakes the proxy for a recency check.

### Preservation
- R4. Classes 1–3 SHALL be unchanged; multiple hints per row SHALL remain allowed; the
  `no deterministic mismatches found` line SHALL still print when there are zero hits; exit
  SHALL stay 0 when the ledger loads.
- R5. The implementation SHALL extend the existing awk pipeline in
  `scripts/roadmap-query.sh` — bash 3.2-safe, git+awk only, no new deps, and SHALL NOT
  introduce a whole-file model read of the ledger.

### Wiring
- R6. `manager/agents/project-manager.md` Step 6 SHALL attribute conditions 3–4 to the
  script (the hints now come from `roadmap-query.sh hygiene`), so no condition is described
  as model-derived when the script emits it. The agent's judgment-over-hints role and its
  propose-then-gate contract SHALL be unchanged.

### Test + versioning
- R7. `scripts/tests/roadmap-query-hygiene-test.sh` SHALL cover hermetically: class 4 fires
  (merged branch + non-shipped status); class 4 silent when status is `shipped`; class 5
  fires (zero artifacts); class 5 silent when a pitch file (or feature dir, or branch)
  exists; and a classes 1–3 regression. A hermetic fixture is required — the live tree has
  no merged branch matching a roadmap slug, so class 4 cannot be proven on real data.
- R8. `manager` SHALL bump SemVer (0.18.0 → 0.19.0, MINOR — new agent-visible hint classes)
  + CHANGELOG + README if the user-visible surface changed. `scripts/roadmap-query.sh` and
  the test are repo-level (outside every `artifact_paths`); only the `project-manager.md`
  edit drives the `manager` bump.
- R9. `bash scripts/gate.sh` SHALL exit 0 after the change.

## Acceptance scenarios (Gherkin)

```gherkin
Feature: Deterministic hygiene classes 4 and 5

  Scenario: A merged branch on a non-shipped item is flagged
    Given a roadmap item "alpha" with status "in_progress"
    And a branch "feature/alpha" merged into the default branch
    When "bash scripts/roadmap-query.sh hygiene" runs
    Then it prints a merged-not-shipped hint naming "alpha" and its status

  Scenario: A merged branch on a shipped item is silent
    Given a roadmap item "beta" with status "shipped"
    And a branch "feature/beta" merged into the default branch
    When hygiene runs
    Then it prints no merged-not-shipped hint for "beta"

  Scenario: An item with zero artifacts is flagged for classification
    Given a roadmap item "gamma" with status "backlog"
    And no feature/gamma branch, no features dir matching gamma, no pitches/gamma.md
    When hygiene runs
    Then it prints a no-artifacts hint naming "gamma"

  Scenario: An item with a pitch file is not flagged as no-artifacts
    Given a roadmap item "delta" with status "backlog"
    And a file "pitches/delta.md" exists
    When hygiene runs
    Then it prints no no-artifacts hint for "delta"

  Scenario: Existing classes still fire
    Given an in_progress item with no matching feature branch
    When hygiene runs
    Then it still prints the stale-in-progress hint (class 3 regression)
```

## Out of Scope

- Recency/staleness by date (R3 — no date field in the schema).
- Any change to `manager:check`'s gate loop or the agent's propose-then-gate contract.
- Auto-applying hygiene fixes — hints only; the human still approves every row diff.
