Feature: Existing structural gate invariants unregressed by the rewrite

  Scenario: bash scripts/gate.sh stays green after the rewrite
    Given ".lsa.yaml" configures a gate: block covering docs-invariants (including lint checks C4, C5, C7, C9), citations, links, project-map, tests, lib-pins
    When "bash scripts/gate.sh" runs against the reworded tree
    Then it exits 0
