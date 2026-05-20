# Roadmap — claude-marketplace

Prioritized list of upcoming work, populated from `vision/VISION.md` §6 *"Adjust"* items, §7 *"Open decisions"*, and post-0.2.0 follow-ups from `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §15.

## Feature Backlog

| Feature | Priority | Status | Notes |
|---|---|---|---|
| EARS notation in AC block | Should | backlog | Per `vision/VISION.md:199` — keep GWT in the spec narrative; add EARS only inside the acceptance-criteria block of `requirements.md`. Tightens what the verifier traces to. |
| Library-spec cache for top 3–5 libraries | Could | backlog | Per `vision/VISION.md:217` — write a pinned module spec for the top 3–5 most-used libraries (a module spec pointed at an external dep). Reactive for everything else. |
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
