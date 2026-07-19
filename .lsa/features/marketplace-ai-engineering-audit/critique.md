# Dual harsh critique — marketplace AI-engineering audit

**Status:** adversarial review of [`report.md`](./report.md) + [`discover.md`](./discover.md)  
**Date:** 2026-07-19  
**Posture:** find weak findings and unhelpful cleverness. Not a compliment sandwich.

Two passes:
- **A — Pro-tier operator:** predictable token/reliability wins under Sonnet usage caps.
- **B — Prompt-systems skeptic:** ceremony that recreates the disease it claims to cure.

---

## Perspective A — Pro-tier operator

### Kill or demote

**1. F02 Prompt ABI as P0 is architecture theater.**  
FACT: the always-on card is already 42 lines (`core/CLAUDE.md`) and says load one skill (`core/CLAUDE.md:40-42`).  
OPINION: building a compiler, manifests, fail-closed coverage lint, and “transitive budget tests” before measuring which actors actually blow context is the opposite of Pro-safe. You already shipped the cheap half (card + digest + map). An ABI is months of meta-work for an unmeasured middle. **Demote below any measured fan-out fix. Do not start.**

**2. F09 capability-class routing is a fake next lever.**  
FACT: only three surfaces are wired; floors already protect reconcile/delegate/implement (`lsa/knowledge/model-routing.md:34,46-50`).  
OPINION: inventing `deterministic | bounded-judgment | synthesis | safety-critical` does not remove a Pro reload. Manager still pays a fresh Agent context on shape/decompose. Escalation-on-failure can *increase* spend. **Kill until F07 lands and you have dispatch-count logs.**

**3. F10 “cross-tier regression lab” as Critical impact is dishonest sequencing.**  
FACT: testing standard explicitly defers automated harness (`.lsa/standards/testing.md:13`).  
OPINION: a lab that needs stub harness + golden corpus + dual-model runs + independent judges is a research program, not a product fix. It does not stop the next `/manager:next` from reading 5 full pitches. **Keep a 3-probe dogfood checklist; demote the lab to “after measured pain.”**

**4. “First blocker = portability” overstates consumer pain.**  
FACT: skills literally say `this repo: bash scripts/roadmap-row.sh` (`manager/skills/next/SKILL.md:24`). Scripts declare NOT shipped (`scripts/roadmap-query.sh:6`).  
OPINION: in *this* marketplace source repo the scripts work. For installed plugins in foreign repos, missing scripts → fallback whole-file read — real, but only if consumers install `manager` elsewhere and still have a YAML roadmap. That is a niche until you dogfood manager outside this repo. **Keep F01, but label it “consumer install correctness,” not “the token crisis.”**

**5. F08 is partly a ghost finding.**  
FACT: reconcile Step 4 already calls `coverage-skeleton.sh` (`lsa/skills/reconcile/SKILL.md:36`).  
OPINION: ranking “turn semantic gates into skeletons” as a forward P1 while the skeleton is on the active branch makes the audit look unaware of its own tree. **Rewrite F08 as “finish remaining scripts (resolve-refs / prompt-lint / overlap); coverage-skeleton is in flight — do not re-pitch.”**

### Overrated cleverness

| Clever idea | Why it won’t pay rent soon |
|---|---|
| Evidence ledger + evidence IDs (F03) | Adds a second citation system models will ignore or invent IDs for. The cheap win is: exempt silence actors + stop printing traces on every load. Ledger is optional later. |
| Typed JSON for every boundary (F05) | Product-manager returning a pitch as markdown is not the bug; dispatcher re-render + gate delivery is. Schema without a measured “omitted pending_gates” rate is speculative. |
| Feature-pack resolver (~31×) | Observation says **if** agents pull the whole tree (`…impact.md:165`). No over-read rate. Building a resolver for an unmeasured “if” is cargo-cult selective-load. |
| Target architecture 6-layer control plane (`report.md:238-244`) | Reads like a platform PRD. You need 2–3 scripts and 2 prompt edits that a dogfood session can feel in a week. |

### Missed problems (higher leverage than half the P0s)

