Feature: One skill invocation bootstraps everything, unattended

  Scenario: Running the bootstrap skill leaves a fully working setup
    Given a scratch repo with .lsa.yaml present (modules: block from lsa:init), Docker installed, not yet bootstrapped
    When lsa:bootstrap-rag is invoked against that repo
    Then a working plugin-shipped image exists
    And a fresh index exists at that repo's .lsa/.rag-index/
    And git config core.hooksPath points at the plugin's own hooks directory
    And .lsa.yaml's gate: block contains rag-index-fresh and rag-index-matches-head entries
    And .lsa.yaml's rag: canonical_paths: block is seeded
    And .gitignore contains an entry for .lsa/.rag-index/
