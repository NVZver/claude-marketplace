Feature: Prompt request returns the agent body unchanged, never executed server-side

  Scenario: Requesting a registered prompt returns the exact source Markdown, with no server-side execution
    Given "manager/agents/project-manager.md" is registered as the "project-manager" prompt
    When a connected client requests the "project-manager" prompt
    Then the response content is byte-identical to the current content of "manager/agents/project-manager.md"
    And the server process makes zero outbound network calls while serving the request
