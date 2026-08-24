Feature: Resource read returns the knowledge file unchanged

  Scenario: Reading a registered resource returns the exact source Markdown
    Given "lsa/knowledge/conventions.md" is registered as a resource
    When a connected client reads that resource
    Then the response content is byte-identical to the current content of "lsa/knowledge/conventions.md"