1. **Pitch fan-out is the only remaining measured manager cliff** — corpus ≈48.6k tok, Mode 1 still full-reads (`…impact.md:155`; `project-manager.md:39`). Audit buries this as P1 F06 under ABI/telemetry/schemas. **Wrong.**
2. **Human gate tax / turn fragmentation** — flow-selector always waits for confirm (`flow-selector/SKILL.md`); every LSA stage gates. Report barely treats this as a Pro cost (context loss between turns > a few trace lines).
3. **`manager:next` “what’s next” still surfaces a Could item first** — `roadmap-row.sh` is file-order among backlog, not Must-aware (live: `library-spec-cache` Could). Selective-load without priority-aware next makes the fast path *product-wrong*, not just token-cheap.
4. **Reconcile N=3 × execution-as-reasoning** — still the expensive fuzzy core. Skeleton helps enumeration; it does not stop three speculative scenario runs. Audit underweights “docs-mode: gate.sh is the does-check; stop pretending Gherkin is executed.”
5. **Ceremony volume of the audit itself** — report + discover + canvas + matrices. If the product’s problem is context budget, shipping a 280-line roadmap of unproven compilers is ironic.

### Better ranking (operator)

| Rank | Do this | Why |
|---|---|---|
| 1 | **Pitch outline script + Mode 1 wiring** (old F06) | Only large remaining *measured* fan-out |
| 2 | **Inline manager shape/decompose/check** (old F07) | Removes real context reloads; standard already says so (`code.md:65`) |
| 3 | **Silence/trace exemption** (thin F03) | One collision, one-day fix; drop the ledger |
| 4 | **Ship roadmap helpers in manager** (F01) | Correctness for foreign installs; shim in source repo |
| 5 | **Pointer+summary for product-manager pitch** (thin F05) | Standard already written (`code.md:69`); no JSON religion |
| 6 | Finish coverage-skeleton epic; add prompt-lint only if review burns tokens | Don’t re-audit F08 |
| — | ABI, capability routing, eval lab | After you can show session token deltas |

### Replacement suggestions (testable)

1. **Pitch ladder in one PR:** `pitch-query.sh outline` → Mode 1 forbids full pitch read until pick; test like F9 ledger test. Success: Mode 1 candidate pass loads &lt;2k tok of pitch text for 5 candidates.
2. **Dispatch counter dogfood:** one shape→decompose→discover session; count Agent tool calls. Success: 0 before implement. No new routing ontology required.
3. **Trace exemption patch:** one paragraph in `output` + `verify-checkpoint` Constraints. Success: no-signal cycle transcript has zero bytes.
4. **Must-aware `roadmap-row.sh`:** prefer Must then Should then Could. Success: fast-path “what’s next” no longer returns a Could while Must items exist.
5. **Drop “Prompt ABI” language.** If you compress prompts, do it by deleting examples from hot actors and citing knowledge — the card pattern you already have.

---

## Perspective B — Prompt-systems skeptic

### Ceremony that eats the gains

The audit’s spine (“compile smaller prompts, type every boundary, evidence ledger, capability router”) recreates a second marketplace *about* the marketplace.  

FACT: `core/skills/output/SKILL.md` is 190 lines; the card already re-grounds the hard rule without loading it (`core/CLAUDE.md`).  
OPINION: a Prompt ABI compiler that must not omit load-bearing rules will become another always-on document generators emit and models half-follow — same failure mode as today’s prose, with worse indirection.

F03’s “evidence ledger with stable IDs” is especially toxic: fact-grounding today means *searchable quote in the source*. IDs require a side channel. Models will fabricate `E-17`. You replace hallucination of facts with hallucination of pointers.

### Real collisions vs aesthetic ones

| Claimed collision | Verdict |
|---|---|
| Trace hard vs verify-checkpoint zero-output | **Real.** `output/SKILL.md:26` “Hard — print it” vs `verify-checkpoint/SKILL.md:54` “zero output”; example even prints a cycle line (`:79-83`). Fix locally. |
| “Visible CoT” vs token efficiency | **Mostly aesthetic.** A 2–4 sentence rationale (`flow-selector/SKILL.md:38`) is cheap vs pitch corpus reads. Renaming to “decision record” + 6 fields can *increase* tokens if models pad every field. |
| Full pitch in payload vs artifact hand-off | **Real process bug, wrong prescription.** Standard already demands pointer+summary (`code.md:69`); product-manager violates it (`product-manager.md:33`). Fix the actor to match the standard — don’t invent JSON Schema first. |
| Soft feature-pack scope | **Unproven harm.** “~31× if” is not “agents do.” |

### Schema/ABI without a failure mode

