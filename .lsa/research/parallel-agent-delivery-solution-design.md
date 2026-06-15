# Parallel-Agent-Delivery — Solution Design (delegate vs. build)

- **Date:** 2026-06-14
- **Builds on:** [`parallel-agent-delivery-prior-art.md`](./parallel-agent-delivery-prior-art.md) (the build/borrow verdicts)
- **Source pitch:** [`.lsa/pitches/parallel-agent-delivery.md`](../pitches/parallel-agent-delivery.md)
- **Purpose:** For each of the 6 components: a sharp **problem statement**, **what we delegate and to what** (the borrowed primitive — we do not rebuild it), and **our layer on top** (the net-new part that actually completes the problem-solving). This is the bridge from the spike to Epics 1–4.

The shape of every point is the same: *the substrate already exists; the thing that makes it ours is the thin layer that the substrate cannot provide.*

---

## 1. Layered quality gate

- **Problem.** The agent that writes the code is also the one that judges it, and nothing forces a "done" claim to be true — so partial/unverified work gets reported as complete (S7), and red code can reach `main`.
- **Delegate to.** **GitHub branch-protection required status checks** as the enforcement slot; the project's own commands (lint · typecheck · test · build · migration-applied) run as GitHub Actions checks. We integrate this; we build no CI engine. (prior-art C1: *"Required status checks must have a successful … status before collaborators can make changes."*)
- **Our layer on top.**
  1. A **quality-gate script contract** — a per-project config mapping each check name → command, so any repo plugs its real commands into the required-check slots.
  2. **`lsa:reconcile` wired as a required check, run by a context with no write access to the tests/gate it grades** — the *isolated spec-conformance grader*. GitHub gives the slot; the unwritable-by-the-work grader is ours. Acceptance `.feature` scenarios + gate config are not editable within the same epic's change. This is the differentiator — no other tool gates merges on "all of and only what was asked," graded independently.

## 2. Fleet dispatcher

- **Problem.** We need to run N agents on disjoint backlog epics at once without them colliding on files, and converge each to `main` as a reviewable unit.
- **Delegate to.** **`git worktree`** (one per agent — Claude Code wraps it via `EnterWorktree` / `isolation: worktree`), the **subagent/Task API** for spawning, and the **`gh` CLI / PR API** for PR-per-agent convergence. All three are off-the-shelf. (prior-art C2: *"edits in one session never touch files in another."*)
- **Our layer on top.**
  1. The **disjoint-epic decomposer** — split a backlog into epics that don't *logically* overlap (vendors isolate file edits, none guarantee epic-logic disjointness; this is the real risk we own).
  2. A **dispatch policy** — one worktree + branch + agent + PR per epic, with a **configurable concurrency cap (default ~4)**, plus teardown baked into the gate (worktrees are a known cleanup footgun).
  3. Likely a new optional **`fleet` plugin** (depends on core + lsa + management).

## 3. Serialized merge (keep `main` always-green)

- **Problem.** Two PRs each pass alone but break when merged together (semantic / "green alone, red merged" conflicts); `main` must never go red.
- **Delegate to.** **GitHub merge queue** via the **`merge_group` event** — it tests each PR "against the latest version of the target branch and any pull requests already in the queue" and merges only the tested SHA. Established pattern (GitLab merge trains, Bors, Mergify). (prior-art C3.)
- **Our layer on top.**
  1. The **`merge_group` Actions wiring** (mandatory, or the queue stalls).
  2. A **local rebase-onto-main + re-gate fallback** (rebase → re-run gate → merge-if-green → next) for repos where merge queue isn't enabled.
  3. The rule that **only the serialized merge step writes `.lsa/roadmap.md` status** — agents *propose* done, the merge step *commits* it (defends the shared-roadmap race, pitch rabbit-hole 8).

## 4. Autonomy policy

