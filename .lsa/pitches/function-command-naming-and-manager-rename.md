Shaped by: Nikita Zverev (via management:product-manager, DX / CLI-ergonomics lens)
Date: 2026-06-15
Status: approved
Locked decisions (gates 2026-06-15): role = DX / CLI-ergonomics PM · verb map = full split (`manager:next` + `manager:decompose` + `manager:check`, `start-feature` → `manager:shape`, new `manager:implement`) · backward-compat = clean break, no aliases (pre-1.0, lsa v0.8.0 precedent) · `manager:implement` = named + read-only preview stub (engine deferred to parallel-agent-delivery).
Why now: Decided 2026-06-14 during parallel-agent-delivery Epic-0 design — the design refinement re-homes parallel orchestration onto a "manager" actor and adopts a function-like naming convention; locking the convention + rename now, before that engine is built, prevents naming the new surface twice (`.lsa/research/parallel-agent-delivery-solution-design.md:82-123`).

# Function-like command naming + rename plugin `management` → `manager`

Adopt a function-like command-naming convention (`<actor>:<action>-<modifier> args` — verbs you call, not nouns you browse), migrate the management command surface to verbs, and rename the plugin `management` → `manager`. This is the naming + rename + command-surface map ONLY; it does not build the parallel-execution engine behind `manager:implement`.

## Problem

The repo owner (and any new user) finds the current management command names opaque. Two concrete defects:

1. **Noun-as-command.** `management:roadmap` "tells me nothing as a user" — it is a noun (a place you browse) that actually bundles three distinct verbs: recommend-next, decompose-pitch, tidy-hygiene. The single skill `management/skills/roadmap/SKILL.md` confirms the bundling: its description lists "recommend what to work on next, decompose pitches into epics, and tidy roadmap hygiene" (`management/skills/roadmap/SKILL.md:3`). One name, three jobs.

2. **Abstract-domain plugin name.** The plugin is named for the abstract domain "management," but the actor doing the work is the *manager*. The design refinement makes this explicit: the SoC table names the actor "**Manager** (`manager`, the project-aware agent)" (`.lsa/research/parallel-agent-delivery-solution-design.md:91`), and the convention note states the rename "Implies the plugin rename **`management` → `manager`** (the actor, not the abstract domain)" (`:121`).

This is the same principle that rejected the abstract codename "fleet": names should be concrete, direct, and factual, with zero metaphor — a new user should understand a command from name + args alone. The prior in-repo rename (drop the `lsa-` stutter) was driven by the identical complaint — user 2026-05-24: *"I got always confused what each command does and what's the correct order"* (`.lsa/roadmap.md:134`).

Current workaround: users ask the `helper` plugin to explain which command does what and in what order, rather than reading it off the name. The `helper` onboarding fast-path already carries management command explanations to compensate (`helper/knowledge/onboarding-fast-path.md` references management commands).

Definition of success:
- The management command surface is verbs: `manager:next`, `manager:decompose <pitch>`, `manager:check`, `manager:shape <idea>`, and the newly-named `manager:implement [epics] [--parallel|--sequential]`.
- The plugin directory, namespace, and every live cross-reference read `manager`, not `management`.
- A reader unfamiliar with the repo can state what each command does from its name + args alone.
- `lsa:verify` (or the equivalent reference check) finds no broken `management:*` cross-references in *live* artifacts after the migration.

## Appetite

Small-to-medium batch — a **mechanically wide but logically shallow** rename. The cost is breadth (many files), not depth (no new behavior). It is bounded by the existing lsa v0.8.0 rename playbook, which did the same class of work (directory rename + namespace change + cross-ref sweep + README/ARCHITECTURE/plugin.json/CHANGELOG in one pass — `lsa/CHANGELOG.md:202-214`).

In appetite:
- Directory rename `management/` → `manager/` (11 files: `management/skills/{roadmap,start-feature}/SKILL.md`, `management/agents/{product-manager,project-manager}.md`, three `management/knowledge/*.md`, `plugin.json`, `README.md`, `CHANGELOG.md`).
- Skill directory renames to the new verbs (`skills/roadmap/` splits into the three verb entry points; `skills/start-feature/` → `skills/shape/`).
- The verb-migration map: `management:roadmap` (3-in-1) → `manager:next` + `manager:decompose` + `manager:check`; `management:start-feature` → `manager:shape`; **name** (not engine) `manager:implement`.
- `.lsa.yaml` module key `management` + its five `artifact_paths` (`.lsa.yaml:42-49`).
- `.claude-plugin/marketplace.json` (3 occurrences), root `README.md` (12), `CLAUDE.md` (2), `core/README.md`, `helper/` cross-refs, `knowledge/index.md` (6), `scripts/lint.sh` (1).
- The module spec `.lsa/modules/management/spec.md` → `.lsa/modules/manager/spec.md` (23 internal `management` occurrences) and `.lsa/main.spec.md` (3).
- Per-plugin CHANGELOG entry + SemVer **minor** bump on the renamed plugin (breaking — every command prefix changes — but the project is **pre-1.0**, so breaking changes bump the *minor*; `1.0.0` is reserved for the first public release, per the roadmap `:19` precedent).

Out of appetite:
- The parallel-execution engine behind `manager:implement` — dependency-wave planning, worktree dispatch, serialized merge, autonomy. That is the separate `parallel-agent-delivery` pitch. This pitch may *name and sketch the signature* of `manager:implement`, but ships it as a read-only preview stub only.
- Rewriting historical references (CHANGELOGs, `.lsa/archive/**`, shipped pitch bodies) to the new name. History is the permanent record and stays as written (see Rabbit hole 3).
- Re-homing the parallel orchestration components onto `manager` in code (the SoC decision at `solution-design.md:96`) — that re-home is *recorded* by this rename but *executed* by the parallel-agent-delivery build.

