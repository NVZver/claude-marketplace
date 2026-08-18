Feature: Hybrid dense + lexical retrieval
  # Requirements: R1-R5 — requirements.md

  Scenario: A lexical-only match (dense embedding misses) is now found
    Given a chunk contains the exact query terms literally
    And the chunk's dense-vector similarity to the query does not clear the
      similarity floor on its own
    When a hybrid query is run
    Then the chunk is returned, surfaced via the full-text signal

  Scenario: An existing dense-only win still passes (no regression)
    Given a query whose best match was already found by dense search alone
      in the original eval (P1, P3, P4, P8, or P9)
    When the same query is run under hybrid search
    Then the same correct chunk is still returned

  Scenario: Semantic judgment of an incidental lexical match is preserved (no regression)
    Given a document containing an incidental, contextually-unrelated literal
      keyword match (the P12 case)
    When a query about that keyword's real subject is run under hybrid search
    Then the incidental match is not promoted above genuinely relevant results
      on lexical presence alone

  Scenario: --path and the empty-miss contract still hold under hybrid search
    Given "--path <prefix>" is set to a directory with no relevant content
    When a hybrid query is run
    Then the result is "{"results": []}", exit 0 — the same miss contract as before
