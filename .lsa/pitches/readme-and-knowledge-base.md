Shaped by: Nikita Zverev
Date: 2026-05-27
Status: approved
Why now: README undercounts plugins (says "four," ships five); JetBrains application raises polish bar on public surface; prompt-audit remediation (roadmap Epics 1-4) is about to restructure knowledge files — restructuring knowledge without an index creates more sprawl, not less.

# README redesign and internal knowledge base

Restructure the repository's public face (README.md) and build a cross-cutting knowledge base that serves three audiences equally: external evaluators, AI agents (helper, orchestrator, product-manager, project-manager), and the repo author onboarding new projects.

## Problem

Three audiences — external evaluators (GitHub visitors, JetBrains reviewers), AI agents (helper, orchestrator, product-manager, project-manager), and the repo author — all read the same monolithic `README.md` to understand the system. The README tries to sell, teach, and reference simultaneously. It undercounts plugins: `README.md:7` says "four composable plugins" when five ship (`core`, `lsa`, `helper`, `management`, `prompt-engineer`). The `main.spec.md` module index (`vision/specs/main.spec.md:14-19`) lists only three of the five.

Knowledge is plugin-siloed: 14 knowledge files across 5 plugin directories (core: 1, helper: 4, lsa: 2, management: 4, prompt-engineer: 3), no cross-cutting index, no shared vocabulary layer. The helper agent compensates by grep-searching the repo with a two-round budget cap (`helper/knowledge/knowledge-scope.md:27-36`). Its onboarding fast-path hardcodes 6 line-range citations (`helper/knowledge/onboarding-fast-path.md:11-18`) that break when the README changes — the citations use `file:line-range` format (e.g., `README.md:73-83`) which is brittle across edits. The catalog also lacks entries for `management` and `prompt-engineer`. New concepts added to the system have no obvious place to land.

Current workaround: the helper agent greps and hopes within its budget cap; the onboarding fast-path uses brittle line-number citations; the author carries the cross-system mental model in their head.

Definition of success: (a) README targets external first-timers with progressive disclosure — overview, quick start, per-plugin user flows with prompt examples and expected outcomes; (b) an indexed knowledge base that agents navigate by structure, not grep; (c) new concepts have a clear home in the knowledge tree; (d) helper citations are stable (heading-anchor-based, not line-number-dependent).

## Appetite

Three stages, planned together, executed as separate batches. Each stage is independently shippable. The first deliverable is Stage 1 (Small batch).

**Stage 1 — Small batch.** README rewrite + knowledge index + stable citations. Scope: rewrite `README.md` for external audience with progressive disclosure (overview, quick start, one primary user flow per plugin with illustrative output snippet); create `knowledge/index.md` as a flat topic-to-path table; update `helper/knowledge/onboarding-fast-path.md` to use heading-anchor citations and add missing plugin rows; fix `main.spec.md` module index.

**Stage 2 — Medium batch.** Shared knowledge layer. Scope: create `knowledge/` at repo root for cross-cutting concepts (glossary, architecture overview, plugin catalog); restructure `helper/knowledge/knowledge-scope.md` to use the index as scope tier 0.

**Stage 3 — Large batch.** Knowledge consolidation + catalog-driven helper. Scope: audit all plugin knowledge files, migrate cross-cutting content to shared layer; redesign helper's onboarding fast-path from hardcoded table to catalog-driven resolution from `knowledge/index.md`.

