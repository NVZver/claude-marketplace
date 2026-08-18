Feature: Path-scoped vector query is a real pre-filter
  # Requirements: R1, R2, R5 — requirements.md

  Scenario: --path filters to only chunks under that prefix, ranked within the subset
    Given a repo indexed with chunks both inside and outside a given directory prefix
    And a query whose single best whole-corpus match lies OUTSIDE that prefix
    When "rag_cli.py query --path <prefix>" is run
    Then no result outside the prefix appears
    And results are ranked by similarity within the filtered subset, not truncated
      from an already-limited whole-corpus top-K

  Scenario: No --path is unchanged from before this epic
    Given the same query run with and without "--path"
    When "--path" is omitted
    Then the result is byte-for-byte identical to the pre-epic query behavior

  Scenario: A path with no relevant content reports an ordinary miss
    Given "--path" set to a directory with no chunk clearing the similarity floor
    When "rag_cli.py query --path <prefix>" is run
    Then the result is "{"results": []}", exit 0 — the same miss contract as epic 1's R4
