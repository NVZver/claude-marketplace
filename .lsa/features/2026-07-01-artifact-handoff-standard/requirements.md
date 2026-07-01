# Artifact hand-off standard — pointer + summary, not full payload

## Summary
A repo standard, authored in `.lsa/standards/code.md`: when an agent produces a sizeable artifact for
another agent, it writes the artifact to a file and returns a **pointer + a decision-relevant summary +
pending gates** instead of round-tripping the full payload through context. Intermediate-only data stays
in the file; fact-grounding citations are preserved in the file (never summarized away); human-facing
content is the carve-out — the dispatcher reads the file and re-renders it to the human. This is a
**standard-authoring change only** — per-agent rewiring is deliberate follow-on and out of scope.

- Standard section: `.lsa/standards/code.md` §"Artifact hand-off — pointer + summary, not full payload"
- Extends: `core/skills/output/SKILL.md:42` Rule 2 *"Pull, don't push"* (human output → inter-agent data)
- Preserves: `core/skills/output/SKILL.md:79-86` Rule 7 *Delivery test* (human-facing content re-rendered)
- Precedent generalized: `lsa/skills/reconcile/SKILL.md:37-39` (`conformance.md` + verdict line)
- Complement: the "Dispatch efficiency" section of `.lsa/standards/code.md` (when to spawn; this = how data crosses)

## Scope
- **In scope.** Author ONE new section in `.lsa/standards/code.md`; a minimal spec (this file).
- **Out of scope.** Rewiring any agent (`manager` shaping/roadmap agents et al.) to the standard;
  a dedicated grounding hand-off file (deferred on the roadmap). No plugin version bump — standards
  are not a plugin.

## Functional requirements (EARS)

- R1. The standard SHALL state that an agent producing a sizeable artifact writes it to a file and returns
  a pointer (file path) + a decision-relevant summary + any pending gates — not the full payload through
  context. (pitch: artifact-handoff-standard; `core/output` Rule 2)
- R2. The standard SHALL state that intermediate-only data — data no human reads — stays in the file and
  never enters the dispatcher's context. (pitch)
- R3. The standard SHALL state that fact-grounding citations (source + verbatim quote per
  `core/ground-rules` Rule 1) are preserved in the file and never summarized away; a summary must never be
  the only surviving copy of a citation. (`.lsa/VISION.md` §1 fact-grounding)
- R4. The standard SHALL state the human-facing carve-out: the dispatcher reads the file and re-renders
  human-facing content itself, per `core/output` Rule 7 *Delivery test* — a human decision is NEVER gated
  behind a file path or a subagent transcript. This carve-out SHALL NOT be relaxed. (`core/output` Rule 7)
- R5. The standard SHALL cite `core/output` Rule 2 + Rule 7 by link, cite `lsa/skills/reconcile/SKILL.md`
  `conformance.md` as the live precedent it generalizes, and cross-link the "Dispatch efficiency" section
  as its complement — matching the existing section style (prose + a `Source:` line). (existing code.md style)
- R6. NO plugin file SHALL change and NO plugin SemVer/CHANGELOG bump SHALL occur — this is a `.lsa/`
  constitution/standards change, and standards are not a plugin. (repo discipline; task constraint)

## Acceptance scenario (Gherkin)

```gherkin
Feature: Artifact hand-off returns pointer + summary while human-facing content is still rendered

  Scenario: A large artifact is handed off by pointer, yet the human still sees the content
    Given an agent produces a large artifact intended for the next agent and the human
    When the agent completes its work under the artifact hand-off standard
    Then it writes the full artifact — including all fact-grounding citations — to a file
    And it returns to the dispatcher only a pointer to that file plus a decision-relevant summary and any pending gates
    And intermediate-only data the human never reads does not enter the dispatcher's context
    And the dispatcher reads the file and re-renders the human-facing content in a turn-final message or an AskUserQuestion gate
    And no human decision is gated behind a bare file path or a subagent transcript
```

## Notes
- Authoring note: on `main` the sibling "Dispatch efficiency" section does not yet exist (it lives on the
  unmerged branch `feature/model-token-optimization`); the new section is placed before
  `## Constitution = .lsa/VISION.md` so a later merge reconciles the two adjacent sections.
