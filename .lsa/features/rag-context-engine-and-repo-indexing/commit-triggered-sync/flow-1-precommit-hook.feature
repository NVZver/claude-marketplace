Feature: Pre-commit hook keeps the index current
  # Requirements: R1, R2 — requirements.md

  Scenario: Hook updates the index on commit
    Given "core.hooksPath" is set to ".githooks"
      (git config core.hooksPath — .git/hooks/ has no non-sample hooks per discover)
    And a tracked Markdown file with H2 headings is modified
    When the change is committed
    Then "scripts/rag-index.sh" has been run scoped to that file
    And the index reflects the new content

  Scenario: Hook failure does not block the commit
    Given "core.hooksPath" is set to ".githooks"
    And the Docker daemon is unreachable
    When a change is committed
    Then the commit succeeds
    And a warning is printed noting the index was not updated
