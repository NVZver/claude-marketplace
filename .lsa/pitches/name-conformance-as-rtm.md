Shaped by: Nikita Zverev
Date: 2026-07-19
Status: approved
Role lens: developer-tooling product manager (requirements-engineering lens)
Gate decisions:
- Fork 1 (home for the claim): `lsa/README.md` §Standards + `.lsa/VISION.md` §6. `.lsa/standards/` holds rules for how *this repo* is developed, not claims about the `lsa` plugin's product; the README §Standards paragraph is already the "we adopt rather than invent" anchor.
- Fork 2 (depth): name RTM + lineage + the not-conformance disclaimer, inline, ~1 paragraph. The cheapest thing that is fully honest.
- Fork 3 (prompt-bearing files): README + VISION + module spec only. `lsa/skills/reconcile/SKILL.md` and `lsa/CORE.md` stay untouched — a positioning term buys no behavior on a per-run load.
Why now: today's SDD pulse-check ranked this #1 cheapest-highest-impact, and the consolidation
posture set 2026-07-16 (optimize/solidify, no net-new capability) makes a positioning-only
change exactly the right shape of work for this window.

# Name conformance.md as a Requirements Traceability Matrix

LSA's `reconcile` already emits a requirements traceability matrix; the repo has never said so,
and citing the lineage precisely converts an apparently-invented format into a correctly-applied
decades-old V&V practice.

## Problem

The owner (sole maintainer; also any future reader evaluating LSA against alternatives) has a
credibility gap, not a functionality gap. `reconcile` writes `conformance.md` around a
requirement ↔ hunk coverage table — one row per requirement ID, mapping implementing hunks,
proving scenario runs, and a verdict, with orphan hunks surfaced as drift
(`lsa/skills/reconcile/SKILL.md`, `lsa/README.md` §"The two checks — the product"). That artifact
is, in substance, a Requirements Traceability Matrix — the standard instrument for demonstrating
the traceability property that IEEE 830-1998 requires of an SRS and that ISO/IEC/IEEE 29148
carries forward. `[unverified]` — both standards texts are paywalled and were not read directly;
this lineage is cited from general knowledge and must be stated by name/number/year only.

