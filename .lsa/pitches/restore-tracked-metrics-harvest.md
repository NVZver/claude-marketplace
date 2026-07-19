Shaped by: Nikita Zverev
Date: 2026-07-19
Status: approved
Role lens: developer-tooling product manager (measurement / observability lens)
Gate decisions:
- Fork 1 (metric scope): all three metrics in one harvest script; the citation metric explicitly labeled a proxy.
- Fork 2 (script home): `scripts/metrics-harvest.sh` — repo-internal, NOT shipped in any plugin, no plugin version bump.
- Fork 3 (citation denominator): record the `check-citations.sh` resolve-rate under an honestly-named column; limitation stated in the schema note. No model-side claim counting.
- Fork 4 (constitution wording): add a one-line `.lsa/VISION.md` §5 clarification via `lsa:revise-constitution` in the same cycle, so the constitution and the implementation agree on the record.
Why now: the metrics writer was silently dropped in lsa 0.16.0 and 23 conformance.md files have
accumulated since with their scope-creep signal computed and discarded — the raw material is
piling up while the ledger sits frozen at 2 rows from May.

# Restore the three tracked metrics — harvested from artifacts, not instrumented

Make the three metrics `.lsa/VISION.md` §5 commits to real by deriving them from artifacts the
system already produces (`conformance.md`, the gate scripts), rather than by building the
session-level telemetry the system has been assuming it needs.

## Problem

The system's constitution commits to tracking three metrics — accuracy to the task, proven facts
with sources, and only-required-changes — and marks the decision **RESOLVED**
(`.lsa/VISION.md` §7 decision 5). None are being tracked today.

The gap is not that the layer was never built. It was built and then dropped:

- `.lsa/metrics.md` exists with the correct three-column schema and an explicit no-statistics
  note ("Pass/fail counts only — no statistical eval"), plus the line "Written by `lsa:verify` on
  clean PASS" — but holds **2 rows, both dated 2026-05-21**.
- `lsa/CHANGELOG.md` (`[0.16.0]`, 2026-06-08) records the cause under Changed: "**`verify`** —
  refocused to the *before*-delegation grounding check … Removed the orphan-AC / `metrics.md`
  machinery." The second writer lived in the `sync` skill, which the same release removed
  entirely (`lsa/skills/` today holds seven skills, no `sync`).
- Since then **23 `conformance.md` files** have been written (`.lsa/features/**/conformance.md`),
  each containing an orphan-hunk list — the per-cycle scope-creep signal — which is computed by
  `reconcile` and then discarded.

The cost is credibility, and the system already says so out loud. `core/CHANGELOG.md` (`[0.20.0]`)
declines to claim a token win: "Load rate is not instrumented — no session-level telemetry exists
— so this is a structural asymmetry corrected, not a measured token saving. Recorded as such
rather than claimed as a win." The competitive pulse check reaches the same verdict about the
whole "where we win" section — every claim in it is "currently unverified by anyone outside this
repo" (`.lsa/observations/2026-07-19-sdd-competitive-pulse-check.md` §5.2). Under
`.lsa/VISION.md` §2 principle 1, "Trust is the product", unmeasured self-assessment is the most
awkward possible gap.

The framing "the most expensive to build" is the thing this pitch challenges. It is expensive only
if the metrics require session telemetry. They do not: two of the three are already emitted as
script output on every gate run, and the third is already computed by `reconcile` and thrown away.

Current workaround: none. Claims about system quality are made narratively, or — at best, as in
`core/CHANGELOG.md` — honestly withheld. The two May rows in `.lsa/metrics.md` are stale enough
to mislead.

Definition of success: after a `reconcile` PASS on any Extended-flow feature, a row is appended to
`.lsa/metrics.md` carrying all three metrics as M/N counts, each traceable to a script's cited
output — and a lint check fails if the emit step is ever removed again. The July 2026 cycles that
already have `conformance.md` files are harvested where their format permits, and explicitly
reported as unparseable where it does not.

## Appetite

Small-to-medium, and hard-capped by one rule: **no new subsystem.** Every number must be readable
from an artifact that already exists or from a script that already runs. Concretely — one new
repo-internal harvest script, one format tightening on `conformance.md`, one restored emit step in
`reconcile`, one presence-guard lint check, and a schema note on `.lsa/metrics.md`.

Out of appetite: any session-level logging, hook, or event stream; any change to how `reconcile`
decides PASS/FAIL; any retroactive reconstruction of cycles whose `conformance.md` predates the
format contract; any presentation layer.

If delivering all three metrics does not fit, only-required-changes ships first — it has the
cleanest raw material and is the metric tied most directly to the system's actual differentiator.

## Solution sketch

- **Key user interactions:** the owner runs `reconcile` as they do today and gets one extra line
  in the verdict — the three M/N counts, each citing the script output it came from. Reading
  `.lsa/metrics.md` shows the trend across cycles. Nothing new is invoked by hand.

