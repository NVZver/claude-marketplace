Feature: rag-index-fresh gate check
  # Requirements: R7 — requirements.md

  Scenario: Gate passes when the daemon is reachable
    Given the Docker daemon is running
    And the gate contract in ".lsa.yaml" (.lsa.yaml:14-20) includes "rag-index-fresh"
    When the "rag-index-fresh" gate check is run
    Then it exits 0

  Scenario: Gate reports [cannot verify] when the daemon is unreachable
    Given the Docker daemon is stopped or unset
    And the gate contract in ".lsa.yaml" includes "rag-index-fresh"
    When the "rag-index-fresh" gate check is run
    Then it exits 2
    And its output is labeled "[cannot verify]", matching the
      "scripts/check-lib-pins.sh" three-outcome convention
