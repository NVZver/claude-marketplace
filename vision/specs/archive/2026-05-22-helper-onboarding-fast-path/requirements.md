> **Trace.** On load, print first: `=============== [vision/specs/features/2026-05-22-helper-onboarding-fast-path/requirements.md] [vision] ===============`

# Feature: Helper fast-path for onboarding questions

> Source: `vision/specs/roadmap.md` §"2026-05-22 backlog detail" #2 (`vision/specs/roadmap.md:110-114`).

## Summary

When a user question matches an **onboarding pattern** (*install / start / what-is-X / how-do-I-run*) and the answer lives in a top-level README that can be cited by `file:line`, Helper short-circuits its scope-order read loop (`helper/knowledge/knowledge-scope.md:9-15`) and returns a README excerpt with citation in seconds — not minutes. Deep grep / `context7` lookups only run when the README catalog does not cover the question. This is a **symptom-level fix** of roadmap row #1 (*Refactor Helper from command-router to assistant*, `vision/specs/roadmap.md:104-108`); it ships standalone as a quick win and stays compatible with the deeper refactor.

**Surface divergence note.** The roadmap row says *"Pattern classifier lives in `helper/skills/helper/SKILL.md`."* (`vision/specs/roadmap.md:114`). That path does not exist — Helper is implemented as an agent at `helper/agents/helper.md` plus three knowledge files in `helper/knowledge/`. This spec lands the classifier on the real surface: a new knowledge file `helper/knowledge/onboarding-fast-path.md` (Knowledge — what counts as onboarding, README excerpt catalog) plus a new Step 1.5 in `helper/agents/helper.md` (Actor — when to short-circuit). Roadmap row to be amended in the same PR.

## Functional Requirements

EARS form per `vision/VISION.md:204`. Journey-shape per `vision/VISION.md` §2 sub-principle 2a (`vision/VISION.md:59`).

| ID | Requirement | Priority |
|----|-------------|----------|
| F1 | **Onboarding-pattern classification.** When a user question arrives via signal (b) free-form, signal (c) `/help <q>`, or the `/help` empty-arg starter-topic dispatch (`helper/commands/help.md:18-24`), the system shall classify it as *onboarding* if it matches an installable trigger pattern from the catalog in `helper/knowledge/onboarding-fast-path.md` AND the catalog maps it to a concrete README excerpt with a `file:line` range. Otherwise the system shall classify it as *non-onboarding* and proceed to the existing scope-order read in Step 2. | Must |
| F2 | **README excerpt response.** When a question is classified as *onboarding*, the system shall respond with the catalog-mapped README excerpt quoted inline (the actual line range, not a pointer), the source `file:line-range` citation, and one closing `AskUserQuestion` offering at most two narrow next steps (e.g., *"Try it now? — Yes / Different question"*). The response shall stay ≤30 lines of content. | Must |
| F3 | **Fall-through to deep research.** If F1 classifies the question as *non-onboarding* — OR a question matched a catalog trigger but the catalog has no `file:line` mapping for the matched concept — then the system shall fall through to the existing scope-order read at Step 2 of `helper/agents/helper.md` without altering behavior. The fast-path adds; it does not narrow. | Must |
| F4 | **No new tools, no new MCPs.** While answering an onboarding question, the system shall use only `Read` against the in-repo READMEs named in the catalog. No `Grep`, no `Glob`, no `context7`. Any pattern requiring those tools by definition does not qualify as onboarding. | Must |
| F5 | **Cooldown + signal compatibility.** When an onboarding question arrives, the system shall continue to honor the cooldown rule in `helper/knowledge/friction-signals.md:17-25` — Step 1 of the agent runs first; the fast-path is inserted as a new Step 1.5 *after* cooldown check and *before* the scope-order read. Signal (c) (`/help`) bypasses cooldown as today. | Must |
| F6 | **Catalog is data, not code.** The trigger pattern list, the README-excerpt mapping table, and the negative examples shall live in `helper/knowledge/onboarding-fast-path.md` as a Knowledge file (per `vision/specs/main.spec.md:32` NFR5 Knowledge vs Actor separation). The agent body holds only the "when to consult the catalog" directive. Adding a new onboarding pattern shall not require editing `helper/agents/helper.md`. | Must |
| F7 | **Cannot-ground fallback unchanged.** When the catalog matches a trigger but its named README range is missing or empty at runtime, the system shall fall through to F3 (deep research) rather than fabricate. The existing `"I cannot verify this"` fallback (`helper/agents/helper.md:50`, `core/ground-rules` Rule 2) stays the final backstop. | Must |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NF1 | **Latency *target*: ≤5 seconds wall-clock for the fast-path answer turn**, from agent invocation to response body. Framed as a target, not a hard pass/fail gate — LLM tool-loop wall-clock has non-deterministic floors that may exceed 5s in practice even on a fast-path hit. Concrete number justified by: (a) the work is ≤3 `Read` calls (catalog + one or two READMEs) where each call is <1s in practice; (b) no LLM tool-use loop beyond classification + compose; (c) the user-reported failure was *~3 minutes* (`vision/specs/roadmap.md:113`), so anything ≤5s is a >30× improvement and crosses the *"feels instant"* threshold. Measured via probe in `test-suites.md` Journey 1; >5s with otherwise-correct response body is recorded but does not block merge. See OQ6. |
| NF2 | **Catalog coverage NFR.** The catalog shall map at minimum the four canonical onboarding patterns named in the roadmap row: *install*, *start / get started*, *what is X* (for `X ∈ {LSA, core, helper}`), *how do I run / use X*. Adding the 5th-Nth pattern is in scope for this feature only if the README excerpt already exists; otherwise it is deferred. |
| NF3 | **Fact-grounding** (per `vision/specs/main.spec.md:28` NFR1). Every README excerpt rendered by the fast-path carries its `file:line-range` citation. |
| NF4 | **Per-plugin SemVer + CHANGELOG** (`vision/specs/main.spec.md:30` NFR3). `helper` plugin bumps minor version (v0.2.1 → v0.3.0) in the same commit; CHANGELOG entry added. |
| NF5 | **Knowledge vs Actor separation** (`vision/specs/main.spec.md:32` NFR5). New file `helper/knowledge/onboarding-fast-path.md` is Knowledge (trigger patterns + excerpt catalog + negative examples). The new Step 1.5 in `helper/agents/helper.md` is Actor (when + how to consult the catalog). |
| NF6 | **No regressions on existing AC paths.** All Acceptance Criteria of the parent helper-agent spec (`vision/specs/features/2026-05-21-helper-agent/requirements.md:64-99` — AC1 through AC8) shall continue to hold. AC1 (Inline question) gains a *faster* path for onboarding subset; the slow path remains for everything else. |

