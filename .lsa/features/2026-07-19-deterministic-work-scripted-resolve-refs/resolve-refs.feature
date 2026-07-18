Feature: Per-symbol reference resolution for verify

  Scenario: Resolve a mix of path, missing path, and identifier
    Given the symbols "scripts/gate.sh", "scripts/nope.sh", and "pass_line"
    When "bash scripts/resolve-refs.sh scripts/gate.sh scripts/nope.sh pass_line" runs
    Then "scripts/gate.sh" resolves to "exists @ scripts/gate.sh"
    And "scripts/nope.sh" resolves to "new"
    And "pass_line" resolves to "exists @ <file>:<line>"
    And it exits 0

  Scenario: path:line range checking
    Given the symbols "lsa/README.md:1" and "lsa/README.md:999999"
    When the script runs
    Then "lsa/README.md:1" resolves to "exists @ lsa/README.md:1"
    And "lsa/README.md:999999" resolves to "OUT-OF-RANGE"

  Scenario: Arg-only invocation never blocks on stdin
    Given symbols passed as arguments
    And stdin is an open pipe that never sends EOF
    When the script runs
    Then it resolves the arguments and exits without reading stdin

  Scenario: Empty input is a usage error
    Given no arguments and empty stdin
    When the script runs
    Then it prints a usage diagnostic
    And it exits non-zero
