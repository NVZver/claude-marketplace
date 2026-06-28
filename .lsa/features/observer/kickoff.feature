Feature: Kickoff and role selection
  Scenario: Inferred role proposed and confirmed
    Given the user starts observe with no role named
    When the observer infers a candidate role and proposes it
    Then observing does not begin until the user confirms or overrides the role
  Scenario: Custom role requires a lens
    Given the user selects the custom role
    When no lens/voice line is provided
    Then the observer requests one before observing
