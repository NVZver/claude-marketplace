Feature: Observation cycle feedback
  Scenario: Pair-programmer stays quiet without a catch
    Given the active role is pair-programmer and the latest changes hold no reuse or simplification catch
    When an observation cycle fires
    Then no feedback is emitted for that cycle
  Scenario: Interviewer orders findings and explains non-destructively
    Given the active role is interviewer and the latest changes contain a correctness gotcha
    When an observation cycle fires
    Then the feedback leads with the solution-level finding and explains the gotcha with a safer alternative
  Scenario: Interviewer adapts difficulty when stuck
    Given the active role is interviewer and the user has been stuck across multiple cycles
    When the next cycle fires
    Then the observer lowers the exercise difficulty and signals a simpler step
