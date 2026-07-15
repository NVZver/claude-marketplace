Feature: project-map-check freshness gate
  As a repo owner
  I want CI to fail when project-map.yaml is stale
  So the atlas stays honest without silent auto-commits

  Scenario: Check passes only when rebuild is a no-op against git
    Given project-map.yaml is committed and matches a fresh rebuild
    When I run bash lsa/scripts/project-map-check.sh
    Then the check exits 0                                                 # F5, AC2

  Scenario: Check fails when the tree changed without updating the map
    Given a new tracked file at depth ≤ 3 was committed without refreshing the map
    When I run bash lsa/scripts/project-map-check.sh
    Then the check rebuilds the map and exits non-zero                     # F5, AC2
    And the message names committing the refreshed project-map.yaml
