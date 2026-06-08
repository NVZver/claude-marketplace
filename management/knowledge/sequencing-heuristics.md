> **Trace.** On load, print first: `=============== [management/knowledge/sequencing-heuristics.md] [management] ===============`

# Sequencing heuristics — knowledge

Three factors for ordering backlog items, adapted from Weighted Shortest Job First (WSJF) [unverified — SAFe framework concept] simplified for a solo workflow: dependency constraints first, then risk, then value. Each factor is grounded in data sources the project-manager agent can read in this repo.

## Roadmap table format

The agent reads the Feature Backlog table at `${specs_root}/roadmap.md`. Expected format (per `${specs_root}/roadmap.md:9`):

```markdown
| Feature | Priority | Status | Notes |
|---|---|---|---|
```

Column definitions:
- **Feature** — item name matching a pitch slug or description.
- **Priority** — `Must`, `Should`, or `Could`.
- **Status** — `backlog`, `not started`, `shipped — <plugin> v<X.Y.Z>`, `deferred`, or a custom value.
- **Notes** — free text; often contains a `Pitch: [<slug>](...)` link.

Parse failures (missing columns, unknown format) are reported to the user, not silently ignored.

## Three sequencing factors

Apply in order. Factor 1 (dependency) produces hard constraints. Factors 2 and 3 break ties among unconstrained items.

### Factor 1: Dependency order

**Rule.** If item B's pitch references work from item A (in Solution sketch, Rabbit holes, or No-gos), A ships first.

**Detection:**
1. Read each backlog item's linked pitch file (found in the Notes column or at `${specs_root}/pitches/<slug>.md`).
2. Scan the pitch's Solution sketch and Rabbit holes for cross-references to other pitches or feature branches.
3. Check if the referenced feature branch exists and is merged (`git branch -a`, `git log --oneline`). If merged, the dependency is satisfied — ignore it.
4. Unmerged dependencies create a hard ordering constraint: the dependency ships first.

### Factor 2: Technical risk

**Rule.** Items with higher uncertainty rank earlier — fail fast. Adapted from the "fail fast" principle common in lean product development [unverified — general lean/agile practice].

**Concrete signal:** Pitches with `[unverified]` or `[assumption]` markers in the Problem section carry unvalidated premises. Rank them earlier to validate or invalidate fast. Beyond this signal, the agent assesses risk from the pitch content — Rabbit holes count, Solution sketch specificity, and open questions all inform the judgment.

### Factor 3: Value delivery

**Rule.** Among items with equal dependency and risk profiles, higher-value items ship first.

**Detection:**
1. Read the Priority column: `Must` > `Should` > `Could`.
2. Read the pitch's `Why now:` metadata line (see [`pitch-structure.md`](./pitch-structure.md) §Metadata header). Pitches with concrete urgency ("third plugin just shipped — pattern is repeating") rank above pitches with no urgency ("no urgency — backlog candidate").
3. Pitches whose Problem section cites user-reported friction (quoted feedback, specific dates) rank above pitches with inferred or hypothetical problems.

## Combining factors

1. Build a dependency graph from Factor 1. Items with unmerged dependencies are blocked — they cannot be recommended until their dependencies ship.
2. Among unblocked items, sort by Factor 2 (higher risk first).
3. Break remaining ties with Factor 3 (higher value first).
4. Each item in the final ordering carries a one-sentence rationale citing which factor(s) determined its position.

## Worked example [illustrative]

Given three backlog items:

| Feature | Priority | Status | Notes |
|---|---|---|---|
| Plugin scaffolding command | Could | backlog | Pitch: [plugin-scaffold](pitches/plugin-scaffold.md) |
| Onboarding checklist | Should | backlog | Pitch: [onboarding-checklist](pitches/onboarding-checklist.md) |
| Verify coverage expansion | Must | backlog | Pitch: [verify-coverage](pitches/verify-coverage.md) |

**Factor 1 (dependency):** The plugin-scaffold pitch's Solution sketch references the onboarding checklist ("scaffolding command auto-applies checklist items"). Onboarding-checklist has no unmerged dependency. Verify-coverage has no dependency on either. Result: plugin-scaffold is blocked by onboarding-checklist.

**Factor 2 (risk):** Verify-coverage pitch has 3 Rabbit holes and a vague Solution sketch. Onboarding-checklist has 1 Rabbit hole and a concrete sketch. Result among unblocked items: verify-coverage ranks first (higher risk, fail fast).

**Factor 3 (value):** Verify-coverage is `Must`; onboarding-checklist is `Should`. Factor 3 confirms the Factor 2 ordering.

**Recommendation:**
1. Verify coverage expansion — `Must` priority, 3 rabbit holes (highest risk), no dependencies.
2. Onboarding checklist — `Should` priority, unblocks plugin-scaffold.
3. Plugin scaffolding command — blocked until onboarding-checklist ships.
