Feature: gate: and CI point at the new location, verified green throughout

  Scenario: No red window across the cutover
    Given bash scripts/gate.sh reports rag-index-fresh and rag-index-matches-head as PASS before any change
    When .lsa.yaml's gate: block and .github/workflows/lint.yml are updated to lsa/scripts/* paths
    Then bash scripts/gate.sh reports rag-index-fresh and rag-index-matches-head as PASS immediately after
    And the gate: commands use plain repo-relative paths, not $CLAUDE_PLUGIN_ROOT, since this repo is the marketplace checkout itself and CI never sets that variable