## Inputs & Outputs

- **Input.**
  - A user question arriving at the Helper agent via signal (a), (b), or (c) (`helper/agents/helper.md:23-28`).
  - The catalog: `helper/knowledge/onboarding-fast-path.md` (new file, content specified in `design.md`).
  - In-repo READMEs referenced by the catalog: `README.md`, `core/README.md`, `lsa/README.md`, `helper/README.md`, plus `vision/VISION.md` §0 / §1 / §4.
- **Output.**
  - **Fast-path branch:** quoted README excerpt + `file:line-range` citation + at most one closing `AskUserQuestion`. ≤30 lines.
  - **Fall-through branch:** existing Helper behavior unchanged (Step 2 scope-order read).
  - **Cooldown silent-exit branch:** existing Helper behavior unchanged (`helper/agents/helper.md:32`).
- **Side effects.** None. Read-only. No state files written. Cooldown remains in main-agent working memory per `helper/knowledge/friction-signals.md:48`.

## Constraints

- **NFR1 fact-grounding** (`vision/specs/main.spec.md:28`).
- **NFR5 Knowledge vs Actor separation** (`vision/specs/main.spec.md:32`).
- **Vision Principle 9 — substrate-native** (`vision/VISION.md:66`) — closing question uses `AskUserQuestion`, never text `[a]/[b]/[c]`.
- **Vision §2 sub-principle 2a — journey-shape AC** (`vision/VISION.md:59`).
- **`core/output` Rule 5 Concrete** (`core/skills/output/SKILL.md` Rule 5) — closing `AskUserQuestion` names the subject (e.g., *"Install both plugins now? — Yes / Different question"*), never opaque IDs.
- **Memory: re-ground jargon on first turn-use** (`feedback_helper_must_reground`) — *LSA* / *flow-selector* / *SKILL.md* keep their 3–5 word gloss on first use even in fast-path responses.
- **Memory: outputs ≤1.5 screens** (`feedback_output_length`) — fast-path is naturally short; cap is ≤30 lines.
- **Constraint inversion of `helper/knowledge/knowledge-scope.md:31`** — that file currently mandates *"Pick the smallest set of source files that could plausibly ground the answer (3–5 files max). Read those."* The fast-path narrows this further: for onboarding-classified questions, read **one or two** named files from the catalog, full stop. The 3–5 budget remains for fall-through.

## Out of Scope

