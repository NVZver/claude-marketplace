Feature: Stale-image detection and gitignore-aware exclusion
  # Requirements: R1-R6 — requirements.md

  Scenario: A source change triggers a real rebuild
    Given "docker/rag_cli.py" has changed since the current image was built
    When "scripts/rag-index.sh" is invoked
    Then the image is rebuilt with --no-cache
    And the new image is tagged with the current source hash

  Scenario: No source change skips the rebuild
    Given the current image's source-hash label matches the current source
    When "scripts/rag-index.sh" is invoked
    Then no rebuild is triggered

  Scenario: Gitignored content is excluded dynamically, not just by hardcoded name
    Given ".claude/worktrees/" and ".DS_Store" are gitignored but not in SKIP_DIR_NAMES
    When the index is built
    Then neither appears in the resulting index

  Scenario: Existing exit-code contracts are unchanged
    Given the Docker daemon is unreachable
    When "scripts/rag-index.sh" or "scripts/rag-query.sh" is invoked
    Then it still exits 2 with the distinct "Docker daemon unreachable" message