- **Main components:**
  1. `scripts/metrics-harvest.sh` — repo-internal, bash, zero model calls, matching the precedent
     of `scripts/coverage-skeleton.sh` and `scripts/check-citations.sh` (both documented as
     "Repo-internal — NOT shipped in any plugin", so no plugin version bump). It reads one
     `conformance.md` plus the gate script outputs and prints the three M/N pairs. It computes, it
     never judges — the same enumeration/judgment split `coverage-skeleton.sh` already states
     ("ENUMERATION ONLY. It never maps a hunk to a requirement.").
  2. The three derivations, all from existing output:
     - **only-required-changes** = (candidate hunks − orphan hunks) / candidate hunks. Both axes
       already exist: `coverage-skeleton.sh` enumerates changed files, and `conformance.md` lists
       orphans below the table.
     - **accuracy to the task** = passing coverage-table rows / total rows, tallied from the
       requirement↔hunk table `reconcile` already writes, plus gate exit codes.
     - **proven facts with sources** = the resolve-rate `check-citations.sh` already prints,
       recorded explicitly as a **proxy** — see rabbit hole 3.
  3. A tightened `conformance.md` output contract in `lsa/skills/reconcile/SKILL.md` §Output, so
     the orphan line is machine-readable rather than free prose.
  4. A C-numbered presence guard in `scripts/lint.sh`, following the existing C6/C15 pattern, that
     FAILs if the metrics-emit step disappears from `reconcile`.
  5. `.lsa/metrics.md` — schema note updated; new rows appended; the two May rows kept and marked
     as pre-contract.

- **Critical path:** `reconcile` finishes a cycle → `metrics-harvest.sh` reads that cycle's
  `conformance.md` + gate output → three M/N pairs printed → row appended to `.lsa/metrics.md` →
  lint C-check keeps the emit step from being dropped again.

## Rabbit holes

1. **The existing `conformance.md` files are not uniformly formatted.** Some carry the canonical
   `Orphan hunks: none.` line; at least one uses a prose heading instead
   (`## Orphan hunks (over-delivery vs F1–F13)` in
   `.lsa/features/2026-07-16-yaml-ledger-read-cutover/conformance.md`). Mitigation: the script
   parses only the canonical shape and reports `UNPARSEABLE` for anything else — never a guess,
   never a regex that tries to be clever. Backfill is best-effort and explicitly partial;
   historical files are not rewritten.

2. **This layer died once already, in a refactor that had nothing to do with it.** `lsa` 0.16.0
   dropped it as collateral while re-basing to the two-verb model. Rebuilding it without an
   anti-regression guard invites the same death. Mitigation: the lint presence-check
   (component 4) is the part the first attempt lacked and is the reason this is hardening rather
   than a repeat.

3. **Citation density has no honest denominator.** The true metric is *share of claims carrying a
   valid source*; "number of claims" is not deterministically countable, so any automated
   denominator is a proxy. `check-citations.sh` measures whether existing `path:line` citations
   still resolve — and its own header warns that a green run means "the citation still points at a
   real line", not "the quote is intact". Mitigation: record it under a column named for what it
   actually is (citation resolve-rate), never label it "citation density", and state the
   limitation in the `.lsa/metrics.md` schema note. An honestly-labeled proxy is in keeping with
   `.lsa/VISION.md` §2 principle 1; a flattering mislabel is not.

4. **Goodhart — the metric becomes a target.** An agent that knows orphan hunks are counted can
   suppress them by mislabeling. Mitigation: metrics are descriptive and never gate anything, and
   the existing independence rule already forbids the implementer from editing its own grader
   (`lsa/knowledge/quality-gate-contract.md`). Metrics inherit that boundary; they do not create a
   new one.

5. **`.lsa/VISION.md` §5's wording says "session-level".** This pitch measures per-cycle, from
   artifacts. That is a clarification of the constitution, and constitution edits are owner-only.
   Resolved at gate: a one-line §5 clarification ships in the same cycle via
   `lsa:revise-constitution`.

## No-gos

1. This pitch does NOT build session-level telemetry, hooks, or an event log — the measurement
   unit is the LSA cycle, and the artifacts for that already exist. This is also what keeps the
   security promise intact: nothing new is observed, so there is nothing new to leak.
2. This pitch does NOT introduce Wilson confidence intervals, Elo, or any variance statistic.
   `.lsa/VISION.md` §6 Adjust #3 deferred these as "genuinely overkill for v1" and this pitch does
   not reopen that decision. Pass/fail with counts only — the shape `.lsa/metrics.md` already
   declares.
3. This pitch does NOT add any external service, network call, or PII collection. Everything is
   local bash over local files, consistent with the existing gate contract's "Pro-safe, local
   bash, zero model calls".
4. This pitch does NOT retroactively rewrite the historical `conformance.md` files to fit the new
   contract. Harvest what parses; report the rest as unparseable.
5. This pitch does NOT change any PASS/FAIL verdict logic, gate threshold, or `reconcile.runs`
   semantics. Measurement observes the gate; it never becomes one.
6. This pitch does NOT ship a dashboard, chart, or visualization. `.lsa/metrics.md` is a markdown
   table and stays one.
