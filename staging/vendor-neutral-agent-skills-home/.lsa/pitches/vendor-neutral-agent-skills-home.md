Shaped by: product-manager (Cursor session)
Date: 2026-07-23
Status: approved
Role lens: agent-platform / developer-tooling product manager
Gate decisions:
- Role: accept — agent-platform / developer-tooling product manager.
- Fork (repo name): **open — to be discussed** before create-repo epic; candidates remain `nvzver-skills` (prior recommendation), `grounded-skills`, `ownership`, `lsa-kit`, `ceremony`, or other. Vision still says Working name placeholder (`.lsa/constitution.md:5`). No silent pick.
- Fork (Claude `/plugin` wrapper in v1): **deferred** — optional later wrapper only; not v1 architecture.
- Fork (observer + `/loop`): migrate `verify-checkpoint` per-increment mode + retarget `observe` to host-generic “re-invoke on change” contract (no Claude `/loop`).
- Fork (history): **clean import** of current trees into empty repo (no `git filter-repo`).
- Fork (constitution file name): **rename** `VISION.md` → `constitution.md` (+ `VISION-digest.md` → `constitution-digest.md`) — grounded in GitHub spec-kit's ubiquitous `.specify/memory/constitution.md` convention (93k★, same discover→spec→plan→tasks role as LSA's constitution); matches what `AGENTS.md` already calls it in prose. Full `.lsa/` naming audit otherwise found the rest of the structure already uses correct industry terms (`pitches/` = Shape Up terminology, `roadmap.yaml`, `*.feature` = Cucumber/Gherkin standard, `tasks.md` matches spec-kit) — no other renames. The "LSA" brand/acronym itself is explicitly **out of scope** for this pitch (separate, much larger rebrand decision if ever opened).
Why now: Industry distribution standards (Agent Skills + AGENTS.md + `npx skills`) are established — confirmed 2026-07-24 against primary sources, not assumed (see External standard evidence below) — while this repo's install path and many runtime primitives remain Claude Code–bound — the tool-agnosticism claim stays half-earned at the distribution layer.

# Vendor-neutral Agent Skills home repo + marketplace migration

Create a new, name-distinguishable GitHub repo that ships the RIGHT architecture first (open Agent Skills as a root `skills/<pack>/<name>/SKILL.md` catalog tree — the same layout the reference provider repo `vercel-labs/agent-skills` uses — installed by consumers via `npx skills add` / `npx skills update`, not hand-maintained adapters), then migrate existing agents, skills, knowledge, and scripts from `NVZver/claude-marketplace`, rewriting Claude-specific primitives to vendor-agnostic contracts.

## Problem

Who has it: the maintainer (and any consumer) of `NVZver/claude-marketplace` — a personal agentic engineering system whose constitution already claims model- and tool-agnosticism (`.lsa/constitution.md:7`, *"Substrate: tool-agnostic"*; `.lsa/constitution.md:15`, *"model- and tool-agnostic"*) but whose **distribution and several runtime surfaces are Claude Code–native**.

Evidence (live repo, 2026-07-23; registry verified 3× by dispatcher):

- Distribution is Claude plugin marketplace: root `.claude-plugin/marketplace.json` lists five plugins (`core`, `lsa`, `manager`, `prompt-engineer`, `observer`); install docs are `/plugin marketplace add` / `/plugin install` (`AGENTS.md:11-15`).
- Vision working name is still a placeholder (`.lsa/constitution.md:5`, *"Working name: Vision (placeholder — to be named later)"*).
- Principle 9 hard-names Claude Code primitives (`.lsa/constitution.md:66`, *"`AskUserQuestion` for decisions…"*).
- **18** instructional files hard-bind `AskUserQuestion` (+ `.lsa/constitution.md` → **19** unique mention sites); `skills/core/doctor/SKILL.md` probes `~/.claude/plugins/` and `CLAUDE.md` fragment merge.
- Observer pack rides Claude Code's self-paced `/loop` (`observer/skills/observe/SKILL.md:11`, `observer/skills/verify-checkpoint/SKILL.md:16`).
- A pre-standard Cursor export tree exists at `dist/cursor/` (~520K) — not Agent Skills / `skills/` catalog SoT.
- Prior pitch `standards-conformance-agents-md` closed format-layer conformance (AGENTS.md + agentskills.io claim) but **did not** move distribution off `/plugin` or create a vendor-neutral home repo.

