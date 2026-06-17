# Live observation — `manager:implement` on TripAnchor-1

External-project run of the shipped fleet engine (`manager:implement`, manager 0.12.0). Observed from the marketplace repo by inspecting TripAnchor-1's git + LSA artifacts (not the agent's own narration). Purpose: collect concrete fix/improve candidates for a later pass. Feeds the in-progress entry in [`../dogfood-log.md`](../dogfood-log.md).

- **Target run:** `agent-robustness-hardening` — harden the `conversation` tier's Claude call-sites (timeouts, retry, structured planner output, usage logging, model registry, 2 guardrail backstops). Spec: `TripAnchor-1/specs/features/agent-robustness/`.
- **Shape:** E14 substrate (committed) → E15–E18 four parallel epics on disjoint files → reconcile (full suite, version bump, changelog, PR).
- **Base:** `feature/agent-robustness-hardening` off `main` 27ca3cf.

---

## Checkpoint log (newest last)

### 2026-06-17 ~22:50 CEST — entry-point + decomposition
- **Discoverability fumble:** Opus could not initially locate what `manager:implement` is; searched, then recovered. (Wasted turns at the exact entry point.) → fix candidate: skill `description` trigger phrasing / pointer from `next`+`decompose` / README.
- **Decomposition correct:** 2 dispatch groups, 6 LSA instances (4 + 2). Disjoint-epic decomposer produced an explicit per-epic write-set table (`epic.md:25-31`) + dependency column.

### 2026-06-17 ~22:48 CEST — substrate-first + spec discipline
- E14 (`lib/fetch-resilient.js`, `lib/models.js`) committed as **new files** the parallel epics only import, never edit (`epic.md:33`) → no shared-file race by construction.
- Spec artifacts (requirements + grounding + 3 `.feature` files) written and pinned to base SHA before any implementation.

### 2026-06-17 23:00 CEST — parallel wave mid-flight
- HEAD still `7834cb1` (E14); reconcile **not** committed yet.
- Working tree: **23 files changed, 6 untracked test files** (was ~16 / 4 at first look ~10 min earlier) — the 4 parallel epics are actively producing.
- **Isolation mechanism = file ownership, NOT git worktrees.** `git worktree list` shows a single tree; the disjoint write-sets are what prevent collision. (Contrast with marketplace memory `project_parallel_worktree_workflow`, which assumes worktree isolation. Open question: is single-tree + disjoint-files robust enough, or does a stray shared-file edit silently corrupt a parallel peer? Watch reconcile for cross-epic contamination.)
- Boundary holding: every changed file maps to a declared epic write-set; all under `conversation/`; no `web/`/`sql/`/prompt-content edits (no-go list `epic.md:37`).
- TDD visible: co-located `*.test.js` per adapter.

---

### 2026-06-17 23:01–23:05 CEST — Fork 1 committed + Fork 2 merging (eventful)
- **Fork 1 (`agent-robustness`) completed + committed** as `2f824ca` "agent robustness hardening (E20–E23) + reconcile". 22 files, +tests, version 0.5.0, CHANGELOG, conformance.md, roadmap reconciled. The 4 parallel epics landed.
- **⚠️ FINDING — epic-ID drift, spec vs. commit.** The spec (`epic.md`) decomposed as **E14–E18**; the commit references **E19 substrate + E20–E23**. IDs renumbered somewhere between decompose and commit. Conformance was updated *in the same commit* so it's internally consistent at HEAD, but the spec-tree ID ≠ commit ID — a traceability seam. → fix candidate **C2**.
- **⚠️ FINDING — reconcile folded into the implementation commit, not an independent context.** `2f824ca` is *one* commit containing both the parallel impl AND the reconcile (version/CHANGELOG/conformance). The marketplace thesis is "reconcile as an **independent** grader run by a separate context" (the differentiator). Here it ran inline in the same agent/commit — no separation visible at the git layer. Open: was it a genuinely separate context that just shares a commit, or the same context self-grading? → fix candidate **C3** (make reconcile's independence observable — separate commit/check, or a gate artifact the impl agent can't write).
- **⚠️⚠️ FINDING (biggest so far) — cross-fork collision on shared ledger files.** A `git merge` is **in progress** (`.git/MERGE_HEAD` present) integrating **Fork 2 (`plan-confirmation-behavior`)**. It conflicted on `CHANGELOG.md` (`UU`) and `specs/roadmap.md` (`MM`) — the shared append-only ledgers **every** fork/epic writes to. Markers already removed (resolved, unstaged), so it's recoverable, but: the disjoint-**code**-file decomposition gives **zero** protection on the shared ledgers, so cross-fork integration *requires* a merge + conflict resolution every time. → fix candidate **C4** (serialize ledger writes, or make CHANGELOG/roadmap append-merge-clean — e.g. per-epic fragment files reconciled at the end, not concurrent edits to one file).
- **Second feature already in flight without pause.** Fork 2 = `plan-confirmation` (new pitch `specs/pitches/plan-confirmation-step.md` + full LSA artifact set under `features/plan-confirmation-behavior/`). Engine moved from Fork 1 → Fork 2 with no human checkpoint between — note for appetite/autonomy review.

