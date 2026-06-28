Feature: Interviewer exercise scaffold
  Scenario: Generate a runnable red exercise
    Given the confirmed role is interviewer and a language and topic are given
    When the observer scaffolds the exercise
    Then a file exists with a problem statement, a function placeholder, and a test suite that fails when run
  Scenario: Scaffold is interviewer-only
    Given the confirmed role is not interviewer
    When the user asks for an exercise
    Then no exercise file is generated