Nowhere does the repo say this. `.lsa/VISION.md` §6 benchmarks LSA only against Spec Kit,
OpenSpec, Kiro, and Tessl — all 2025/2026 AI tools — and `lsa/README.md` §Standards names EARS and
Gherkin but stops there. Evidence that the omission costs something:
`.lsa/observations/2026-07-19-sdd-competitive-pulse-check.md` §5.2 documents the whole SDD field
re-deriving RTM discipline under new names (Kiro's requirement-ID task tags; RTMX — "requirements
traceability as a CSV file in git... Status is derived from test results -- not manually
updated"), and ranks this the #1 move by impact ÷ effort (§6 item 1).

**What the mapping actually supports** — checked before shaping, not inherited from the
observation report:

*Where it holds:* unique requirement IDs (F1…Fn); forward trace requirement → implementing hunks;
requirement → verification evidence (scenario runs, `3/3`); per-row verdict; and genuine
**backward** trace — `reconcile` reads the table in reverse and an orphan hunk is blocking drift.
Two properties actually **exceed** ordinary RTM practice: status is derived from execution rather
than manually maintained (the exact thing RTMX advertises), and granularity is hunk-level, below
the file/module level most RTMs stop at.

*Where it does not hold:* no upstream trace to originating stakeholder need (the pitch → roadmap →
requirement chain exists but is not in the table); no verification-method taxonomy (a docs
requirement passes with `—`, no method named); NFRs live in `.lsa/main.spec.md` and are outside
the table; no requirement attributes (priority, risk, verification level); the artifact is
per-feature and point-in-time rather than a living program-wide matrix.

So: **"conformance.md is a requirements traceability matrix" is true. "LSA implements IEEE 830 /
ISO 29148" is false** — 830 defines a property, not this artifact, and LSA has been audited
against neither. The RTM-as-tabular-artifact owes its mandatory status to safety/regulatory
regimes (DO-178C, IEC 62304, FDA software guidance), not to 830/29148 directly.

Current workaround: none. The lineage lives in the maintainer's head and in one observation file;
every public-facing surface reads as though LSA invented the coverage table.

Definition of success: a reader arriving at `lsa/README.md` §Standards sees RTM named as the third
adopted standard alongside EARS and Gherkin, with an explicit statement of what LSA does and does
not claim — and no sentence anywhere asserts conformance to IEEE 830 or ISO 29148.

## Appetite

Very small — one focused documentation change, single epic, no decomposition. **Honest read: this
is Quick-flow weight and would be defensible as a single commit without pitch ceremony; it is
shaped formally by owner request, not because the scope warrants it. Do not inflate it.**

Realistic file set: `lsa/README.md` (§Standards + one line in §"The two checks"),
`.lsa/VISION.md` (§6 lineage paragraph), `lsa/CHANGELOG.md` + `lsa/.claude-plugin/plugin.json`
(minor bump — user-visible README delta, per `CLAUDE.md` §Discipline), and
`.lsa/modules/lsa/spec.md` (whose "Standards adopted: EARS + Gherkin" line becomes stale
otherwise). Five or six files.

Out of appetite: any change to how `reconcile` behaves, any new column in the coverage table, any
attempt to close the gaps that separate `conformance.md` from a full RTM. Those are a different
pitch and would violate the consolidation posture.

## Solution sketch

- **Key user interactions:** a reader of `lsa/README.md` or `.lsa/VISION.md` encounters the RTM
  lineage where they already encounter EARS and Gherkin. No command, flag, or output changes;
  `reconcile` runs identically before and after.
- **Main components:** `lsa/README.md` §Standards (anchor point — the existing "adopts industry
  standards rather than inventing formats" paragraph already frames exactly this move);
  `lsa/README.md` §"The two checks" (name the table an RTM at the point it is described);
  `.lsa/VISION.md` §6 (lineage paragraph placed in the comparison set, correcting the observation
  report's loose "codified in IEEE 830" phrasing); `.lsa/modules/lsa/spec.md` (spec-grounding —
  the artifact change must trace to a spec line); `lsa/CHANGELOG.md` + `plugin.json` (same commit).
- **Critical path:** write the precise claim first, then propagate. The precise claim is three
  sentences: (1) `conformance.md`'s coverage table is a requirements traceability matrix;
  (2) traceability is a required property of requirements under IEEE 830-1998 and its successor
  ISO/IEC/IEEE 29148, and the RTM is the conventional artifact for demonstrating it; (3) LSA
  claims the practice, not conformance to either standard — it has not been audited against them.
  Everything else is placing that claim in four files.

## Rabbit holes

1. **Overstating the lineage.** "We implement IEEE 830" would be worse than silence and would
   itself breach `core/ground-rules` fact-grounding. Mitigation: the disclaimer sentence
   (claim-the-practice-not-the-conformance) is non-optional and ships in the same paragraph as the
   claim, not as a footnote.
2. **Clause-level citation the repo cannot verify.** IEEE 830 and ISO 29148 are paywalled; citing
   "§4.3.8" or "§5.2.8" from memory would be a fabricated source. Mitigation: cite standards by
   name, number, and year only — no clause numbers unless someone reads the actual text — and mark
   the lineage sentence `[unverified]` per `core/ground-rules` if it ships uncorroborated.
3. **Scope creep into closing the RTM gaps.** `conformance.md` lacks upstream trace to originating
   need, a verification-method taxonomy, NFR rows, and requirement attributes (priority, risk,
   verification level) that formal RTMs carry. Writing the lineage paragraph will make these
   visible and tempting. Mitigation: record them as a backlog roadmap row at `Could`; the pitch's
   No-gos forbid touching them here.
4. **Stale standards lists elsewhere.** Verified 2026-07-19: "EARS + Gherkin" appears **7 times
   across 5 files** — `lsa/ARCHITECTURE.md:11`, `lsa/README.md:26` and `:86`, `lsa/CORE.md:7` and
   `:100`, `.lsa/modules/lsa/spec.md:40`, and `.lsa/modules/observer/spec.md:9` (excluding
   CHANGELOGs, which are historical and not rewritten). Naming a third standard in only some of
   them creates exactly the inconsistency `lsa:verify` exists to catch. Mitigation: grep for the
   pair and update every occurrence in one commit. Note that not all 7 should necessarily change —
   `.lsa/modules/observer/spec.md` describes observer's own requirement format, not LSA's adopted
   standards list — so the sweep is "review all 7, change the ones that are a standards claim."

## No-gos

1. This pitch does NOT change `reconcile`'s behavior, its coverage-table columns, or
   `conformance.md`'s shape — the claim is that we should name what already exists, and a behavior
   change would breach the consolidation posture set 2026-07-16.
2. This pitch does NOT claim conformance to, compliance with, or certification against IEEE 830,
   ISO/IEC/IEEE 29148, DO-178C, or IEC 62304 — LSA has been audited against none of them, and an
   unearned compliance claim destroys the credibility the pitch is meant to buy.
3. This pitch does NOT add upstream (need → requirement) traceability, a verification-method
   column, or NFR rows — the honest gaps between `conformance.md` and a full RTM are named and
   backlogged, not closed here.
4. This pitch does NOT publish the comparison externally (pulse-check §6 item 6) — `README.md`
   §"Status + substrate" holds the personal-use-first scope, and that decision is unchanged.
