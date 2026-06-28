Feature: Stop the session
  Scenario: Stop on request
    Given an active observe session
    When the user requests stop
    Then the loop ends
  Scenario: Stop on inactivity
    Given an active observe session with no changes for the inactivity timeout
    When the timeout elapses
    Then the loop ends and reports it stopped due to inactivity
