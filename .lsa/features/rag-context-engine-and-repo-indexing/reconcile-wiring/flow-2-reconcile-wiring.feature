Feature: reconcile Step 4 queries the graded sha
  # Requirements: R3 — requirements.md

  Scenario: Step 4's semantic mapping queries the graded sha
    Given "lsa:reconcile" is grading a diff at sha "<sha>"
    When Step 4 needs broader context to map a hunk to a requirement
    Then it queries "scripts/rag-query.sh --sha <sha>"
    And falls back to Grep/Read per-path on any discarded/missing result

  Scenario: Zero change to does-only-all logic when RAG is unused or falls back
    Given the RAG index is absent or entirely stale for the graded sha
    When "lsa:reconcile" completes Step 4
    Then the coverage table, orphan-hunk line, and verdict are produced
      exactly as before this epic
