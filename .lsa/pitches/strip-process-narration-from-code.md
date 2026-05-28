Shaped by: Nikita Zverev
Date: 2026-05-28
Status: draft
Why now: end-of-project user feedback flagged generated code as polluted with Epic IDs and process artifacts — every additional implementation epic that ships under the current `lsa:implement` produces more polluted code; fixing the agent prompts is cheap; rewriting comments in already-shipped code later is not.

# Strip process narration from generated code

`lsa:implement`, `lsa/agents/developer.md`, and `lsa:verify` must produce code with only code-related comments (inline doc for functions, classes, modules) — no Epic IDs, requirement IDs, TDD phase tags, or spec-artifact references. Traceability lives in commits and PR descriptions, not in source.

## Problem

Generated code is leaking process metadata into comments. The user reads source and finds comments like `// Epic 3: implements AC-2 (RED phase)` or `// Per requirements.md F1 — covers Journey 2 step 4` — content that means nothing to anyone reading the source standalone (downstream consumer, future maintainer, code reviewer). The signal-to-noise ratio of code comments drops as a result; real inline documentation (parameter contracts, invariant explanations, non-obvious algorithm reasoning) gets crowded out.

Evidence (user, 2026-05-28, verbatim): *"Too much comments in the code, especially about Epics and other stuff. I want to see only code related comments like inline doc for functions and classes."*

Diagnosis: the LSA build cycle has strong traceability discipline — every code change traces to an epic, every epic covers a requirement, every requirement has acceptance criteria — and the agents have been *expressing* that traceability inline in code comments, in addition to (or instead of) the proper homes for it (commit messages, PR descriptions, the spec artifacts themselves). The `lsa:plan` artifact carries epic IDs; the `lsa:implement` step references them when writing tests and code; the references end up in source.

Two failure modes:
1. **Test comments.** `lsa:implement` runs RED -> GREEN -> REFACTOR and labels the test cases with epic and phase metadata in comments. The metadata pollutes both test source and (via test names) test output.
2. **Production code comments.** `lsa/agents/developer.md` (the developer actor invoked from `lsa:implement`) adds traceability headers ("// Implements Epic 3, AC-2") on functions and modules, instead of clean inline doc.

Current workaround: the user manually rewrites comments after each implement turn, or asks the agent to clean up — both are wasted cycles.

Definition of success: (a) every comment in generated code is a code comment (parameter contract, invariant, algorithm note, public API doc) — no process artifact; (b) Epic IDs, AC IDs, TDD phase tags, "Per requirements.md..." references do not appear in source; (c) the same traceability information lives in the commit message body and PR description, not in source; (d) `lsa:verify` flags violations.

## Appetite

Small batch. The change is narrow: edit the two LSA prompts that generate code (`lsa/skills/implement/SKILL.md` + `lsa/agents/developer.md`), add a verify-side regex check in `lsa/skills/verify/SKILL.md` for the common violation patterns, and document the rationale in `lsa/knowledge/conventions.md` (traceability-in-commits-not-source).

Out of appetite:
- Backfilling existing repo code to strip process comments (one-time cleanup is a separate concern; this pitch prevents future pollution).
- Reworking the upstream traceability data (epic IDs, AC IDs continue to exist in spec artifacts and PR descriptions).
- Building a code-comment style guide beyond the one rule.
- Touching commit message format (commits are already where this info should land; no change to commit conventions).

## Solution sketch

- **Scope.** This pitch is LSA-only. The fix surfaces are:
  - `lsa/skills/implement/SKILL.md` — the TDD loop skill that drives RED → GREEN → REFACTOR.
  - `lsa/agents/developer.md` — the developer actor invoked from `lsa:implement` (confirmed present at `/Users/nikitazverev/nn/claude-marketplace-1/lsa/agents/developer.md`).
  - `lsa/skills/verify/SKILL.md` — the verify skill where the regression check lives.
  - `lsa/knowledge/conventions.md` — the rationale + banned-pattern enumeration.
  - Note: `dev-plugin:implement` is **not** in this repo (separately-installed plugin) and is out of scope.