- **The full Helper refactor (roadmap row #1).** This spec adds one specific short-circuit path. The deeper assistant-shape refactor (goal-understanding, no-mandatory-picker) is `vision/specs/features/<future>` and may subsume parts of this work later. Defined boundary below in **Interaction with roadmap row #1**.
- **`AskUserQuestion` overuse audit (roadmap row #3).** This spec touches one closing picker in fast-path responses; the broader Helper / LSA picker audit is separate.
- **LSA verb-headline preamble (row #4)** and **show-actual-changes-inline (row #5).** Both touch Helper but on different surfaces.
- **Onboarding patterns whose answer is *not* in a top-level README.** Example: *"how do I configure `.lsa.yaml`"* — answer is in `lsa/ARCHITECTURE.md` §4.10, which is not a top-level README. Treated as deep-research subject; not fast-path eligible v1. Catalog expansion is a follow-up.
- **External-library onboarding (e.g., `context7` itself).** `context7` is reachable via MCP but its docs are URL-cited, not `file:line`. Stays in the existing scope-3 path (`helper/knowledge/knowledge-scope.md:15`).
- **Telemetry / metrics auto-emit.** Latency is measured manually in `test-suites.md` Journey 1 probe; no metrics file is written this feature.
- **First-run onboarding wizard.** Already out of scope per parent spec (`vision/specs/features/2026-05-21-helper-agent/requirements.md:60`); not reopened here.

## Interaction with roadmap row #1 (boundary)

- **This row delivers (standalone, mergeable now):** one specific short-circuit path for onboarding-pattern questions, defined in a Knowledge file, wired into the existing agent via a new Step 1.5. No change to Helper's overall shape (still picker-closed, still command-router).
- **Row #1 subsumes later:** the broader question of *"should Helper lead every turn with a picker at all?"*. When row #1 lands, Step 5 of `helper/agents/helper.md` (`helper/agents/helper.md:36`) may stop being mandatory; the fast-path's closing picker becomes one example among several "optional offer" shapes, not a mandatory one. F2's *"one closing `AskUserQuestion`"* may relax to *"zero or one"* under row #1.
- **What does NOT change between this row and row #1:** the catalog (`helper/knowledge/onboarding-fast-path.md`), the classifier algorithm, and the README-excerpt mapping table. Row #1 inherits all of them.

## Acceptance Criteria

Journey-shaped per `vision/VISION.md` §2 sub-principle 2a. EARS form per `vision/VISION.md:204`.

- [ ] **AC1 — Onboarding fast-path: "how do I get started with LSA".**
  *Journey:* user types `/help how do I get started with LSA` (or free-form mid-flow). User has never used Helper this session.
  *Behavior:* **When** a user question matches the onboarding trigger pattern *"start / get-started + LSA"*, **the system shall** respond within ≤5 seconds wall-clock with the README excerpts at `README.md:73-83` (the "Install" block) AND `lsa/README.md:49-60` (Depends on / install order) both quoted inline, the citations `README.md:73-83` and `lsa/README.md:49-60` rendered with the response (matching catalog row 2 in `design.md:85` and Journey 1 in `test-suites.md:32`), the 3-word `LSA` gloss on first turn-use per `helper/knowledge/output-discipline.md:18`, and one closing `AskUserQuestion` (e.g., *"Want a walkthrough of the first `/lsa:init` run? — Yes / Different question"*). No `Grep`, no `context7`, no `mcp__plugin_context7_context7__*` tool call.

- [ ] **AC2 — Onboarding fast-path: "how do I install the marketplace".**
  *Journey:* user types `/help install` (or `/help how do I install`).
  *Behavior:* **When** a user question matches the onboarding trigger pattern *"install"*, **the system shall** respond within ≤5 seconds with the install block from `README.md:73-83` quoted inline, the `file:line-range` citation, and one closing `AskUserQuestion`.

- [ ] **AC3 — Onboarding fast-path: "what is core" / "what is LSA" / "what is helper".**
  *Journey:* user types `/help what is core` (or `lsa`, or `helper`).
  *Behavior:* **When** a user question matches the onboarding trigger pattern *"what is + {core, lsa, helper}"*, **the system shall** respond within ≤5 seconds with the matching catalog excerpt — `core/README.md` opening, `lsa/README.md:1-9`, or `helper/README.md:1-10` — quoted inline with citation. No deep-grep, no `context7`.

- [ ] **AC4 — Fall-through: question outside catalog.**
  *Journey:* user types `/help what does lsa-verify's orphan-AC predicate do?` — a question whose answer is in `lsa/skills/lsa-verify/SKILL.md`, not a top-level README.
  *Behavior:* **When** a user question does not match any catalog onboarding trigger, **the system shall** proceed to the existing scope-order read (`helper/agents/helper.md` Step 2) without altering it. The fast-path adds no latency to the non-onboarding path.

- [ ] **AC5 — Fall-through: trigger matches but catalog excerpt missing.**
  *Journey:* user types `/help install context7` — *install* trigger fires, but the catalog has no entry for *install + context7*.
  *Behavior:* **When** a trigger pattern matches but the catalog does not map it to a concrete `file:line` README range, **the system shall** fall through to deep research (Step 2). No fabricated answer, no half-baked excerpt.

- [ ] **AC6 — Cannot-verify backstop preserved.**
  *Journey:* user types `/help what is the snorgleblat?` (no marketplace subject).
  *Behavior:* **When** the catalog has no trigger match AND the scope-order read returns no source, **the system shall** respond `"I cannot verify this."` per `helper/agents/helper.md` Step 3 / `core/ground-rules` Rule 2 — unchanged from today.

- [ ] **AC7 — Closing question subject-named, not opaque.**
  *Journey:* any fast-path response closing picker.
  *Behavior:* **The system shall always** name the real subject in the closing `AskUserQuestion` (e.g., *"Run `/lsa:init` now? — Yes / No"*), never opaque IDs (`AC1`, `OQ5`) or jargon-only labels. Per `core/output` Rule 5 and `feedback_gate_prompts_concrete` memory.

- [ ] **AC8 — Cooldown honored.**
  *Journey:* user already declined an auto-engaged Helper (signal b) earlier in the session for the same friction window; then types a free-form onboarding question matching signal (b) again before any other signal fires.
  *Behavior:* **When** the cooldown rule (`helper/knowledge/friction-signals.md:17-25`) would silently exit Helper for signal (b), **the system shall** silently exit *before* reaching the fast-path. Step 1 runs first; Step 1.5 (fast-path) runs only if Step 1 proceeds.

## Open Questions

- **OQ1.** **Classifier shape — regex+keyword catalog vs. agent-judgement?** Recommendation in `design.md`: keyword catalog (cheap, deterministic, easy to read). Open: should we instead trust the LLM to read the catalog as Knowledge and judge match? Trade-off — judgement scales to natural phrasing without catalog expansion, but is harder to test deterministically. **Tentative resolution in `design.md`: keyword catalog + LLM judgement together (catalog is the seed, LLM expands phrasing).**
- **OQ2.** **What counts as "in a top-level README"?** The four canonical ones (`README.md`, `core/README.md`, `lsa/README.md`, `helper/README.md`) are unambiguous. Should `vision/VISION.md` §0 *"The one sentence"* qualify? It is at the constitution level, not a README, but it answers *"what is this whole thing"* in one paragraph. **Tentative resolution: include `vision/VISION.md:13-15` as an onboarding excerpt for the *"what is this marketplace"* trigger.**
- **OQ3.** **Latency budget enforcement.** NF1 says ≤5s wall-clock. There is no telemetry emitter; the probe in `test-suites.md` Journey 1 measures it manually. If row #1 lands telemetry, can adopt automated check. **Tentative resolution: manual probe is sufficient for v1; auto-check deferred.**
- **OQ4.** **Multiple onboarding triggers in one question.** E.g., *"how do I install LSA and what does it do?"* matches *install* AND *what is LSA*. Which excerpt wins? **Tentative resolution in `design.md`: catalog rows are ordered; first match wins; closing `AskUserQuestion` offers the other excerpt as a follow-up.**
- **OQ5.** **Catalog drift.** When a README changes, line ranges in the catalog rot. Should drift detection be in scope here? **Tentative resolution: out of scope this feature; drift will surface naturally when AC tests run. Catalog uses heading anchors as a secondary citation hint to ease re-pin.**
- **OQ6.** **NF1 latency as target vs. hard requirement.** ≤5s wall-clock is reframed as a target (see NF1). LLM tool-loop floors are non-deterministic. Should it stay a target, or be relaxed to a wider band (e.g., ≤15s) as a hard gate? **Tentative resolution: keep as target for v1; revisit after Journey 1 probe data exists.**
- **OQ7.** **Classifier non-determinism on ambiguous multi-trigger questions.** OQ4's first-match-wins resolution assumes the LLM-judgement step picks the "right" first match. For genuinely ambiguous phrasings like *"how do I install LSA and what does it do"* (Journey 4) the LLM could pick row 2 (*get started with LSA*) instead of row 1 (*install*). The catalog ordering is a hint, not a hard pin. **Tentative resolution: accept as a known fragility for v1; Journey 4 records which row fires and we revisit if mis-pick rate is >0 across the probe runs.**
