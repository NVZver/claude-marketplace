Feature: Deterministic roadmap schema gate

  Scenario: Malformed ledger fails the gate
    Given .lsa/roadmap.yaml is malformed or missing a required key
    When bash scripts/lint.sh runs
    Then the new schema check fails and lint.sh exits non-zero

  Scenario: Well-formed ledger passes
    Given .lsa/roadmap.yaml is well-formed with all required keys
    When bash scripts/lint.sh runs
    Then the schema check passes
