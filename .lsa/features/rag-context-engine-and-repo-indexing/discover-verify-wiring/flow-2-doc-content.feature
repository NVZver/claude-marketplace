Feature: The three files document the right order and references
  # Requirements: R4, R5, R6 — requirements.md

  Scenario: Read protocol documents the three-stage order
    Given "lsa/knowledge/conventions.md" Read protocol section (lines 29-41 pre-epic)
    When the section is read after this epic
    Then it documents, in order: project-map.yaml scope resolution,
      rag-query.sh ranking within scope, Grep/Read fallback

  Scenario: discover Step 1 references the updated protocol
    Given "lsa/skills/discover/SKILL.md" Step 1 (pre-epic: project-map consultation)
    When Step 1 is read after this epic
    Then it references querying rag-query.sh within the resolved scope

  Scenario: verify's feasibility step references RAG, symbol resolution unchanged
    Given "lsa/skills/verify/SKILL.md" Step 1 uses scripts/resolve-refs.sh for
      named-symbol resolution (unchanged)
    And Step 2 handles broader buildability/feasibility checks
    When Step 2 is read after this epic
    Then it references rag-query.sh for broader exploratory search
    And Step 1's resolve-refs.sh usage is unchanged