**Out of appetite (all stages):**
- Static site generator or docs website.
- User-facing tutorials or guided walkthroughs.
- Full rewrite of per-plugin READMEs (see Rabbit hole #1 for the scope tension with user-flow additions).

## Solution sketch

- **Key user interactions:**
  - An external evaluator opens `README.md` and reads a progressively-disclosed document: (1) high-level overview — what the system is, the problem it solves, the five plugins; (2) quick start — install, wire CLAUDE.md, first command; (3) per-plugin user flows — one primary flow each with a concrete prompt and brief illustrative output snippet.
  - The five primary flows in the root README:
    - **`core`** — always-on discipline. Show how `flow-selector` classifies a task before work begins.
    - **`lsa`** — the build cycle: `lsa:discover` -> `lsa:plan` -> `lsa:implement` -> `lsa:verify`. Prompt, phase, and what the user sees at each step.
    - **`helper`** — `/help what is LSA?` -> cited answer in seconds.
    - **`manager`** — `manager:shape` with a vague idea -> shaped pitch -> approval gate -> LSA handoff.
    - **`prompt-engineer`** — `prompt-engineer:prompt-review <path>` -> findings table with severity and rule citations.
  - The helper agent reads `knowledge/index.md` — a flat table (one row per topic: name, canonical file path, one-sentence description) indexing every knowledge file across all plugins. Agents look up topics by structure instead of grepping.
  - The onboarding fast-path switches from `file:line-range` citations (e.g., `README.md:73-83`) to `file#heading-anchor` citations (e.g., `README.md#install`). Headings survive line shifts. New rows added for `manager` and `prompt-engineer`.
  - `main.spec.md` module index gains entries for `helper` and `prompt-engineer`.

- **Main components (Stage 1):**
  - `README.md` — full rewrite.
  - New `knowledge/index.md` — cross-plugin topic index.
  - `helper/knowledge/onboarding-fast-path.md` — citation format migration + new rows.
  - `vision/specs/main.spec.md` — add two missing module index entries.

- **Critical path:** README rewrite (establishes heading structure) -> knowledge index (references new headings and catalogs all knowledge files) -> onboarding fast-path update (consumes the new citation format and index).

## Rabbit holes

1. **Per-plugin README scope tension.** The appetite excludes "rewriting per-plugin READMEs," but the solution calls for full user-flow sets in per-plugin READMEs (one primary flow in root README, full set in each plugin's README). Adding user flows to per-plugin READMEs IS modifying them. Mitigation: treat per-plugin README user-flow additions as a Stage 1.5 follow-on batch — not a full rewrite, but scoped additions of a "User flows" section to each of the five per-plugin READMEs. This keeps the root README deliverable clean while acknowledging the follow-on work.

2. **Heading-anchor stability.** Switching onboarding fast-path citations from `file:line-range` to `file#heading-anchor` assumes heading text stays stable. If someone renames a heading, the citation breaks silently (no line-number shift warning). Mitigation: the knowledge index becomes the single source of truth for heading names — any heading rename must update the index, which makes the breakage visible in one file instead of scattered across consumers.

3. **Knowledge index maintenance burden.** A flat `knowledge/index.md` must be updated every time a knowledge file is added, moved, or removed. If it falls out of sync, agents navigate to dead paths. Mitigation: `lsa:verify` can be extended (in Stage 2 or 3) to check that every path in the index resolves. For Stage 1, maintenance is manual — acceptable given the current 14-file count.

4. **Prompt-audit overlap.** Roadmap Epics 1-4 (prompt audit remediation) are restructuring knowledge files at the same time. If both land in parallel, merge conflicts are likely in `helper/knowledge/onboarding-fast-path.md` and any knowledge files that move. Mitigation: sequence Stage 1 after Epic 1 (broken cross-references) or coordinate to avoid touching the same files in the same PR.

## No-gos

1. This pitch does NOT cover a static site generator, docs website, or hosted documentation — those are a separate concern with a different appetite.
2. This pitch does NOT cover user-facing tutorials or guided walkthroughs — the README shows what to type, not how to think about it.
3. This pitch does NOT cover full rewrites of per-plugin READMEs — per-plugin README user-flow additions are flagged as a Stage 1.5 follow-on (Rabbit hole #1), not part of the core deliverable.
4. This pitch does NOT cover making `knowledge/index.md` machine-enforced (e.g., a `verify` check that all index paths resolve) — that is a Stage 2/3 concern.