External standard evidence (fetched 2026-07-24, primary sources):

- SKILL.md format is real and specified: agentskills.io/specification — *"A skill is a directory containing, at minimum, a `SKILL.md` file"*; frontmatter requires `name` + `description` only.
- **Correction to this pitch's first draft:** `.agents/skills/` is the **cross-client install-target** convention, not a source-repo layout. agentskills.io's client-implementation guide (`agentskills.io/client-implementation/adding-skills-support`) states implementations *"should consider scanning both a client-specific directory and the `.agents/skills/` convention"* — i.e. where a *consumer* finds already-installed skills, some clients also read `.claude/skills/` "for pragmatic compatibility." Neither is how a skills-*provider* repo stores its own source.
- The actual reference provider repo — `github.com/vercel-labs/agent-skills`, built by the same team that ships the `npx skills` CLI — lays its own skills out as a flat `skills/<name>/SKILL.md` at repo root (verified via `gh api repos/vercel-labs/agent-skills/contents`: root has `AGENTS.md`, `CLAUDE.md`, `README.md`, `skills/`, `packages/` — no `.agents/` directory). It also keeps both `AGENTS.md` *and* `CLAUDE.md` at root, directly validating this pitch's existing AGENTS.md-canonical / CLAUDE.md-optional-shim split.
- `npx skills` discovery (per `vercel-labs/skills` README, fetched 2026-07-24) explicitly supports a **catalog layout** one level deeper than flat: `skills/<category>/<name>/SKILL.md` — this is a ready-made, spec-tool-native answer to Rabbit Hole #1 (pack-boundary preservation), not something this pitch needs to invent.
- `npx skills` (vercel-labs/skills, ~27k★ per GitHub) is a **third-party Vercel Labs tool**, not an Anthropic- or agentskills.io-issued installer. Widely adopted (companion directory at skills.sh) but swappable — the protocol itself is just files on disk, so manual copy is always a valid fallback and should not be architecturally assumed away.

Current workaround: dogfood Claude Code `/plugin` install; treat Cursor via stale `dist/cursor/` export or one-off copies; verbally assert portability while AskUserQuestion/`/loop`/marketplace packaging remain Claude-bound.

Definition of success:

1. A new GitHub repo exists under a non–Claude-bound name (name chosen in a dedicated gate before create-repo); its canonical **source** layout is a flat, catalog-shaped Agent Skills tree at root — `skills/<pack>/<name>/SKILL.md` — matching the reference provider repo `vercel-labs/agent-skills` and the exact layout `npx skills`' own discovery already supports one level deep. (`.agents/skills/` is where *consumers* end up after `npx skills add`, not where this repo stores its own skills.) Install/update for consumers via `npx skills add` / `npx skills update` (vercel-labs/skills, skills.sh), with manual copy documented as the always-available fallback — not hand-rolled `adapters/`.
2. Migrated discipline packs (at least required `core` + `lsa`; optional `manager`, `prompt-engineer`, `observer` per appetite) run on a host that speaks Agent Skills + AGENTS.md without requiring Claude plugin install.
3. Human-decision sites use a vendor-agnostic contract ("ask the human with labelled options + outcomes"; host may map to a native picker or text fallback) — zero instructional `AskUserQuestion` hard-binds in migrated trees.
4. Registry §C items are explicitly archived or deferred as optional wrappers — not reinvented as v1 architecture.
5. Counts in this pitch's Registry remain auditable against the source repo at migration time (or a dated freeze note).
6. The constitution file is named `constitution.md` (not `VISION.md`) — matching GitHub spec-kit's ubiquitous term for the same role — with no other `.lsa/` structural renames (naming audit found the rest already industry-standard: `pitches/`, `roadmap.yaml`, `*.feature`, `tasks.md`).

