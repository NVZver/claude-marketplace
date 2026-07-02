Shaped by: Nikita Zverev
Date: 2026-07-02
Status: approved
Role lens: developer-experience / catalog-integrity product manager
Decisions:
- Fork 1 (recurrence-guard scope): ship the deterministic count + file-existence lint check now; include the description-covers-skills check only if it can be made exact — drop it rather than ship fuzzy matching.
- Fork 2 (dependencies format): bare-name form `["core","lsa"]`, matching the three manifests already using it; semver constraints are a later, separate decision.
- Fork 3 (sweep breadth): full sweep — all four stale marketplace.json descriptions (core, manager, lsa, observer) + every cited surface in one pass.
- External fact (resolved during shaping): the `dependencies` field EXISTS — official plugins-reference documents it (`dependencies | array | "Other plugins this plugin requires, optionally with semver version constraints"`, code.claude.com/docs/en/plugins-reference) and it is functional since Claude Code v2.1.110 (github.com/anthropics/claude-code/issues/48864). Adopt it everywhere; the "prose-only" claims are the wrong side.
- Post-shaping note (2026-07-02): plugin versions moved after shaping (lsa 0.23.0, observer 0.2.1, core 0.15.2) — the drift findings were re-verified against d8d1662 and all hold; implementer re-checks current versions at build time.
Why now: a fast week of merges (observer 0.2.x, lsa 0.21–0.23, helper 0.5.1–0.5.4) left the pre-install trust surface behind — a whole shipped skill (observer:verify-checkpoint) is invisible and contributors get contradictory instructions on the dependencies field. This is the storefront; it is reviewer-facing (JetBrains application) right now.

# Catalog-surface drift — refresh every discovery surface to one current story

The public discovery surfaces — pre-install browse copy, the root knowledge index, the in-context-help catalog, and per-plugin status headers — have fallen behind the last week of merges. Refresh them so a newcomer, a contributor, and the in-repo Helper agent all read the same, current facts.

## Problem

Three audiences hit stale or contradictory catalog copy:

- **A user browsing before install** reads `.claude-plugin/marketplace.json`, which describes observer as *"One Actor skill (observer:observe)"* — but observer has shipped two skills since 0.2.0: *"through two Actor skills"* (`observer/README.md:3`), confirmed by the manifest itself naming `observer:verify-checkpoint`. The same file describes core as *"ground-rules + actor-template"* when core ships five skills (ground-rules, output, actor-template, flow-selector, reuse-first), and the manager entry names only shape + decompose, omitting next/check/implement (`manager/README.md:31-34`).

- **A newcomer following the root README's navigation pointer** — *"[`knowledge/index.md`](./knowledge/index.md) — flat topic-to-path index across every knowledge file"* (`README.md:200`) — lands on an index that undercounts itself. It claims *"every knowledge file across the five marketplace plugins"* (`knowledge/index.md:5`) and *"Catalog — 21 knowledge files"* (`knowledge/index.md:9`); the filesystem has **22 files across six plugins** (`observer/knowledge/roles.md` exists but has no row). The same index cites a phantom consumer, *"cited by `lsa:next`, `manager:next`"* (`knowledge/index.md:13`), but `lsa:next` was removed — *"stale `lsa:next` removed from the fast-path consumer list"* (`core/CHANGELOG.md:107`); the real fast-path is `manager:next`. The index's own header warns *"a stale row breaks navigation silently"* (`knowledge/index.md:5`).

- **A contributor** gets opposite instructions on the same field. `helper/README.md:46` states *"Claude Code's plugin manifest does not yet expose a `dependencies` field; dependencies are prose-only"*, and `.lsa/main.spec.md:29` repeats it for lsa. Yet `lsa`, `manager`, and `observer` manifests all declare `"dependencies": ["core"]`, and `manager/README.md:24` says *"Declared in … `plugin.json` `dependencies` field."* The field question is now settled: the official plugins-reference documents `dependencies` (array; "Other plugins this plugin requires, optionally with semver version constraints"), and it became functional in Claude Code v2.1.110. So the "prose-only" story is the wrong one — and `helper/.claude-plugin/plugin.json` is the only dependent manifest missing the field despite depending on core + lsa.

Two more surfaces are silently stale:

- **observer:verify-checkpoint is invisible outside observer/README** — grep count in root `README.md` is **0**; the six-plugin table row describes coach-only behavior (`README.md:18`) and the user-flow shows only `observe` (`README.md:144-159`). A shipped gating skill has no public mention.
- **The in-context help cannot answer "what is observer"** — `helper/knowledge/onboarding-fast-path.md:24` says *"Catalog size v2: **8 rows** … cover all five shipped plugins"* with no observer row, so the Helper agent's onboarding fast-path has no mapping for the sixth plugin. And `helper/README.md:12` header reads *"## Status — v0.5.2"* while the manifest is `0.5.4` and the release table stops at v0.5.0.

