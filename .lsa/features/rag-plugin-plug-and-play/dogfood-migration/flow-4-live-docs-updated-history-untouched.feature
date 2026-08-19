Feature: Live docs updated to the new paths; historical records left alone

  Scenario: Living docs reference lsa/scripts/*, history stays as-is
    Given README.md, CONTRIBUTING.md, SECURITY.md, lsa/knowledge/conventions.md, and lsa/skills/discover|verify|reconcile/SKILL.md reference the old root-level paths
    And .lsa/features/**, .lsa/observations/**, and .lsa/pitches/** are historical, point-in-time records
    When the cutover is committed
    Then every live doc above references the new lsa/scripts/* locations
    And no file under .lsa/features/, .lsa/observations/, or .lsa/pitches/ is modified
