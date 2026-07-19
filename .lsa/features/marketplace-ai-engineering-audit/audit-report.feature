Feature: Marketplace AI-engineering audit

  Scenario: Produce an evidence-backed optimization roadmap
    Given ".lsa.yaml" defines artifact paths for core, lsa, manager, prompt-engineer, and observer
    And "README.md" states that deterministic work is delegated to scripts
    And ".lsa/VISION.md" states that context is a budget
    When the behavior-bearing marketplace surfaces are audited
    Then every high-priority recommendation cites repository evidence
    And every high-priority recommendation explains its model-tier effect
    And every high-priority recommendation includes a deterministic validation method
    And measured evidence is distinguished from estimates
    And no marketplace implementation change is made
