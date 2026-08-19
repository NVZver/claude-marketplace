Feature: An unconfigured repo defaults safely, but loudly

  Scenario: No rag: canonical_paths: block -> safe default + visible notice
    Given a scratch repo whose .lsa.yaml has no rag: canonical_paths: block at all
    When the scratch repo is indexed via lsa/scripts/rag-index.sh
    Then /index/.canonical-paths.txt is empty and every chunk classifies as "historical"
    And an explicit one-line notice naming the seed script is printed to stderr