- **Key user interactions:**
  - User runs `lsa:implement` -> generated test file has `it("returns 401 for expired tokens", ...)` with no `// Epic 3 RED phase` annotation; instead, the commit message body says *"Epic 3 RED — covers AC-2 from `.lsa/.../requirements.md`."*
  - User runs `lsa:implement` and the developer agent writes production code -> functions have JSDoc / docstring style inline doc describing parameters, return shape, and non-obvious behavior, with no spec traceability annotation.
  - User runs `lsa:verify` -> a new check scans the diff for banned patterns (`Epic \d+`, `AC-\d+`, `Per requirements\.md`, `RED phase`, `GREEN phase`, `REFACTOR phase`, `Covers Journey \d+`, `F\d+`, `OQ\d+`) in code files (excluding `.md`, `CHANGELOG`, `plugin.json`). Hits surface as warnings.

- **Main components:**
  - `lsa/agents/developer.md` — explicit constraint: *"Code comments document code (parameters, contracts, invariants, non-obvious behavior). Process metadata — Epic IDs, AC IDs, TDD phase tags, spec artifact references — belongs in the commit message body and PR description, never in source."* Plus a worked example of compliant vs. non-compliant comments.
  - `lsa/skills/implement/SKILL.md` — same constraint applied to the implement loop, plus an explicit step that says *"after writing the test, the test description should describe the behavior — not the process step."* Test-name template explicitly produces behavior-shaped names ("returns 401 for expired tokens"), not process-shaped names ("Epic 3 AC-2 RED").
  - `lsa/skills/verify/SKILL.md` — new sub-check ("process-narration in code") with the banned-pattern regex set. Warning-only initially.
  - `lsa/knowledge/conventions.md` — new section "Traceability in commits, not source" documenting the principle, with the banned patterns enumerated so the agent and human have a single source.

- **Critical path:** add the conventions rule -> update `lsa/agents/developer.md` + `lsa/skills/implement/SKILL.md` to cite it -> add the verify check in `lsa/skills/verify/SKILL.md` -> validate against a recent PR (positive: shows clean comments; negative: shows pre-rule code with violations).

## Rabbit holes

1. **TDD phase visibility in test output.** Stripping phase tags from test names may reduce the visibility of "is this the RED test or the GREEN test" during the implement loop itself. Mitigation: phase tracking lives in the agent's working memory and in the commit message (each RED commit is `feat(epic3): RED — failing test for X`; each GREEN commit is `feat(epic3): GREEN — implementation for X`). The test source stays clean.

2. **Acceptable spec references.** A test or function may legitimately reference an external spec (e.g., RFC 7231 §6.5.1 for HTTP 401) — that is *content* traceability, not *process* traceability, and should be allowed. Mitigation: the banned patterns are spec-artifact internal IDs (Epic N, AC-N, F-N, OQ-N, Per requirements.md), not external spec citations. Document the distinction in `lsa/knowledge/conventions.md`.

3. **Verify check false positives.** The banned-pattern regex set could match legitimate uses (a variable named `epic3` in a feature flag system, a string literal in a test fixture). Mitigation: scope the check to comment lines only (`//`, `#`, `/* ... */`), not code identifiers or string literals. Ship as warning-only until the false-positive rate is known.

4. **Backwards compatibility with existing code.** Existing source in this and downstream repos may already carry process-narration comments. Mitigation: this pitch is forward-only; backfill is a separate cleanup pitch if the user wants it. The verify check operates on PR diffs (modified files only), not the full tree, so legacy comments don't trigger warnings.

## No-gos

1. This pitch does NOT cover commit message format changes — commits are already the right home for traceability.
2. This pitch does NOT cover removing epic / AC IDs from spec artifacts (requirements.md, tasks.md, design.md). Those are the source of truth for traceability and stay as-is.
3. This pitch does NOT cover backfilling existing source to strip pre-existing process comments — forward-only.
4. This pitch does NOT cover external spec citations (RFC numbers, language standards) — those are content, not process, and remain allowed.
5. This pitch does NOT cover PR description templates — that's a downstream consideration; in scope is only what *the agent writes in source*.
6. This pitch does NOT cover `dev-plugin:implement` — that plugin is separately installed and not in this repo's scope.

## Open questions

1. Should the verify check also scan generated test names (not just comments), or only comments? Test names appear in test runner output and have user-visible blast radius — argues for including them. Mitigation: probably yes, but call out as a follow-up.
2. The banned-pattern regex set is the heart of the verify check. Should it live in `lsa/knowledge/conventions.md` (alongside the rule) or in a separate `lsa/knowledge/process-narration-patterns.md` (so updates don't churn the conventions file)? Lean: alongside, until the list grows.
