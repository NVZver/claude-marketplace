# The Vision

**Working name:** Vision (placeholder — to be named later)
**Version:** 0.5 — draft for review
**Scope:** Tech is the first pack; the **core is domain-neutral**. Substrate: **Claude Code only.** (The Claude App is something you manage yourself; the system does not target it.)
**Status:** Vision only. Build comes next, together.
**Target rigor:** Level 2.5 — spec-anchored, human may edit code under gates; the system reconciles drift gracefully rather than forbidding the edit.

---

## 0. The one sentence

> Build a personal, model-agnostic agentic engineering system whose single job is **trustworthy output** — every fact traces to a source, every line of code traces to a spec — and whose **ceremony scales to the weight of the task**. And whose operating philosophy is **ownership over automation** — the system does not think for the human; it makes the human think.

Everything below serves that sentence.

---

## 1. The throughline

The six projects are not six ideas. They are one idea maturing through five levels of abstraction:

| Project | What it is | Abstraction level |
| --- | --- | --- |
| Backbase Playwright agent | One concrete agent, one job, proven with metrics | A working instance |
| GoGlobal marketplace | A team platform across eng + PM | A product |
| Living Spec Architecture | Spec-as-source methodology | A method |
| Agentic Registry Pattern | Lazy-load map-not-territory | A mechanism |
| Agentic Platform PRD v1.2 | Vendor-neutral generalization | A standard |

Under all five sits a stable DNA. The vision keeps the DNA and discards the ceremony that does not earn its place in a personal workflow.

**The two invariants — the spine.** Trust in agent output rests on two kinds of grounding, and the system exists to guarantee both:

1. **Fact-grounding.** No claim without `Statement + Source + searchable quote`. No silent hedging. Missing a source means the claim is dropped or marked `[assumption]` / `[cannot validate]`. This is the anti-hallucination backbone present in every project.
2. **Spec-grounding.** No code without a spec requirement it traces to. The spec is the permanent source of truth; code is derived, never the reverse. This is LSA's contribution.

**The supporting DNA — non-negotiable, unchanged since the first project:**

- **Knowledge vs Actor separation.** Every file is either *what is true* (rules, patterns, checklists) or *how to act* (Role, Goal, Input, Steps, Output, Constraints). Never both.
- **Three principles.** Separation of Concerns, DRY, KISS. Every actor is `Goal + Input + Steps + Output + Constraints`, no more. Every step produces an observable result.
- **Source-of-truth first, runtime-discovered.** Read the truth before acting. Bind tools at runtime by description match. No hard-coded vendor names.
- **Production prompt techniques.** Role+Goal, Chain-of-Thought via numbered steps, few-shot in frontmatter, structured output, constraints kept distinct from quality rules.
- **Distribution + versioning.** Registry, SemVer, per-plugin CHANGELOG, bump-before-publish, one-line install.
- **Human gates + TDD + measurement** as defaults, not afterthoughts.
- **Dogfood.** Use the system to build the system.

---

## 2. First principles (the constitution)

These are the rules the whole system answers to. Short on purpose.

1. **Trust is the product.** A fast wrong answer is a defect. A grounded "I cannot verify this" is a feature.
   - **1a. Ownership over automation.** The system surfaces facts, lays out options, and demands choice. It never silently decides on the human's behalf. (See `core/ground-rules` Rule 0.)
2. **Two groundings, always.** Facts trace to sources. Code traces to specs. No exceptions; only explicit, marked assumptions.
   - **2a. Acceptance criteria are journey-shaped.** Each AC in `requirements.md` describes a user-observable behavior at the user/system boundary — how a user achieves a goal or how the system handles a corner case. Unit-test-scope checks (correctness of an internal function, helper, or non-user-observable computation) live in `test-suites.md` paths or downstream tests, not in the AC sub-block. Spec-grounding at the AC level is only meaningful when traced behavior is user-observable. (See `lsa/skills/lsa-specify/SKILL.md` User Verification 2 rows 1a + 1b.) <!-- revised: 2026-05-21-ears-journey-shape-ac 2026-05-21; renamed Gate 2 → User Verification 2 in lsa v0.6.2 -->
