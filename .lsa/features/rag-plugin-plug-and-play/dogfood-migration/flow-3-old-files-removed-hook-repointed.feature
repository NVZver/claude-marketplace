Feature: Root-level RAG files removed; local git hook repointed

  Scenario: Superseded files are gone, core.hooksPath points at the plugin
    Given Dockerfile, docker/rag_cli.py, scripts/rag-index.sh, scripts/rag-query.sh, scripts/check-rag-index-fresh.sh, scripts/check-rag-index-matches-head.sh, and .githooks/pre-commit are fully superseded by epics 1-3's plugin-shipped equivalents
    When the cutover is committed
    Then none of the seven old files exist in the working tree
    And git config core.hooksPath points at lsa/hooks
