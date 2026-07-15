Shaped by: product-manager agent (role lens: agent-platform cost-efficiency PM — reshape v2, owner amendments A1-A4 + model-routing direction incorporated)
Date: 2026-07-15
Status: approved
Gate decisions: role confirmed (agent-platform cost-efficiency PM); Fork A/C confirmed as amended (index 100% script-generated, no model description pass; constitution digest inside WS1); Fork B = all four workstreams (~4 small-batch epics, lever-ordered WS1→WS4→WS2→WS3); Fork D = commit hook + CI mirror auto-rebuild the index (superseded at the project-index spec gate → a lint freshness-gate that detects staleness rather than a hook that auto-rebuilds, per `.lsa/features/pro-tier-token-affordability/project-index/requirements.md` D3: no git-hook infra exists, and a silent auto-rebuild conflicts with the ownership-over-automation credo); Fork E = routing lives as a `routing:` map in `.lsa.yaml` read at dispatch time (zero shipped pins; absent key = inherit; reconcile grader never routable down).
Why now: the constitution's own standard declares the marketplace "must run 100% on the Claude Pro plan" (.lsa/standards/code.md:49) and today it does not; the in-progress inline-dispatch rollout (.lsa/roadmap.md:62) makes this the moment to decide model routing for the dispatches that legitimately remain.

# Pro-tier token affordability

Make the marketplace genuinely usable on the $20 Pro tier by compressing the always-on
read floor, replacing model-side mechanical work with deterministic scripts (including a
100% script-generated, token-budgeted project index), and routing every remaining Agent
dispatch to the cheapest capable model via a documented tier table.

## Problem

The system is unusable on the Pro plan (Sonnet + 5-hour usage window): context is
exhausted by the second question of a session, or mid-`lsa:discover`. Verified drivers
(line counts `wc -l`-verified at discovery 2026-07-15):

1. **Always-on read floor ~456 lines (330 non-blank).** `core/CLAUDE.md:9-37` mandates
   four skills on every substantive task: ground-rules (140 lines) + output (190) +
   flow-selector (72) + reuse-first (54), plus the 37-line fragment itself. Loaded
   before any work begins. (Correction 2026-07-15: reshape v2 reported these figures as
   post-trim shrinkage — they were non-blank counts of the same unchanged files;
   `wc -l` re-verified at discovery.)
2. **Mandatory constitution re-read per LSA skill.** The read protocol at
   `lsa/knowledge/conventions.md:31-35` makes `.lsa/VISION.md` (278 lines; 197 non-blank) a
   required read for every LSA skill invocation — and every fresh sub-agent context
   reloads the whole floor again (`.lsa/standards/code.md:59`).
