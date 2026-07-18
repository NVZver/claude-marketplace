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
