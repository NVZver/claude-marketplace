Feature: Always-on discipline from a single card
  Scenario: Substantive task under card-only discipline
    Given a project CLAUDE.md carrying the merged always-on card    # fact: core/CLAUDE.md:5 (opt-in fragment)
    And the card is at most 45 lines                                 # F1
    When the agent answers a substantive question with factual claims
    Then every claim carries a source and a searchable quote         # card hard rule, ground-rules Rule 1
    And the response prints the card's file-load trace line          # F8
    And no full discipline SKILL.md has been loaded                  # F2
