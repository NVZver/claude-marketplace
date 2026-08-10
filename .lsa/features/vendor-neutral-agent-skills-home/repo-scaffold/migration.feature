Feature: Smoke-test skill migration with contract rewrite
  Scenario: ground-rules migrates with its AskUserQuestion hard-bind rewritten
    Given `core/skills/ground-rules/SKILL.md:28` names `AskUserQuestion` directly
    When the skill is migrated to `skills/core/ground-rules/SKILL.md`
    Then the migrated file uses the vendor-agnostic labelled-options contract
    And no literal `AskUserQuestion` string remains in the migrated file

  Scenario: output migrates with its AskUserQuestion hard-bind rewritten
    Given `core/skills/output/SKILL.md:86` names `AskUserQuestion` directly
    When the skill is migrated to `skills/core/output/SKILL.md`
    Then the migrated file uses the vendor-agnostic labelled-options contract
    And no literal `AskUserQuestion` string remains in the migrated file
