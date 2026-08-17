Feature: RAG queried within project-map scope before falling back
  # Requirements: R1, R2, R3 — requirements.md

  Scenario: Good match — RAG used directly, no whole-file read
    Given "project-map.yaml" has resolved a directory scope for the request
      (lsa/knowledge/conventions.md:37 — locate the directory, then read files under it)
    And the RAG index is warm and has a good match for the query
    When "lsa:discover" (or "lsa:verify"'s feasibility step) searches for content
    Then "scripts/rag-query.sh" is called before any Grep or whole-file Read
      for that content
    And the cited chunk is used directly

  Scenario: Miss, stale, or unavailable — falls back exactly as before
    Given the RAG index is absent, stale, or the Docker daemon is unreachable
    When "lsa:discover" (or "lsa:verify") searches for content within a
      project-map-resolved scope
    Then the search falls back to Grep/Read
    And a one-line notice records that the fallback path was used
    And the end result is unchanged from pre-epic behavior
