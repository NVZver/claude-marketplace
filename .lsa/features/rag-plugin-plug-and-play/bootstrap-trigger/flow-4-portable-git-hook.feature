Feature: The portable git hook works from a shared plugin location

  Scenario: A real commit in the target repo triggers the correct reindex
    Given core.hooksPath points at lsa/hooks/ (the plugin's shared location)
    And lsa/hooks/pre-commit self-locates its sibling lsa/scripts/rag-index.sh
    When a file is staged and committed in the target repo
    Then the target repo's own index is updated, not some other repo's