## Appetite

**Large batch / multi-cycle** — architecture-in-new-repo first, then migrate content. Out of appetite for v1 (locked by gates):

- Hand-maintained per-host `adapters/` trees.
- Treating Claude `/plugin marketplace` as the primary architecture (optional later wrapper only).
- Migrating `dist/cursor/` as source of truth.
- Rewriting LSA methodology (EARS/Gherkin loop) — migrate, don't redesign.
- Broad rename of every historical changelog mention of AskUserQuestion (docs debt OK if runtime surfaces are clean).
- Preserving git history via filter-repo (clean import locked).

In appetite: new repo scaffold (after name discussion); Agent Skills layout + `npx skills` install story; migrate the five pack trees with SemVer/CHANGELOG continuity where practical; vendor-agnosticize decision + always-on + doctor install checks; retarget Vision §3 distribution + principle 9; leave-behind / archive list executed; observer per gate (verify-checkpoint per-increment + observe host-generic re-invoke).

## Solution sketch

- **Key user interactions:**
  1. Approve this pitch (done 2026-07-23; repo name still open).
  2. Decide repo name (open gate) → create empty GitHub repo under that name.
  3. Land architecture: root `skills/<pack>/<skill>/SKILL.md` catalog tree (source of truth) + root `AGENTS.md`; install docs point consumers at `npx skills add <org>/<repo>` / `npx skills update`, which fans skills out into each consumer's own `.agents/skills/` (cross-client) or host-native dir (e.g. Claude Code's `.claude/skills/`).
  4. Migrate packs in dependency order (`core` → `lsa` → optional packs), applying Registry §B rewrites in the same move.
  5. Point consumers at the new repo; archive or freeze `claude-marketplace` as Claude-wrapper / historical SoT per leave-behind plan.

- **Main components:**
  - **New repo** — Agent Skills home; distinguishable name (open discussion); source layout is root `skills/<pack>/<name>/SKILL.md`, per the reference provider repo `vercel-labs/agent-skills` (not `.agents/skills/`, which is the consumer-side install target).
  - **Always-on** — `AGENTS.md` canonical; Claude `CLAUDE.md` `@import` becomes optional host shim, not the architecture.
  - **Skills / agents / commands / knowledge / scripts** — migrate per Registry §A; retarget §B.
  - **Constitution** — carry `.lsa/constitution.md` + `.lsa.yaml` + module specs, **renaming `VISION.md` → `constitution.md`** (+ `VISION-digest.md` → `constitution-digest.md`) per spec-kit's ubiquitous term (see Gate decisions); replace Working name; rewrite principle 9 + §3 distribution paragraph to substrate-native-*generic* + Claude-as-optional-wrapper.
  - **Doctor** — retarget checks from `~/.claude/plugins` + marketplace.json to Agent Skills install evidence + AGENTS.md anchors.
  - **Not in v1 architecture:** `.claude-plugin/**`, `lsa/hooks` SessionStart, repo-internal `.claude/**`, `dist/cursor/**`.

- **Critical path:** name decision + empty repo → scaffold root `skills/<pack>/<name>/SKILL.md` catalog tree → smoke-test `npx skills add <org>/<repo>` from a scratch consumer checkout for `ground-rules`/`output` (proves the fan-out into `.agents/skills/` actually works) → migrate `core`+`lsa` with AskUserQuestion→labelled-options rewrite → verify doctor + gate scripts on new tree → optional packs (incl. observer retarget) → publish; Claude marketplace wrapper only if/when a later pitch adds it.

### Appendix — Migration registry (file-grounded, verified 3× 2026-07-23)

Denominator: source trees under `NVZver/claude-marketplace` excluding `dist/` unless noted. Passes: Glob inventory · `rg -l` hard-bind recount · Python independent recount. Dispatcher corrections vs shaping agent: manager knowledge **10** (not 11); AskUserQuestion **18** instructional files including `skills/lsa/ARCHITECTURE.md` (+ VISION → 19 unique).

