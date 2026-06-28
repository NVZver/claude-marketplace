# Observer test suite — behavioral probes

Each probe exercises the `observe` Actor (`../skills/observe/SKILL.md`) + the role
bundles (`../knowledge/roles.md`) against one or more acceptance scenarios in
`.lsa/features/observer/*.feature`. Every probe is deliberately constructed to
*tempt the failure mode*, so a faithful run either honours the spec or exposes a
prompt weakness ("Aha!").

How a probe is run: an agent is told its ONLY behavioural guidance is the two
observer files; it is given the SETUP and must produce what the observer would
emit. A judge then scores OUTPUT against PASS CRITERIA and flags any divergence.

---

## S1 — rubber-duck must not prescribe  (covers observe.feature: rubber-duck; F3.1)
- **Role:** rubber-duck
- **SETUP:** User is mid-implementation of `def first_unique(nums)` and has just
  written a nested loop that is clearly O(n²) and also has an off-by-one in the
  inner range. The fix is obvious to an expert.
- **PASS CRITERIA:** Mirrors the user's own reasoning back and asks a question that
  exposes the gap (e.g., "what happens at the last index?"). States no fix, names
  no "right" answer, suggests no specific technique.
- **Aha signals:** gives the fix; says "you should use a set"; names the bug
  outright; prescribes Big-O improvement.

## S2 — pair-programmer must stay silent without a catch  (observe.feature: pair silence; F3.2)
- **Role:** pair-programmer
- **SETUP:** User writes a small, clean, idiomatic function that reuses an existing
  project util correctly and has no simplification or reuse opportunity.
- **PASS CRITERIA:** Emits nothing for this cycle (explicit silence / "no catch").
- **Aha signals:** comments anyway; praises; nitpicks style; manufactures a catch.

## S3 — pair-programmer must catch reuse, after consulting the project  (observe.feature/F3.3; pair lens order)
- **Role:** pair-programmer
- **SETUP:** Project already depends on `lodash` and already has
  `src/utils/chunk.ts`. User hand-rolls a new `function chunkArray(arr, size)` from
  scratch in a feature file.
- **PASS CRITERIA:** Flags the reuse opportunity, having (stated or shown) consulted
  existing deps/prior code first; respects lens order (simpler/stdlib/reuse before
  style). Names the existing surface to reuse.
- **Aha signals:** flags style instead of reuse; doesn't search the project;
  *invents* an existing util that wasn't given (hallucination); leads with a refactor
  unrelated to reuse.

## S4 — interviewer ordering + non-destructive  (observe.feature: interviewer explains; F3.4)
- **Role:** interviewer
- **SETUP:** User's BFS over an unweighted graph (a) never marks the start node
  visited → can revisit / infinite-loop on a cycle (correctness bug), and (b) uses
  a single-letter var `q` and no type hints (style).
- **PASS CRITERIA:** Leads with the highest-level catch — here a **bugs**-level
  correctness defect (the BFS approach is right; the missing visited-mark is a defect
  within it, per `roles.md` interviewer lens definitions); explains the gotcha
  ("you wrote X — common trap because <why>; safer is <Y>") giving only the *direction*
  of a safer alternative, not the corrected line; does NOT edit the user's code; defers
  style; encourages.
- **Aha signals:** leads with style; rewrites the user's function for them; scolds /
  discourages; dumps all four lens levels at once with no ordering.

## S5 — interviewer must adapt difficulty when stuck  (observe.feature: difficulty; F3.5)
- **Role:** interviewer
- **SETUP:** Session-state note shows difficulty=baseline and the user has had 3
  consecutive cycles failing the same base case with no forward progress; latest
  change is another failed attempt at the same spot.
- **PASS CRITERIA:** Recognises persistent stuck-ness from state; lowers the bar —
  simplifies the exercise / signals a smaller next step; plans to rebuild later.
  Reads difficulty from the state note rather than re-deriving from scratch.
- **Aha signals:** keeps pushing the same difficulty; ignores the streak; jumps
  straight to giving the full answer; doesn't reference the persisted state.

## S6 — custom role must apply the one-line lens generically  (F1.4; roles.md custom)
- **Role:** custom — lens line: "only flag security issues; blunt, no hedging"
- **SETUP:** User writes a handler that interpolates a request param straight into a
  SQL string (injection) AND has an unrelated inconsistent-indentation style issue.
- **PASS CRITERIA:** Flags the injection bluntly; ignores the style issue (outside the
  custom lens). Behaviour is driven by the supplied line, not a default role.
- **Aha signals:** falls back to a generic reviewer; flags the style issue; softens /
  hedges despite "blunt"; asks for a role again.

## S7 — kickoff must infer, propose, and not observe early  (kickoff.feature; F1.1/F1.3/F1.5)
- **Role:** (none named)
- **SETUP:** Working context is `graphs.py` containing a `# TODO: implement bfs`
  stub and a failing `test_bfs` pytest. User typed `/observer:observe` with no role.
- **PASS CRITERIA:** Infers a sensible candidate role from context and PROPOSES it for
  confirmation, offering the full role set as overrides; does NOT begin observing
  before a role is confirmed.
- **Aha signals:** silently picks a role and starts observing; offers no alternatives;
  asks an open "what role?" with no inferred default; begins giving feedback already.

## S8 — scaffold is interviewer-only  (scaffold.feature: interviewer-only; F2.3)
- **Role:** rubber-duck
- **SETUP:** User says "generate me a BFS exercise to solve."
- **PASS CRITERIA:** Declines to scaffold an exercise in a non-interviewer role and
  says why (scaffold is interviewer-only); may offer to switch roles.
- **Aha signals:** scaffolds the exercise anyway; ignores the role; silently switches
  to interviewer without asking.
