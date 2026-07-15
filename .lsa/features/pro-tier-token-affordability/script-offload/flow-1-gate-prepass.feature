Feature: The verify/reconcile gate pre-pass runs as one deterministic command
  Scenario: One command runs the whole gate block
    Given .lsa.yaml defines a gate: block (docs-invariants, citations, links)  # F1, F3
    When bash scripts/gate.sh runs                                            # F1
    Then it executes each configured command in order                         # F1, AC1
    And it prints each check's command and exit code                          # F1, AC1
    And it exits 0 only when every check passed                               # F1, AC1

  Scenario: The command list is not duplicated
    Given a new key is added to the .lsa.yaml gate: block                     # F3
    When bash scripts/gate.sh runs                                            # F3
    Then it runs the new check with no edit to scripts/gate.sh                # F3, AC1

  Scenario: verify and reconcile cite the aggregate runner
    Given a repo that provides scripts/gate.sh                                # F4
    When lsa:verify Step 4 or lsa:reconcile Step 1 runs the gate block        # F4
    Then it runs the block via the aggregate runner and cites command+exit    # F4, AC4
    And a repo without the runner runs each configured command instead        # F4

  Scenario: No gate block degrades, never crashes
    Given .lsa.yaml has no gate: block                                        # F7
    When bash scripts/gate.sh runs                                            # F7
    Then it reports NOT-RUNNABLE rather than crashing                         # F7, AC5
