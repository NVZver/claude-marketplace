Feature: Sha-pinned query filtering
  # Requirements: R1, R2 — requirements.md

  Scenario: Unchanged path since the graded sha is kept
    Given a file has not changed between commit "<sha>" and HEAD
    And that file is a candidate match for a query
    When "scripts/rag-query.sh --sha <sha> \"<query>\"" is run
    Then the result for that path is kept

  Scenario: Changed path since the graded sha is discarded
    Given a file HAS changed between commit "<sha>" and HEAD
    And that file would otherwise be a candidate match for a query
    When "scripts/rag-query.sh --sha <sha> \"<query>\"" is run
    Then the result for that path is discarded
    And other unaffected paths in the same query are unaffected

  Scenario: Unresolvable sha reports an ordinary miss, not a fault
    Given "<sha>" does not resolve to a valid commit
    When "scripts/rag-query.sh --sha <sha> \"<query>\"" is run
    Then the result is the same empty-result contract as an ordinary miss
    And it is not reported as Docker-unreachable
