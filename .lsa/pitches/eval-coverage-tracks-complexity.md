Shaped by: Nikita Zverev
Date: 2026-07-02
Status: approved
Role lens: eval / test-infrastructure lead for a prompt-native plugin marketplace
Decisions:
- Fork 2 (coverage breadth): lsa + manager get new observer-style drill suites; helper VERIFICATION re-scoped to the current 0.5.x surface; core/prompt-engineer static suites untouched.
- Fork 3 (observer remediation): folded in — M1–M5 + the `observe/SKILL.md:55` example fix land in this pitch as one epic.
- Fork 4 (reconcile deterministic backstop): INCLUDED here — requirement-ID ↔ diff-hunk coverage table in `conformance.md`, unconditional `.lsa.yaml` gate step, and the N definition all belong to THIS pitch, folding roadmap row "Reconcile classification automation". Cross-pitch dedup: the `sonnet-robustness-consistency-sweep` pitch's threshold workstream explicitly EXCLUDES reconcile/N (owned here) and covers only the observer timeout + manager row-selection/cap thresholds.
- Fork 5 (N default): N = 3, with a documented `.lsa.yaml` escape hatch (raise for high-stakes epics).
Why now: the adversarial-dogfooding standard was promoted to the constitution yesterday (2026-07-01, vision 0.12, .lsa/standards/testing.md:31-48), but coverage of it is 1 of 6 plugins and inverted against complexity — the flagship and the most complex plugin have zero behavioral evals, and the one eval that ran (observer, 2026-06-27) found real bugs whose fixes were never shipped. The discipline exists on paper; this pitch makes it real where it matters most.

# Behavioral eval coverage should track complexity, not invert against it

The marketplace tests prompt structure everywhere but prompt behavior almost nowhere — and the one plugin with real behavioral evals is one of the simplest, while the flagship (lsa) and the highest-stakes plugin (manager) have none.

## Problem

The maintainer (and any future contributor) ships behavior-bearing prompts with no proof the guards actually hold. Coverage today, verified 2026-07-02 against the live repo:

- **observer** — the only industry-grade suite: 8 adversarial probes (`observer/tests/scenarios.md` S1-S8), each run by an agent whose only guidance is the prompt, then scored by an independent judge (`observer/tests/eval-findings-2026-06-27.md`). This is the pattern the constitution now mandates (`.lsa/standards/testing.md:31-48`, "Guards must be prompt-forced (adversarial dogfooding)").
- **core, prompt-engineer** — static grep-based `tests/repo-anchored.md` + `VERIFICATION.md`. Structure, not behavior.
- **helper** — `helper/VERIFICATION.md:1` is titled "Helper v0.2.0" and `:7` states "Probes are scoped to the v0.2.0 surface"; the plugin ships at 0.5.4 (three minors stale), manual and non-adversarial.
- **lsa, manager** — no `tests/` directory and no `VERIFICATION.md` (confirmed by `ls`). `.lsa/standards/testing.md:7` routes lsa's probes to a dated design doc. Yet `manager:implement` drives parallel-worktree dispatch and the autonomy ladder — the highest-stakes behavior in the marketplace — and `lsa:reconcile` is the build loop's merge gate.

Two compounding gaps:

1. **The one eval that ran was never closed.** Observer's judges found 5 MEDIUM prompt gaps (`eval-findings-2026-06-27.md:29-33`, M1-M5) that were never shipped or logged as declined — no matching edits in `observer/knowledge/roles.md` or `observe/SKILL.md`. Worse, M3 caught a self-contradiction (`SKILL.md` picks `pair-programmer` for a stub-plus-red-test context that M3 says should route to `interviewer`) and the kickoff Example at `observe/SKILL.md:55` still proposes `pair-programmer` for exactly that context. An eval that finds bugs nobody fixes is theater.

2. **The merge gate rides on model judgment.** `lsa:reconcile`'s "only what's needed" and "all of the plan" checks (`reconcile/SKILL.md:33-34`) are pure judgment; the deterministic gate step at `:32` is conditional ("Where `.lsa.yaml` defines a `gate:`" — and `.lsa.yaml` does define one: `docs-invariants` / `citations` / `links`); and the scenario-run count N (`:32`, also `lsa/CORE.md:66`: "run N times… pass = ≥95% of runs") is never defined, so a weaker model must invent it.

Current workaround: the maintainer eyeballs prompts and trusts that Opus self-restrains — which is exactly the failure mode the constitution now forbids ("a guard that holds only because the model is generous is not a guard", `.lsa/standards/testing.md:33-35`).

