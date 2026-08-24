Feature: Widened pre-fusion candidate pool gives canonical chunks a fair chance

  Scenario: SP4's total-miss shape is addressed by widening, not just boosting
    Given docker/rag_cli.py:594 currently caps the vector sub-query at TOP_K=5 candidates before fusion
    And docker/rag_cli.py:608-609 currently trims the FTS sub-query to TOP_K=5 before fusion
    And stress-report.md Part 2 SP4 shows a total miss (unrelated top-3), consistent with the correct chunk not being a raw top-5 candidate on either side
    When CANDIDATE_K (R2) replaces TOP_K at both pre-fusion limits
    Then the final response to scripts/rag-query.sh still returns exactly TOP_K=5 results (R3)
    And the SP4 canonical chunk is present in the fused candidate set before the final TOP_K slice
