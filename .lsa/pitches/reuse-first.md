Shaped by: Nikita Zverev
Date: 2026-07-01
Status: approved
Role lens: developer-tooling product manager
Gate decisions:
- Fork A (rung 1): keep rung 1 as an explicit ladder rung with a cross-ref link to ground-rules R3.
- Fork B (scope gate): description-based auto-trigger — frontmatter names coding verbs/nouns; silent on prose/analysis.
Why now: low urgency — discipline-completeness driver. The pre-write reflex is the clearest
missing rung between spec ("what") and reconcile ("verify"), and an external plugin (ponytail)
offers a ready ladder to adapt down to our constitution.

# Authoring-time reuse ladder (`core/reuse-first`)

An always-on `core` skill that runs a 7-rung reuse ladder on coding tasks before code is
written — closing the gap between the spec and reconcile's after-the-fact "only" check.

## Problem

Coding agents in this marketplace over-deliver and reinvent at authoring time. The
*philosophy* of writing less code already exists — but only as philosophy and as
after-the-fact verification, never as an operational pre-write reflex:

- `core/ground-rules` Rule 4 states the principle — "Deliver exactly the task. No padding,
  no unrequested extras" (`core/skills/ground-rules/SKILL.md:79`). It is a content rule, not
  an authoring procedure.
- `lsa:reconcile`'s "only" check catches over-delivery *after* the diff exists — "every
  changed hunk traces to a requirement; an untraced hunk is over-delivery"
  (`lsa/skills/reconcile/SKILL.md:33`). reconcile is explicitly "the *after* check"
  (`lsa/skills/reconcile/SKILL.md:8`).
- `core/flow-selector` scales *ceremony* by task weight (`core/skills/flow-selector/SKILL.md:19-21`),
  but says nothing about how much code a given task should produce.

The gap: nothing prevents over-delivery *before* the code is written. reconcile catches it
post-hoc, which forces rework. There is no authoring-time "how" sitting between the spec
("what") and reconcile ("verify").

Who has it: every coding agent (and the human owning the loop) in a Standard or Extended
flow. Evidence: the marketplace's own after-check design — reconcile's "only" check exists
precisely because over-delivery is expected in the diff
(`lsa/skills/reconcile/SKILL.md:33`) [assumption: the recurring-cost claim is inferred from
the presence of the after-check, not from a logged incident count].

Current workaround: agents rely on the Rule 4 principle plus habit, then reconcile flags
untraced hunks and drift after the fact — rework, not prevention.

Definition of success: an always-on skill that, on coding tasks, walks a reuse ladder before
writing — so reinvention and over-delivery are caught before the diff exists, and reconcile's
"only" check (`lsa/skills/reconcile/SKILL.md:33`) surfaces fewer untraced hunks.

## Appetite

Small, single-skill addition. One new always-on skill `core/skills/reuse-first/SKILL.md` in
actor-template shape (Goal/Input/Steps/Output/Constraints per
`core/skills/actor-template/SKILL.md:14-21`); one cross-reference line wired into the
`core/CLAUDE.md` always-on block; and — in the same commit — a `core/CHANGELOG.md` entry, a
SemVer bump in `core/.claude-plugin/plugin.json`, and README deltas (`README.md` six-plugins
area if the user-visible surface changes, `core/README.md` skill list), per the per-plugin
CHANGELOG + SemVer discipline (`CLAUDE.md` "Per-plugin SemVer + CHANGELOG").

Out of appetite: any new command surface; an intensity dial; a debt-comment ledger; any
change to test strategy; and reshaping ground-rules or reconcile (this skill cross-references
them, never restates them).

## Solution sketch

- **Key user interactions:** on a coding task, the agent walks a 7-rung reuse ladder before
  writing code; on prose/analysis tasks the skill is silent (activation via description-based
  auto-trigger — Fork B decision). Borrowed from the external ponytail plugin
  (`github.com/DietrichGebert/ponytail`) [external source — not verified against the repo],
  stripped of everything that conflicts with this constitution (see No-gos).
- **Main components:** one new `core/skills/reuse-first/SKILL.md`; one line in
  `core/CLAUDE.md`; `core/CHANGELOG.md` + `core/.claude-plugin/plugin.json` bump;
  `README.md` + `core/README.md` deltas. No other plugin is touched.
- **Critical path:** coding task detected → ladder rungs evaluated in order → shortest working
  diff (or no code at all) → reconcile's "only" check passes cleaner. The ladder:
  1. Understand the real flow end-to-end FIRST (explicit rung; cross-refs ground-rules R3 —
     Fork A decision).
  2. Does it need to exist at all (YAGNI)?
  3. Already in this codebase — grep for an existing helper/util/type/pattern and reuse it.
  4. Stdlib/builtin does it.
  5. Native platform feature (CSS over JS, DB constraint over app code).
  6. An already-installed dependency (never add a new dep for a few lines).
  7. Otherwise, the shortest working diff.
  Plus two rules: root-cause-not-symptom (grep every caller of the function you're about to
  touch; fix once in the shared path, not per-symptom), and deletion over addition / boring
  over clever.

## Rabbit holes

1. Restating instead of cross-referencing — the ladder overlaps `ground-rules` R3
   (`core/skills/ground-rules/SKILL.md:68-75`) and R4 (`:79`) and reconcile's "only" check
   (`lsa/skills/reconcile/SKILL.md:33`). Restating them bloats the skill and invites drift.
   Mitigation: cross-reference by markdown link, never restate — consistent with `core/output`
   being the single source-of-truth for output discipline (`core/README.md:8`).
2. Scope-gating — an always-on skill that must stay silent on prose/analysis needs a concrete
   activation mechanism (resolved: description-based auto-trigger, Fork B).
3. No behavioral gate — a prompt-only skill has no runtime test, yet the `core` module carries
   a test suite (`core/tests/**/*.md` in `.lsa.yaml:19`, e.g. the D2 assertion cited at
   `core/README.md:8`). Mitigation: add anchored assertions to the core test suite in the same
   epic, per zero-tech-debt discipline (`feedback_zero_tech_debt_tolerance.md`).

## No-gos

1. This pitch does NOT adopt the "ponytail / lazy / caveman" metaphor naming — it violates the
   concrete-names-no-metaphor rule ("a name must say what it does, with zero metaphor" —
   `feedback_concrete_names_no_metaphor.md:12`). The skill is named `reuse-first`.
2. This pitch does NOT add a lite/full/ultra intensity dial — `core/flow-selector` already
   scales ceremony by task weight (`core/skills/flow-selector/SKILL.md:19-21`); a persistent
   global dial contradicts "the task picks the flow, not habit." The ladder is always-on, no dial.
3. This pitch does NOT add a debt-comment ledger or `-debt` / `-audit` commands — it violates
   zero-tech-debt-tolerance (`feedback_zero_tech_debt_tolerance.md:10`), and LSA Level 2.5
   reconcile already absorbs drift into the spec (`lsa/skills/reconcile/SKILL.md:43`); a
   parallel ledger duplicates and contradicts it.
4. This pitch does NOT apply YAGNI to tests — it conflicts with the TDD-first methodology.
   Test discipline defers to TDD; this skill does not touch test strategy.
5. This pitch does NOT add `-gain` / `-review` command surface — reconcile's "only" check
   (`lsa/skills/reconcile/SKILL.md:33`), the `prompt-engineer` agent, and the built-in
   `/code-review` and `/simplify` already cover that ground.