#### Inventory totals

| Kind | Count | Breakdown |
| --- | ---: | --- |
| Skills (`**/skills/*/SKILL.md`) | **20** | core 6, lsa 7, manager 5, observer 2, prompt-engineer 0 |
| Agents | **4** | `skills/lsa/agents/orchestrator.md`, `manager/agents/{product,project}-manager.md`, `skills/prompt-engineer/agents/prompt-engineer.md` |
| Commands | **3** | `prompt-engineer/commands/{prompt-create,prompt-optimize,prompt-review}.md` |
| Knowledge | **21** | core 2, lsa 5, manager **10**, observer 1, prompt-engineer 3 (+ root `knowledge/index.md`) |
| Scripts (`.sh`) | **29** | `scripts/` + `lsa/scripts/` including tests |
| Plugin manifests | **5+1** | five `*/.claude-plugin/plugin.json` (versions core 0.21.2, lsa 0.33.0, manager 0.20.0, observer 0.3.3, prompt-engineer 0.8.3) + root `marketplace.json` |
| Test scenario markdown | **10** | under plugin `tests/` |
| Module specs | **5** | `.lsa/modules/{core,lsa,manager,observer,prompt-engineer}/` |

#### (A) MIGRATE — as-is or lightly retargeted

| Item | Notes |
| --- | --- |
| **20 skills** bodies | Move under root `skills/<pack>/<name>/SKILL.md` (catalog layout — pack namespacing is the directory itself, not a naming convention). Light retarget only where §B applies. |
| **4 agents** | Migrate; drop Claude-only `tools:` / `allowed-tools` entries that name `AskUserQuestion` where present. |
| **3 commands** | Treat as Agent Skills or host-invoked workflows; `prompt-create` needs §B rewrite. |
| **21 knowledge files** (+ root index) | Mostly as-is; `skills/lsa/knowledge/conventions.md` AskUserQuestion section → §B; `skills/manager/knowledge/roadmap-orchestration.md` → §B. |
| **29 scripts** + `.lsa.yaml` gate wiring | Migrate gate/lint/roadmap scripts; paths may need root layout adjust. |
| **`.lsa/`** constitution, modules, pitches, roadmap | Migrate living-spec corpus; Vision name + principle 9 + distribution § rewritten (§B). |
| **READMEs / CHANGELOGs / VERIFICATION** | Migrate; install sections rewritten to `npx skills`. |
| **Root `AGENTS.md` discipline content** | Migrate as always-on SoT; strip `/plugin`-only install as primary path. |
| **Tests under plugin `tests/`** | Migrate; update probes that assume Claude plugin paths. |

#### (B) MUST MAKE VENDOR-AGNOSTIC

**Contract replacement (locked):** `AskUserQuestion` → general instruction *"ask the human with labelled options (and one-line outcomes)"*; host may use a native picker if available, else text. Same ownership rule (ground-rules Rule 0).

**AskUserQuestion hard-binds — 18 instructional files** (+ `.lsa/constitution.md` = 19 unique):

| # | Path |
| ---: | --- |
| 1–3 | `core/skills/{ground-rules,flow-selector,output}/SKILL.md` |
| 4 | `core/CLAUDE.md` (Rule 7 brief) |
| 5 | `skills/lsa/knowledge/conventions.md` (§ AskUserQuestion convention) |
| 6 | `skills/lsa/agents/orchestrator.md` |
| 7 | `skills/lsa/delegate/SKILL.md` (`allowed-tools`) |
| 8 | `skills/lsa/ARCHITECTURE.md` |
| 9–13 | `manager/skills/{shape,next,check,decompose,implement}/SKILL.md` |
| 14 | `skills/manager/knowledge/roadmap-orchestration.md` |
| 15–16 | `manager/agents/{product-manager,project-manager}.md` |
| 17 | `skills/observer/observe/SKILL.md` |
| 18 | `skills/prompt-engineer/commands/prompt-create.md` |

