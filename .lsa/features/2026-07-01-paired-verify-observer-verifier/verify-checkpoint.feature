Feature: Checkpoint verification of an implementer increment

  Scenario: Conformant increment auto-clears        # F6,F7,F9
    Given an active checkpoint-verification session riding the self-paced /loop
    And a checkpoint signal naming target requirement F-K with the implementer paused
    And every changed hunk traces to F-K and F-K's scoped scenarios pass
    When the verifier grades the increment
    Then it emits a CLEAR verdict
    And the boundary clears without interrupting the human

  Scenario: Scope-creep blocks on the "only" check   # F7,F10
    Given a checkpoint signal naming target requirement F-K
    And the increment contains a changed hunk that traces to no requirement
    When the verifier grades the increment
    Then it emits a BLOCK verdict naming the untraced hunk as over-delivery
    And the block surfaces to the human before the next task

  Scenario: Broken increment blocks on the "does" check   # F6,F10
    Given a checkpoint signal naming target requirement F-K
    And a scenario mapped to F-K fails
    When the verifier grades the increment
    Then it emits a BLOCK verdict naming the failing scenario

  Scenario: Unbuilt future requirements are not under-delivery   # F8
    Given a checkpoint signal naming target F-K at an early checkpoint
    And requirements after F-K are not yet implemented
    When the verifier grades the increment
    Then it does not flag the unbuilt future requirements
    And the verdict depends only on does·only for F-K

  Scenario: No signal produces a silent cycle        # F4
    Given an active session and no checkpoint signal this cycle
    When the cycle runs
    Then no verdict and no user-facing output are produced

  Scenario: Grading never mutates graded artifacts   # F11
    Given a checkpoint verification in progress
    When the verifier grades the increment
    Then it does not modify the tests, .feature scenarios, or .lsa.yaml gate: config
    And the verdict is emitted as an artifact the implementer could not author
