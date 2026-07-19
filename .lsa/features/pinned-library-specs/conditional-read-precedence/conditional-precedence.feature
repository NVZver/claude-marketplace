Feature: A pinned spec outranks external docs only while its pin verifies

  Background:
    Given a fixture library "acme" registered under "libs:" in ".lsa.yaml"     # R1
    And a pinned spec at ".lsa/libs/acme.md" pinned to "3.1.0"                # R1
    And an LSA skill needs the signature of "acme.charge()"                    # R1

  Scenario: Fresh pin is read locally with zero external calls
    Given "bash scripts/check-lib-pins.sh" reports "OK" for "acme"            # R3
    And the pinned spec covers "acme.charge()"                                 # R1
    When the library-documentation protocol runs
    Then the pinned spec is read from disk                                     # R1
    And no resolve-library-id, query-docs, or WebSearch call is made           # R1, R7
    And the claim is cited as "lib:acme:charge via pin@3.1.0"                  # R5

  # adversarial — rabbit hole 1: precedence must be conditional, not positional
  Scenario: A STALE pin is NOT authoritative and the reactive protocol resumes
    Given "bash scripts/check-lib-pins.sh" reports "STALE" for "acme"         # R3
    And the stale pinned spec still contains an answer for "acme.charge()"     # R4
    And that answer disagrees with the current external docs                   # R4
    When the library-documentation protocol runs
    Then the pinned spec is NOT read as authoritative                          # R2, R4
    And the answer is NOT cited as "via pin@3.1.0"                             # R5
    And the protocol continues to step 1 (resolve-library-id)                  # R1, R6
    And the answer is cited as "lib:acme:charge via context7"                  # R6
    And the in-repo pin ranks below the external source for this lookup        # R2

  # adversarial — an unknown is not a soft pass
  Scenario: [cannot verify] falls through exactly like STALE
    Given "bash scripts/check-lib-pins.sh" reports "[cannot verify]" for "acme"  # R4
    When the library-documentation protocol runs
    Then the pinned spec is NOT read as authoritative                            # R4
    And it is NOT treated as a warn-and-proceed or a "probably fine"             # R4
    And the reactive protocol runs to completion                                 # R4, R6

  Scenario: BROKEN falls through too
    Given "bash scripts/check-lib-pins.sh" reports "BROKEN" for "acme"        # R4
    When the library-documentation protocol runs
    Then the reactive protocol runs and the pin is not cited                   # R4

  Scenario: Freshness is never the model's judgment
    Given a manifest declaring the range "^3.0.0" for "acme"                   # R3
    When the protocol decides whether the pin is authoritative
    Then the decision comes from the script's status line and exit code        # R3
    And the model does not compare versions or interpret the range itself      # R3

  Scenario: A green pin that does not cover the symbol falls through
    Given "check-lib-pins.sh" reports "OK" for "acme"                         # R1
    And the pinned spec does not document "acme.refund()"                      # R1
    When the protocol resolves "acme.refund()"
    Then it continues to step 1 for that symbol                                # R1
    And the pin is still authoritative for symbols it does cover               # R1

  Scenario: Non-registered libraries are unaffected
    Given library "zeta" is not registered under "libs:"                       # R6
    When the protocol resolves a "zeta" API
    Then it runs today's four steps unchanged                                  # R6
    And the terminal "state it, never guess" case is unchanged                 # R6
