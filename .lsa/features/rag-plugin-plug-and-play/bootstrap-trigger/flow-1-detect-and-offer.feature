Feature: Docker present and not yet bootstrapped triggers a fast, one-line offer

  Scenario: Offer fires within the hook's timeout budget
    Given a scratch repo with .lsa.yaml present (lsa:init already run) and no rag-index-fresh entry in its gate: block
    And docker is installed and reachable
    When the SessionStart detection script runs
    Then it prints exactly one line offering the lsa:bootstrap-rag skill
    And it completes well within its declared timeout
