# Roadmap — claude-marketplace

Prioritized list of upcoming work, populated from `vision/VISION.md` §6 *"Adjust"* items, §7 *"Open decisions"*, and post-0.2.0 follow-ups from `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15.

## Feature Backlog

| Feature | Priority | Status | Notes |
|---|---|---|---|
| EARS notation in AC block | Should | backlog | Adopted via Tech Picture 2026-05-20 — see §"Tech Picture adoption — 2026-05-20" #1. |
| Library-spec cache for top 3–5 libraries | Could | backlog | Adopted via Tech Picture 2026-05-20 — see §"Tech Picture adoption — 2026-05-20" #2. |
| Diagonal cross-artifact analysis at `lsa-specify` Gate 2 | Should | backlog | Adopted via Tech Picture 2026-05-20 — see §"Tech Picture adoption — 2026-05-20" #3. |
| Tier-selector threshold finalization | Should | backlog | Per `vision/VISION.md:242` — pin the exact file-count threshold + add more worked examples to `core/tier-selector`'s few-shot block. Needs the two-week dogfood log first. |
| Project naming | Could | deferred | Per `vision/VISION.md:249` — currently "Vision" placeholder. |
| `core/registry` skill resurrection | Could | deferred to core v0.3.0 | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — if a second pack arrives and starts duplicating lazy-load logic Claude Code's native discovery doesn't cover, design the skill. |
| Two-week dogfood log | Should | not started | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — capture every tier call, every reconcile run, every verify outcome on this repo for the first two weeks. Validate ~90% trigger thresholds. |
| Doc-mode strict per-line tracing | Could | deferred | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — v0.2.0 accepts "intended per spec" as the trace bar. Tighten if untraced changes become a real problem. |
| Marketplace dependency field | Could | blocked | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §14 — adopt when Claude Code's plugin manifest supports a `dependencies` field. Currently prose-only in `lsa/.claude-plugin/plugin.json: description`. |
| Retro habit (`vision/specs/retro.md` or equivalent) | Should | deferred to lsa v0.3.0 | Per `vision/VISION.md:159` — scratchpad of mistakes and fixes, with a promotion path into standards or new skills. File format + promotion gate need design. |
| Self-eval harness | Should | deferred to lsa v0.3.0 | Per `vision/VISION.md:160` — structural checks (every actor has its sections), boundary checks (no Knowledge file holds execution flow), banned-hedge-word lint. Implementable as a `core` skill once surface stabilizes. |
| T2 metrics surface | Could | deferred to lsa v0.3.0 | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — v0.2.0 emits metrics for T3 only. If T2 becomes the dominant flow, design a coarser-grain aggregate (per-day/per-week) from the dogfood log. |
| `lsa-discover` → `lsa-specify` handoff format | Could | deferred to lsa v0.3.0 | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — formalize `discovery.md` if T3 invocations frequently want richer handoff (arch sketch, dep graph). |
| Tier-selector as Vision §3 amendment | Could | open | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — Vision §3 currently lists `tier-selector` as on-demand only; v0.2.0 made the invocation rule always-on via `core/CLAUDE.md`. Codify as a Vision §3 amendment in a future Vision revision. |
| Reconcile classification automation | Could | deferred | Per `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15 — class (a)/(b) is currently agent-judged. If misclassifications become a real problem, design a deterministic check (per-requirement IDs). |

## Recently merged

| Release | Date | Highlights |
|---|---|---|
| `core` v0.2.0 | 2026-05-20 | Adds `tier-selector` skill + `core/CLAUDE.md` always-on fragment. |
| `lsa` v0.2.0 | 2026-05-20 | Adds `lsa-discover` + `lsa-reconcile`; `.lsa.yaml` loader; doc-mode in verify; `.lsa-sync-state.json`; per-feature `metrics.md`; SessionStart drift hook; skill-shape refactor across all 6 existing skills; marker convention swept to lowercase. |
| `core` v0.1.0 / `lsa` v0.1.0 / v0.1.1 | 2026-05-20 | Initial releases. See per-plugin CHANGELOG.md for detail. |

## Tech Picture adoption — 2026-05-20

`READY` — three recommendations adopted from the 2026-05-20 Tech Picture analysis. Each passes the four credo tests: **Simple · Direct · Factual · Make-you-own-it**. Items rejected or deferred in that analysis are not promoted here. Status of each entry remains `backlog` in the table above until a plan file under `vision/plans/` is opened.

### 1. EARS notation in the `requirements.md` AC block

