Feature: Live role switch
  Scenario: New role applies without restart
    Given an active observe session in the rubber-duck role
    When the user switches to pair-programmer
    Then the next cycle's feedback follows the pair-programmer lens without restarting the loop
