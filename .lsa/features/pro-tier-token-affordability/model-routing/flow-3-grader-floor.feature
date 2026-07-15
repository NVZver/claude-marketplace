Feature: Safety-critical graders are never routed down
  Scenario: Reconcile grader holds at inherit despite a lower map entry
    Given .lsa.yaml routing maps lsa:reconcile to haiku                    # adversarial
    When a dispatcher resolves the reconcile grader tier                   # F5
    Then the resolved tier is inherit, not haiku                           # F5, AC4
    And the contract documents the refusal by name                        # F5

  Scenario: Implementer and worktree fan-out are floored too
    Given the floored set is reconcile grader + delegate implementer + implement fan-out
    When any of those surfaces resolves its tier                           # F5
    Then it never resolves below inherit                                   # F5
