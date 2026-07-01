Feature: reuse-first ladder on coding tasks
  # Each Given is grounded in a fact from lsa:discover.

  Scenario: Reuse an existing in-codebase helper (rung 3, F3)
    Given the reuse-first skill is installed in core (.lsa.yaml:10-19)
    And a coding task needs behavior a helper in the repo already provides
    When the agent walks the ladder before writing code
    Then it reuses the existing helper instead of reimplementing it
    And no duplicate implementation is added to the diff

  Scenario: Prefer stdlib over a hand-rolled version (rung 4, F4)
    Given a coding task needs behavior the standard library provides
    When the agent walks the ladder
    Then it uses the stdlib/builtin and writes no hand-rolled equivalent

  Scenario: Root-cause bug fix across callers (F8)
    Given a bug report naming one symptom path
    And multiple callers route through a shared function
    When the agent applies the reuse-first bug rule
    Then it fixes the shared function once, not each caller

  Scenario: Prose task does not trigger the ladder (F9, test E2)
    Given a prose/analysis request with no code to author
    When the skill's description-based auto-trigger is evaluated
    Then the reuse-first ladder does not fire

  Scenario: Skill cross-references, never restates (F11)
    Given the reuse-first SKILL.md body
    When it references ground-rules R3/R4 (core/skills/ground-rules/SKILL.md:67,77) and reconcile's "only" check (lsa/skills/reconcile/SKILL.md:33)
    Then each reference is a markdown link, not a restated rule
