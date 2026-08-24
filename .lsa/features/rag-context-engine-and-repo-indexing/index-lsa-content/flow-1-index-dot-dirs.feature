Feature: Index dot-prefixed directories except real tool internals
  # Requirements: R1-R5 — requirements.md

  Scenario: Genuine tool/VCS internals stay excluded
    Given the walk encounters ".git", ".rag-index", "node_modules", or "__pycache__"
    When the index is built
    Then none of their contents are indexed

  Scenario: .lsa/ content is now indexed
    Given ".lsa/features/", ".lsa/pitches/", ".lsa/research/" contain real project content
    When the index is built
    Then chunks from these directories appear in the index

  Scenario: .lsa/archive/ stays excluded, by path not by name
    Given ".lsa/archive/" is a frozen historical record
    And some other, unrelated directory elsewhere in the tree happens to be named "archive"
    When the index is built
    Then ".lsa/archive/"'s contents are excluded
    And the unrelated same-named directory elsewhere is NOT excluded

  Scenario: Previously-invisible content is now findable
    Given ".githooks/pre-commit" and ".lsa/plans/2026-05-20-credo-rollout-plan.md" were
      never indexed before this epic
    When a relevant query is run after re-indexing
    Then both files are genuine candidates for retrieval
