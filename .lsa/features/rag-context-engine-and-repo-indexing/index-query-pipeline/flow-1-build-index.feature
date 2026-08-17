Feature: Build or update the local RAG index
  # Requirements: R1, R2, R5 — requirements.md

  Scenario: Index a directory with the Docker daemon reachable
    Given the Docker daemon is running
    And a directory containing at least one Markdown file with H2 headings
    When "scripts/rag-index.sh" is invoked against that directory
    Then the local vector index under ".lsa/.rag-index/" contains an entry
      for each H2-bounded chunk in that file
    And no network call was made during embedding

  Scenario: Re-running the index build skips unchanged chunks
    Given a directory already indexed by "scripts/rag-index.sh"
    And no file in that directory has changed
    When "scripts/rag-index.sh" is invoked against the same directory again
    Then no chunk is re-embedded

  Scenario: Docker daemon unreachable during a build
    Given the Docker daemon is stopped or unset
    When "scripts/rag-index.sh" is invoked
    Then the script exits with a status distinct from success and from an
      ordinary retrieval miss
    And the reported fault names "Docker daemon unreachable"