- **Name.** EARS notation, scoped to the acceptance-criteria sub-block of `lsa-specify`'s `requirements.md`. GWT (Given/When/Then) stays for the surrounding narrative.
- **Source.**
  - In-repo verdict: `vision/VISION.md:199` — *"Verdict: keep GWT for the spec narrative; add EARS only in the acceptance-criteria block, since that's what the verifier traces to code. A tightening, not a replacement."*
  - EARS five-pattern definition: `vision/VISION.md:198` — *"EARS has five fixed patterns: Ubiquitous ('shall always'), Event ('When X… shall'), State ('While X… shall'), Optional ('Where feature X… shall'), Unwanted ('If X happens, then… shall'). You cannot write 'handles errors gracefully' in EARS — no pattern accepts a vague line."*
  - External origin: [Alistair Mavin — EARS official guide](https://alistairmavin.com/ears/); cross-industry adoption (Airbus, NASA, Rolls-Royce) per [Jama Software — Adopting EARS Notation](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/adopting-the-ears-notation-to-improve-requirements-engineering/) [unverified — claim sourced from 2026-05-20 search summary, not verified against the source page].
- **Description.** Inside `requirements.md`, the AC sub-block changes from free-form GWT prose to a list of EARS one-liners — one behavior per line, each keyed to a precondition/trigger. The verifier (`lsa-verify`) then traces every code change to a specific AC line; one EARS line maps to one test in `test-suites.md`.
- **How it supports the credo.**
  - **Simple.** Five fixed patterns. No formal modeling language, no new tooling.
  - **Direct.** One line = one test. The verifier reads it without interpretation.
  - **Factual.** EARS rejects un-testable phrasing — *"handles errors gracefully"* cannot be written.
  - **Make-you-own-it.** Forces the human to name the trigger or precondition; the agent cannot paper over the gap with vague words.

### 2. Pinned library-spec cache for top 3–5 dependencies

- **Name.** Pinned library specs under `vision/specs/libs/<lib>.spec.md`. Bounded to the 3–5 most-used external dependencies; everything else stays reactive (fetched on demand by `lsa-discover`).
- **Source.**
  - In-repo verdict: `vision/VISION.md:217` — *"Verdict: do NOT build a 10,000-spec registry — that's their product. But write a pinned spec once for your 3–5 most-used libraries. It's a module spec pointed at an external dep. Everything else stays reactive."*
  - Comparable (the product NVZver deliberately does not replicate): [Tessl Skills Registry](https://tessl.io/blog/my-coding-agent-needed-a-package-manager-for-its-own-brain-and-i-gave-it-one-using-a-skills-registry/) — 10k+ community-curated library specs distributed as MCP tiles.
- **Description.** Each pinned spec is structured as a module spec whose target is an external library at a specific version. `artifact_paths` covers no in-repo files; the spec is the contract the agent reads before any call into that library. Updates are human-authored on a version bump — never auto-fetched, never imported from a community registry.
- **How it supports the credo.**
  - **Simple.** Bounded scope (3–5 files). No registry build, no fetcher, no cache invalidation logic.
  - **Direct.** Agent consults one local file before any API call into the library. No per-feature re-fetch, no MCP round trip.
  - **Factual.** The version pin closes the LLM's guess on API shapes; a drift between pin and library version is an editable spec line, not a silent runtime bug.
  - **Make-you-own-it.** The human writes the pin and updates it on every bump; the system refuses to auto-import a stranger's library spec.

### 3. Diagonal cross-artifact analysis at `lsa-specify` Gate 2

- **Name.** A diagonal cross-artifact coverage check inside `lsa-specify` Gate 2, extending the existing AC→Journey check to the full set of artifact pairs.
- **Source.**
  - Existing in-repo precedent (the seed): `vision/plans/2026-05-20-credo-rollout-plan.md:243-246` — sample S6 already does AC→Journey coverage: *"AC coverage check: / - AC1 → Journey 1 (happy path)  ✓ / - AC2 → Journey 2 (expired-link path)  ✓ / - AC3 → Journey 1, step 4 (session reset)  ✓"*.
  - Inspiration: [GitHub Blog — Spec-driven development with AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/) — the Spec-Kit toolkit ships *"quality checklists, and cross-artifact analysis"* between phases [unverified — claim sourced from 2026-05-20 search summary, not verified against the source page].
- **Description.** Inside Gate 2, the coverage check is extended from AC→Journey only to four diagonal pairs: AC→Journey, Journey→Design, Design→Contract, Contract→test-suites. Each row is a one-line citation between two artifact lines (e.g., `Design §"Token storage" ↔ Contract §"reset_tokens"`). When a row fails, the gate surfaces the conflict as a Rule 6 decision block (`[a] revise AC / [b] revise Design / [c] custom`) — the system never auto-resolves.
- **How it supports the credo.**
  - **Simple.** One tabular gate row per artifact pair. Same shape as the existing AC→Journey check, repeated for three more diagonals.
  - **Direct.** Verdict-first per Rule 7; the human's eye lands on `✗` rows first; passing rows collapse below the fold.
  - **Factual.** Every row cites the two specific artifact lines being compared — no aggregated "looks good".
  - **Make-you-own-it.** Conflicts surface as explicit options with outcomes (Rule 6); the agent refuses to pick which artifact "wins". The human owns the reconciliation.
