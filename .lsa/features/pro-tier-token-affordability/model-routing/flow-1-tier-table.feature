Feature: Documented per-dispatch tier table
  Scenario: Every dispatch surface carries a documented tier
    Given the shipped knowledge file lsa/knowledge/model-routing.md        # F1
    When the owner reads the tier table
    Then every marketplace Agent-dispatch surface appears as a row         # F1, AC1
    And each row names its tier, cite, and rationale                       # F1
    And transitional surfaces are marked distinctly from the durable classes # F7
    And the file prints its file-load trace line                          # F8
