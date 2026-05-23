# Design: LSA — what-and-why preamble on every verb-headline

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #4 (`vision/specs/roadmap.md:122-126`).

## Modules Affected

| Module | Change Type |
|--------|-------------|
| `core` (`core/skills/output/SKILL.md`) | New **Rule 6** ("What-and-why preamble") — single source of truth for the preamble obligation. See OQ1 (resolved). |
| `lsa` (5 of 8 skill bodies) | Cite the new rule + replace bare "PROPOSED verdict" / "DRIFT verdict" / etc. templates with preamble-first templates. |
| `lsa` (3 of 8 skill bodies — discover, specify, plan) | No-op for verdict labels; reviewed and confirmed in inventory below. |

## Verb-headline inventory

The roadmap row's phrase "verb-headline" maps mechanically to the **verdict labels** defined in `core/knowledge/output-vocabulary.md:11-22`. That table is the canonical marketplace-wide vocabulary with 10 verdicts: `PROPOSED / READY / PASS / PASS WITH WARNINGS / FAIL / BLOCKED / DRIFT / CLEAN / APPLIED / REJECTED`.

**Roadmap correction (must land as a tasks.md item).** The roadmap row at `vision/specs/roadmap.md:124` lists `INFERRED`, `MERGED`, `RECONCILED`, `SYNCED`, `GATED` as example verbs. **None of these exist** in `core/knowledge/output-vocabulary.md:11-22` or in any LSA skill body today — they are speculative / stale examples drafted before the canonical vocabulary was finalized. This plan's inventory uses only the canonical vocabulary cited above. Recommendation: a one-line edit to the roadmap row replacing the speculative list with the canonical 10 — captured as a `tasks.md` item so it ships in the same PR.

**Currently-emitted vs. canonical-but-unemitted (inventory note for F1 / AC7).** F1 / AC7 list all 10 canonical verdicts because the rule is future-proof — any future emission must comply. Today, however, only **3** verdicts are emitted in any LSA skill body: `PROPOSED` (`lsa-init`, `lsa-revise-constitution`), `APPLIED` (`lsa-sync`), `DRIFT` (`lsa-reconcile`). `lsa-verify` adds **3 more** (`PASS`, `PASS WITH WARNINGS`, `FAIL`) — but those are emitted only inside `lsa-verify`. **Currently un-emitted anywhere**: `READY`, `BLOCKED`, `CLEAN`, `REJECTED`. Grep across all 8 LSA skill bodies shows zero emission sites for those 4. The rule still ships covering all 10, so the moment any of them is emitted in the future the preamble obligation attaches automatically.

Inventory below maps every actual emission site to its label + file:line.

### Per-skill inventory

| Skill | File:line | Verdict label | Emission template (verbatim excerpt) |
|---|---|---|---|
| `lsa-init` | `lsa/skills/lsa-init/SKILL.md:51` | `PROPOSED` | "Present: PROPOSED verdict (`<N>` modules inferred) + per-module table …" |
| `lsa-reconcile` | `lsa/skills/lsa-reconcile/SKILL.md:35` | `DRIFT` | "Present each delta individually: DRIFT verdict + module name + file/line counts …" |
| `lsa-sync` | `lsa/skills/lsa-sync/SKILL.md:131` | `APPLIED` | "Present: APPLIED verdict + updated-modules list …" |
| `lsa-revise-constitution` | `lsa/skills/lsa-revise-constitution/SKILL.md:61` | `PROPOSED` | "Present each proposed change individually (one per turn): PROPOSED verdict + change-N-of-M …" |
| `lsa-verify` | `lsa/skills/lsa-verify/SKILL.md:83` | `PASS` | "**PASS:** verdict + 1-sentence headline + per-check-group results table …" |
| `lsa-verify` | `lsa/skills/lsa-verify/SKILL.md:84` | `FAIL` | "**FAIL:** verdict + 1-sentence headline naming the failed groups …" |
| `lsa-verify` | `lsa/skills/lsa-verify/SKILL.md:85` | `PASS WITH WARNINGS` | "**PASS WITH WARNINGS:** verdict + 1-sentence headline + Issues table …" |

### Per-skill counts

