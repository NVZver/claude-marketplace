Shaped by: product-manager (developer-productivity / quality-engineering lens)
Date: 2026-06-09
Status: approved
Decisions (2026-06-09, human-gated via start-feature orchestrator):
- Shaping lens: confirmed (QE / developer-productivity).
- Appetite: **fork A** — personal dogfood practice (`.lsa/escapes.md` + manual procedure), zero plugin code, no version bump. Fork B (shippable `reconcile`/`revise-constitution` surface) is the explicit follow-on, promotion-gated on the manual loop firing once on a real escape.
- User-flow decisions (walked end-to-end before locking epics, per "manual before automate"):
  - **Escape boundary:** post-`reconcile`-PASS only. A bug qualifies as an escape solely if it slipped a full `reconcile` PASS. Quick/Standard-flow work that skips full reconcile does not generate escapes — keeps the signal clean.
  - **Finding-class:** small controlled vocabulary per stage (not free text), so the ≥2 aggregation matches reliably. The vocabulary starts minimal and grows only when `revise-constitution` promotes a genuinely new class. This is part of E1's schema design.
Why now: LSA captures lagging outcomes (`.lsa/metrics.md`) but every escaped bug is currently a dead end — caught, fixed, and forgotten, with no path back into the rules. The loop measures itself but cannot yet heal itself; closing that gap is the next move on VISION principle 8 ("the system improves itself").

# Self-healing escape loop for LSA

Give LSA an escape-analysis loop: every defect found *after* a `reconcile` PASS is logged, attributed to the LSA stage that should have caught it, and routed back to `revise-constitution` as a candidate rule — so the system learns from holes in its own process, not just measures outcomes.

## Problem

The person dogfooding LSA on this repo (the repo owner today; any LSA adopter tomorrow) has a measurement system but not a learning system.

Evidence — what exists and where it stops:

- **Lagging outcomes are tracked.** `.lsa/metrics.md:9-12` records three per-feature scores (accuracy, facts-with-sources, only-required-changes) written by `lsa:verify` on clean PASS (`.lsa/metrics.md:5`). These tell you *whether* a feature came out clean — never *why* a later bug slipped through.
- **Per-feature loop telemetry exists but is descriptive, not corrective.** `.lsa/archive/2026-05-21-ears-journey-shape-ac/metrics.md:40-59` logs questions-per-phase, amendment cycles, and findings closed-in-feature vs. deferred. It is a post-mortem of one feature's *build cost*, with no aggregation across features and no escape concept.
- **`reconcile` already produces a per-requirement does/only/all breakdown** (`lsa/skills/reconcile/SKILL.md:29-34`) and writes `conformance.md`. But its judgement is point-in-time: it asks "is this diff correct *now*," never "what class of defect keeps reaching this gate."
- **A promotion path already exists — and is idle.** `lsa/skills/revise-constitution/SKILL.md:17-18` exists precisely to "make the rules a merged feature taught us permanent — one change at a time." Nothing feeds it a *defect signal*; it only runs on whatever lessons a human happens to remember at archive time.
- **The pattern for absorbing a recurring finding-class is proven.** `scripts/lint.sh` checks C4/C5/C6 (`scripts/lint.sh:100-165`) are the established shape: a finding that recurs becomes a mechanical check. There is no trigger that *notices* the recurrence and routes it to that shape.

So the gap is specific: LSA has no **escape log + stage attribution**. A bug found after a PASS is invisible to the system — it never becomes a rule, a lint check, or a metric. VISION §5 names a "retro habit" with "a promotion path into standards or new skills" (`.lsa/VISION.md:167`) and principle 8 calls drift "a measured failure mode, not a surprise" (`.lsa/VISION.md:65`) — but the retro/self-eval rows are still deferred in `.lsa/roadmap.md:28-29`. This pitch is the smallest concrete carving of that intent that delivers the *self-healing* property specifically.