3. **Ceremony scales to weight.** A typo fix does not get a discovery phase. A new module does not skip one. The system *escalates* rigor; it never front-loads it.
4. **Knowledge is not Actor.** Keep what-is-true separate from how-to-act. Boundary violations are the highest-severity defect.
5. **The map is not the territory.** Load registries always; load full definitions only on match. Context is a budget.
6. **Read before you write.** In-repo config → in-repo docs → the code itself → external sources → ask the human. In that order.
7. **The human owns intent; the system absorbs reality.** Specs and gates are human-owned. Code and execution are agent-owned. But a developer may edit code directly — the system's job is then to *reconcile*: detect the divergence and offer to update the spec to match, never to block the edit or silently let the spec rot. The goal is to improve devs' lives, not retrain how they work.
8. **The system improves itself.** Every iteration leaves a trace: a retro, a metric, a changelog entry. Drift is a measured failure mode, not a surprise.
9. **Substrate-native first.** When the platform provides a primitive — picker, file API, task tracker, verifier — use it. Don't ship a text-shadow of a feature the substrate already gives you. In Claude Code: `AskUserQuestion` for decisions, `Read`/`Edit`/`Write` for files, `TaskCreate`/`TaskUpdate` for task tracking, `Skill` for skill invocation. Informs `core/ground-rules` (read protocol — rule 3) and `core/output` (picker-and-format selection).

---

## 3. Architecture — core + packs

The system splits into a domain-neutral **core** and on-demand **domain packs** — the BMAD idea, but with one deliberate inversion.

**The inversion: the core is the discipline, not the tech.** BMAD makes software development the core and treats every other domain as an expansion pack. That's backwards for a personal system, because the invariant DNA — fact-grounding, zero hedging, read-before-write, only-required-output — *does not depend on code existing*. So the core is the domain-neutral discipline, and **even tech is just a pack** — the first and most-developed one, but not privileged.

The test for every rule: **does it depend on code existing?** No → core. Yes → tech pack.

```
core/  (domain-neutral — always loaded; the spine for any pack)
├── ground-rules     fact-grounding · zero hedging · read-before-write · only-required-output
├── actor-template   Goal + Input + Steps + Output + Constraints
├── flow-selector    orchestrator's chain-of-thought: Quick / Standard / Extended (renamed from tier-selector in core v0.5.2)
└── registry         the map-not-territory loader

packs/  (load on demand)
├── tech/            TDD loop · verifier (code↔spec) · spec lifecycle · reconcile
│                    library-docs · API contracts · EARS · marketplace/SemVer
├── writing/         (later)
├── research/        (later)
└── planning/        (later)
```

**Core rules are always-on; flows govern workflow, not rules.** A deliberate decision: the four discipline rules fire on every task regardless of flow — facts get sourced even on a throwaway draft. What scales with the flow is *process ceremony* (how many phases), not *whether grounding applies*. (One refinement: "zero hedging" bans unsupported claims hidden behind vague words, not natural-language opinion stated honestly as opinion — otherwise prose goes robotic.)

**Why core-first.** The core is pure markdown ground rules with no code dependency, so it can be installed and exercised on its own before the heavy tech pack exists — catching bugs in the vision against real usage. Tech, the heaviest pack, comes after the spine is proven.

### Primitives and where each lives in Claude Code

Five primitives, mapped to Claude Code's native surfaces.

| Primitive | What it is | Claude Code home |
| --- | --- | --- |
| **Rule** | Always-on constraint | `CLAUDE.md` (loaded every session) |
| **Skill** (Knowledge) | On-demand expertise, loaded by description match | `skills/<topic>/SKILL.md` |
| **Agent** (Actor) | A worker subprocess with declared tools | Subagent |
| **Command** (Actor) | A user-invoked workflow | Slash command (a Skill) |
| **Bundle** | Versioned package of the above | Plugin, distributed via `marketplace.json` |

**Distribution: one repo, native install.** Everything ships through the `claude-marketplace` GitHub repo. Claude Code consumes it natively: `/plugin marketplace add <you>/claude-marketplace` then `/plugin install <pack>`. No build step, no per-surface packaging.

