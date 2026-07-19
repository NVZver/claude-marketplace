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