### 2026-06-17 23:11 CEST — both forks produced PRs; gate-proven "done" is working; epic-ID chaos confirmed
- **Both forks landed as PRs.** Fork 2 (`plan-confirmation`) → **PR #83, already merged to `main`** (`fae1933`). Fork 1 (`agent-robustness`) → **PR #85, OPEN**. The feature branch pulled `main` back in via two `Merge origin/main` commits (`f225adf`, `95c6ede`) — so the 23:05 shared-ledger conflict (C4) was the branch absorbing #83's CHANGELOG/roadmap edits. Confirms C4 is real *and* recurring (resolved by merge each time).
- **✅ POSITIVE — "done" is gate-gated, not asserted.** PR #85 is **OPEN with a full check matrix running**, not claimed done. Checks: Repo tests (unit+contract) **pass**, Web tests **pass**, Docker build **pass**, Smoke+lint **pass**, Version+changelog gate **pass**, Playwright e2e **pending**, Vercel **fail**. The engine opened the PR and let the agent-inaccessible CI gate run — the core thesis holding on an external project. Manual-merge boundary intact (#85 not auto-merged).
- **⚠️ FINDING — non-code infra check pollutes the gate signal (new C6).** PR #85 **Vercel = fail**, but the reason is *"Git author NVZver must have access to the project on Vercel to create deployments"* — a **permissions** failure, not a code defect. It plants a permanent red ✗ on the PR unrelated to correctness; a naive "is it green?" reads as failed. → fix candidate **C6** (classify/quarantine non-code infra checks, or fix Vercel author access so the gate signal is clean).
- **⚠️⚠️ FINDING — epic-ID numbering is unstable AND now colliding (escalates C2).** Same agent-robustness work carries **three different ID ranges**: spec `epic.md` = **E14–E18**, commit `2f824ca` = **E19–E23**, PR #85 title = **E31–E35**. Worse, **two different commits both claim E27**: `fae1933` (conversation: plan confirmation) and `051e574` (database: DB security hardening). Epic IDs are not a stable key — they drift per stage and collide across tracks. Any traceability that keys on epic ID is broken. → **C2 escalated to high.**

### 2026-06-17 23:14–23:16 CEST — Fork 1 PR MERGED gate-proven; engine churns onward
- **✅ PR #85 MERGED** at 23:14:16 (`6c52e6a` now on `main`). Every functional check green: Repo tests, Web tests, Docker build, Smoke+lint, Version+changelog gate, **Playwright e2e (4m36s) pass**. The full done-predicate held end-to-end on a real repo: decompose → parallel impl → reconcile → PR → **agent-inaccessible CI green** → merge. This is the pitch's thesis working in the wild.
- **C6 downgraded to cosmetic.** Vercel stayed ✗ (permissions) but **did not block the merge** — it isn't a required check, so the merge logic correctly ignored it. The signal is *correct*; only the human-glance read is noisy. C6 = signal-clarity nice-to-have, **not** a correctness bug.
- **Engine continues fully autonomously — no human gate between PRs.** Immediately after #85 merged, **PR #86 opened** ("E30 — DB security baseline + non-blocking advisor guard"). The run is churning the backlog PR-after-PR with no pause. Reinforces **C5** (autonomy: is this the intended default, or should it checkpoint?). Note it's producing *correct* gated PRs, so autonomy is behaving — the question is whether unattended multi-PR churn is the desired mode.
- **C2 reinforced — IDs non-monotonic.** E31–E35 just merged; the *next* PR is **E30**. Epic IDs aren't even ordered. They're decorative labels, not keys.

