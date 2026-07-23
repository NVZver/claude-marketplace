Feature: Cross-model status is observable on the reconcile verdict

  Background:
    Given lsa:reconcile is a floored routing surface that resolves the tier "inherit"
    And the verdict line prefix "reconcile: PASS|FAIL @ <graded-sha>" is unchanged

  Scenario: Pro user with nothing configured is never blocked
    Given ".lsa.yaml" has a "reconcile:" block containing only "runs: 3"
    And delegate declared "implementer: agent:inherit"
    When reconcile emits its verdict
    Then "reconcile.cross_model" resolves to "observe"
    And the verdict line reads "reconcile: PASS @ <graded-sha> (implementer: agent:inherit, grader: inherit, cross-model: no)"
    And the PASS/FAIL outcome is identical to a run without this feature

  Scenario: Same tier on both sides records "no"
    Given delegate declared "implementer: agent:inherit"
    And the grader resolved the tier "inherit"
    When reconcile computes the cross-model field
    Then the value is "no"

  Scenario: A different declared implementer tier records "yes"
    Given delegate declared "implementer: agent:sonnet"
    And the grader resolved the tier "inherit"
    When reconcile computes the cross-model field
    Then the value is "yes"
    And the comparison used only the tier strings, never a model name

  Scenario: Non-Agent-dispatched implementer records "unknown"
    Given the implementer was a human, Cursor, or Copilot
    And delegate declared "implementer: external"
    When reconcile computes the cross-model field
    Then the value is "unknown"
    And conformance.md records "cross-model: unknown — implementer not Agent-dispatched; independence unobservable, not asserted"

  Scenario: A missing declaration is an illegal unknown, not a free pass
    Given the handoff carries no "implementer:" line
    And ".lsa.yaml" sets "reconcile.cross_model: observe"
    When reconcile emits its verdict
    Then the cross-model field is "unknown"
    And conformance.md records "cross-model: unknown — no implementer declaration in the handoff (illegal for an Agent-dispatched implementer)"
    And the PASS/FAIL verdict is unchanged

  Scenario: require turns a same-model run into a FAIL with a stated reason
    Given ".lsa.yaml" sets "reconcile.cross_model: require"
    And delegate declared "implementer: agent:inherit"
    And the grader resolved the tier "inherit"
    When reconcile emits its verdict
    Then the verdict is "FAIL"
    And the reason "cross-model: no — implementer and grader resolved to the same tier; cross_model: require" is stated alongside the verdict
    And the failure is an ordinary reconcile FAIL the human can override

  Scenario: require does not FAIL on an unobservable external implementer
    Given ".lsa.yaml" sets "reconcile.cross_model: require"
    And delegate declared "implementer: external"
    When reconcile emits its verdict
    Then the cross-model field is "unknown"
    And the verdict is not FAILed on the cross-model check
    And no enforcement claim is made, per delegate's "No silent enforcement claim" constraint

  Scenario: require FAILs a missing declaration
    Given ".lsa.yaml" sets "reconcile.cross_model: require"
    And the handoff carries no "implementer:" line
    When reconcile emits its verdict
    Then the verdict is "FAIL"
    And the stated reason names the missing declaration

  Scenario: An illegal cross_model value degrades, never blocks
    Given ".lsa.yaml" sets "reconcile.cross_model: enforce"
    When reconcile reads the key
    Then it reports a configuration error naming "cross_model" and the legal values "observe" and "require"
    And it proceeds as "observe"
    And the run is not blocked

  Scenario: The grader floor beats any cross-model preference (adversarial)
    Given ".lsa.yaml" sets "reconcile.cross_model: require"
    And ".lsa.yaml" routing maps "lsa:reconcile" to "haiku"
    When the grader's tier is resolved
    Then the resolved tier is "inherit", not "haiku"
    And the map entry is ignored because lsa:reconcile is floored
    And no cross-model preference re-tiers, down-routes, or unfloors the grader

  Scenario: No model name is hardcoded anywhere in the change
    Given the diff for this epic
    When every changed file is inspected
    Then no file contains a hardcoded model pin such as "opus", "fable", or a "claude-*" id
    And only the tier vocabulary "inherit | sonnet | haiku" appears
    And no "model:" pin is added to any plugin frontmatter

  Scenario: Schema is documented in both required places
    Given the change is complete
    When "lsa/README.md" and "lsa/ARCHITECTURE.md" §3 are read
    Then each shows "cross_model" nested under the "reconcile:" block beside "runs"
    And each states the default "observe", the legal values "observe | require", and that "require" is never the default
    And each states that the grader floor takes precedence over any cross-model preference

  Scenario: The versioning trail lands in the same commit
    Given the change is complete
    When the commit is inspected
    Then "lsa/.claude-plugin/plugin.json" reads version "0.29.0"
    And "lsa/CHANGELOG.md" has a matching "[0.29.0]" entry
    And "lsa/README.md" carries the schema delta
    And "bash scripts/gate.sh" exits 0

  Scenario: Existing conformance files stay valid
    Given conformance.md files written before this change
    When they are read after the change
    Then they are not retro-edited
    And no script parses the verdict line, so the format extension breaks no consumer
