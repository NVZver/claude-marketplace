Feature: Deterministic project-map.yaml generation
  As an LSA user on any repo
  I want a script-generated 3-level project-map.yaml
  So discover can scope reads without walking the whole tree

  Scenario: Build is deterministic and depth-bounded
    When I run bash lsa/scripts/project-map-build.sh twice
    Then both outputs are byte-identical                                    # F1, AC1
    And paths deeper than 3 levels do not appear as leaves                 # F3, AC1
    And depth-3 parents of deeper paths are tagged dir                     # F3, AC1
    And the map opens with GENERATED — DO NOT EDIT                         # F2, AC5
    And the map does not list project-map.yaml in tree                     # F2, AC5
