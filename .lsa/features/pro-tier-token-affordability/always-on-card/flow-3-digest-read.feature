Feature: LSA read protocol consumes the constitution digest
  Scenario: Ordinary LSA skill start
    Given .lsa.yaml configures the constitution                      # fact: .lsa.yaml:5
    And a digest deterministically derived from it exists            # F6
    When any LSA skill begins its read protocol
    Then the read-summary cites the digest as the constitution read  # F4
    And the digest trace line prints                                 # F8

  Scenario: Stale digest fails the gate
    Given the constitution was edited after digest generation
    When bash scripts/lint.sh runs
    Then it exits non-zero naming the stale digest                   # F5
