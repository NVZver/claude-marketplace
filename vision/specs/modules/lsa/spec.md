# Module Spec — `lsa`

The Living Spec Architecture plugin. Eight skills + one SessionStart hook + a config schema.

**Plugin manifest:** [`lsa/.claude-plugin/plugin.json`](../../../../lsa/.claude-plugin/plugin.json) (v0.2.0)
**Plugin README:** [`lsa/README.md`](../../../../lsa/README.md)
**Methodology doc:** [`lsa/ARCHITECTURE.md`](../../../../lsa/ARCHITECTURE.md)

## Role in the marketplace

`lsa` is the spec-first methodology pack — humans write and own specs; agents write and own artifacts; the **reconcile loop** absorbs direct artifact edits rather than blocking them (Level 2.5, `vision/VISION.md:138`). Depends on `core` (`lsa/README.md` *"Depends on"*) for:

- `core/ground-rules` — fact-grounding policy (`lsa/ARCHITECTURE.md` §2 P4, §7).
- `core/tier-selector` — orchestration handoff upstream of `lsa-discover` for every T2 / T3 task.
- `core/actor-template` — the Goal/Input/Steps/Output/Constraints shape every LSA skill body matches.

## Phases

LSA defines **eight numbered phases (Phase 0 + Phases 1–7) plus one ad-hoc phase (Reconcile)** — 9 total. v0.1.1 had Phases 1–7; v0.2.0 inserts Phase 0 (Discover) at the front of every T2/T3 flow and adds Reconcile as a fires-on-drift ad-hoc step. (This count is documented explicitly to avoid the off-by-one math noted in `vision/specs/2026-05-20-lsa-v0.2.0-design.md` §16.)

| Phase | Tier(s) | Skill | Gate |
|---|---|---|---|
| Pre-feature checklist | T3 | (none — manual) | none |
| Tier selection | every non-trivial task | `core/tier-selector` | hard confirm (tier) |
| **Phase 0 — Discover** | T2, T3 | `lsa-discover` | none of its own |
| Phase 1 — Specify | T3 | `lsa-specify` | hard/soft per artifact |
| Phase 2 — Plan | T3 | `lsa-plan` | hard confirm (tasks.md) |
| Phase 3 — Implement | T2, T3 | (sub-agents per epic for T3; free-form TDD for T2) | per-epic verify |
| Phase 4 — Sub-Agent Deep Review | T3 | (sub-agents) | human reviews findings |
| Phase 5 — Verify | T2, T3 | `lsa-verify` | hard gate on FAIL |
| Phase 6 — Sync | T3 | `lsa-sync` | hard confirm (delta) |
| **Phase Reconcile** (ad-hoc) | any | `lsa-reconcile` | hard confirm per module |
| Phase 7 — Replan | T3 | (and optionally `lsa-revise-constitution`) | per-change hard confirm |

## Skills

### `lsa-init`

| | |
|---|---|
| **Role** | One-time spec-tree initializer (greenfield or brownfield). |
| **Behavioral contract** | Reads `.lsa.yaml` (or defaults), scaffolds `${specs_root}/{main.spec,roadmap,research-backlog,standards/*,modules,features,archive}.md`. Brownfield mode scans `modules.*.artifact_paths` (or `/src/` fallback) and marks each inferred requirement `[assumption: inferred from <source>; verify]`. Per `lsa/skills/lsa-init/SKILL.md`. |
| **Invariants** | Never overwrites existing specs. Never invents brownfield structure not derivable from configured paths. |

### `lsa-discover` — NEW in v0.2.0

| | |
|---|---|
| **Role** | Phase 0 — light three-question discovery probe at the start of every T2 and T3 task. |
| **Behavioral contract** | Reads `.lsa.yaml`, lists candidate module names, asks exactly three questions (module, change, AC). T2: emits oral context paragraph; T3: writes scratch `discovery.md` and hands off to `lsa-specify`. Per `lsa/skills/lsa-discover/SKILL.md`. |
| **Invariants** | Three questions, no more. Does not write to `${specs_root}/`. Does not invent module names. |

