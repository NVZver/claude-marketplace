Feature: Consumer selective-load (no happy-path whole-file read)

  Scenario: manager:next Mode 0 uses the extractor
    Given a plain "what's next" question and .lsa/roadmap.yaml present
    When manager:next Step 0 runs
    Then it obtains the first backlog row via scripts/roadmap-row.sh
    And it does not whole-file-read the ledger

  Scenario: No consumer whole-file-reads on the happy path
    Given the read-consumers manager:next Mode 0, project-manager Mode 0/1, manager:check, manager:implement preview
    When each runs its happy path
    Then a test asserts none performs a whole-file read of the ledger
