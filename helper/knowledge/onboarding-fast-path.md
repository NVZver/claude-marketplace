> **Trace.** On load, print first: `=============== [helper/knowledge/onboarding-fast-path.md] [helper] ===============`

# Onboarding fast-path — knowledge

When the user asks an onboarding-flavored question (*install / start / what-is-X / how-do-I-run*), Helper consults this catalog **before** [`./knowledge-scope.md`](./knowledge-scope.md)'s Step 2 scope-order read. If a row matches, Helper responds directly from the cited README excerpt — no `Grep`, no `Glob`, no `context7`. Per [`.lsa/features/2026-05-22-helper-onboarding-fast-path/requirements.md`](../../.lsa/features/2026-05-22-helper-onboarding-fast-path/requirements.md) F1 / F2 / F4.

## Catalog — onboarding trigger → README excerpt

Each row maps a plain-English intent to a concrete `file:line-range` excerpt. The agent reads the excerpt, quotes it inline with citation, and closes the turn (Step 5 of [`../agents/helper.md`](../agents/helper.md)).

| # | Trigger intent (plain English) | Example phrasings | Excerpt path:lines | What it answers |
|---|---|---|---|---|
| 1 | Install the marketplace | "how do I install", "install marketplace", "/plugin install commands", "set me up" | `README.md:73-83` | The four-line install block + the "install `core` first" caveat. |
| 2 | Get started with LSA | "how do I get started with LSA", "where do I start with LSA", "first steps LSA" | `README.md:73-83` (install) + `lsa/README.md:49-60` (Depends on / install order) | Install both plugins, then invoke `/lsa:init`. |
| 3 | What is the marketplace | "what is this marketplace", "what is `claude-marketplace`", "what is NVZver" | `README.md:1-12` + `.lsa/VISION.md:13-15` | One-sentence frame + the three-plugin list. |
| 4 | What is `core` | "what is core", "what does core do", "what is `core/ground-rules`" | `README.md:25-49` | Three always-on skills + four supporting bullets. Glosses each. |
| 5 | What is `lsa` | "what is LSA", "what does lsa do", "what is Living Spec Architecture" | `README.md:51-68` + `lsa/README.md:1-9` | Definition + 8-skill table + credo quote. |
| 6 | What is `helper` | "what is helper", "what does helper do", "what is `/help`" | `helper/README.md:1-10` | Two surfaces + invocation paths. |

Catalog size v1: **6 rows**. Floor named in `requirements.md` NF2 (install / start / what-is + {core, lsa, helper} / how-do-I-run). Expansion happens here, not in [`../agents/helper.md`](../agents/helper.md) (F6 — catalog is data, not code).

## Matching rules

- **Match on intent, not literal keywords.** *"how do I get going with LSA"* matches row 2 (*start*) even though the word *start* is absent. The example phrasings are seeds, not regexes.
- **First match wins.** If a question matches multiple rows (e.g., *"how do I install LSA and what does it do?"* matches rows 1, 2, AND 5), respond from the first match (row 1). The closing `AskUserQuestion` MAY offer up to two additional matched rows as follow-up options. Per `design.md` OQ4 resolution.
- **Canonical subjects only.** Catalog subjects are `marketplace`, `core`, `lsa`, `helper`. Other plugin names (`dev-plugin`, `atlassian`, `supabase`, `frontend-design`) are NOT onboarding subjects — they live in scope 2 of [`./knowledge-scope.md:13`](./knowledge-scope.md) and require a deep-read.
- **One bounded LLM pass.** Read this catalog + read the user's question + decide: catalog row N matched, or no match. No multi-turn classification, no chain-of-thought scaffolding. The fast-path's latency target (≤5s wall-clock per `requirements.md` NF1) depends on staying inside one bounded pass.

## Negative examples — onboarding-shaped but NOT fast-path-eligible

- *"how do I configure `.lsa.yaml`"* — answer lives in `lsa/ARCHITECTURE.md` §4.10, not a top-level README. Fall through to Step 2.
- *"what does `lsa-verify`'s orphan-AC predicate do"* — mechanism question; answer lives in `lsa/skills/lsa-verify/SKILL.md`, not a README. Fall through.
- *"why was `flow-selector` renamed from `tier-selector`"* — history question; lives in `core/CHANGELOG.md` + `.lsa/roadmap.md`. Fall through.
- *"how do I install `context7`"* — `context7` is an external MCP, not a marketplace plugin. No catalog row maps the trigger to a `file:line` excerpt. Fall through (and Step 2 will likely declare cannot-verify or route to scope 3).
- *"what is `dev-plugin`"* — not a canonical marketplace subject (canonical = `marketplace` / `core` / `lsa` / `helper`). Fall through to scope-order read.
- *"how do I write an EARS acceptance criterion"* — methodology question; answer lives in `.lsa/VISION.md` §3 + `lsa/skills/lsa-specify/SKILL.md`. Fall through.

## Fall-through rules — when to defer to Step 2

The fast-path **adds**; it does not narrow. Fall through to Step 2 (scope-order read in [`../agents/helper.md`](../agents/helper.md)) when ANY of:

- **No catalog match.** The question does not match any trigger intent in the catalog.
- **Match but no excerpt.** A trigger pattern matched but the catalog row has no concrete `file:line` mapping for the matched concept (per `requirements.md` F3).
- **Match but excerpt missing at runtime.** The catalog row cites a `file:line` range that no longer resolves (file deleted, range stale beyond ±3 lines, heading not found). Do not fabricate; fall through. Per `requirements.md` F7.
- **Match against negative-example pattern.** Question superficially matches a trigger but is listed in §"Negative examples" above (e.g., `.lsa.yaml` configuration is install-shaped but not fast-path-eligible).

On fall-through, Helper proceeds to Step 2 of [`../agents/helper.md`](../agents/helper.md) unchanged. The `"I cannot verify this."` fallback (`../agents/helper.md` Step 3, per [`core/ground-rules`](../../core/skills/ground-rules/SKILL.md) Rule 2) remains the final backstop if Step 2 also returns no source.
