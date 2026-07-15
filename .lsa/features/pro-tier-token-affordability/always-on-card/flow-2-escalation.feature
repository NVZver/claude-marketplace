Feature: On-demand escalation to full rule text
  Scenario: Editing a marketplace instructional file
    Given the card lists escalation triggers                         # F3
    When the user asks to edit core/skills/output/SKILL.md
    Then the agent loads core/skills/output/SKILL.md in full
    And ground-rules and flow-selector SKILL.md stay unloaded