## Solution sketch

- **Key user interactions:** the user types a verb that reads like a function call. `manager:next` (recommend next item), `manager:decompose <pitch>` (pitch → epics), `manager:check` (roadmap hygiene), `manager:shape <idea>` (was `start-feature`), `manager:implement [epics] [--parallel|--sequential]` (no-arg = read-only preview of the last X roadmap items with parallel indication; with args = the manager *proposes* a plan and the human confirms — ownership-over-automation per `core/ground-rules` Rule 0, `solution-design.md:100`). The signature table is at `solution-design.md:102-107`.
- **Main components:**
  1. **Convention knowledge file** — write the `<actor>:<action>-<modifier> args` convention down as a citable rule (candidate: `manager/knowledge/command-naming.md`) so future commands inherit it.
  2. **Directory + namespace rename** `management/` → `manager/` (Claude Code derives the command prefix from the dir name, so the rename *is* the prefix change).
  3. **Skill split/rename** — `roadmap` skill's three verbs become three command entry points (`next`/`decompose`/`check`); `start-feature` → `shape`; `implement` added as a named preview stub.
  4. **Config + manifest sweep** — `.lsa.yaml` module key + artifact_paths, `marketplace.json`, plugin.json (name + **major** bump).
  5. **Cross-ref sweep** — all *live* artifacts across root, `core/`, `helper/`, `lsa/`, `knowledge/index.md`, `.lsa/modules/`, `.lsa/main.spec.md` rewritten `management` → `manager`.
  6. **Module-spec rename** `.lsa/modules/management/` → `.lsa/modules/manager/`.
- **Critical path:** decide the verb map (locked: full split) → rename dir + skills → update plugin.json (name + minor bump) + marketplace.json + `.lsa.yaml` → sweep live cross-refs → rename module spec → CHANGELOG + READMEs (root + plugin) in the same commit → reference check passes (no broken `management:*` in live artifacts).

## Rabbit holes

1. **Backward-compat aliases.** Whether old `management:*` invocations get redirect aliases or it's a clean break. **Resolved (gate): clean break, no aliases** — follow the lsa v0.8.0 precedent (that rename removed old `lsa:lsa-*` names outright, `lsa/CHANGELOG.md:203`), justified by pre-1.0 status. Aliases would mean keeping `management/` shims alive, doubling the surface — the opposite of the clarity goal.

2. **The `roadmap` 3-in-1 split.** `management:roadmap` bundles three verbs in one skill (`roadmap/SKILL.md:3`) with a fast-path Step 0 branch (`roadmap/SKILL.md:24`). Splitting into `next`/`decompose`/`check` is real skill surgery, not pure rename — the shared `project-manager` agent dispatch and the staged `lsa:discover` handoff must be preserved across the split. Mitigation: keep one `project-manager` agent; the three skills are thin entry points dispatching it with different intents.

3. **Partial rename / stale historical refs.** 148 `management` occurrences across 33 files — but many are in CHANGELOGs, `.lsa/archive/**`, and shipped pitch bodies that are *historical record* and must NOT be rewritten (rewriting history is its own defect). Mitigation: scope the sweep to *live* artifacts only; explicitly exclude `**/CHANGELOG.md` history sections, `.lsa/archive/**`, and already-shipped pitch bodies. The lsa precedent swept "all *active* files" (`lsa/CHANGELOG.md:210`) — same boundary. The reference check must distinguish live from historical, or it will flag intentional history.

4. **`manager:implement` scope creep.** Naming a command whose engine lives in another pitch invites building the engine here. **Resolved (gate): named + read-only preview stub** — it prints the last X roadmap items + parallel indication and explicitly states the wave-planning engine is pending (parallel-agent-delivery). Hard no-go below.

5. **Verb-map bikeshedding.** **Resolved (gate): full split as sketched** (`next`/`decompose`/`check`/`shape` + `implement`). Locked before any rename so the mechanical work happens once.

6. **Two-name window in dependent plugins.** `helper`'s onboarding fast-path and `core`/`lsa` cross-refs name management commands; if the rename lands without sweeping them, helper will teach dead command names. Mitigation: the cross-ref sweep (component 5) is in the same commit as the rename, per the "same commit" README/CHANGELOG discipline in `CLAUDE.md`.

## No-gos

1. This pitch does NOT build the parallel-execution engine (dependency-wave planning, worktree dispatch, serialized merge, autonomy knob, roll-up) behind `manager:implement` — that is the `parallel-agent-delivery` pitch (`.lsa/pitches/parallel-agent-delivery.md`). Here, `manager:implement` is named and stubbed (read-only preview) only.
2. This pitch does NOT re-home the parallel-orchestration components onto `manager` in code — it only records the home decision in the renamed specs. The re-home executes in the parallel-agent-delivery build (`solution-design.md:96`).
3. This pitch does NOT rewrite historical references (CHANGELOG history, `.lsa/archive/**`, shipped pitch bodies) — history is the permanent record. Only live artifacts are swept.
4. This pitch does NOT add backward-compat aliases for `management:*` — clean break (gate decision).
5. This pitch does NOT introduce a new `fleet` plugin — that idea is explicitly superseded by the `manager`-as-home decision (`solution-design.md:82,96`).
