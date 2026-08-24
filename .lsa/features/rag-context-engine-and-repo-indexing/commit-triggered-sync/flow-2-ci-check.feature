Feature: CI catches a skipped or bypassed pre-commit hook
  # Requirements: R3, R4 — requirements.md

  Scenario: CI passes when the index matches HEAD
    Given a commit whose pre-commit hook successfully updated the index
      for every changed file
    When the index-matches-HEAD CI check runs
    Then it exits 0

  Scenario: CI fails when the hook was bypassed
    Given a commit made with "git commit --no-verify" (hook skipped)
    When the index-matches-HEAD CI check runs
    Then it exits non-zero