3. **Unbounded discovery.** `lsa/skills/discover/SKILL.md:29` says "read the code/specs
   the request touches" with no index to scope the read; `.lsa/` is 121 markdown files
   (verified via glob 2026-07-15; ~12.8k lines at the original draft's measurement).
4. **Deterministic work is model-executed.** The gate block (`.lsa.yaml:15-18`) covers
   only docs-invariants / citations / links; roadmap extraction, verify pre-passes, and
   inventory scans still burn model tokens.
5. **Multipliers.** `reconcile.runs: 3` (`.lsa.yaml:23-24`), `implement` concurrency 4
   (`.lsa.yaml:30-31`), and sub-agent fan-out is a known 4-7x token multiplier
   [research: multi-agent dispatch overhead studies] — every dispatched context re-pays
   drivers 1-2 in full.

Current workaround: the owner runs on Max or rations Pro sessions around the 5-hour
window; Pro-only users cannot complete a Standard flow.

Definition of success:
- A Pro session completes `lsa:discover` plus one shaped pitch without context exhaustion.
- The always-on floor is one short card (~40 lines) with full skills as on-demand references.
- The project index is 100% script-generated, ≤ 1k tokens, and rebuilt free on every change.
- **Model routing:** every Agent-dispatch surface in the marketplace carries a documented
  tier with rationale (the table in this pitch, kept as a shipped knowledge file), and a
  dogfood session shows mechanical dispatches measurably running on the cheapest tier.

## Appetite

Four small-batch workstreams, each its own epic; ~4 epics total. Priority order is the
token-lever order: WS1 (floor) pays on every turn, WS4 (routing) on every dispatch,
WS2/WS3 on discovery/mechanical passes.

- **WS1 — Read-floor compression (promoted to first).** Compress the always-on core trio
  (ground-rules / output / flow-selector) into ONE short always-on card (~40 lines) with
  the full skills demoted to on-demand references — restoring platform progressive
  disclosure (published pattern: ~500-token index vs ~70k always-loaded; "five idle
  plugins burn 55k tokens before you type a word" [research]). A stable small card is
  also prompt-cache-optimal. Includes: constitution digest (VISION.md → ~30-line digest
  as the mandatory read, full text on demand), cite-without-loading conventions, and
  `reconcile.runs` guidance text.
- **WS2 — Deterministic project index.** 100% script-generated — NO model description
  pass by default (research: LLM-generated context files slightly reduced success rates
  and raised cost ~20%; aider's repo-map is fully deterministic — tree-sitter + PageRank,
  zero LLM tokens). For markdown trees (this repo, `.lsa/` spec trees) extracted headings
  ARE the descriptions. Hard token budget on the index itself: 1k tokens (aider's
  default) — an unbudgeted index is the next context-killer. Script-only generation
  dissolves the staleness and build-burn rabbit holes: rebuild is free on every change.
  Reuse-before-build for the code-repo side (core/reuse-first rung 6): evaluate
  codebase-map, codebase-index, ctags, LSP/Serena-style symbol tools, and Claude Code's
  built-in LSP tool before writing anything; own only the markdown/spec-tree indexer.
- **WS3 — Script offload.** Verify pre-pass and roadmap-row extractor move from model
  passes to `scripts/` (same Pro-safe pattern as the existing gate block, `.lsa.yaml:9-14`).
- **WS4 — Model routing.** The per-dispatch tier table (Solution sketch below), its
  policy resolution (Fork E, decided: `.lsa.yaml` `routing:` map), and the
  config/knowledge artifacts that carry it.

Out of appetite: tiered behavior profiles ("Pro mode" vs "Max mode" semantics); any
weakening of hard rules or gates; model-written index descriptions.

## Solution sketch

- **Key user interactions:** a Pro user runs a Standard flow end-to-end in one session;
  discovery consults the ≤1k-token index instead of walking 121 files; dispatching skills
  read a routing entry and pass the model at the Agent-tool boundary; the owner sees
  which tier each dispatch ran on in the dispatch line.
- **Main components:** `core/CLAUDE.md` + the three core skills (WS1 card); a new
  `scripts/build-index.sh` + committed index file with a lint-enforced 1k-token cap
  (WS2); `scripts/` additions (WS3); a routing knowledge file + `.lsa.yaml` `routing:`
  key (WS4, per Fork E decision).
- **Critical path:** WS1 card ships → a Pro session's per-turn floor drops ~85% → WS4
  routing table ships against the surviving dispatch surfaces → WS2 index bounds
  discovery → dogfood a full Standard flow on a Pro session and record the token delta.

### Model-routing tier table (WS4 deliverable — inventory verified 2026-07-15)

Platform mechanics first: skills and slash commands run in the MAIN thread and inherit
the session model — there is no per-skill model override. The routing lever exists ONLY
at Agent-dispatch boundaries (agent frontmatter `model:` or the Agent-tool model
parameter). So routing is a table over the marketplace's actual dispatch surfaces.
Note: `.lsa/standards/code.md:53` already legalizes `sonnet` pins on purely-mechanical
sub-agents — Fork E (decided) keeps the haiku tier in `.lsa.yaml` config, zero shipped pins.

| # | Dispatch surface | Cite | Survives inline rollout? | Tier | Rationale |
|---|------------------|------|--------------------------|------|-----------|
| 1 | `manager:shape` → product-manager | `manager/skills/shape/SKILL.md:26` | No — slated inline (`.lsa/roadmap.md:62`); transitional | inherit | Shaping is judgment-heavy; inline removal beats routing here |
| 2 | `manager:decompose` → project-manager | `manager/skills/decompose/SKILL.md:37` | No — transitional | inherit | Epic boundaries / risk ordering = judgment |
| 3 | `manager:next` → project-manager | `manager/skills/next/SKILL.md:42` | No — transitional; fast-path already answers without dispatch (`:39`) | sonnet | Bounded sequencing over one roadmap file |
| 4 | `manager:check` → project-manager | `manager/skills/check/SKILL.md:34` | No — transitional | **haiku candidate** | Mechanical hygiene scan (staleness rows, drift inventory) |
| 5 | `manager:implement` per-epic fan-out | `manager/skills/implement/SKILL.md:36`; cap `.lsa.yaml:30-31` | Yes — worktree isolation load-bearing (`code.md:63`) | inherit | Writes production artifacts; a downgrade recreates the hallucinated-completion failure the engine exists to prevent |
| 6 | `lsa:delegate` → external implementer | `lsa/skills/delegate/SKILL.md:47` | Yes (`code.md:61`) | inherit | Code quality is load-bearing; outside the LSA boundary |
| 7 | `lsa:delegate` → `observer:verify-checkpoint` | `observer/skills/verify-checkpoint/SKILL.md:15` | Yes — independent per-increment grader | sonnet | Scoped does·only grading of ONE increment against one F-requirement; bounded inputs. NOT haiku — grading is judgment |
| 8 | `lsa:reconcile` independent grader | `lsa/skills/reconcile/SKILL.md:33` (N=3 runs), `:40` (context implementer cannot author) | Yes — independence is the point (`code.md:62`) | inherit — **flagged: not a downgrade candidate** | This is the regression harness; grader quality is the safety floor of the whole system. Routing it down saves tokens by weakening the only check that catches everything else |
| 9 | prompt-engineer agent dispatches | `prompt-engineer/agents/prompt-engineer.md` | Per-command | sonnet for mechanical scan intents, inherit for authoring | Direct application of existing `code.md:53` |

Haiku candidates are deliberately few: row 4, plus any future mechanical extraction that
stays model-side (roadmap-row extraction if WS3 doesn't fully script it; index
description passes if ever enabled — currently a No-go). Interaction with the inline
rollout: routing makes remaining dispatches cheaper, inlining removes them — rows 1-4
are transitional (routing helps until `.lsa/roadmap.md:62` completes; once inline, they
inherit the session model and have no routing lever). The durable routing surface is
exactly the three isolation classes of `code.md:59-63`: external implementer,
independent graders, worktree fan-out.

## Rabbit holes

1. **Haiku hard-pin hard-error.** `code.md:52`: a hardcoded model a plan lacks is a hard
   error, not a fallback. Mitigation: Fork E (decided) routes via `.lsa.yaml` config
   read at dispatch time — absent key degrades to inherit; no shipped artifact ever pins.
2. **Index budget creep.** Mitigation: the 1k-token cap is lint-enforced in
   `scripts/lint.sh` (same owner as the existing C7-C11 checks), not advisory.
3. **Routing down the graders.** Mitigation: rows 7-8 are tier-floored in the table
   itself; reconcile's grader is excluded from downward routing by name.
4. **Routing table staleness across the inline rollout.** Mitigation: table is keyed to
   the three durable isolation classes (`code.md:59-63`), with transitional rows marked;
   completing roadmap row 62 deletes rows, never re-tiers them.
5. ~~Index staleness / description build-burn~~ — dissolved by amendment A1 (100%
   script-generated; headings are the descriptions; rebuild is free).

## No-gos

1. Does NOT re-own the manager inline-dispatch rollout — `.lsa/roadmap.md:62` owns it;
   this pitch only marks its surfaces transitional in the routing table.
2. Does NOT re-own CI gate wiring — deterministic-enforcement-gates shipped
   (`.lsa/roadmap.md:64`).
3. REVISED from v1 ("don't change Model policy"): the Model policy (`code.md:47-55`) was
   in scope via Fork E; DECIDED — zero shipped pins stand, routing lives in `.lsa.yaml`
   config; `opus`/`fable` hard pins stay banned (the `code.md:52` hard-error class is
   non-negotiable).
4. Does NOT weaken any hard rule or gate — floor compression changes packaging
   (card + on-demand reference), never rule content.
5. Does NOT introduce tiered behavior profiles — one behavior, cheaper delivery.
6. Does NOT add model-written index descriptions by default — per research (LLM context
   files: lower success, ~20% higher cost) and aider precedent.
