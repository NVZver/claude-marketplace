Feature: Unconditioned tool-name prose reworded to generic action + citation

  Scenario Outline: Each flagged line matches its specified after-text exactly
    Given "<file>" line <line> currently contains an unconditioned literal Claude-Code-tool-name mention
    When the rewrite table entry for "<file>:<line>" is applied
    Then that line matches the specified after-text exactly
    And no other line in "<file>" changed

    Examples:
      | file                                    | line |
      | core/skills/output/SKILL.md              | 80   |
      | lsa/agents/orchestrator.md                | 25   |
      | lsa/agents/orchestrator.md                | 30   |
      | lsa/agents/orchestrator.md                | 31   |
      | lsa/agents/orchestrator.md                | 43   |
      | lsa/skills/delegate/SKILL.md               | 42   |
      | lsa/skills/delegate/SKILL.md               | 48   |
      | lsa/skills/delegate/SKILL.md               | 51   |
      | lsa/skills/verify/SKILL.md                 | 26   |
      | manager/agents/product-manager.md          | 53   |
      | manager/agents/project-manager.md          | 19   |
      | manager/agents/project-manager.md          | 32   |
      | manager/agents/project-manager.md          | 66   |
      | manager/agents/project-manager.md          | 105  |
      | manager/skills/check/SKILL.md              | 23   |
      | manager/skills/decompose/SKILL.md          | 20   |
      | manager/skills/decompose/SKILL.md          | 22   |
      | manager/skills/implement/SKILL.md          | 26   |
      | manager/skills/implement/SKILL.md          | 30   |
      | manager/skills/next/SKILL.md               | 20   |
      | manager/skills/next/SKILL.md               | 22   |
      | manager/skills/shape/SKILL.md              | 7    |
      | manager/skills/shape/SKILL.md              | 22   |
      | manager/skills/shape/SKILL.md              | 24   |
      | manager/skills/shape/SKILL.md              | 25   |
      | manager/skills/shape/SKILL.md              | 26   |
      | manager/skills/shape/SKILL.md              | 31   |
      | manager/skills/shape/SKILL.md              | 57   |
      | manager/skills/check/SKILL.md              | 23   |

  Scenario: The 3 already-compliant citation lines are untouched
    Given "core/skills/flow-selector/SKILL.md:46", "core/skills/ground-rules/SKILL.md:24", and "core/skills/ground-rules/SKILL.md:71" already follow the "in Claude Code" citation pattern
    When the rewrite is applied to the rest of the first-slice tree
    Then those 3 lines remain byte-identical to their current content
