Feature: Canonical sources rank above historical documents at comparable relevance

  Scenario: SP4 — canonical RRFReranker usage outranks an unrelated historical doc
    Given the query "What is reciprocal rank fusion and where is it implemented?"
    And the corpus includes docker/rag_cli.py's RRFReranker usage (path prefix "docker/" — canonical per R1)
    And stress-report.md Part 2 SP4 documents this query's pre-fix top-3 as an unrelated dropped-feature spec under .lsa/features/ (historical per R1)
    When the query is run via scripts/rag-query.sh
    Then the docker/rag_cli.py chunk appears in the returned results

  Scenario: SP9 — VISION.md's own principle statement outranks a historical implementation doc
    Given the query "What does principle 10 say about deterministic work?"
    And .lsa/VISION.md:67 states the principle directly (path ".lsa/VISION.md" — canonical per R1)
    And stress-report.md Part 2 SP9 documents the pre-fix top-2 as a historical doc about when the principle was added, under .lsa/features/ (historical per R1)
    When the query is run via scripts/rag-query.sh
    Then the .lsa/VISION.md chunk appears in the returned results

  Scenario: SP3 — discover/SKILL.md's own arrow-notation usage outranks an unrelated historical doc
    Given the query "What does the arrow notation like '(→ codebase facts)' mean in LSA skill files?"
    And lsa/skills/discover/SKILL.md:29-31 uses and is representative of this notation (path "lsa/" — canonical per R1)
    And stress-report.md Part 2 SP3 documents the pre-fix top hit as an unrelated requirements.md under .lsa/features/ (historical per R1)
    When the query is run via scripts/rag-query.sh
    Then the lsa/skills/discover/SKILL.md chunk appears in the returned results