Current workaround: none — each surface drifts independently and is only caught by manual audit (this one). The "READMEs are living documents" rule in `CLAUDE.md` is prose-only and demonstrably not holding.

Definition of success (deterministic checks, per the verifiable-done predicate):
- `knowledge/index.md` header states six plugins / 22 files; a row for `observer/knowledge/roles.md` exists; `lsa:next` no longer appears in the file (grep = 0 outside CHANGELOG); a new `scripts/lint.sh` check proves the header count equals the on-disk `*/knowledge/*.md` count and each row maps to a real file.
- `grep -c verify-checkpoint README.md` ≥ 1; the observer table row and user-flow both mention it.
- `marketplace.json` observer entry says two skills; core, manager, lsa entries name their current skill sets and lsa's orchestrator framing matches `orchestrator.md:3` (inline stages, two boundary crossings).
- `helper/README.md` header equals `helper` `plugin.json` version; the release table reaches the current version.
- `onboarding-fast-path.md` has an observer row and says six plugins.
- The dependencies contradiction is gone one way: `helper/plugin.json` declares `dependencies`, and `helper/README.md:46` + `.lsa/main.spec.md:29` no longer claim the field is unavailable.

## Appetite

Small batch — one build cycle. This is documentation reconciliation across enumerated files, one small manifest-field addition, two corrected claims, and one bounded lint check. No new agent logic, no new skills, no behavior change to any plugin's runtime. Per-file version bumps + CHANGELOG entries land in the same commits per the marketplace's SemVer rule.

Out of appetite: any redesign of the catalog format, generating descriptions from a single source, or a CI wiring change beyond adding checks to the existing `scripts/lint.sh`.

## Solution sketch

- **Key user interactions:** none change at runtime; the deliverable is that every discovery surface reads the same current facts, and a `lint.sh` run fails loudly on the next count/coverage drift.
- **Main components (all edits to existing files):**
  1. `knowledge/index.md` — header (six plugins / 22 files), add the `observer/knowledge/roles.md` row, add observer to the sort note (`:35`), drop `lsa:next` from the fast-path-consumer description (`:13`).
  2. `.claude-plugin/marketplace.json` — refresh core, manager, lsa, and observer descriptions to their current skill sets; align lsa's orchestrator phrasing with `orchestrator.md:3`.
  3. `README.md` — observer table row (`:18`) + user-flow (`:144-159`) gain a `verify-checkpoint` mention (one coaches, one gates).
  4. `helper/README.md` — header → current version, extend the release table, and correct the `:46` dependencies claim.
  5. `helper/knowledge/onboarding-fast-path.md` — add an observer row (row 9), update the count + "six shipped plugins" (`:24`).
  6. `helper/.claude-plugin/plugin.json` — add `"dependencies": ["core", "lsa"]` (bare-name form, matching lsa/manager/observer).
  7. `.lsa/main.spec.md:29` — correct the lsa "does not expose a dependencies field" note.
  8. `scripts/lint.sh` — add a check: index header count == on-disk `*/knowledge/*.md` count, and each index row resolves to a file; optionally (only if exact) a description-covers-skills check.
- **Critical path:** resolve the dependencies field first (fact already in hand → adopt it), then sweep the surfaces, then add the lint check that would have caught the count drift, then run `scripts/lint.sh` green as the gate.

## Rabbit holes

1. **Lint check over-reach** — a "every skill mentioned in every description" check can balloon into fuzzy string matching and false positives. Mitigation: ship the pure integer count + file-existence check (deterministic) as the required guard; treat the description check as best-effort and drop it if it can't be made exact within appetite.
2. **Dependencies format choice** — the field accepts bare names (`["core"]`) or semver objects. Mitigation: use bare names to match the three manifests already using them; semver constraints are a separate, later decision, not this pitch.
3. **New drift introduced while fixing drift** — editing many files by hand risks a fresh miscount. Mitigation: the count lint check runs as the completion gate, so any count error fails the build before merge.

## No-gos

1. This pitch does NOT change any plugin's runtime behavior, skills, or agents — it reconciles descriptive surfaces only.
2. This pitch does NOT introduce a generator that derives descriptions from a single source (single-source-of-truth for catalog copy is a larger, separate pitch); it fixes the current copy and adds a drift *detector*, not a drift *preventer-by-construction*.
3. This pitch does NOT add semver version constraints to any `dependencies` field — bare plugin names only.
4. This pitch does NOT touch CI configuration beyond adding checks to the existing `scripts/lint.sh`.
