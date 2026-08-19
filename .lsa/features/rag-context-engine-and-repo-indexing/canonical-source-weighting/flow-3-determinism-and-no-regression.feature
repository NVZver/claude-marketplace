Feature: Ranking stays deterministic and does not regress already-passing queries

  Scenario: Identical repeated query returns identical order
    Given an unchanged index
    When the same query is run twice via scripts/rag-query.sh
    Then both result lists are identical in order and content

  Scenario Outline: Already-passing stress probes remain unchanged
    Given stress-report.md Part 1/2 records <probe> as already passing before this epic
    When <probe> is re-run against the fix
    Then it continues to return its previously-correct result

    Examples:
      | probe                                |
      | SP1 (MIN_SIMILARITY value)           |
      | SP5 (GraphQL miss-bait)              |
      | SP7 (chunk schema version)           |
      | SP8 (roadmap priority lookup)        |
      | P9 regression guard (0.8697 top hit) |

  Scenario Outline: Explicit non-goals are not treated as regressions
    Given <probe> is disclosed in requirements.md as out of this epic's design reach
    When <probe> is re-run against the fix and still misses
    Then that miss is reported honestly and is not treated as a failing requirement

    Examples:
      | probe                                        |
      | SP2 (pure paraphrase, zero literal overlap)   |
      | SP6 (pitch vs. research doc, both historical) |
