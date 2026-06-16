# Parallel-Agent-Delivery — Prior-Art Spike (Epic 0)

- **Date:** 2026-06-14
- **Source pitch:** [`.lsa/pitches/parallel-agent-delivery.md`](../pitches/parallel-agent-delivery.md) (components enumerated at `:31`)
- **Roadmap row:** `.lsa/roadmap.md:58` (Epic 0)
- **Spec:** [`.lsa/features/2026-06-14-parallel-agent-delivery-epic-0/requirements.md`](../features/2026-06-14-parallel-agent-delivery-epic-0/requirements.md)
- **Purpose:** For each of the 6 pitch components, give a **build / borrow / hybrid** verdict grounded in cited prior art, so Epics 1–4 integrate existing primitives instead of reinventing CI. **Informs, does not block** the build epics.
- **Doc-mode note:** This is a research artifact (`.lsa.yaml:7` `mode: docs`); it is not in any module's `artifact_paths` and ships no code.

## Method

- Sources rated **primary vendor docs > reputable engineering blog > inferred**. Every verdict cites ≥2 sources, each with a searchable verbatim quote (per `core/ground-rules` Rule 1, `core/skills/ground-rules/SKILL.md:36`).
- Three external anchors already in the pitch were independently re-verified; **one is wrong and is corrected below** (see Open Questions O1).
- In-repo components (5, 6) grounded against the live repo; external components (1–4) grounded via web search of official docs (GitHub, Claude Code, Cursor, Cognition, GitLab, Mergify) plus arXiv.

---

## Component 1 — Layered quality gate

Repo-local gate scripts (lint/typecheck/test/build/migration-applied) run as GitHub **required status checks**, PLUS a spec-conformance check (`lsa:reconcile`) run by an agent **other** than the implementer (grader isolation).

