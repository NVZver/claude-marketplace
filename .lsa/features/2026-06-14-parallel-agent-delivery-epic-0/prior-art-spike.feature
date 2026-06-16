Feature: Parallel-agent-delivery prior-art spike is complete and grounded

  Scenario: Every pitch component carries a cited build/borrow verdict
    Given the 6 components listed in pitch parallel-agent-delivery.md:31
    When the research doc .lsa/research/parallel-agent-delivery-prior-art.md is read
    Then each component has exactly one findings block with a Build/Borrow/Hybrid verdict
    And each block cites at least 2 sources, each with a searchable quote
    And the roll-up table maps each component to a verdict and a target Epic

  Scenario: No verdict is ungrounded
    Given a build/borrow verdict in the research doc
    When the verdict's reasoning is inspected
    Then it cites a primary source quote, not a vague maturity claim