| Skill | Verdict emission sites | Status |
|---|---|---|
| `lsa-discover` | 0 | No edit needed (verdict labels not emitted; only a 3-row discovery table). |
| `lsa-init` | 1 | Edit. |
| `lsa-specify` | 0 | No edit needed for verdicts. (Has "Hard Confirm" gates but no verdict label per `output-vocabulary.md`.) |
| `lsa-plan` | 0 verdict labels; 1 picker call site that uses `PASS / FAIL` *inside* the self-verification table (`lsa/skills/lsa-plan/SKILL.md:87,114`) but never as a top-level *headline*. | No edit needed — `PASS/FAIL` here is a table-cell value, not a verdict-headline emission. The table itself is preceded by step text that already names the action. Re-confirm in tasks.md Task 5b. |
| `lsa-verify` | 3 (`PASS` / `FAIL` / `PASS WITH WARNINGS` variants) | Edit. |
| `lsa-sync` | 1 (`APPLIED`); also references `PASS` at `lsa-sync/SKILL.md:17,99` as *narrative description*, not emission | Edit at line 131 only. |
| `lsa-reconcile` | 1 (`DRIFT`) | Edit. |
| `lsa-revise-constitution` | 1 (`PROPOSED`) | Edit. |
| **Total** | **7 emission sites across 5 skills** | |

This is fewer than the roadmap's "spans all 8 LSA skill bodies" framing implies. The 8-skill framing reflects an *initial estimate*; the inventory reveals 5 of the 8 actually emit verdict labels. Three (`lsa-discover`, `lsa-specify`, `lsa-plan`) do not. The rule still ships in `core/output` (marketplace-wide), so all 8 inherit the obligation should they add verdict emissions later — but the *current* skill-body edits are 5, not 8.

## Format spec — the canonical preamble template

### Template

```
<one-sentence context in the user's frame, naming (a) the action and (b) the consequence>. <VERDICT> verdict + <existing details>.
```

Length: ≤ ~25 words for the preamble sentence. Per `core/skills/output/SKILL.md:17-22` (1–1.5 screen budget).

### Worked examples

**1. lsa-init brownfield — `PROPOSED`** (gold reference, see `vision/specs/roadmap.md:125`)

- Before (current at `lsa/skills/lsa-init/SKILL.md:51`):
  > `PROPOSED: 3 modules inferred for TripAnchor.`
- After:
  > `I scanned this repo and drafted 3 module specs from /src/ so future LSA steps can attach changes to a specific module — without these specs the next /lsa:discover has nothing to pick. PROPOSED: 3 modules inferred for TripAnchor.`

**2. lsa-reconcile — `DRIFT`**

- Before:
  > `DRIFT: auth/sessions.ts diverges from spec.`
- After:
  > `The auth spec says sessions expire after 24 hours, but the code now sets 7 days — one needs to win, otherwise the next review will block the merge until you pick one. DRIFT: auth/sessions.ts diverges from spec.`

**3. lsa-verify — `FAIL`**

- Before:
  > `FAIL: 2 untraced diff hunks.`
- After:
  > `Two code changes in this branch have no matching epic in tasks.md — merging now would ship code that no requirement covers, breaking the trace chain. FAIL: 2 untraced diff hunks.`

**4. lsa-sync — `APPLIED`**

- Before:
  > `APPLIED: 4 module specs updated.`
- After:
  > `Module specs for auth, billing, sessions, and webhooks now reflect the merged feature — the docs are current, and the next decision is just whether to open the PR now or later. APPLIED: 4 module specs updated.`

**5. lsa-revise-constitution — `PROPOSED`**

- Before:
  > `PROPOSED: add "no inline secrets" rule to CLAUDE.md.`
- After:
  > `Last feature surfaced a rule worth making permanent: I'm offering to add a "no inline secrets" line to CLAUDE.md — accepting makes it enforced on every future change; rejecting means the next contributor can still paste a secret without a warning. PROPOSED: add "no inline secrets" rule to CLAUDE.md.`

### Anti-pattern — what fails the rule

- ✗ `PROPOSED: 3 modules inferred.` — bare label, no preamble.
- ✗ `Proposing module inference. PROPOSED: 3 modules inferred.` — preamble exists but uses jargon (`module inference`) and names no consequence.
- ✗ `Found 3 modules. PROPOSED: 3 modules inferred.` — preamble exists but names the *what* only, not the consequence.
- ✓ `<plain-English action>. <consequence>. <VERDICT>: <details>.` — passes (the consequence may be expressed as `without X, Y happens` per the gold reference).

## Where the rule lives — recommendation + rationale

Three candidate locations were considered:

| Location | Pros | Cons |
|---|---|---|
| (a) Inline in each of the 5 affected `lsa/skills/**/SKILL.md` bodies | Local, no cross-plugin coupling. | Restates the same rule 5×; violates `core/output` "Sourced — cite by link" pattern (`core/skills/output/SKILL.md:27-28`); future verdict emitters (helper, downstream plugins) won't inherit it. |
| (b) In `lsa/knowledge/conventions.md` as a new section, cited by each LSA skill | One place to maintain within LSA; matches existing pattern for "Read protocol" and "Confirm gate types" at `lsa/knowledge/conventions.md:26-50`. | Scoped to LSA — but the verdict vocabulary itself is *marketplace-wide* at `core/knowledge/output-vocabulary.md:5` ("*Components whose chosen format uses a verdict line … pick from this table*"). The rule should live at the same layer as the vocabulary. |
| (c) In `core/skills/output/SKILL.md` as a new **Rule 6** ("What-and-why preamble"), cited by each LSA skill | Single source-of-truth at the marketplace layer; matches the verdict vocabulary's home; every plugin that emits verdicts inherits the obligation; aligns with `core/output`'s canonical-source claim at `core/skills/output/SKILL.md:8`. | Requires a `core` SemVer bump + CHANGELOG entry alongside `lsa`. |

**Recommendation: (c) as a new Rule 6, NOT a sub-bullet under Rule 5.** Re-reading `core/skills/output/SKILL.md:32-40`, Rule 5 is *"Concrete (decision prompts) — prompt voice"* — its scope is **picker subjects**: "Questions and options name the real-world subject … Pickers surface only choices that change the outcome." That is the *framing of decision prompts presented to the human*. A what-and-why preamble is a **different category**: the framing of the agent's own actions/verdicts *before any decision is offered*. Tucking the preamble under Rule 5 would be a category-mismatch — preamble obligation does not derive from prompt-voice, it derives from action-framing. New Rule 6 is the honest path. (OQ1 resolved here; previously deferred.)

The verdict vocabulary is marketplace-wide; the emission format is the same problem domain. A standalone Rule 6 in `core/output` keeps the rule + the vocabulary co-located and forces every future verdict-emitter (helper today, downstream plugins tomorrow) to inherit the discipline. Each LSA skill body cites the new rule by markdown link (one extra link per file) — no rule restatement. Trade-off (`core` SemVer bump + "five golden rules" framing becomes "six golden rules") is accepted because `core` already shipped `v0.5.5` for the canonical-source claim; this is the next logical addition.

**Cross-row coordination with roadmap row #5 (`show-changes-inline`).** Row #5 also adds a new rule to `core/output` (write-show-comment). To avoid numbering collisions if both land via PR-α, the recommended assignment is:

- **Rule 6 = "What-and-why preamble"** (this feature, row #4).
- **Rule 7 = "Show changes inline (write-show-comment)"** (row #5).

Row #4 ships first (see "Interaction with roadmap row #5" below), so this feature's PR locks in Rule 6; row #5 then claims Rule 7 by ordering.

### Concrete shape of the `core/output` edit

Add a new **Rule 6** after Rule 5 in `core/skills/output/SKILL.md` (currently the file ends after Rule 5 at line ~40 with a separator + the "Substrate selection" reference). New Rule 6 named *"What-and-why preamble — verdicts carry a one-sentence frame"*.

Indicative content:

```
## 6. What-and-why preamble — verdicts carry a one-sentence frame
Every emission of a verdict label from
[`core/knowledge/output-vocabulary.md`](../../knowledge/output-vocabulary.md) §"Verdicts"
is preceded in the same paragraph by a one-sentence preamble naming
(a) the action in plain English in the user's frame, and (b) the concrete
consequence if the human does not act. Canonical format:
`<context sentence>. <VERDICT> verdict + <details>.` A bare verdict line
fails this rule.
```

Each affected LSA skill body then adds, at the verdict emission step, a one-line citation: *"Verdict carries a preamble per [`core/output`](…) Rule 6."* — and updates the *worked-example* template inline (per AC6 and F6).

## Cross-Module Contracts

- **`core` → `lsa`.** `lsa` cites `core/skills/output/SKILL.md` (link) for the preamble rule; no schema dependency. Same direction as today's vocabulary citation (`lsa/skills/lsa-verify/SKILL.md:87` cites `core/knowledge/output-vocabulary.md`).
- **`core` → future plugins.** Any future plugin emitting verdict labels inherits the obligation by virtue of citing `core/output`. No explicit registration needed.
- **README delta.** Per `CLAUDE.md` "Discipline (sourced)" — *"any functional change to a plugin … updates the relevant README in the same commit, if any user-visible aspect changed."* The new rule is a user-visible discipline. `core/README.md` MUST gain a one-line note ("Rule 6: what-and-why preamble — verdicts carry a one-sentence frame"); `lsa/README.md` MAY gain a one-line note in the skills table noting that 5 of 8 skills now emit preamble-fronted verdicts (pull, not push — only if `lsa/README.md` already enumerates verdict formats; check at task time).

## Interaction with roadmap row #5 ("Show actual changes inline")

These two rows compose at runtime but ship independently:

| Concern | Row #4 (this feature) | Row #5 |
|---|---|---|
| Layer | Framing of *actions* | Content of *changes* |
| Surface | The one-sentence preamble *before* the verdict label | The inline-quoted change *after* the verdict label |
| Format | `<preamble>. <VERDICT> verdict + <details>.` | `<…>. <quoted diff or compressed inspection table>.` |
| Composition | `<preamble>. <VERDICT> verdict + <details>. <inline-quoted change>.` | — |
| Gold reference | `lsa-init` brownfield diagnostic (`vision/specs/roadmap.md:125`) | `lsa-reconcile` 8-element drift block (`vision/specs/roadmap.md:131`, memory: `feedback_lsa_reconcile_gold_standard.md`) |

If both ship: a verdict emission becomes `<preamble>. <VERDICT> verdict + <details>. <inline-quoted change or compressed table>.` Row #4 ships first because (a) it has fewer affected sites (7 vs. likely 20+ for #5), (b) the gold reference is already concrete, (c) the format rule is short. Row #5 is the larger sweep.

## Sequencing with roadmap row #6 (`custom-inventions-sweep`)

Row #6's candidate sweep includes removing the "Hard Confirm / Soft Confirm" vocabulary. That vocabulary surfaces in two files this feature also touches:

- `lsa/skills/lsa-reconcile/SKILL.md:35` — the `DRIFT` emission site this feature edits.
- `lsa/skills/lsa-revise-constitution/SKILL.md:61` — the `PROPOSED` emission site this feature edits.

**Sequence: row #4 ships first, then row #6 (Quick flow) runs the Hard/Soft removal.** Rationale: row #4 preserves the vocabulary as it exists today (the worked-example preambles for AC2 / AC5 avoid the term in user-facing prose but the surrounding skill-body steps still reference it). Row #6 then does a clean delete pass without colliding with this feature's preamble edits. If the order is reversed, row #4's diffs would be re-based against shifted line numbers — strictly avoidable friction. Capture this in row #6's `tasks.md` when it's planned.

## Open Questions

1. **Sub-rule or new top-level rule in `core/output`?** ✅ **RESOLVED → new Rule 6.** Re-reading Rule 5 (`core/skills/output/SKILL.md:32-40`) confirms its scope is *picker subjects* (decision-prompt voice), not action-framing. A preamble obligation is a different category and tucking it under Rule 5 would be a category-mismatch. New Rule 6 = "What-and-why preamble" is the honest path. Naming reserved alongside Rule 7 = "Show changes inline" (row #5). See §"Where the rule lives — recommendation + rationale" for the rationale.
2. **Should `lsa-plan`'s in-table `PASS / FAIL` cells (`lsa/skills/lsa-plan/SKILL.md:87,114`) be treated as verdict emissions or as table-cell values?** Current call: table-cell values, no preamble obligation. Open because the boundary is judgment — a re-reading by a non-LSA user could go either way. Resolution: capture explicitly in `tasks.md` Task 5b ("re-read in helper-mode; if user-visible as a verdict emission, add preamble; otherwise document the exclusion in the design").
3. **Does `lsa-sync`'s narrative `PASS` references at `lsa/skills/lsa-sync/SKILL.md:17,99` need any change?** Current call: no — those are descriptions of an upstream gate's outcome, not emissions by `lsa-sync` itself. Worth a second look during edits.
4. **SemVer bump magnitude.** `core` v0.5.5 → v0.5.6 (sub-rule = patch) or v0.6.0 (visible discipline change = minor)? Keep-a-Changelog allows either; the existing pattern in `core/CHANGELOG.md` should drive the choice. Resolution: check `core/CHANGELOG.md` at task time; prefer the smaller bump unless the entry pattern dictates otherwise.
5. **Does the rule also obligate non-verdict action prose** (e.g., `Observable result:` lines, `Stop.` directives)? Current call: no, scope is explicitly verdict labels per `vision/specs/roadmap.md:126`. But a downstream reading might claim *every* action headline counts. Strict scope keeps the feature shippable; future row can extend.
