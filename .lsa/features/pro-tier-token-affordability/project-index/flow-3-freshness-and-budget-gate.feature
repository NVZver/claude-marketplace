Feature: Lint enforces index freshness and the token budget
  Scenario: A stale index fails the freshness gate
    Given a tracked markdown file was added or an H1 changed              # F5
    And .lsa/PROJECT-index.md was not regenerated                         # F5
    When bash scripts/lint.sh runs                                        # F5
    Then the freshness check FAILs naming bash scripts/build-index.sh      # F5, AC3
    And regenerating the index makes the check PASS                        # F5, AC3

  Scenario: The token budget is a gate, not advice
    Given the committed .lsa/PROJECT-index.md                             # F3
    When bash scripts/lint.sh runs                                        # F3
    Then the budget check prints the token estimate (chars / 4)            # F3, D4
    And it PASSes only when the estimate is <= 1000 tokens                 # F3, AC2

  Scenario: A missing index is caught
    Given .lsa/PROJECT-index.md is absent                                 # F5
    When bash scripts/lint.sh runs                                        # F5
    Then the freshness check FAILs naming the regeneration command         # F5