Definition of success:
- Every plugin has a behavioral eval artifact current to its shipped version — lsa and manager get observer-style drill suites; helper's VERIFICATION is re-scoped to the 0.5.x surface.
- Observer's M1-M5 are each shipped or logged as explicitly declined with rationale, and the `observe/SKILL.md:55` example is reconciled with M3.
- `conformance.md` carries a deterministic requirement-ID ↔ diff-hunk coverage table the judge must produce and cite; the `.lsa.yaml` gate step in reconcile becomes unconditional.
- N is a named default (3, with a documented escape hatch — per Decisions).
- `.lsa/standards/testing.md` codifies that evals run on Sonnet.

## Appetite

Large batch, but bounded by the fact that observer's pattern is agent-generated + judge-scored, not hand-written — the maintainer authors the SETUP/PASS-CRITERIA framing, agents produce the runs and the judging. Target the highest-stakes behaviors only, not exhaustive coverage: for lsa, reconcile's does·only·all lens; for manager, `manager:implement`'s wave-plan + autonomy ladder. Cap each new suite at roughly observer's ~8 probes.

Out of appetite: statistical eval rigor (Wilson CIs / Elo — already deferred, `.lsa/standards/testing.md:21-23`); a CI harness (evals stay manual, local, Pro-safe with zero model calls in the deterministic gate); behavioral upgrades to core/prompt-engineer's static tests (they have coverage — that's a separate appetite).

## Solution sketch

- **Key user interactions:** the maintainer runs the observer drill pattern (agent-run probes + independent judge + findings file) against lsa and manager; reviews the findings; ships or declines each. For reconcile, the maintainer reads a deterministic requirement↔hunk table instead of trusting a prose verdict.
- **Main components:**
  - New `lsa/tests/scenarios.md` + `eval-findings-<date>.md`, and `manager/tests/scenarios.md` + findings, mirroring `observer/tests/`.
  - Observer remediation: apply M1-M5 to `observer/knowledge/roles.md` + `observe/SKILL.md`, fix the `:55` example, re-run the suite to prove the guards are now forced.
  - Re-scoped `helper/VERIFICATION.md` (0.2.0 → 0.5.x surface), with a lint that flags version-scope drift against `plugin.json`.
  - `lsa/skills/reconcile/SKILL.md` + `lsa/CORE.md`: define N = 3 (+ `.lsa.yaml` escape hatch); make the conformance artifact a structured requirement-ID ↔ diff-hunk table (tightening the existing `conformance.md` at `:35`, not new machinery); make the gate step unconditional.
  - `.lsa/standards/testing.md`: add an "evals run on Sonnet" clause.
- **Critical path:** stand up the lsa + manager drill suites → run them → the runs surface real gaps (the observer precedent guarantees they will) → ship or decline each → the reconcile deterministic backstop lands so future gaps are caught at the merge gate, not by eyeball.

## Rabbit holes

1. Scope creep into statistical rigor — mitigation: explicit no-go #1, citing the existing deferral at `.lsa/standards/testing.md:21-23`. This is pass/fail adversarial, not Wilson/Elo.
2. lsa/manager suites ballooning past appetite — mitigation: cap at ~8 probes each, agent-generated, targeting only the highest-stakes behaviors named in Appetite.
3. The reconcile deterministic backstop overlaps the deferred roadmap row "Reconcile classification automation" (`.lsa/roadmap.md:33`) and the in-flight `paired-verify` pitch (`:63`) — mitigation: fold row 33 into this epic (per Decisions); the table tightens the existing `conformance.md` (`reconcile/SKILL.md:35` already writes "each requirement → the change/test"), so this is a format contract, not a new ID system.
4. The new evals could themselves be describe-only, generous passes — mitigation: reuse observer's method exactly (author ≠ judge, independent context), per the promoted standard (`.lsa/standards/testing.md:36-44`); the judge must find the passes forced, not generous.
5. Helper's VERIFICATION re-scope drifts again next release — mitigation: the version-scope lint (component above) makes the drift a gate finding, not a manual catch.

## No-gos

1. This pitch does NOT build statistical eval rigor (Wilson CIs / Elo head-to-head) — deferred per `.lsa/VISION.md` §6 and `.lsa/standards/testing.md:21-23`.
2. This pitch does NOT add a CI eval harness — evals stay manual and local; only the deterministic structural gate (`bash scripts/*.sh`, zero model calls) runs in the merge path.
3. This pitch does NOT re-test core/prompt-engineer's static suites — they have coverage; a behavioral upgrade there is a separate appetite decision.
4. This pitch does NOT change reconcile's does·only·all semantics — it only makes the conformance artifact deterministic and the gate step unconditional.
