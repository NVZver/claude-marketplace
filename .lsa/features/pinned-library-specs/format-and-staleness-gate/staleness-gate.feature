Feature: Pinned-library staleness gate — fresh, stale, and honestly unverifiable

  Background:
    Given a sandbox repo root containing a ".lsa.yaml" with a "libs:" block   # R3
    And each registered lib names a "spec:" and a "manifest:"                 # R3

  Scenario: A fresh pin exits 0
    Given lib "stripe" whose spec carries "Pinned-Version: 18.5.0"            # R1
    And the spec carries "Lockfile: package-lock.json"                        # R1
    And the spec carries 'Lockfile-Assertion: "stripe": "18.5.0"'             # R1
    And "package-lock.json" exists and contains that literal substring        # R6.5
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line starting with "  OK" naming "stripe" and "18.5.0"   # R4
    And it exits 0                                                            # R5

  Scenario: A moved dependency is STALE and exits 1
    Given the same "stripe" pin at "18.5.0"                                   # R1
    And "package-lock.json" exists but contains '"stripe": "19.0.0"'          # R6.6
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line starting with "  STALE" naming "stripe"             # R4
    And it exits 1                                                            # R5

  # adversarial — rabbit hole 4: a manifest range must never read green
  Scenario: No lockfile reports [cannot verify] and NEVER exits 0
    Given lib "claude-code" whose spec carries "Pinned-Version: 2.0.14"       # R1
    And the spec carries "Manifest: none" and "Lockfile: none"                # R1
    And the manifest, were one present, would declare a range like "^2.0.0"   # rabbit hole 4
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line containing "[cannot verify]" naming "claude-code"   # R4
    And it does NOT print "OK" for "claude-code"                              # R5
    And it exits 2, never 0                                                   # R5
    And the manifest range was not used to decide freshness                   # R6

  Scenario: A missing lockfile file is [cannot verify], not OK
    Given a spec carrying "Lockfile: package-lock.json"                       # R1
    And no file exists at "package-lock.json"                                 # R6.3
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints "[cannot verify]" with reason "lockfile not found"         # R4
    And it exits 2                                                            # R5

  Scenario: STALE outranks [cannot verify] in the aggregate exit code
    Given one lib is STALE and another is [cannot verify]                     # R5
    When "bash scripts/check-lib-pins.sh" runs
    Then both status lines are printed                                        # R4
    And it exits 1, not 2                                                     # R5

  Scenario: A broken registration is BROKEN, not silently skipped
    Given a "libs:" entry whose "spec:" path does not exist                   # R6.1
    When "bash scripts/check-lib-pins.sh" runs
    Then it prints a line starting with "  BROKEN" naming the lib             # R4
    And it exits 1                                                            # R5

  Scenario: An empty registry is a pass
    Given ".lsa.yaml" contains "libs: {}"                                     # R13
    When "bash scripts/check-lib-pins.sh" runs
    Then it exits 0                                                           # R5

  Scenario: The gate blocks a GROUNDED verdict on a non-zero pin check
    Given ".lsa.yaml" gate: contains "lib-pins: bash scripts/check-lib-pins.sh"  # R7
    And the pin check exits non-zero
    When "bash scripts/gate.sh" runs
    Then it prints "FAIL" for the "lib-pins" check with its exit code            # R7
    And "bash scripts/gate.sh" exits 1                                           # R7
    And lsa:verify yields NOT-GROUNDED per verify/SKILL.md:42                    # R7

  Scenario: The 5-lib cap fails the lint above 5
    Given ".lsa.yaml" registers 5 libs
    When "bash scripts/lint.sh" runs
    Then C18 reports PASS                                                     # R9
    Given a 6th lib is registered
    When "bash scripts/lint.sh" runs
    Then C18 reports FAIL naming the count and the cap of 5                   # R9
    And "bash scripts/lint.sh" exits 1                                        # R9
