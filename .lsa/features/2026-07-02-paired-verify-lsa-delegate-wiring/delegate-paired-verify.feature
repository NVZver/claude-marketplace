Feature: Checkpoint-mode delegation wiring

  Scenario: paired_verify off reproduces today's delegation   # G2
    Given .lsa.yaml has no paired_verify key (or paired_verify: off)
    When lsa:delegate runs on a grounded spec
    Then it packages the spec, dispatches the implementer, and awaits the diff
    And it injects no pause instruction and dispatches no verifier

  Scenario: async is refused, not silently degraded            # G3
    Given .lsa.yaml has paired_verify: async
    When lsa:delegate runs
    Then it errors that async (concurrent interrupt) is not yet implemented
    And it does not fall back to checkpoint or off

  Scenario: checkpoint injects the pause+signal protocol        # G4,G5
    Given .lsa.yaml has paired_verify: checkpoint and an agent implementer
    When lsa:delegate hands off the spec
    Then the implementer prompt instructs it to, after each plan task F-K, write a
      checkpoint-signal note with fields target, since, spec, status and then await clearance

  Scenario: a CLEAR verdict auto-advances                       # G6,G7
    Given a checkpoint delegation and a signalled increment for F-K
    When observer:verify-checkpoint returns CLEAR
    Then the implementer proceeds to the next task with no human interrupt

  Scenario: a BLOCK verdict surfaces before the next task       # G6,G7
    Given a checkpoint delegation and a signalled increment for F-K
    When observer:verify-checkpoint returns BLOCK
    Then delegate surfaces the block to the human before the next task begins

  Scenario: the final reconcile still runs                      # G9
    Given a checkpoint delegation that produced per-increment CLEAR verdicts
    When delegation completes
    Then the final lsa:reconcile still grades the whole diff

  Scenario: non-agent implementer gets advisory protocol        # G10
    Given paired_verify: checkpoint but the implementer is external/human
    When lsa:delegate runs
    Then it states the pause-protocol is advisory and does not claim to enforce pausing
