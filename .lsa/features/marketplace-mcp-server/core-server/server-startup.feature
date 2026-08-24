Feature: MCP server startup and primitive registration

  Scenario: Registers a tool per skill and a resource per knowledge file across all three plugins
    Given the repo has 6 SKILL.md files under "core/skills/" (actor-template, doctor, flow-selector, ground-rules, output, reuse-first)
    And the repo has 7 SKILL.md files under "lsa/skills/" (delegate, discover, init, reconcile, revise-constitution, specify, verify)
    And the repo has 5 SKILL.md files under "manager/skills/" (check, decompose, implement, next, shape)
    And the repo has 2 knowledge files under "core/knowledge/", 5 under "lsa/knowledge/", 10 under "manager/knowledge/"
    When the MCP server starts over stdio
    Then "tools/list" returns exactly 18 tools
    And "resources/list" returns exactly 17 resources
    And no file content was copied into a separate distribution directory

  Scenario: Skips a malformed skill file without crashing startup
    Given a SKILL.md file exists with no frontmatter "name" key
    When the MCP server starts over stdio
    Then that file is not registered as a tool
    And the server finishes startup successfully