**The always-on-vs-on-demand resolution.** Claude Code makes a distinction the App couldn't: a rule that must fire on *every* task belongs in `CLAUDE.md` (genuinely always-on), while a procedure needed only *sometimes* belongs in a description-matched skill. So `ground-rules` (always-on) ships as a `CLAUDE.md` fragment; `flow-selector` and `actor-template` (on-demand) ship as skills. This ends the activation tension — the discipline that must always apply is loaded every session, not gambled on a description match.

**The registry/lazy-load principle stays.** Partly native now (Claude Code reports per-component token cost), but the load-bearing idea holds: read the map, enter only the rooms you need. The context-budget discipline for the whole system.

---

## 4. The operating model — ceremony that scales

This is the one genuinely new design decision versus the six docs. The enterprise systems are high-ceremony by default (7 phases, 12–16 row checklists, eval harnesses). For a personal daily system that is friction. The fix: **three flows, and the task picks the flow — not the calendar, not habit.** The flow names describe the *process shape*, not a hierarchy. Renamed from `T1` / `T2` / `T3` in `core` v0.5.2; the slug `core/tier-selector` became `core/flow-selector`.

| Flow | When | Loop | Groundings enforced |
| --- | --- | --- | --- |
| **Quick** (was `T1`) | Typo, rename, one-line fix, a question | Single pass. Cite sources if any claim is made. | Fact-grounding only |
| **Standard** (was `T2`) | A bug, a small task, a refactor | Discover (light) → implement TDD → verify | Both, lightweight |
| **Extended** (was `T3`) | A new feature or module | Full LSA: specify → plan → implement → verify → sync | Both, full lifecycle + permanent spec |

**The escalation rule** is the heart of it: start at the lowest plausible flow; escalate the moment the work crosses a boundary. The **orchestrator picks the flow by chain-of-thought**, then states its reasoning and the human confirms or overrides. The reasoning is visible, not hidden — that is itself the fact-grounding principle applied to the system's own decisions.

**How the orchestrator reasons (worked examples).** The trigger signals it weighs: does this touch a *new* module? introduce or change an *API/contract*? change a *data model*? exceed roughly a handful of files? lack an existing spec?

| Request | Orchestrator's chain of thought | Flow |
| --- | --- | --- |
| "Fix the typo in the login button label" | One file, one string, no behavior change, no new contract → no grounding to verify beyond the change itself. | **Quick** |
| "The date formatter returns the wrong month off-by-one" | One bug, one module that already has a spec, behavior change but no new API → needs a failing test that captures the bug, then a fix, then verify against the existing spec. No new spec needed. | **Standard** |
| "Add password-reset via email" | New behavior, new endpoint (API change), touches auth + mailer modules, no spec exists yet → crosses three boundaries. Must specify first, plan epics, implement TDD, verify every line traces to a requirement, then sync a permanent spec. | **Extended** |
| "Rename `getUser` to `fetchUser` everywhere" | Many files but zero behavior change, no contract change → mechanical. Verify nothing broke, but no spec work. | **Standard** (wide, shallow) |

The orchestrator can be wrong; that is why it *proposes* and the human confirms. Over time, corrections to its flow calls become training examples in the orchestrator's own few-shot block — the system learns your boundaries.

