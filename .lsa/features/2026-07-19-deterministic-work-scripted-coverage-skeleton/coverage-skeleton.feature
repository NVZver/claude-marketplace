Feature: Coverage-skeleton enumeration for reconcile

  Scenario: Enumerate both axes of the coverage table
    Given a feature dir whose requirements.md lists R1..R9
    And 3 files changed since HEAD outside that feature dir
    When "bash scripts/coverage-skeleton.sh <feature-dir>" runs
    Then stdout has a coverage-table skeleton with 9 requirement rows
    And a "Candidate hunks" checklist with the 3 changed files
    And it exits 0

  Scenario: An untracked new file surfaces as a candidate hunk
    Given a new file added to the tree but not yet committed or staged
    When "bash scripts/coverage-skeleton.sh <feature-dir>" runs
    Then that untracked file appears in the "Candidate hunks" checklist

  Scenario: The spec's own files are excluded as hunks
    Given the changed files include "<feature-dir>/requirements.md"
    When the script runs
    Then that spec file is NOT listed as a candidate hunk

  Scenario: Bad input exits non-zero
    Given a feature dir path that does not exist
    When the script runs
    Then it prints a one-line diagnostic
    And it exits non-zero
