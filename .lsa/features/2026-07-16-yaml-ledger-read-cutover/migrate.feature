Feature: Roadmap ledger migration (MD → YAML, lossless, single SoT)

  Scenario: Every backlog row migrates with full notes preserved
    Given the former .lsa/roadmap.md (378 lines) has a "## Feature Backlog" table with paragraph-length Notes
    When the one-shot migrator runs
    Then .lsa/roadmap.yaml has one items entry per backlog row
    And each entry's notes field contains that row's full Notes text verbatim

  Scenario: Backlog-detail appendix sections are preserved losslessly
    Given the former roadmap has dated "backlog detail" sections and a "Tech Picture adoption" section documenting specific backlog items
    When the migrator runs
    Then each section's content is preserved verbatim in .lsa/roadmap.yaml (associated with its item, or under a preserved appendix)
    And no section content is dropped

  Scenario: Recently-merged rows become shipped_history
    Given the former roadmap has a "## Recently merged" section
    When the migrator runs
    Then those rows appear under shipped_history and are not loaded by default

  Scenario: The markdown source-of-truth is removed
    Given .lsa/roadmap.yaml has been written
    When the migration completes
    Then .lsa/roadmap.md no longer exists