- **Problem.** Different users / situations want different amounts of human-in-the-loop; full-auto must never be the silent default.
- **Delegate to.** The **mental model**, not an implementation: borrow **Claude Code's graduated mode ladder** (conservative default → classifier-gated escalation) and the **HITL-by-default safety posture** (Anthropic: *"selective autonomy,"* not unsupervised). (prior-art C4.)
- **Our layer on top.**
  1. A **`.lsa.yaml` autonomy knob: `manual | semi | auto`, default `manual`.**
  2. **Binding each level to an SDLC outcome** — `manual` = human merges; `semi` = auto-merge on green; `auto` = full SDLC incl. deploy + healthcheck. This SDLC binding is what no tool ships. `semi`/`auto` are later epics, gated on `manual` proving safe in dogfooding.

## 5. Transparency roll-up

- **Problem.** Runs end with "Done, you can check" instead of evidence of what changed — the human re-runs `git status`/`git diff` and re-reads transcripts to reconstruct the work.
- **Delegate to.** Our own in-repo contract: the **`lsa-stage-reports`** report shape (which mandates **`core/output` Rule 7**'s compressed inspection table) + **Conventional Commits `type(scope)`** as the file-grouping key. We reuse, not reinvent — one report contract. (prior-art C5; pitch `:42`.)
- **Our layer on top.** The **fleet-scope roll-up** layered over one stage report per agent: **per-agent attribution · per-epic gate verdicts · proven facts (checks passed, SHA, healthcheck) · open items.** Evidence-over-assertion: the gate output *is* the report. Dependency: `lsa-stage-reports` ships first (roadmap `:57`).

## 6. "Done = a cited, gate-proven predicate" ground rule

- **Problem.** Agents fabricate completion "even after safety training" — prompting alone can't stop it; a state may only be reported if something unwritable-by-the-agent proved it.
- **Delegate to.** Nothing external — borrow the **existing `core/ground-rules` Rule 1 pattern** (a claim needs a source + searchable quote) and treat "done" as a claim whose *source is the gate artifact*. Evidence borrowed: S7 (*"turns a partial or unverified state into a completion claim"*) + Claude best-practices (*"'looks done' is the only signal available"*).
- **Our layer on top.** A **new always-on content rule**: an agent may report a state (`merged @ <sha>`, `migration applied`, `deployed`) only when a deterministic, agent-inaccessible gate proved it and the rule cites the gate artifact; anything else is reported `attempted` / `unknown` with evidence attached. Plus a **regression probe** (lint precedent: `scripts/lint.sh` C4–C6).

---

## Delegate-vs-build at a glance

| # | Component | Delegate to (borrowed) | Our layer (net-new) | Epic |
|---|---|---|---|---|
| 1 | Quality gate | GH required checks + project commands as Actions | gate-script contract + **isolated reconcile grader** | 1 |
| 2 | Fleet dispatcher | `git worktree` + subagent API + `gh` PR | **disjoint-epic decomposer** + dispatch policy + `fleet` plugin | 2 |
| 3 | Serialized merge | GH merge queue (`merge_group`) | `merge_group` wiring + local rebase/re-gate fallback + roadmap-write lock | 1/3 |
| 4 | Autonomy policy | CC mode-ladder model + HITL default | `.lsa.yaml` `manual\|semi\|auto` + SDLC-outcome binding | later |
| 5 | Transparency roll-up | lsa-stage-reports + Rule 7 + Conv. Commits | fleet-scope attribution + proven-facts roll-up | 4 |
| 6 | Done-predicate rule | ground-rules Rule 1 pattern + S7/best-practices | new always-on rule + regression probe | 1 + cross-cutting |

**The whole product in one line:** we delegate *isolation, enforcement, and serialization* to GitHub + git + Claude Code, and build the three things none of them provide — a **grader the work cannot edit**, a **decomposer that keeps epics disjoint**, and a **rule that makes "done" a proven, cited fact**.

## Suggested epic ordering (informed, not binding)

- **Epic 1** — components 1, 3, 6 (the safety core: isolated gate + serialized merge + done-rule) at `manual` autonomy. First shippable slice per the pitch Appetite.
- **Epic 2** — component 2 (the `fleet` dispatcher + disjoint-epic decomposer).
- **Epic 3** — semi autonomy (auto-merge on green), gated on Epic 1 proving safe.
- **Epic 4** — component 5 fleet roll-up (after `lsa-stage-reports` lands) + auto autonomy (deploy + healthcheck).
