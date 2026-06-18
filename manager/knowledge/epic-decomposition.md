> **Trace.** On load, print first: `=============== [manager/knowledge/epic-decomposition.md] [manager] ===============`

# Epic decomposition — knowledge

Rules for breaking a shaped pitch into epics, adapted from Shape Up's "scoping" phase [unverified — Basecamp Shape Up methodology]. Each epic maps to one LSA build cycle: `lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`.

**Scope.** These rules govern epics *within* one pitch. Cross-feature sequencing *between* pitches is governed by [`sequencing-heuristics.md`](./sequencing-heuristics.md) §"Factor 1: Dependency order".

## What makes a good epic

1. **Independently shippable.** Completing the epic delivers observable value even if subsequent epics are deferred. If epic B is meaningless without epic A's output, they are one epic.
2. **One-sentence scope.** The scope fits a single sentence. If the sentence contains "and" joining two unrelated outcomes, split.
3. **One LSA cycle.** The epic completes in one pass through `lsa:discover` → `lsa:specify` → `lsa:verify` → `lsa:delegate` → `lsa:reconcile`. If discovery alone requires multiple user-verification rounds for different subsystems, the epic is too wide.
4. **Clear definition of done.** State the observable result a human can verify — a passing test, a new file, a changed behavior. "Refactored internally" is not done; "X test passes with Y input" is done.
5. **Parent pitch link.** Every epic references the pitch it was decomposed from: `Parent: [<pitch-title>](../../pitches/<slug>.md)` (path is relative to the feature file at `${specs_root}/features/<slug>/`).

## Finding decomposition boundaries

Read the pitch's **Solution sketch** section (see [`pitch-structure.md`](./pitch-structure.md) §Five sections). Look for natural boundaries — distinct user interactions, separate components, or stages in the critical path that produce testable intermediate states. Adapted from Shape Up's "scoping" practice [unverified — Basecamp Shape Up methodology]: break shaped work into slices that can be completed and verified independently.

When in doubt, prefer the boundary that produces the smaller, more testable epic.

## Anti-patterns

1. **Sequential dependency chain.** If epic 2 cannot start until epic 1 merges, and epic 3 cannot start until epic 2 merges, the decomposition is a disguised waterfall. Re-split along component boundaries so epics can proceed independently.
2. **Ordinal naming / global epic counter.** Naming epics by ordinal ("Part 1", "Part 2", "Epic 5") signals the split is arbitrary, *and* a global counter is not a stable identity: it drifts and collides as work moves between stages. Observed live: the same epic carried three different ID ranges across spec, commit, and PR (E14–E18 → E19–E23 → E31–E35), two unrelated commits both claimed "E27", and IDs were non-monotonic ([`../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md:41`](../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md) — *"Epic IDs are not a stable key — they drift per stage and collide across tracks"*). Find a real boundary and key the epic by a **stable slug** (see §Epic key), not a number — the name states *what* it delivers, not *when* or *which ordinal*.
3. **Shared-state epic.** Two epics that both read and write the same new data structure cannot be verified independently. Consolidate into one epic or isolate the data structure as its own epic.
4. **Test-only epic.** An epic that adds tests but no behavior (or behavior but no tests) violates the TDD cycle. Every epic includes both the behavior and its tests.

## Epic key

Every epic gets a **stable slug** assigned once at decompose time: `<feature-slug>/<short-kebab-scope>` (e.g. `agent-robustness/retry-adapter`). The slug is derived from *what the epic delivers* — never a global ordinal counter, which renumbers and collides across stages (see Anti-patterns §2).

**Immutability rule.** The epic key is **immutable from decompose through commit and PR.** The same slug appears verbatim in the spec (`epic.md`), the commit message, the branch name, and the PR title — no renumbering, no per-stage re-derivation. A reader can grep one slug and find the epic across the whole trail. This is the fix for the observed three-range drift (E14–E18 spec ≠ E19–E23 commit ≠ E31–E35 PR) per [`../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md:41`](../../.lsa/observations/2026-06-17-tripanchor-manager-implement.md).

## Epic format

```markdown
### Epic <feature-slug>/<short-kebab-scope>: <one-sentence scope>

**Definition of done:** <observable result a human can verify>
**Parent:** [<pitch-title>](../../pitches/<slug>.md)
```

The slug from the heading is carried unchanged into the commit message subject and the PR title for this epic.

## Worked example [illustrative]

Given a pitch "Onboarding checklist for new marketplace plugins" with a Solution sketch naming (a) a new knowledge file with checklist items, (b) a `lsa:verify` integration that traces checklist items to real files:

```markdown
### Epic onboarding-checklist/knowledge-file: Onboarding checklist knowledge file

**Definition of done:** `core/knowledge/new-plugin-checklist.md` exists with numbered items; each item names a file path to create. Manual walkthrough produces a scaffold that passes `lsa:verify`.
**Parent:** [onboarding-checklist](../../pitches/onboarding-checklist.md)

### Epic onboarding-checklist/verify-drift: Verify integration for checklist drift

**Definition of done:** `lsa:verify` reads the checklist file and reports a finding when a listed file path does not exist in the plugin directory. Test: delete one expected file, run verify, observe the finding.
**Parent:** [onboarding-checklist](../../pitches/onboarding-checklist.md)
```

The `onboarding-checklist/knowledge-file` epic is shippable alone (the checklist works manually). `onboarding-checklist/verify-drift` adds automation but is not required for the checklist to deliver value. Both slugs travel unchanged into their commit subjects and PR titles.
