> **Trace.** On load, print first: `=============== [helper/knowledge/onboarding-fast-path.md] [helper] ===============`

# Onboarding fast-path — knowledge

When the user asks an onboarding-flavored question (*install / start / what-is-X / how-do-I-run*), Helper consults this catalog **before** [`./knowledge-scope.md`](./knowledge-scope.md)'s Step 2 scope-order read. If a row matches, Helper responds directly from the cited README excerpt — no `Grep`, no `Glob`, no `context7`. Per [`.lsa/archive/2026-05-22-helper-onboarding-fast-path/requirements.md`](../../.lsa/archive/2026-05-22-helper-onboarding-fast-path/requirements.md) F1 / F2 / F4.

This catalog is the first shipped instance of the marketplace's single-source-of-truth fast-path pattern; the pattern's general statement (direct read + cited quote, exact-phrase detection, fall-through-on-failure, `file:line` quote-back) is canonical at [`../../core/knowledge/fast-path-source-of-truth.md`](../../core/knowledge/fast-path-source-of-truth.md), and this file is its onboarding-trigger data.

## Catalog — onboarding trigger → README excerpt

Each row maps a plain-English intent to a concrete heading-anchor excerpt (e.g., `README.md#install`). Heading anchors survive line shifts; line-range citations did not. The agent reads the excerpt, quotes it inline with citation, and closes the turn (Step 5 of [`../agents/helper.md`](../agents/helper.md)).

