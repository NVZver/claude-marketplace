Feature: On-demand roadmap query (zero-token slice)

  Scenario: First backlog row, zero model tokens
    Given .lsa/roadmap.yaml has at least one backlog item
    When scripts/roadmap-row.sh runs
    Then it prints that item's row with a path:line citation to stdout
    And it consumes zero model tokens

  Scenario: Bounded backlog slice
    Given the ledger has more than N backlog/not_started items
    When scripts/roadmap-query.sh backlog --limit N runs
    Then at most N rows are printed to stdout

  Scenario: Single record by slug
    Given the ledger has an item with slug "X"
    When scripts/roadmap-query.sh get X runs
    Then only that record is printed

  Scenario: Missing data falls through
    Given the ledger is absent or the query matches nothing
    When a query script runs
    Then it exits non-zero
