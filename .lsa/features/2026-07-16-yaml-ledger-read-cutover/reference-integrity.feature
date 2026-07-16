Feature: Reference integrity after markdown deletion

  Scenario: No dangling literal path reference
    Given .lsa/roadmap.md has been deleted
    When bash scripts/check-links.sh and bash scripts/check-citations.sh run
    Then both exit 0

  Scenario: Format citation rewritten to the schema
    Given manager/knowledge/sequencing-heuristics.md:9 cited the markdown table format
    When the sweep completes
    Then that citation names the YAML schema instead

  Scenario: No live markdown reference remains in manager/
    Given the sweep is complete
    When grep for roadmap.md across manager/ runs
    Then no live (non-historical) reference is returned