Current workaround: when the user finds a post-PASS bug, they fix it ad hoc and — if they remember — manually invoke `lsa:revise-constitution`. Stage attribution lives only in their head; recurrence is noticed only by memory; nothing is logged. The lesson is lost unless the human carries it.

Definition of success: a post-PASS defect produces a logged escape with a stage tag, and a recurring escape-class (same stage + same finding-class, ≥2 features) surfaces as an explicit candidate routed to `revise-constitution` or a lint check. Concretely: at least one real escaped defect, during the dogfood window, travels the full path log → attribute → promoted rule/check — without the human having to remember to start it. That single completed loop is the proof the property exists.

## Appetite

Small batch. The whole point is to harvest from artifacts the loop already emits (`metrics.md`, `conformance.md`, `revise-constitution`) — "ownership over automation," minimal new machinery. The deliverable is an **escape log file + a stage-attribution convention + one routing step into `revise-constitution`**, plus a thin aggregation pass that flags a repeat escape-class. No new scoring math, no dashboard, no agent.

**The one genuine fork the human must settle — how far this goes:**

- **(A) Personal dogfood practice.** A markdown escape log (`.lsa/escapes.md`) + a documented manual procedure: when you find a post-PASS bug, you append a row, tag the stage, and the next `revise-constitution` run reads the log. Zero plugin code, zero version bump. Smallest thing that proves the property; matches the "manual before automate" preference (run the procedure by hand e2e before building a tool). Risk: relies on the human remembering to log.
- **(B) Shippable LSA capability.** The same escape log, but `reconcile` (or a new `escape` skill) writes the row on a detected post-PASS defect, and `revise-constitution` formally consumes the log as a declared Input. This is a real LSA surface change — touches `lsa/skills/`, plugin.json, CHANGELOG, README — and earns an Extended flow. Risk: builds machinery before the manual practice has revealed its true shape.

The QE read: **start at (A)**, run one or two real escapes through it by hand, let lived experience shape the schema, and only promote to (B) once the manual loop has fired and you know exactly what `reconcile` should write. This pitch is drafted to make (A) the recommended appetite and (B) the explicit follow-on — but the boundary is the human's to set, since it decides whether this cycle touches plugin code at all.

Out of appetite regardless of fork:

- Statistical eval (Wilson CI, Elo, variance-aware ranking) — VISION §6 "Adjust #3" defers it explicitly (`.lsa/VISION.md:245`); pass/fail counts only.
- Vanity metrics (LOC, specs-written) and token/latency dashboards as primary signals.
- Auto-applying any promoted rule — `revise-constitution` keeps its one-change-at-a-time human gate (`lsa/skills/revise-constitution/SKILL.md:40`). The loop *proposes*; the human still owns intent.

## Solution sketch