| # | Trigger intent (plain English) | Example phrasings | Excerpt | What it answers |
|---|---|---|---|---|
| 1 | Install the marketplace | "how do I install", "install marketplace", "/plugin install commands", "set me up" | [`README.md#install`](../../README.md#install) | The marketplace-add + plugin-install block + the "install `core` first" caveat + the first-command pointer. |
| 2 | Get started with LSA | "how do I get started with LSA", "where do I start with LSA", "first steps LSA" | [`README.md#install`](../../README.md#install) + [`README.md#lsa`](../../README.md#lsa) | Install the plugins, then run `/lsa:init`, then `/lsa:discover` — the spec loop (discover → specify → verify → delegate → reconcile) follows. |
| 3 | What is the marketplace | "what is this marketplace", "what is `claude-marketplace`", "what is NVZver" | [`README.md#the-six-plugins`](../../README.md#the-six-plugins) | One-paragraph frame + the six-plugin table. |
| 4 | What is `core` | "what is core", "what does core do", "what is `core/ground-rules`" | [`README.md#core`](../../README.md#core) | Always-on discipline + the `flow-selector` user flow with illustrative output. |
| 5 | What is `lsa` | "what is LSA", "what does lsa do", "what is Living Spec Architecture" | [`README.md#lsa`](../../README.md#lsa) | Definition + the spec loop with illustrative output. |
| 6 | What is `helper` | "what is helper", "what does helper do", "what is `/help`" | [`README.md#helper`](../../README.md#helper) | Cited Q&A user flow + auto-engage friction signals. |
| 7 | What is `manager` | "what is manager", "what does manager do", "what is `shape`" | [`README.md#manager`](../../README.md#manager) | Pitch-shaping user flow + the human approval gate before `manager:decompose` breaks the pitch into LSA-ready epics. |
| 8 | What is `prompt-engineer` | "what is prompt-engineer", "what does prompt-engineer do", "what is `prompt-review`" | [`README.md#prompt-engineer`](../../README.md#prompt-engineer) | Prompt-quality user flow + the severity / rule / finding output shape. |
| 9 | What is `observer` | "what is observer", "what does observer do", "what is `observer:observe`" | [`README.md#observer`](../../README.md#observer) | Live observe-and-coach user flow — role confirmation (rubber-duck / pair-programmer / interviewer / custom) + the self-paced `/loop` cycle with illustrative output. |

Catalog size v3: **9 rows**. Floor named in `requirements.md` NF2 (install / start / what-is + {core, lsa, helper} / how-do-I-run); v2 extended the *what-is* row set to five plugins per [`.lsa/pitches/readme-and-knowledge-base.md`](../../.lsa/pitches/readme-and-knowledge-base.md) "Solution sketch"; v3 adds *what is `observer`*, covering all six shipped plugins ({core, lsa, helper, manager, prompt-engineer, observer}) per the `catalog-surface-drift` pitch (`.lsa/pitches/catalog-surface-drift.md`). Expansion happens here, not in [`../agents/helper.md`](../agents/helper.md) (F6 — catalog is data, not code). The canonical heading-name registry is [`knowledge/index.md`](../../knowledge/index.md) — any heading rename in `README.md` must update both files in the same commit.

## Matching rules

- **Match on intent, not literal keywords.** *"how do I get going with LSA"* matches row 2 (*start*) even though the word *start* is absent. The example phrasings are seeds, not regexes.
- **First match wins.** If a question matches multiple rows (e.g., *"how do I install LSA and what does it do?"* matches rows 1, 2, AND 5), respond from the first match (row 1). The closing `AskUserQuestion` MAY offer up to two additional matched rows as follow-up options. Per `design.md` OQ4 resolution.
- **Canonical subjects only.** Catalog subjects are `marketplace`, `core`, `lsa`, `helper`, `manager`, `prompt-engineer`, `observer`. Other plugin names (`dev-plugin`, `atlassian`, `supabase`, `frontend-design`) are NOT onboarding subjects — they live in scope 2 of [`./knowledge-scope.md`](./knowledge-scope.md) and require a deep-read.
- **One bounded LLM pass.** Read this catalog + read the user's question + decide: catalog row N matched, or no match. No multi-turn classification, no chain-of-thought scaffolding. The fast-path's latency target (≤5s wall-clock per `requirements.md` NF1) depends on staying inside one bounded pass.

## Negative examples — onboarding-shaped but NOT fast-path-eligible

- *"how do I configure `.lsa.yaml`"* — answer lives in `lsa/ARCHITECTURE.md` §3, not a top-level README. Fall through to Step 2.
- *"what does `lsa:verify`'s orphan-AC predicate do"* — mechanism question; answer lives in `lsa/skills/verify/SKILL.md`, not a README. Fall through.
- *"why was `flow-selector` renamed from `tier-selector`"* — history question; lives in `core/CHANGELOG.md` + `.lsa/roadmap.md`. Fall through.
- *"how do I install `context7`"* — `context7` is an external MCP, not a marketplace plugin. No catalog row maps the trigger to a heading-anchor excerpt. Fall through (and Step 2 will likely declare cannot-verify or route to scope 3).
- *"what is `dev-plugin`"* — not a canonical marketplace subject (canonical = `marketplace` / `core` / `lsa` / `helper` / `manager` / `prompt-engineer` / `observer`). Fall through to scope-order read.
- *"how do I write an EARS acceptance criterion"* — methodology question; answer lives in `.lsa/VISION.md` §3 + `lsa/skills/specify/SKILL.md`. Fall through.
- *"what's next"* / *"what should I work on next"* — roadmap-navigation question, NOT an onboarding question. Its answer lives in `.lsa/roadmap.md` §`## Feature Backlog`, which is outside this catalog's README-excerpt scope. This is its own fast-path, owned by `manager:next` per [`../../core/knowledge/fast-path-source-of-truth.md`](../../core/knowledge/fast-path-source-of-truth.md); Helper does not duplicate it. Fall through to Step 2; if the user wants the next backlog item, the closing picker MAY offer to run `manager:next` (a skill handoff per [`../agents/helper.md`](../agents/helper.md) Step 4), not a roadmap deep-read. Resolves the pitch's Open Question #1: the catalog had no navigation-class gap to fill — "what's next" is a deliberately separate fast-path, not a missing onboarding row.

## Fall-through rules — when to defer to Step 2

The fast-path **adds**; it does not narrow. Fall through to Step 2 (scope-order read in [`../agents/helper.md`](../agents/helper.md)) when ANY of:

- **No catalog match.** The question does not match any trigger intent in the catalog.
- **Match but no excerpt.** A trigger pattern matched but the catalog row has no concrete heading-anchor mapping for the matched concept (per `requirements.md` F3).
- **Match but excerpt missing at runtime.** The catalog row cites a heading anchor that no longer resolves in the target file (heading renamed, section deleted, file moved). Do not fabricate; fall through. Per `requirements.md` F7.
- **Match against negative-example pattern.** Question superficially matches a trigger but is listed in §"Negative examples" above (e.g., `.lsa.yaml` configuration is install-shaped but not fast-path-eligible).

On fall-through, Helper proceeds to Step 2 of [`../agents/helper.md`](../agents/helper.md) unchanged. The `"I cannot verify this."` fallback (`../agents/helper.md` Step 3, per [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 2) remains the final backstop if Step 2 also returns no source.
