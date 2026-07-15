Feature: Dispatch resolves and echoes the routed tier
  Scenario: A mechanical dispatch runs on the cheapest tier
    Given .lsa.yaml routing maps manager:check to haiku                    # F2, D3
    When manager:check dispatches the project-manager agent                # F3
    Then the Agent model parameter is haiku                                # F3, AC2
    And the dispatch line names tier: haiku                                # F6, AC2

  Scenario: Absent key degrades to inherit, never a hard error
    Given .lsa.yaml has no routing entry for the surface                   # F4
    When the skill dispatches the agent
    Then the dispatch resolves to inherit                                  # F4, AC3
    And no hard error blocks the dispatch                                  # F4

  Scenario: No model pin ships in frontmatter
    Given the routing tiers live only in .lsa.yaml                         # F2
    When bash scripts/lint.sh runs
    Then C8 stays green with zero opus/haiku/fable frontmatter pins        # F2, AC5
