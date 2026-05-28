Shaped by: Nikita Zverev
Date: 2026-05-26
Status: approved
Why now: fourth plugin (management) just shipped — the pattern has repeated four times; cost of missed files compounds with each new plugin

# Plugin onboarding checklist

Plugin authors forget structural files when scaffolding a new plugin, leading to follow-up commits that pollute git history and delay the first clean verify.

## Problem

Plugin authors (the repo owner today, but the pattern should hold for contributors) forget steps when scaffolding a new plugin. The file surface per plugin is large — at least 9 files across 4 directories — and undocumented as a unit.

Evidence: the `helper` plugin's `.lsa.yaml` module entry was added in v0.2.0 as a separate item, not part of the v0.1.0 scaffold (`helper/CHANGELOG.md:61` — *"`.lsa.yaml` — added `modules.helper` block with artifact paths ... so `lsa-verify` tracks the plugin"*). The module spec at `.lsa/modules/helper/spec.md` was also a later addition, first referenced in the v0.3.0 changelog. `CONTRIBUTING.md` documents how to add a skill (8-step checklist, lines 42–51) and a knowledge surface (lines 57–62), but has no "Adding a plugin" section.

Current workaround: the author manually cross-references existing plugins (copies structure from `helper/`, `lsa/`, or `management/`) and hopes they remember every file. Each new plugin repeats this from scratch.

Definition of success: a new plugin scaffold passes `lsa:verify` on the first commit — no follow-up fix commits for missing structural files.

## Appetite

Small batch. The deliverable is a static knowledge file (checklist) plus a `CONTRIBUTING.md` update — no agent logic, no automation.

Out of appetite: a scaffolding command that auto-generates files (separate pitch), an `lsa:verify` enhancement that structurally validates plugin completeness (separate pitch), external contributor onboarding (CoC, PR templates), and content templates (boilerplate text to paste).

## Solution sketch

- **Key user interactions:** author opens `CONTRIBUTING.md`, finds the new "Adding a plugin" section, follows the pointer to the checklist. Each checklist item is a numbered step with a file path, a one-sentence description, and a cross-reference to the canonical format source. Author creates each file in order, then runs `lsa:verify`.
- **Main components:** one new knowledge file at `core/knowledge/new-plugin-checklist.md` (pure knowledge, no actor logic; the `core/knowledge/**/*.md` glob in `.lsa.yaml` already covers this path); one edit to `CONTRIBUTING.md` adding an "Adding a plugin" section between the existing "Adding a Knowledge surface" and "Editing an existing skill" sections.
- **Critical path:** author opens checklist → walks items top to bottom in dependency order (manifest → CHANGELOG → README → actor file → knowledge files → module spec → `.lsa.yaml` entry → `main.spec.md` registration → root README update) → runs `lsa:verify` → passes on first attempt.

## Rabbit holes

1. **Checklist drift** — the checklist could fall out of sync with actual plugin structure as conventions evolve. Mitigation: the checklist lives in `core/knowledge/` (tracked by `lsa:verify` doc-mode); any structural change to plugin conventions updates the checklist in the same commit, matching the existing "READMEs are living documents" discipline (`CLAUDE.md` §"Discipline (sourced)").
2. **Checklist length vs. usability** — 9–10 items with sub-details risks skim-reading. Mitigation: each item is one line (file path + one sentence) with a cross-reference for format details. The checklist is a pointer map, not a tutorial.
3. **`core` version bump** — placing the checklist in `core/knowledge/` requires a `core` minor version bump. Appropriate because `core` is the domain-neutral discipline layer, and the checklist is pure knowledge with no skill behavior impact.

## No-gos

1. This pitch does NOT cover auto-scaffolding (a `/plugin new` or `management:scaffold-plugin` command) — that requires agent logic and a separate appetite decision. The checklist establishes the canonical file list that any future scaffolding command would consume.
2. This pitch does NOT cover `lsa:verify` structural validation (automatically checking plugin completeness) — that is a verification enhancement, not a knowledge artifact. Follow-on pitch that could read the checklist as its source of truth.
3. This pitch does NOT cover external contributor onboarding (CoC, PR templates, contributor license) — community governance, not plugin structure.
4. This pitch does NOT cover content templates (pre-filled `plugin.json`, boilerplate `CHANGELOG.md` text) — the checklist tells you what to create and where to find the format, not what to paste. Content templates blur into scaffolding, which is out of appetite.
