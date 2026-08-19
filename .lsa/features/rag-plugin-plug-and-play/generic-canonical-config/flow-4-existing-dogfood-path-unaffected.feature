Feature: claude-marketplace's own existing setup is unaffected

  Scenario: Root-level gate checks pass exactly as before
    Given docker/rag_cli.py (root-level, unmodified) and this repo's own .lsa.yaml (no rag: block) are untouched by this epic
    When bash scripts/gate.sh is run before and after this epic's changes
    Then rag-index-fresh and rag-index-matches-head report the same result in both runs
