Feature: Query the local RAG index
  # Requirements: R3, R4, R5 — requirements.md

  Scenario: A known term returns its cited chunk
    Given a directory indexed by "scripts/rag-index.sh"
      (per .lsa.yaml:14-20's gate-contract pattern of a script whose output is cited)
    And that directory contains a file with a distinctive, known term
    When "scripts/rag-query.sh" is invoked with that term
    Then the returned result includes a chunk from that file
    And the chunk carries a "path:start-end" citation

  Scenario: No good match returns an empty result, not a guess
    Given a directory indexed by "scripts/rag-index.sh"
    When "scripts/rag-query.sh" is invoked with a query matching no indexed content
    Then the result is empty
    And the result is not reported as an error

  Scenario: Docker daemon unreachable during a query
    Given the Docker daemon is stopped or unset
    When "scripts/rag-query.sh" is invoked
    Then the script exits with a status distinct from success and from an
      ordinary retrieval miss
    And the reported fault names "Docker daemon unreachable"
