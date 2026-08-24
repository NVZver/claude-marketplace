Feature: MCP server startup and prompt registration

  Scenario: Registers one prompt per first-slice agent file
    Given "manager/agents/product-manager.md" exists (63 lines, frontmatter name/description/tools)
    And "manager/agents/project-manager.md" exists (114 lines, frontmatter name/description/tools)
    And "lsa/agents/orchestrator.md" exists (50 lines, frontmatter name/description/tools)
    When the MCP server starts over stdio
    Then "prompts/list" returns exactly 3 prompts
    And the existing "tools/list" (18) and "resources/list" (17) counts are unaffected

  Scenario: Skips a malformed agent file without crashing startup
    Given an agent .md file exists with no frontmatter "name" key
    When the MCP server starts over stdio
    Then that file is not registered as a prompt
    And the server finishes startup successfully