Ask of every typed-boundary proposal: *what broken transcript does this catch that a human gate missed?*

| Proposal | Failure mode named in audit? | Actual product failure mode |
|---|---|---|
| Prompt ABI | “conflicting-instruction load” | Vague. No session log of which rule conflict caused a wrong action. |
| JSON pending_gates | “omitted gates / mode confusion” | Plausible but uncounted. Cheaper: one Example Output fixture + lint that payload lists `Pending gates:`. |
| Checkpoint JSON schema | “malformed note” | Possible; four Markdown fields are already a table. Awk required-field check &gt; JSON Schema ecosystem. |
| Capability router | “static names” | Not a user-visible failure. Wrong model tier is rare vs wrong pitch load. |

### F01–F10 kill / keep / rewrite

| ID | Verdict | Rewrite |
|---|---|---|
| **F01** | **Keep (narrow)** | Ship `manager/scripts/{roadmap-row,roadmap-query}.sh` + `CLAUDE_PLUGIN_ROOT`. Drop “shared helpers plugin” fantasy. |
| **F02** | **Kill** | Replace with: delete/move examples out of top 3 hottest actors; keep card pattern. No compiler. |
| **F03** | **Keep 20%, kill 80%** | Exempt silence + make trace guidance (or debug-only). **No evidence ledger.** |
| **F04** | **Rewrite tiny** | Change “chain-of-thought” → “rationale (≤3 sentences, cite signals).” Skip 6-field schema + lint crusade. |
| **F05** | **Keep thin slice** | product-manager writes pitch to scratch path, returns pointer+pending_gates list. Defer JSON Schema. Optional: awk field check on checkpoint notes. |
| **F06** | **Keep / promote to #1** | Pitch outline script + wiring test. Feature-pack resolver only after measuring over-read. |
| **F07** | **Keep / promote to #2** | Inline manager per existing standard. Benchmark = Agent call count. |
| **F08** | **Rewrite** | “Complete in-flight skeleton epic; extract prompt-lint only for checks already duplicated in `lint.sh`.” |
| **F09** | **Kill for now** | Revisit after F07; don’t add escalation ontology. |
| **F10** | **Kill as program; keep dogfood** | 5 fixed Sonnet probes per release, pass/fail log. No dual-tier lab until product metrics exist. |

### 2-week ruthless cut

**Week 1**
1. Pitch outline script + Mode 1 change + no-wholefile-pitch test.  
2. Trace/silence exemption + fix verify-checkpoint example.  
3. product-manager pointer hand-off (match `code.md`).

**Week 2**
4. Inline `manager:check` + `manager:next` non-fast-path (smallest surface).  
5. Must-aware roadmap-row ordering.  
6. Dogfood log: tokens approx (bytes of files Read) + Agent dispatch count on one shape→decompose path.

**Explicitly not in 2 weeks:** Prompt ABI, evidence ledger, capability router, cross-tier lab, feature-pack resolver, epic-overlap graph, JSON Schema suite.

---

## Cross-cutting weaknesses (both perspectives agree)

1. **Measured vs imagined:** report’s best numbers are yesterday’s selective-load wins; most “Critical” items lack a before/after session metric.
2. **Ranking inverted:** largest residual fan-out (pitches) and largest residual reload (manager Agent) sit below unbuilt compilers.
3. **Small vs top-tier columns are mostly filler.** Many rows are generic (“leaves context for reasoning”) with no falsifiable prediction.
4. **Audit contradicts principle 10:** it proposes large non-deterministic programs (ABI, lab, router) instead of the next thin scripts.
5. **Partial in-flight work under-integrated:** F08 / coverage-skeleton should have reordered the whole program around “finish what’s open,” not open ten new fronts.
6. **Product sequencing ignored:** fast-path next item can be a Could while Must audit sits later in the file — a product bug the audit never filed as F0.

---

## What would actually make the product better

If the goal is “useful on small models AND stronger on top-tier,” the boring stack wins:

1. **Less input** — pitch outlines, inline manager, Must-aware next.  
2. **Fewer fake obligations** — silence-safe traces; stop mandatory quote spam on trivial clauses (guidance, not a ledger).  
3. **One real hand-off fix** — pointer+summary where the standard already requires it.  
4. **Prove with dogfood numbers** — file-bytes read + Agent dispatches per canonical flows — before any compiler or eval lab.

Everything else in the report is optional narrative until those move.
