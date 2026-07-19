Feature: Deterministic harvest of the three tracked metrics from one conformance.md

  Background:
    Given the script "scripts/metrics-harvest.sh" exists and is executable
    And it makes zero model calls and no network requests

  Scenario: Canonical conformance file yields all three metrics
    Given a conformance.md containing the line "Orphan hunks: none."
    And a requirement-hunk coverage table with 4 rows keyed F1..F4, 3 of them "✅"
    When "bash scripts/metrics-harvest.sh <that file>" runs
    Then line 1 starts with "feature: "
    And line 2 starts with "only-required-changes: " and its value is "<N>/<N>"
    And line 3 is "accuracy-to-task: 3/4"
    And line 4 starts with "citation-resolve-rate: " and ends with "(PROXY — resolve-rate, not quote integrity)"
    And it exits 0

  Scenario: Orphans are subtracted from the candidate-hunk denominator
    Given a conformance.md containing the line "Orphan hunks: 3"
    And "bash scripts/coverage-skeleton.sh <feature-dir>" lists 10 candidate hunks
    When the script runs
    Then "only-required-changes: 7/10" is printed
    And it exits 0

  Scenario: Non-canonical orphan line is reported UNPARSEABLE, never guessed
    Given the real file ".lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md"
    And its orphan section is the prose heading "## Orphan hunks (over-delivery vs F1–F13)"
    When "bash scripts/metrics-harvest.sh .lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md" runs
    Then the only-required-changes line contains "UNPARSEABLE"
    And it contains the reason "(non-canonical orphan-hunk line)"
    And no numeric M/N is emitted for only-required-changes
    And the accuracy-to-task line still prints an M/N value
    And the citation-resolve-rate line still prints an M/N value
    And the historical file is left byte-for-byte unchanged
    And it exits 0

  Scenario: Citation metric is derived from check-citations.sh and labelled a proxy
    Given "bash scripts/check-citations.sh" prints "FAIL 2 broken citation(s) of 50 checked"
    When the script runs
    Then "citation-resolve-rate: 48/50  (PROXY — resolve-rate, not quote integrity)" is printed
    And the string "citation density" appears nowhere in the script or its output

  Scenario: Multiple canonical orphan lines are ambiguous, not averaged
    Given a conformance.md containing both "Orphan hunks: none." and "Orphan hunks: 2"
    When the script runs
    Then the only-required-changes line contains "UNPARSEABLE"

  Scenario: Missing argument is a usage error
    Given no arguments
    When "bash scripts/metrics-harvest.sh" runs
    Then it prints "metrics-harvest: usage: metrics-harvest.sh <conformance.md> [git-diff-args…]" to stderr
    And it exits non-zero

  Scenario: Missing file is an input error
    Given the path "does/not/exist/conformance.md"
    When the script runs with that path
    Then it prints "metrics-harvest: no such file: does/not/exist/conformance.md" to stderr
    And it exits non-zero

  Scenario: The harvest never writes
    Given any valid invocation
    When the script runs
    Then ".lsa/metrics.md" is unchanged
    And no file in the working tree is created or modified

  Scenario: The test is wired into the gate
    When "bash scripts/run-tests.sh" runs
    Then its output contains "PASS  metrics-harvest-test.sh"
    And "bash scripts/gate.sh" exits 0