- **Verdict:** **Hybrid** — borrow the enforcement substrate; build only the independent grader.
- **Borrowed primitive:** GitHub branch-protection / rulesets **required status checks** (enforcement slot) + the merge queue substrate. Repo gate scripts plug in as named Actions checks.
- **Net-new to build:** the gate-script bundle + Actions wiring, and — the genuinely novel piece — the **spec-conformance grader run in a context with no write access to the tests/gate it grades**. GitHub gives the gate slot, not grader-independence.
- **Prior art:**
  - GitHub docs — "Required status checks must have a `successful`, `skipped`, or `neutral` status before collaborators can make changes to a protected branch." (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub docs (bypass authority) — "By default, the restrictions of a branch protection rule don't apply to people with admin permissions" (same URL) → "merge only on green" is only as strong as bypass-list hygiene.
  - Graphite — "The Not Rocket Science Rule Of Software Engineering: automatically maintain a repository of code that always passes all the tests" (https://graphite.com/blog/bors-google-tap-merge-queue) — the principle the gate enforces.
  - Anthropic *Sycophancy to Subterfuge* — "editing the test file so that the tests don't catch it" (https://arxiv.org/html/2406.10162v3) — primary evidence models tamper with their own tests ⇒ motivates grader isolation.
- **Reason:** the merge-gate machinery is commodity; the unwritable-by-the-work spec grader is the differentiator.
- **Informs:** **Epic 1** (layered gate + reconcile-as-required-check).

## Component 2 — Fleet dispatcher (epics → worktrees → agents → PRs)

One worktree + feature branch + agent + PR per disjoint epic; likely a new optional `fleet` plugin.

- **Verdict:** **Hybrid** — every isolation/spawn/converge primitive exists; orchestrate, don't reinvent.
- **Borrowed primitive:** `git worktree` (Claude Code wraps it via `--worktree` / `EnterWorktree` / `isolation: worktree`); Claude Code subagents/Task API (spawn+coordinate); `gh` CLI / PR API (convergence); Conventional Commits `type(scope)` (roll-up grouping key).
- **Net-new to build:** the **epic decomposer** that splits a backlog into *disjoint* epics (collision-avoidance — the part vendors leave to the human), the dispatch policy (worktree+branch+agent per epic, configurable cap), and the gated merge + roll-up reporter.
- **Prior art:**
  - Claude Code docs — "Running each Claude Code session in its own worktree means edits in one session never touch files in another" (https://code.claude.com/docs/en/worktrees).
  - Cognition/Devin — coordinator "scopes the work, assigns each piece to a managed Devin … resolves any conflicts, and compiles the results," each "running in its own isolated virtual machine" (https://cognition.ai/blog/devin-can-now-manage-devins) — the fleet pattern, already shipped.
  - GitHub Copilot coding agent — "will simultaneously open both a branch and a pull request, which will evolve as Copilot works" (https://docs.github.com/copilot/how-tos/use-copilot-agents/coding-agent/assign-copilot-to-an-issue) — PR-per-agent as the industry convergence unit.
  - Conventional Commits v1.0.0 — "A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., `fix(parser):`" (https://www.conventionalcommits.org/en/v1.0.0/).
- **Reason:** isolation + spawning + PR convergence are solved; disjoint-epic decomposition is the real net-new value.
- **Informs:** **Epic 2** (the `fleet` plugin).

## Component 3 — Serialized merge (keep `main` always-green)

GitHub merge queue when available; else local rebase-onto-main + re-run gate before each merge. Defends against semantic ("green alone, red merged") conflicts.

- **Verdict:** **Borrow** (with a thin local fallback to build).
- **Borrowed primitive:** GitHub **merge queue** — tests each PR against the up-to-date base + queued PRs, merges only the tested SHA. Cross-system precedent: GitLab merge trains, Bors-NG, Mergify, Graphite.
- **Net-new to build:** the **local serialized fallback** (rebase → re-gate → merge-if-green → next) for repos without merge queue enabled.
- **Prior art:**
  - GitHub docs — "The merge queue will ensure the pull request's changes pass all required status checks when applied to the latest version of the target branch and any pull requests already in the queue" (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
  - GitHub docs — "You **must** use the `merge_group` event to trigger your GitHub Actions workflow when a pull request is added to a merge queue" (same URL) — required wiring; without it the queue stalls.
  - GitLab docs — "the second merge train pipeline runs on the changes of both merge requests combined with the target branch" (https://docs.gitlab.com/ci/pipelines/merge_trains/) — same pattern, established prior art.
  - Mergify — "two PRs that individually pass tests – one renames a function, and another adds a call to the old name, resulting in a broken main after sequential merges" (https://mergify.com/blog/the-origin-story-of-merge-queues) — the semantic-conflict ("green alone, red merged") problem named.
- **Reason:** the queue solves the exact serialize-and-test-against-post-merge-state problem; we only author the no-queue fallback.
- **Informs:** **Epic 1 / Epic 3** (merge convergence).

## Component 4 — Autonomy policy (`manual | semi | auto`, default `manual`)

A `.lsa.yaml` knob: manual = human merges; semi = auto-merge on green; auto = full SDLC incl. deploy.

- **Verdict:** **Hybrid (lean Borrow)** — borrow the graduated mode-ladder model + conservative default; build the SDLC-stage semantics and the config surface.
- **Borrowed primitive:** Claude Code's mode ladder (`default` reads-only → … → `bypassPermissions`) with a classifier gating the loose tiers; HITL-by-default safety posture. Maps ~1:1 to manual/semi/auto.
- **Net-new to build:** binding levels to *SDLC outcomes* (semi = auto-merge-on-green; auto = deploy authority) and the per-project `.lsa.yaml` knob — nobody ships exactly that policy.
- **Prior art:**
  - Claude Code docs — `default` = "Reads only"; and "In every mode except bypassPermissions, writes to protected paths are never auto-approved" (https://code.claude.com/docs/en/permission-modes) — conservative-default + graduated-escalation pattern.
  - Claude Code docs — auto mode: "A separate classifier model reviews actions before they run, blocking anything that escalates beyond your request," blocking "Production deploys and migrations" by default (same URL) — precedent for gating the deploy tier.
  - Cursor — Auto-review "allowing low-stakes actions to run freely while slowing down when an action crosses a meaningful boundary" (https://cursor.com/blog/agent-autonomy-auto-review).
  - Anthropic — "not moving toward fully unsupervised autonomy but toward selective autonomy" (https://www.anthropic.com/research/measuring-agent-autonomy) — supports default = manual, opt-in escalation.
- **Reason:** the named-levels + safe-default mental model is well-established; only the SDLC binding is ours.
- **Informs:** later epics (semi/auto tiers; manual ships first per the pitch Appetite).

## Component 5 — Transparency roll-up

A fleet-scoped, evidence-over-assertion roll-up reusing the `lsa-stage-reports` contract.

- **Verdict:** **Borrow** — reuse the in-repo report contract; build only the fleet-scope wrapper.
- **Borrowed primitive:** the `lsa-stage-reports` report shape, which itself mandates `core/output` Rule 7's compressed inspection table (`| # | file:line | type | summary |`) for the files section; Conventional Commits `type(scope)` as the grouping key.
- **Net-new to build:** the **fleet-scope additions** — per-agent attribution, per-epic gate verdicts, proven facts (checks passed, SHA, healthcheck), open items — layered over one stage report per agent.
- **Prior art:**
  - `lsa-stage-reports` pitch — "the knowledge file mandates Rule 7's compressed inspection table verbatim as the files section; no new table schema" (`.lsa/pitches/lsa-stage-reports.md:30`).
  - `core/output` Rule 7 — the single-change template + compressed inspection table for batches (`core/skills/output/SKILL.md:88-95`).
  - Conventional Commits v1.0.0 — `type(scope)` grouping (https://www.conventionalcommits.org/en/v1.0.0/), per Component 2.
  - Pitch self-reference — "this pitch reuses (and may supersede) it for the report shape; one report contract, fleet roll-up on top" (`.lsa/pitches/parallel-agent-delivery.md:42`).
- **Reason:** the report contract is being authored anyway (lsa-stage-reports ships first); the fleet only needs a roll-up layer.
- **Informs:** **Epic 4** (transparency roll-up). Dependency: lsa-stage-reports ships first (roadmap `:57`).

## Component 6 — `core/ground-rules` addition: "done = a cited, gate-proven predicate"

A new content rule: an agent may only report a state a deterministic, agent-inaccessible gate proved; anything else is reported as attempted/unknown with evidence attached.

- **Verdict:** **Build** (thin) — a new content rule, but a small extension of an existing 7-rule structure and justified entirely by borrowed evidence.
- **Borrowed primitive:** the existing `core/ground-rules` rule structure (currently "seven content rules", `core/skills/ground-rules/SKILL.md:3`) and Rule 1's `claim → source + searchable quote` shape — "done" becomes a claim subject to the same discipline, with the gate artifact as its source.
- **Net-new to build:** the rule text itself + its placement among the existing rules + a regression probe (precedent: `scripts/lint.sh` C4–C6, `.lsa/VISION.md:267`).
- **Prior art:**
  - S7 failure mode (re-verified) — "The agent consistently turns a partial or unverified state into a completion claim," from a study of "20,574 coding-agent sessions from 1,639 repositories" (https://arxiv.org/abs/2605.29442). This is the failure the rule prevents.
  - Claude Code best-practices (re-verified, exact) — "Claude stops when the work looks done. Without a check it can run, \"looks done\" is the only signal available, and you become the verification loop" (https://code.claude.com/docs/en/best-practices). The why-a-gate-is-mandatory.
  - `core/ground-rules` Rule 1 — "Every such claim must come with a source … and a searchable quote" (`core/skills/ground-rules/SKILL.md:36`) — the existing rule the done-predicate extends.
- **Reason:** the rule is small and local; the evidence and rule-pattern are borrowed, only the wording is authored.
- **Informs:** **Epic 1** (and cross-cutting — every epic's agents report under it).

---

## Verdict roll-up

| # | Component | Verdict | Borrowed primitive | Net-new to build | Informs |
|---|---|---|---|---|---|
| 1 | Layered quality gate | **Hybrid** | GitHub required checks + merge queue | gate scripts + isolated spec-conformance grader | Epic 1 |
| 2 | Fleet dispatcher | **Hybrid** | git worktree + subagent API + `gh` PR | disjoint-epic decomposer + dispatch policy | Epic 2 |
| 3 | Serialized merge | **Borrow** | GitHub merge queue (`merge_group`) | local rebase + re-gate fallback | Epic 1/3 |
| 4 | Autonomy policy | **Hybrid (lean Borrow)** | Claude Code mode ladder + HITL default | SDLC-stage semantics + `.lsa.yaml` knob | later epics |
| 5 | Transparency roll-up | **Borrow** | lsa-stage-reports + Rule 7 + Conv. Commits | fleet-scope attribution + proven-facts roll-up | Epic 4 |
| 6 | Done-predicate ground rule | **Build** (thin) | ground-rules Rule 1 pattern + S7/best-practices evidence | rule text + regression probe | Epic 1 + cross-cutting |

**Headline:** zero components are "Build from scratch." Four borrow GitHub-native or in-repo primitives; the only genuinely net-new engineering is the **disjoint-epic decomposer** (Component 2) and the **isolated spec-conformance grader** (Component 1) — both already named in the pitch as the differentiators.

## Open questions / risks

- **O1 (correction — affects the pitch).** The pitch cites `arxiv.org/html/2505.19955v1` for "agents fabricate success even when explicitly instructed not to" / "rewrite testing code." **That id is wrong** — `2505.19955` is *MLR-Bench* (ML-research eval; its real finding is result fabrication "in 80% of the cases"). The correct anchor is **arXiv:2406.10162** *Sycophancy to Subterfuge* (Anthropic), quote: "editing the test file so that the tests don't catch it." Also soften the phrasing: the paper's claim is *zero-shot generalization despite harmlessness training* ("adding harmlessness training to our gameable environments does not prevent reward-tampering"), not defiance of an explicit instruction. **Action for Epic 1:** fix the pitch citation before it propagates into a spec.
- **O2 (Component 1/3).** Required checks and merge queue **do not bind admins by default**; ruleset bypass lists exempt members wholesale. "Merge only on green" requires an empty (or owner-only) bypass list as explicit policy.
- **O3 (Component 2).** The pitch's "vendors cap ~8 parallel" is **only partly sourced** — Cursor's "up to eight agents" is blog-cited, not first-party; Claude Code documents **no numeric cap**. Recommendation: make the cap configurable, default low (≈4), and justify by review-overhead + rate-limits, not a magic number.
- **O4 (Component 2).** Worktree **disjointness of edits is solved; disjointness of epic *logic* is not** — overlap surfaces only at PR/merge time. The epic decomposer carries this risk; Component 3's re-gate-on-merge is the backstop.
- **O5 (Component 3).** GitHub merge queue availability has historically varied by plan; the `merge_group` Actions trigger is mandatory wiring. Verify plan eligibility before committing to it as the primary path (the local fallback covers the gap).
- **O6 (Component 5).** This component **depends on `lsa-stage-reports` shipping first** (roadmap `:57`); if that pitch is reshaped, the fleet roll-up's base contract moves with it.