**The reconcile loop (Level 2.5's defining capability).** Because a developer may edit `/src` directly, the system needs a step the original LSA did not have:

```
Developer edits src/auth/login.ts by hand.
→ System detects: code no longer matches modules/auth/spec.md.
→ It does NOT block or revert. It reasons about the delta:
  "The spec says sessions expire at 30 days; the code now says 7.
   Source of the change: the human's edit (confirmed)."
→ It offers: "Update the spec to 7 days to match your edit? [Y/n]"
→ On confirm: reverse-sync — the spec absorbs reality, drift closes.
```

This is the difference between forbidding the edit (Level 3) and absorbing it (Level 2.5). Spec drift becomes a *conversation*, not a violation.

The single test the whole model answers: **what is the minimum ceremony that still guarantees grounded, spec-anchored output for *this* task?**

---

## 5. The evolution loop — how the vision stays alive

You asked to "constantly revisit how it performs and what can be improved." That requirement is itself a first-class component, not a good intention.

- **Metrics, borrowed from your own track record.** You already measured Backbase (1–5h → 10min–1h) and GoGlobal (≥50% fewer bugs, ~90% fewer one-line tickets). The three you've chosen to track personally: **accuracy to the task**, **proven facts with sources** (citation density), and **only-required-changes** (scope-creep rate). Measure them the same disciplined way you measured the team projects.
- **A retro habit.** A per-repo markdown scratchpad of mistakes the system made and the fix (the pattern is now common in the ecosystem). Promote recurring fixes into rules or skills.
- **A self-eval harness.** Lightweight version of the PRD's harness: structural checks (every actor has its sections), boundary checks (no Knowledge file holds execution flow), and banned-hedge-word lint on agent outputs. Run on change.
- **This document is versioned.** Every meaningful change to the vision gets a changelog entry below. The vision evolves the way the code does: deliberately, traceably.

---

## 6. Where you stand vs the industry (May 2026)

Honest read, grounded in current sources. Three buckets.

### Ahead — keep and defend

- **Spec-anchored lifecycle.** Your `lsa-sync` merges decisions into permanent module specs on every merge — zero-drift by design. The mainstream tools are critiqued precisely for *not* doing this: spec-kit is spec-first only (branch-per-change, no feature-lifetime spec), and OpenSpec's proposal docs drift during long implementations. This is your clearest lead.
- **Verification as the real work.** Your verifier traces every code change to a requirement and blocks untraced changes, so the human reviews spec diffs, not code diffs (bounded AI fatigue). The field's sharpest critique of SDD tooling is that they multiply artifacts without easing verification. You attack that head-on.
- **Fact-grounding as a ground rule.** `Statement + Source + searchable quote` enforced platform-wide is stronger and more general than most tools' API-hallucination fixes.

### Converged — you're in good company, sharpen the edge

- **Workflow shape.** The most-starred community framework (Superpowers) independently arrived at brainstorm → plan → subagent-per-task → TDD red-green-refactor → review-before-merge — nearly your dev-plugin pipeline. Convergent evolution validates the design. Your differentiators are the permanent spec layer and citation discipline; lead with those, not the pipeline itself.
- **Drift control.** "Re-anchoring to prevent drift" and "receipt-based gating" now ship in community plugins (Flow-Next). Same instincts as sync + verifier proofs.
- **Token-budget discipline.** Your registry pattern is now partly native (per-component token cost in `/plugin`). The principle holds; the bespoke mechanism matters less.

### Adjust — each with a concrete before/after, and a verdict

**1. EARS notation for the acceptance-criteria block.**

*Your approach (Given-When-Then) — one scenario, behaviors can tangle:*
```
Given a user with an expired session
When they request a protected endpoint
Then they receive a 401 and are redirected to login
```

*EARS — one behavior per line, keyed to its trigger:*
```
While a session is expired, when a protected endpoint is requested,
  the system shall respond with 401.
When a 401 is returned for an expired session,
  the system shall redirect to the login page.
```

EARS has five fixed patterns: Ubiquitous ("shall always"), Event ("When X… shall"), State ("While X… shall"), Optional ("Where feature X… shall"), Unwanted ("If X happens, then… shall"). You cannot write "handles errors gracefully" in EARS — no pattern accepts a vague line. GWT reads better to humans; EARS is harder to fake and one-line-to-one-test for your verifier. **Verdict: keep GWT for the spec narrative; add EARS only in the acceptance-criteria block, since that's what the verifier traces to code. A tightening, not a replacement.**

**Decision: RESOLVED → adopted.** See §2 sub-principle 2a (Acceptance criteria are journey-shaped) and `lsa/skills/lsa-specify/SKILL.md` User Verification 2 rows 1a + 1b; `lsa/skills/lsa-verify/SKILL.md` AC-ID trace; `lsa/skills/lsa-plan/SKILL.md` epic `**Covers:**` line. Feature: `vision/specs/archive/2026-05-21-ears-journey-shape-ac/`. <!-- revised: 2026-05-21-ears-journey-shape-ac 2026-05-21; renamed Gate 2 → User Verification 2 in lsa v0.6.2 -->


**2. A small library-spec cache (the Tessl idea, shrunk).**

*Your approach — reactive, fetched at discovery, cached per session:*
```
About to call stripe.charges.create()
→ /discover fetches Stripe docs via context7, records in Library Docs table
→ cite: lib:stripe:charges.create via context7
→ re-fetched next feature (cache is per-session)
```

*Tessl — proactive, pre-validated, version-pinned, never fetched:*
```
/specs/libs/stripe.spec.md written once, pinned to your Stripe version
→ agent reads it before any Stripe call, every feature, zero latency
```

Yours self-corrects but repeats work and only catches libraries the agent knew it was unsure about. **Verdict: do NOT build a 10,000-spec registry — that's their product. But write a pinned spec once for your 3–5 most-used libraries. It's a module spec pointed at an external dep. Everything else stays reactive.**

**3. Statistical eval rigor.**

*Your approach — pass/fail:*
```
DeepEval: output has expected structure → pass. Coverage: 100% of modules.
```

*Community tooling — variance-aware:*
```
Run the skill 20× on the same input → 17/20 grounded
→ Wilson 95% CI [0.62, 0.96]: "85%" is really "62–96%"
→ Elo: rank skill v2 vs v1 head-to-head to prove an edit helped
```

Pass/fail hides variance — a skill that passes once may fail 4-in-10. **Verdict: genuinely overkill for v1, defer. The day "did my edit make this better or worse?" becomes unanswerable with pass/fail, this is the tool. Not before.**

**4. The honest risk — RESOLVED to Level 2.5.** You aim at spec-as-source (Level 3) with markdown tooling, which the field calls expensive without precise, round-trip-capable spec formalism. **Decision: target Level 2.5 — spec-anchored, the developer may edit code under gates, and the system reconciles drift gracefully (see §4 reconcile loop).** This serves the real goal — improving devs' lives, not retraining them — and turns markdown's looseness from a liability into the right tool for the chosen level. Drift is handled by absorption, not prohibition.

---

## 7. Open decisions — status

1. **Target rigor level. → RESOLVED: Level 2.5.** Spec-anchored; developer may edit code under gates; system reconciles drift by absorbing the edit into the spec (§4). Goal is to improve devs' lives, not retrain them.
2. **Flow boundaries (was Tier boundaries). → DIRECTION SET, examples drafted (§4).** Orchestrator selects flow by visible chain-of-thought over boundary signals (new module? API/contract change? data-model change? file count? spec exists?), then proposes and the human confirms. Still to finalize together: the exact file-count threshold and whether to add more worked examples to the orchestrator's few-shot block.
3. **Substrate. → RESOLVED: Claude Code only.** The whole system targets Claude Code natively (skills, `CLAUDE.md`, plugins, `marketplace.json`). The Claude App is managed separately by you and is not a target of the system.
4. **First bundle. → AGREED.** Minimal `core` bundle: fact-grounding ground rule + actor template + registry + one T2 implement→verify loop. Add the reconcile step early since it defines Level 2.5. Prove the spine before porting LSA's full seven phases.
5. **Metrics. → RESOLVED. Track three:**
   - **Accuracy to the task** — did the output do what was asked, no more, no less?
   - **Proven facts with sources** — share of agent claims carrying a valid `Source + searchable quote`.
   - **Only-required-changes** — did the change touch only what the task needed? (scope-creep / untraced-change rate)
6. **Name. → DEFERRED.** "Vision" for now.

---

## Changelog

- **v0.8** — Naming clarity (Bundle B). Renamed `lsa-specify` "Gate N" → "User Verification N: <name>" (1: Requirements + Contract Trigger; 2: Test Suites + Contract + Design; 3: Final Integration). Renamed tier flow `T1` / `T2` / `T3` → `Quick` / `Standard` / `Extended` and the skill `core/tier-selector` → `core/flow-selector`. The new names describe *who* (the human) and *what* (verifying) and *process shape* respectively; the prior labels carried position but no meaning. Active behavior files updated; historical CHANGELOG / plan / archive references kept under original names with a one-line back-link note in the renamed surface. Corresponds to `core` v0.5.2 + `lsa` v0.6.2.
- **v0.7** — Discipline ground (Bundle A). Elevated two `core/output` operational checkpoints to always-on bullets in `core/CLAUDE.md`: substrate-native pickers (`AskUserQuestion` in Claude Code; never text `[a]/[b]/[c]` blocks where picker exists) and the 1–1.5 screen budget per turn (split decisions, pull don't push). Tightened `core/output` Rule 2 (Minimal) with concrete screen-budget shape; renamed Rule 5 heading to *"Concrete (decision prompts) — prompt voice"*. `lsa-specify` / `lsa-plan` / `lsa-init` Present blocks gained explicit subject-voice scaffolds so pickers stop saying *"Approve Gate 1?"* / *"Approve F3?"*. Corresponds to `core` v0.5.1 + `lsa` v0.6.1.
- **v0.6** — LSA-skill refit (credo rollout PR 2). Every LSA skill (+ `core/tier-selector` — later renamed `core/flow-selector` in v0.8) adopts a component-specific output format that satisfies the four golden rules in `core/output`. **`lsa-specify` collapses 7 confirm stops to 3 bundled gates** (Gate 1 = requirements + contract-trigger; Gate 2 = test-suites + contract + design; Gate 3 = final integration — Gates renamed "User Verification N" in v0.8). **`lsa-discover` Output becomes a 3-row table** (Module / Change / Acceptance) instead of a single-paragraph context summary; Step 2 questions (b) and (c) shift to assume-then-override. **`lsa-verify` reports lead with the verdict** (PASS / FAIL / PASS WITH WARNINGS); metadata moves below the fold. Every decision-bearing prompt uses `AskUserQuestion` in Claude Code (substrate-native) with text decision-blocks as the fallback. Corresponds to `lsa` plugin v0.4.0; `lsa/ARCHITECTURE.md` Version bumped 0.2.1 → 0.4.0.
- **v0.5** — Codified the operating-philosophy credo: §0 sentence + §2 sub-principle 1a (*Ownership over automation*) + §2 principle 9 (*Substrate-native first*). The `core/ground-rules` skill extended 4 → 6 content rules (added Rule 0 Ownership + Rule 5 No filler + Rule 1 amendment Scope + Illustrative). NEW skill `core/output` ships the four format golden rules (structured, minimal, formatted, sourced) every component cites — single source of truth for output discipline. NEW Knowledge surface `core/knowledge/output-vocabulary.md` lifts the verdict vocabulary out of any Actor body. Corresponds to `core` plugin v0.4.0. The LSA-skill refit (per-component formats) lands as Vision v0.6 alongside `lsa` plugin v0.4.0.
- **v0.4** — Simplified to **Claude Code only.** Removed the Claude App as a target (managed separately by the user), and dropped the dual-track packaging (no zips, no per-surface build). Distribution is the native `claude-marketplace` repo. Resolved the long-running activation tension: `ground-rules` ships as an always-on `CLAUDE.md` fragment; `tier-selector` and `actor-template` ship as on-demand skills.
- **v0.3** — Introduced the **core + packs** architecture (BMAD-style, inverted: the domain-neutral discipline is the core, tech is the first pack — not the privileged center). Defined the core/pack test ("does it depend on code existing?"). Decided the four discipline rules are **always-on** across all tiers; tiers govern workflow ceremony only. Refined "zero hedging" to target unsupported claims, not honest opinion. Drafted the three core skills.
- **v0.2** — Resolved five of six open decisions. Set target rigor to **Level 2.5** and added the **reconcile loop** as its defining capability (system absorbs direct code edits into the spec rather than forbidding them). Made the system **Claude-Code-first and unified** (App is secondary/optional). Gave the orchestrator **chain-of-thought tier selection** with four worked examples. Replaced the three "Adjust" items with concrete before/after examples (EARS, library-spec cache, statistical eval) and verdicts. Set the three tracked metrics (accuracy to task, proven facts with sources, only-required-changes). Dropped the GAE name; "Vision" placeholder.
- **v0.1** — Initial vision. Distilled from six projects (Backbase agent, GoGlobal marketplace, LSA, Registry Pattern, Platform PRD v1.2). Scope set to engineering; substrate set to Claude Code + Claude App. Introduced the ceremony-scales-to-weight tier model (T1/T2/T3) as the personal-use adaptation. Industry comparison grounded against the 2026 spec-driven-development landscape.