## Run lifecycle captured (the representative arc)
`manager:implement` discover/decompose → spec-per-fork (LSA) → substrate-first → 4‖ + 2‖ parallel epics (disjoint code files, single tree) → reconcile (version/CHANGELOG/conformance) → branch absorbs `main` (ledger merge, C4) → PR → full CI gate → merge. Observed twice (Fork 1 #85, Fork 2 #83). Engine then auto-advances to the next backlog item (#86). The core machinery works; the defects are at the **seams** (epic-ID identity, shared-ledger merges, reconcile-independence visibility, gate-signal hygiene).

## Open questions to resolve by end of run
1. Does reconcile run as an **independent context** (the differentiator) or does the same agent self-grade?
2. Do the 4 parallel epics merge cleanly, or is there a manual integration step the engine glossed?
3. Is "done" reported as a **gate-proven, cited** predicate (CI green on tested SHA + PR) or asserted?
4. Does the appetite/scope hold, or does it over-build past the pitch slice (the marketplace E3/E4 failure mode)?

## Resolution — 2026-06-17 (feature `2026-06-17-parallel-engine-findings`)

All six findings fixed on branch `feature/fix-parallel-engine-findings` (manager 0.15.0 + lsa 0.20.0), built by dogfooding the parallel engine itself: 4 disjoint prompt-engineer epics + orchestrator-owned shared-ledger writes (the C4 fix, applied to its own build). **C1–C6 resolved** (see CHANGELOG entries). One new finding logged below.

- **C7 — `manager:implement` SKILL documents worktree-per-epic, but the live run used a single tree + file-ownership isolation.** `manager/skills/implement/SKILL.md` Step 4 / `parallel-dispatch.md` §3 say "one worktree + branch per epic (`isolation: worktree`)"; the observed run showed `git worktree list` = single tree (this log's 23:00 checkpoint). Spec-vs-behavior seam; also contradicts marketplace memory `project_parallel_worktree_workflow`. **Open** — not fixed this pass; candidate for the next remediation (decide: enforce worktrees in the engine, or update the contract to bless single-tree + disjoint-file ownership).

## Fix/improve candidates (running)
- **C1 — entry-point discoverability.** `manager:implement` hard to find. (Confirmed.)
- **C2 — epic-ID drift spec↔commit.** Decompose said E14–E18; commit says E19–E23. Renumber breaks spec-tree → git traceability.
- **C3 — reconcile independence not observable.** Reconcile shares the implementation commit; the "independent grader" differentiator isn't visible at the git/gate layer.
- **C4 — cross-fork shared-ledger collision.** `CHANGELOG.md` + `specs/roadmap.md` conflict on every fork integration (disjoint-code decomposition doesn't cover shared append files). Candidate: per-epic fragments reconciled at the end, or serialized ledger writes.
- **C5 — no human checkpoint between forks.** Engine flowed Fork 1 → Fork 2 with no pause; check against intended autonomy default (`manual`?).
- **C6 — non-code infra check pollutes gate signal.** Vercel ✗ on PR #85 is a permissions failure, not a code defect, but reads as "failed". Classify/quarantine infra checks or fix Vercel author access.
- _more to come as the run progresses._

## What's working well (running)
- Disjoint-**code**-file decomposition: zero collision on source files across 4 parallel epics.
- Substrate-first sequencing (new files imported, not edited) — dependency-correct by construction.
- Spec-before-code discipline held per fork (requirements + grounding + `.feature` pinned to base SHA).
- TDD visible: co-located `*.test.js` per unit, committed with impl.
- Reconcile *did* produce real artifacts: version bump, CHANGELOG, conformance.md, roadmap reconcile (quality is there even if independence isn't observable — see C3).
- **Gate-proven "done" works on a real project.** PR opened with a full agent-inaccessible CI matrix (unit/contract/web/docker/smoke/version+changelog/e2e); not claimed done; manual-merge boundary held. The pitch's central differentiator survived contact with an external repo.
- Both parallel forks produced **mergeable PRs** (#83 merged, #85 open) — the dispatcher genuinely shipped parallel work to PR stage.
