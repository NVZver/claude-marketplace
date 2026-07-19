Feature: Reconcile emits a metrics row, and C17 proves the emit step cannot be dropped silently

  Background:
    Given "scripts/metrics-harvest.sh" exists (delivered by epic 1)
    And "scripts/lint.sh" currently ends at check C15
    And C16 is reserved by standards-conformance-agents-md/agents-md-canonical

  Scenario: Machine-readable orphan line in the reconcile output contract
    Given "lsa/skills/reconcile/SKILL.md" §Output
    When the contract is read
    Then it specifies exactly one line of the form "Orphan hunks: none." or "Orphan hunks: <integer>"
    And it states that a prose heading such as "## Orphan hunks (over-delivery vs F1–F13)" does not satisfy the contract
    And the synthetic coverage-table example shows the canonical line

  Scenario: A PASS cycle appends one row to the ledger
    Given reconcile has written conformance.md with verdict "reconcile: PASS @ <sha>"
    When the metrics emit step runs
    Then "bash scripts/metrics-harvest.sh <feature-dir>/conformance.md" is executed and its output quoted
    And exactly one row is appended to ".lsa/metrics.md" using the six-column schema
    And an UNPARSEABLE metric is written verbatim as "UNPARSEABLE" in its column

  Scenario: A FAIL cycle appends nothing
    Given reconcile's verdict is FAIL
    When the cycle completes
    Then no row is appended to ".lsa/metrics.md"

  Scenario: Measurement never becomes a gate
    Given "scripts/metrics-harvest.sh" exits non-zero or emits UNPARSEABLE for every metric
    When reconcile would otherwise return PASS
    Then the verdict is still PASS
    And the harvest failure is recorded in the row's Notes column

  Scenario: C17 passes on the intact repo
    When "bash scripts/lint.sh" runs
    Then the output contains a "PASS" line naming C17 and "scripts/metrics-harvest.sh"
    And the output contains a "PASS" line naming C17 and ".lsa/metrics.md"

  Scenario: NEGATIVE CONTROL — deleting the emit step turns the gate red
    Given "lsa/skills/reconcile/SKILL.md" has been backed up with a restoring EXIT trap
    And every line containing "scripts/metrics-harvest.sh" is removed from it
    And every line containing ".lsa/metrics.md" is removed from it
    When "bash scripts/lint.sh" runs
    Then the output contains a "FAIL" line naming C17
    And the FAIL text names the regression ("metrics writer dropped again — see lsa 0.16.0")
    And "scripts/lint.sh" exits non-zero

  Scenario: NEGATIVE CONTROL — restoration returns the gate to green
    Given the negative-control mutation has been reverted from the backup
    When "bash scripts/lint.sh" runs
    Then the C17 lines are PASS again
    And the working tree is byte-for-byte identical to before the test

  Scenario: The falsification test is wired into the gate
    When "bash scripts/run-tests.sh" runs
    Then its output contains "PASS  metrics-emit-guard-test.sh"
    And "bash scripts/gate.sh" exits 0

  Scenario: Ledger schema names the proxy honestly
    Given ".lsa/metrics.md"
    When its schema note is read
    Then the citation column is named "Citation resolve-rate"
    And the note states it proves the citation points at a real line, not that the quote is intact
    And the string "citation density" does not appear
    And the "Pass/fail counts only — no statistical eval" note is retained
    And the two 2026-05-21 rows are present and marked pre-contract

  Scenario: The constitution clarification is owner-gated, not self-applied
    Given ".lsa/VISION.md" §5 describes the three metrics as personally measured
    When the implementer reaches the constitution requirement
    Then it drafts a one-line clarification that the metrics are measured per LSA cycle from artifacts
    And it surfaces that wording as a pending gate for the owner via "lsa:revise-constitution"
    And it does not edit ".lsa/VISION.md" directly
    And if the gate is not run the requirement is reported as blocked, not silently applied

  Scenario: Versioning discipline
    Given "lsa/skills/reconcile/SKILL.md" changed and it is inside the lsa artifact_paths
    When the change ships
    Then "lsa/.claude-plugin/plugin.json" reads version "0.29.0"
    And "lsa/CHANGELOG.md" carries a matching entry in the same commit
    And "lsa/README.md" notes that reconcile writes a .lsa/metrics.md row on PASS
    And no other plugin version is bumped
