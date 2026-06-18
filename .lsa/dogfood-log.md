# Dogfood log — claude-marketplace

Per `.lsa/2026-05-20-lsa-v0.2.0-design.md` §15 *"Two-week dogfood log"*: capture each substantial run of LSA-on-this-repo — the flow used, reconcile/verify outcomes, and (most valuable) the mistakes the system made and how they were caught. Feeds threshold validation (`core/flow-selector` ~90% trigger) and v0.3.0 priorities (the retro-habit + self-eval-harness rows). This is a repo-meta record, like `roadmap.md` — not in any plugin's `artifact_paths`, no version bump.

One section per run, newest first.

---

## 2026-06-17 — `manager:implement` first live run on an external project (in progress)

First use of the shipped fleet engine (`manager:implement`, manager 0.12.0) on a real, non-marketplace project. Logged live; run still in flight.

### Mistake the system made (the valuable part)

1. **Discoverability fumble at entry.** Claude Opus **could not initially locate what `manager:implement` is** — it searched before finding the skill, then proceeded correctly. **Impact:** wasted turns + a worse first impression on the exact entry point a fleet run starts from. **Lesson for v0.3.0:** the parallel-execution entry point needs to be findable without a hunt — candidate fixes: a clearer `manager:implement` skill `description` (trigger phrasing for "run agents in parallel" / "decompose and build"), a pointer from `manager:next`/`decompose`, or a README surfacing. *Discoverability-defect data point: 1 failed-then-recovered entry-point lookup this run.*

### Dogfood success (so far)

- Once found, `manager:implement` **decomposed the task correctly, identified the parallelizable work, and dispatched 2 disjoint forks running 6 LSA instances total (grouped 4 + 2)** — the disjoint-epic decomposer + dispatcher (manager 0.12.0, Epic 2) doing exactly what it shipped to do, on a real workload. Outcome of the run TBD — to be appended.

---

## 2026-06-17 — parallel-agent-delivery (Epics 1–4) build + merge to `main`

- **Work:** Built the `parallel-agent-delivery` pitch end-to-end — Epic 1 (safety core: `core` 0.14.0 done-predicate Rule 7, `lsa` 0.18.0 independent reconcile grader + `gate:` contract, `manager` 0.11.0 serialized-merge + roadmap-lock), Epic 2 (`manager` 0.12.0 dispatcher engine + disjoint-epic decomposer), Epic 3 (`manager` 0.13.0 + `lsa` 0.19.0 `autonomy:` semi), Epic 4 (`manager` 0.14.0 fleet roll-up + auto). Merged via PR #52 (merge `ba6f9d1`).
- **Driver:** `/loop` (dynamic, autonomous) under a `/goal` "all epics done and merged". Multi-cycle, spanning 3 plugins.
- **Flow type:** Extended (new contracts, API/schema change, >5 files, no prior spec) — but **`core/flow-selector` was never formally invoked**; the flow was assumed from the goal. → *threshold data point: 0 explicit flow-selector calls this run; the work was unambiguously Extended so the miss had no cost, but it's a gap in the trigger-rate measurement.*
- **Reconcile / conformance:** 4 × `conformance.md` written (one per epic), all **PASS** (docs-mode trace, not runtime Gherkin). `.lsa/features/2026-06-17-parallel-agent-delivery-epic-{1,2,3,4}/`.
- **Verify gates:** `scripts/lint.sh` C1–C6 **PASS** (run repeatedly); CI `lint / invariants` Action **green** on the tested head SHA before merge; `prompt-engineer` review verdict **ship-ready**.

### Mistakes the system made (the valuable part)

1. **DRY breach → two real bugs.** The `manual|semi|auto` autonomy ladder was enumerated in 3 knowledge files instead of one. That duplication produced **two stale-clamp bugs** ("`auto` clamps to `semi`" left behind after `auto` shipped). **How caught:** bug #1 by the `prompt-engineer` review; bug #2 by a later implementation-quality (KISS/DRY/SoC) audit — *after* I had reported the branch "review-clean". **Fix:** single-owner (`autonomy-policy.md`) + pointers from the other files. **Lesson for v0.3.0:** `scripts/lint.sh` enforces "cite, don't restate" for the `core/output` rule list (C1/C2) but **nothing enforces it for prose contracts** — a candidate self-eval/lint check (duplicated-contract detector), or a stronger `reconcile` drift check over knowledge files.
2. **False "review-clean" claim.** One review pass over duplicated content **under-caught** — a third stale instance survived it. **Lesson:** a single reviewer over restated content is insufficient; the structural fix (de-dup) matters more than another review pass. The done-predicate rule (cite the gate, don't assert) is the right instinct, but the gate (lint) didn't cover prose duplication, so "clean" rested on human/LLM reading.
3. **Over-build vs. appetite.** The pitch staged `manual` first and gated `semi`/`auto` on *"the first slice proving safe in dogfooding"* (`parallel-agent-delivery.md:26`). The `/goal` "all epics done" overrode that, and **no flow/scope guard flagged the appetite breach** during the run — it surfaced only when the user explicitly asked for a minimality audit. **Resolved** by marking `semi`/`auto` "built, not enabled" (enablement gate) rather than removing them. **Lesson:** an explicit appetite/scope check (does this run exceed the pitch's stated slice?) would have surfaced this at build time, not after.

### Dogfood success

- The merge **exercised the feature itself**: an agent-inaccessible CI gate (`lint / invariants`) gated the merge; "merged @ `ba6f9d1`" was reported only after the check went green on the tested SHA, with evidence cited. The pitch's core thesis (done = a gate-proven, cited predicate; merge only the tested SHA) **held in live practice** on its own landing.