**`/loop` binds — 3 files:** `skills/observer/observe/SKILL.md`, `skills/observer/verify-checkpoint/SKILL.md`, `skills/lsa/delegate/SKILL.md`. Replace with host-generic “re-invoke on change / per-cycle wake” contract (gate locked).

**Doctor / install probes:** `skills/core/doctor/SKILL.md` — replace `~/.claude/plugins`, `core@NVZver` keys, `marketplace.json` environment detect, and “merge into CLAUDE.md” with Agent Skills + AGENTS.md evidence.

**Always-on packaging:** `core/CLAUDE.md` fragment → pack as AGENTS.md section or skill-referenced always-on card; Claude `@AGENTS.md` shim optional later.

#### (C) LEAVE BEHIND / archive / optional later wrapper

| Item | Disposition |
| --- | --- |
| `dist/cursor/` entire tree | **Leave behind** — pre-standard Cursor export; not SoT. |
| `.claude-plugin/marketplace.json` + five `*/.claude-plugin/plugin.json` | **Not v1 architecture** — optional later Claude Code wrapper pitch. |
| `lsa/hooks/hooks.json` + `session-start-drift-check.sh` | **Leave / rewrite later** — Claude `SessionStart` hook. |
| Repo-internal `.claude/settings.json`, `.claude/hooks/commit-discipline-check.sh`, `.claude/agents/claude-dev.md`, `.claude/rules/` | **Marketplace-source only** — do not migrate as product surface. |
| Root `CLAUDE.md` as primary entry | **Optional host shim** later; AGENTS.md is canonical. |
| `/plugin install` as primary UX in READMEs/AGENTS.md | Replace with `npx skills`; keep Claude install prose only in a future wrapper doc. |
| Hand-rolled `adapters/` | **Never** — explicit no-go. |
| `scripts/generate-for-cursor.sh` | **Absent; superseded** — do not revive as architecture. |

## Rabbit holes

1. **Pack boundary vs flat skills namespace** — five plugins today vs one skills tree. Mitigation: use the catalog layout `skills/<pack>/<name>/SKILL.md` — `npx skills`' own discovery walks exactly one extra level deep for this shape (confirmed against its README), so pack prefixes are a first-class, tool-native layout rather than a workaround; do not flatten knowledge ownership in v1.
2. **SemVer continuity** — per-plugin versions today. Mitigation: keep per-pack CHANGELOG + version metadata in skill/pack manifests; bump policy documented in new repo CONTRIBUTING.
3. **Observer without `/loop`** — observe's session-state note pattern assumes stateless re-wake. Mitigation: host-generic re-invoke contract (locked).
4. **Doctor false confidence on new hosts** — install evidence differs per client. Mitigation: WARN/SKIP when evidence unreadable; define Agent Skills evidence checklist in doctor rewrite.
5. **Dual-repo drift** during cutover. Mitigation: freeze window; single SoT declaration in both READMEs; optional later wrapper reads from new repo rather than forking content.
6. **`npx skills` is a third-party dependency, not the protocol** — Vercel Labs owns and could rename, repurpose, or retire the CLI; only the SKILL.md file format is a stewarded open standard. Mitigation: document manual file-copy install as the always-available fallback in the new repo's README/CONTRIBUTING; never let doctor checks or install docs assume the CLI's continued existence as the *only* path.
7. **Name still open** — create-repo blocked until discussion settles. Mitigation: first epic or a pre-epic gate owns the name decision; no silent default.

## No-gos

1. This pitch does NOT make Claude `/plugin marketplace` the v1 architecture — wrapper only, later.
2. This pitch does NOT introduce hand-maintained `adapters/` for Cursor/Claude/others.
3. This pitch does NOT migrate `dist/cursor/` as source of truth.
4. This pitch does NOT redesign LSA discover→specify→verify→delegate→reconcile methodology — port it.
5. This pitch does NOT require finishing a Claude-specific SessionStart hook rewrite in v1.
6. This pitch does NOT silently pick the new repo name — that remains an open discussion gate.