- **Key user interactions:**
  - When the user finds a bug *after* a `reconcile`/`verify` PASS, they record an **escape**: one row in `.lsa/escapes.md` — what escaped, which feature it slipped through, and the **stage tag** for the LSA stage that should have caught it (`discover` / `specify` / `verify` / `reconcile`).
  - At constitution-revision time, `revise-constitution` reads the escape log and, for any escape-class seen in ≥2 features, presents it as a candidate permanent rule or lint check — through its existing one-change-at-a-time gate.
  - Three **leading indicators** (supporting, not the spine) are harvested from artifacts already emitted, to predict a bad outcome before it lands: grounding first-pass rate (verify GROUNDED on attempt 1), reconcile failure split (which of does/only/all fails most — already in `conformance.md`), and flow-call accuracy (orchestrator's flow proposal vs. human override — VISION §4 already names overrides as a few-shot training signal, `.lsa/VISION.md:142`). Discovery self-sufficiency (questions the repo could have answered) is a fourth candidate, tied to the standing "discovery must discover" preference — included only if it can be read cheaply from existing telemetry, dropped otherwise.

- **Main components:**
  - **Escape log** — one new markdown file, `.lsa/escapes.md`, append-one-row-per-escape, schema mirroring the `.lsa/metrics.md` table style (`.lsa/metrics.md:7`): `escape · feature · stage · finding-class · status (open / promoted-to-rule / promoted-to-lint / dropped)`.
  - **Stage-attribution convention** — a short knowledge note defining the four stage tags and how to choose one. This is the load-bearing idea: attributing the escape to a stage is what turns "a bug" into "a hole in a specific part of the loop."
  - **Routing step** — `revise-constitution` gains the escape log as an Input (formally in fork B; by documented procedure in fork A) and a step that proposes repeat-escape-classes as candidate rules.
  - **Repeat-finding aggregation** — a thin pass (manual checklist in A; a step in B) that groups escapes by stage + finding-class and flags any class with count ≥2 as a promotion candidate, following the C4/C5/C6 precedent (`scripts/lint.sh:100-165`).

- **Critical path:** post-PASS bug found → escape row logged with stage tag → at next revision, aggregation flags a ≥2 escape-class → `revise-constitution` presents it through its existing human gate → human approves → it becomes a permanent rule or a new lint check → that class stops escaping. The loop has healed a hole in itself. Everything else (leading indicators, the fourth indicator, automation) is supporting and can be dropped without breaking this path.

## Rabbit holes

1. **Stage attribution becomes a debate.** "Should `specify` or `verify` have caught this?" can stall on every escape. Mitigation: the attribution note gives a default tie-break (attribute to the *earliest* stage that had enough information to catch it) and allows a `multi` tag; attribution is a fast judgement, not a tribunal — the value is in the trend across many escapes, not perfect per-escape precision.
2. **The log goes stale because logging is manual (fork A).** If the human forgets to log, the loop starves. Mitigation: keep the log row dead-simple (5 fields, no ceremony); make appending an escape part of the bug-fix habit, not a separate ritual. This rabbit hole is itself the strongest *evidence for* eventually promoting to fork B — but only after the manual practice proves the schema.
3. **Leading indicators drift toward a dashboard.** The supporting indicators could quietly grow into the token/latency dashboard this pitch explicitly excludes. Mitigation: cap at the three (possibly four) named indicators, each readable from an artifact that already exists; if an indicator needs new instrumentation to compute, it is out of appetite this cycle.
4. **Premature automation in fork B.** Writing escape-detection into `reconcile` before the manual loop has run risks encoding the wrong schema and the wrong stage-tag taxonomy. Mitigation: the recommended sequence (A then B) exists precisely to retire this risk — B is shaped by what A reveals.

## No-gos

1. This pitch does NOT add statistical eval, variance-aware ranking, or any scoring beyond pass/fail counts — VISION §6 "Adjust #3" defers that explicitly (`.lsa/VISION.md:245`), and re-opening it is out of scope.
2. This pitch does NOT build a metrics/observability dashboard or any token/latency surface as a primary signal — excluded by the user's locked constraints; the leading indicators are diagnostic reads off existing artifacts, not a dashboard.
3. This pitch does NOT auto-apply promoted rules — `revise-constitution`'s one-change-at-a-time human gate (`lsa/skills/revise-constitution/SKILL.md:40`) is preserved; the loop proposes, the human disposes (principle 1a, ownership over automation).
4. This pitch does NOT subsume the deferred "Retro habit" and "Self-eval harness" roadmap rows (`.lsa/roadmap.md:28-29`) — it is the narrower *escape-analysis* slice of that intent. A general retro scratchpad and a structural/boundary/hedge-word lint harness remain separate, later work; this pitch deliberately carves only the self-healing escape loop.
5. This pitch does NOT, in its recommended fork (A), change any plugin surface (no `lsa/skills/` edits, no plugin.json bump, no CHANGELOG/README delta). If the human chooses fork (B), those obligations re-attach and the work escalates to an Extended LSA flow — that is the trigger for re-scoping, not a silent expansion of this pitch.