### `lsa-specify`

| | |
|---|---|
| **Role** | Phase 1 (T3 only) — write the formal feature spec. |
| **Behavioral contract** | Writes `${specs_root}/features/<name>/{requirements.md, test-suites.md, contract.yaml, design.md, tasks.md}` with hard confirm on `requirements.md` and `test-suites.md` and soft confirm on `contract.yaml` and `design.md`. Step 8 integration-check before handing off to `lsa-plan`. Consumes optional `discovery.md` from `lsa-discover` when present. Per `lsa/skills/lsa-specify/SKILL.md`. |
| **Invariants** | Never skips a gate. Never writes outside the feature directory. |

### `lsa-plan`

| | |
|---|---|
| **Role** | Phase 2 (T3 only) — decompose approved spec into ≤5 parallel-safe epics. |
| **Behavioral contract** | Writes `${specs_root}/features/<name>/tasks.md`. Self-verification table (traceability, accuracy, consistency, test coverage, completeness). Hard confirm before any implementation begins. Per `lsa/skills/lsa-plan/SKILL.md`. |
| **Invariants** | Max 5 epics. Each epic independent or its dependency is explicit. |

### `lsa-verify`

| | |
|---|---|
| **Role** | Phase 5 (T2 and T3) — verify every change traces to a spec requirement. |
| **Behavioral contract** | Branches by `.lsa.yaml: mode`. Code-mode (default): diffs `/src/`. Doc-mode: diffs each module's `artifact_paths`. Mixed: both, either failing fails. Tracing in doc-mode satisfied by (a) feature spec naming the file or its dir in an AC, OR (b) diff is wholly mechanical (rename / whitespace / formatting), agent-judged and reported. On clean T3 PASS, writes `${specs_root}/archive/<feature>/metrics.md`. Errors cleanly when invoked without an active feature spec, pointing the user at `/lsa:reconcile`. Per `lsa/skills/lsa-verify/SKILL.md`. |
| **Invariants** | FAIL on any untraced change. No metrics written on FAIL or PASS WITH WARNINGS. No metrics for T2 (no feature spec, no sync step). |

### `lsa-sync`

| | |
|---|---|
| **Role** | Phase 6 (T3 only) — extract delta into module specs, archive feature, record sync SHA. |
| **Behavioral contract** | Extracts only system-level decisions; tags every addition `<!-- added: [feature-name] [YYYY-MM-DD] -->`. Archives feature dir to `${specs_root}/archive/$(date)-<feature>/`. Writes `.lsa-sync-state.json` (HEAD SHA + ISO timestamp per touched module; preserves untouched modules). If `lsa-verify` wrote a per-feature `metrics.md`, appends one row to `${specs_root}/metrics.md`. Per `lsa/skills/lsa-sync/SKILL.md`. |
| **Invariants** | Human reviews delta before any spec write. Never deletes content. Preserves untouched modules' state-file entries. |

### `lsa-reconcile` — NEW in v0.2.0

