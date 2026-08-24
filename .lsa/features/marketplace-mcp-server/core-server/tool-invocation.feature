Feature: Tool call returns the skill body unchanged

  Scenario: Calling a registered tool returns the exact source Markdown
    Given "core/skills/ground-rules/SKILL.md" is registered as the "ground-rules" tool (frontmatter at core/skills/ground-rules/SKILL.md:1-3)
    When a connected client calls the "ground-rules" tool
    Then the response body is byte-identical to the current content of "core/skills/ground-rules/SKILL.md"
