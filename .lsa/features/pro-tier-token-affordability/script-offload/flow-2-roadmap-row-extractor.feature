Feature: manager:next extracts the first backlog row via a script
  Scenario: The extractor prints the first backlog row with its citation
    Given .lsa/roadmap.md has a ## Feature Backlog table                      # F2
    When bash scripts/roadmap-row.sh runs                                     # F2
    Then it prints the first backlog/not-started row with its path:line       # F2, AC2
    And it exits 0                                                            # F2, AC2

  Scenario: manager:next Step 0 uses the extractor with a model-side fallback
    Given the repo provides scripts/roadmap-row.sh                           # F5
    When manager:next answers a plain "what's next"                          # F5
    Then Step 0 runs the extractor and quotes its output                      # F5, AC3
    And a repo without the extractor locates the row model-side               # F5, AC3

  Scenario: No backlog row falls through, never crashes
    Given the roadmap has no backlog/not-started row (or no anchor)          # F7
    When bash scripts/roadmap-row.sh runs                                     # F7
    Then it exits non-zero so the skill falls through to model-side           # F7, AC5
