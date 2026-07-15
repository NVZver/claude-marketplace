Feature: Discover consults project-map.yaml
  As an agent running lsa:discover
  I want the read protocol to name project-map.yaml
  So I open the atlas before walking the tree

  Scenario: Read protocol and discover Step 1 name the map
    When I open lsa/knowledge/conventions.md section Read protocol
    And I open lsa/skills/discover/SKILL.md Step 1
    Then both name project-map.yaml as the scoping atlas                   # F6, AC3
    And an absent map falls back to a tree-walk                            # F7
