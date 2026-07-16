Feature: Human-readable roadmap view

  Scenario: Pretty-print to stdout
    Given .lsa/roadmap.yaml is the source-of-truth
    When scripts/roadmap-print.sh runs
    Then a readable roadmap table is printed to stdout
    And no second source-of-truth file is created
