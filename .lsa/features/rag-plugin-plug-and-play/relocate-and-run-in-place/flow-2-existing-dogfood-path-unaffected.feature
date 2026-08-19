Feature: claude-marketplace's own existing RAG setup is unaffected by the relocation

  Scenario: Root-level gate checks pass exactly as before
    Given scripts/check-rag-index-fresh.sh and scripts/check-rag-index-matches-head.sh at their current root-level location, per .lsa.yaml's gate: block
    When bash scripts/gate.sh is run before and after this epic's changes
    Then both rag-index-fresh and rag-index-matches-head report the same result in both runs
