Feature: The detection hook stays silent in every negative case

  Scenario Outline: No offer, exit 0, never blocks session start
    Given <condition>
    When the SessionStart detection script runs
    Then it prints nothing and exits 0

    Examples:
      | condition                                                              |
      | .lsa.yaml already has a rag-index-fresh gate entry (already bootstrapped) |
      | .lsa.yaml does not exist (lsa:init not run)                            |
      | docker is not installed or not reachable                              |
