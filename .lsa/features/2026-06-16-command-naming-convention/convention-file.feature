Feature: The command-naming convention is documented and citable

  Scenario: The convention file is present and grounded
    Given the management knowledge directory
    When management/knowledge/command-naming.md is read
    Then line 1 is the file-load trace header
    And it states the <object|actor>:<action>-<modifier> args rule
    And it contrasts the management:roadmap noun anti-pattern with the verb split
    And the anti-pattern cites management/skills/roadmap/SKILL.md:3

  Scenario: The module spec and README list the new knowledge file
    Given the convention file has been written
    When .lsa/modules/management/spec.md and management/README.md are read
    Then both list command-naming.md among the management knowledge files
    And the module spec carries a canonical-source invariant for it