| | |
|---|---|
| **Role** | Ad-hoc phase — absorb direct artifact edits into module specs (Level 2.5). |
| **Behavioral contract** | Per-module `git diff <recorded-sha> -- <artifact_paths>` (working-tree vs recorded SHA — catches uncommitted edits). Classifies class (a) — change to existing behavior — or class (b) — new behavior. Per-module hard confirm. On confirm: class (a) updates the contradicted requirement line(s) in place (replaces, doesn't append-next-to); class (b) appends a new requirement; both tagged `<!-- reconciled: YYYY-MM-DD -->`. Updates `.lsa-sync-state.json`. On reject: spec untouched; optional row to `research-backlog.md`. Per `lsa/skills/lsa-reconcile/SKILL.md`. |
| **Invariants** | Never blocks, reverts, or reformats artifact edits (`vision/VISION.md:144`). Never leaves the spec self-contradictory. One module at a time. Handles missing `.lsa-sync-state.json` (initialize, don't error) and unreachable SHA (warn, baseline at HEAD). |

### `lsa-revise-constitution`

| | |
|---|---|
| **Role** | Phase 7 (T3 only) — propose and apply constitution / standards changes after a feature merge. |
| **Behavioral contract** | Reads the configured constitution + `${specs_root}/standards/*`, extracts proposed changes from the most recently archived feature, presents each individually with hard confirm, applies approved changes (tagged `<!-- revised: [feature-name] [YYYY-MM-DD] -->`), opens a `constitution/<change-description>` branch for PR to main independent of features. Per `lsa/skills/lsa-revise-constitution/SKILL.md`. |
| **Invariants** | Per-change hard confirm; never bulk-approves. Never touches specs, src, or skills — only the configured constitution and `${specs_root}/standards/`. |

## Hooks

### SessionStart drift-warning hook — NEW in v0.2.0

| | |
|---|---|
| **Manifest** | [`lsa/hooks/hooks.json`](../../../../lsa/hooks/hooks.json) — single-file plugin hook convention per `code.claude.com/docs/en/hooks`. |
| **Trigger** | `SessionStart` with `matcher: "startup"` (not `resume`/`clear`/`compact` — drift state doesn't change on those events). |
| **Script** | `${CLAUDE_PLUGIN_ROOT}/hooks/session-start-drift-check.sh`. Timeout 10s. |
| **Behavior** | No-op when not in a git repo, when `.lsa.yaml` is absent, or when `.lsa-sync-state.json` is absent. Otherwise, for each module: `git diff --quiet <last_sync_sha> -- <artifact_paths>`. If any module shows drift, prints one line: `LSA: drift detected in modules [...] — run /lsa:reconcile to absorb.` Exits 0 always — informational, must not block session start. |
| **Invariants** | Never blocks session. Never writes anything. Silent on no-config or no-baseline. |

## `.lsa.yaml` schema

Single config file at the project's repo root. All keys optional. Schema version 1 (matches `lsa` major version 0.x.y). Full schema in `lsa/ARCHITECTURE.md` §4.10.

```yaml
constitution: vision/VISION.md       # default: /CLAUDE.md
specs_root: vision/specs/            # default: /specs/
mode: docs                           # docs | code | mixed. default: code
modules:
  <name>:
    spec: <path>
    artifact_paths:
      - <glob>
```

When absent, LSA falls back to v0.1.1 behavior (`/CLAUDE.md`, `/specs/`, code-mode, no module map). All v0.1.1 projects continue to work without change.

## State files

| File | Owner | Purpose |
|---|---|---|
| `.lsa.yaml` | Human (or `lsa-init`) | Path + mode + module config. |
| `.lsa-sync-state.json` | `lsa-sync` (write) and `lsa-reconcile` (write on confirm) | Per-module last-sync SHA + ISO timestamp. Consumed by the SessionStart drift hook and by `lsa-reconcile`'s diff base. |
| `${specs_root}/archive/<feature>/metrics.md` | `lsa-verify` (write on clean T3 PASS) | Per-feature metric counts (accuracy / facts / only-required-changes). |
| `${specs_root}/metrics.md` | `lsa-sync` (append) | Aggregate row per archived T3 feature. Optional. |

## Invariants

- **Versioning.** `lsa` evolves with its own SemVer + CHANGELOG (`vision/VISION.md` §1 *"Distribution + versioning"*). Currently v0.2.0; v0.3.0 backlog includes retro habit, self-eval harness, T2 metrics surface (see `vision/specs/roadmap.md`).
- **Markdown + small JSON-/YAML-/bash-script surface.** No `/src/`. Plugin manifest is JSON; config is YAML; hook is bash. Per `vision/specs/standards/code.md`.
- **Depends on `core` v0.2.0** for `tier-selector`. Documented in `lsa/.claude-plugin/plugin.json: description` and `lsa/README.md` *"Depends on"*.
