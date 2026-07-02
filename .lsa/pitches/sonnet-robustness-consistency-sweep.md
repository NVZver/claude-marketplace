Shaped by: Nikita Zverev
Date: 2026-07-02
Status: approved
Role lens: prompt-engineering + marketplace-maintenance reviewer
Decisions:
- Fork 2a ("Sonnet" rationale references): generalize to "the Pro-tier model (see `.lsa/standards/code.md` §Model policy)" in `lsa/CORE.md:29` and `lsa/agents/orchestrator.md:30,:46`.
- Fork 2b (reconcile N default): OWNED BY `eval-coverage-tracks-complexity` — that pitch defines N = 3 + `.lsa.yaml` escape hatch alongside the reconcile deterministic backstop. This pitch's threshold workstream excludes reconcile/N to avoid a double edit.
- Fork 2c (observer inactivity timeout): default = 2 consecutive no-change `/loop` cycles (cycle-based, since observe rides the self-paced `/loop`; no wall clock), with an escape hatch.
- Fork 2d (minor drifts): included — prompt-engineer `<example>` XML in its agent description, ToCs for the two >100-line manager files, and the core-manifest "7 format golden rules" wording all land in this sweep.
Why now: the model policy was just codified (PR #64) and is 100% complied with, but the 2026-07-02 evaluation found it is under-specified for a weaker model in six spots — and a fast week of merges (observer 0.1.1, lsa 0.21.0) left the manager plugin and two manifests contradicting their own documented laws, on a repo that is reviewer-facing.

# Sonnet-robustness + self-consistency sweep

Correct the prompt artifacts so a Sonnet-class model can run every skill without inventing a missing threshold or dropping a step, and so the manager plugin and the lsa/core manifests stop contradicting their own documented naming and version rules.

## Problem

Two populations have this problem.

**Anyone running the marketplace on Claude Pro (Sonnet)** — the stated critical constraint (`.lsa/standards/code.md` "Pro-safe by default"). The policy is codified and today 100%-complied-with (zero `model:` pins shipped), but several artifacts still lean on inference a stronger model papers over and a weaker one must invent:

- **Undefined thresholds.** `lsa/skills/reconcile/SKILL.md:32` and `lsa/CORE.md:66` say *"run each Gherkin scenario against the diff **N times** … pass = succeeds on ≥95% of runs"* — `N` is defined nowhere (fix owned by the eval-coverage pitch, per Decisions). `observer/skills/observe/SKILL.md:41` stops *"when the session is self-determined over, or when inactivity exceeds the timeout"* — no timeout value or derivation; `observer/knowledge/roles.md:33` *"When the candidate is persistently stuck, lower the bar"* is unquantified in the data file the skill actually reads (the "3 cycles" figure lives only in `scenarios.md`, which the skill does not read). `manager/skills/implement/SKILL.md:30` collects *"the last ~5 `backlog` / `not started` rows"* over a roadmap table with no timestamp column ("last" is not deterministically resolvable), and the concurrency *"cap (default ~4)"* at `:36` is approximate.

- **Bundled multi-action steps** — the house style elsewhere is one action per step plus an `Observable result:` line (`core/skills/reuse-first/SKILL.md`, the `prompt-engineer` agent, `observer/skills/verify-checkpoint/SKILL.md`). Three artifacts break it: `helper/agents/helper.md` Step 1 (`:36`) folds recognise-signal + cooldown-check + exit-or-proceed + derive-goal + the bare-`/help` special case into one paragraph, and Step 4 (`:39`) mixes compose/gloss/budget/cannot-verify/gate across ~15 lines; `manager/skills/implement/SKILL.md` Step 4 (`:36`) bundles dispatch + cap + worktree + per-agent loop + gate + teardown + cross-wave gating, and Step 5 (`:38`) conflates the manual/semi/auto ladder + roadmap-write timing + rollback; `observer/skills/observe/SKILL.md` kickoff (`:27`) says *"infer one candidate role from context"* with no signal→role map — its own eval (`observer/tests/eval-findings-2026-06-27.md`, M3) flagged this as nondeterministic and it is unfixed.

**The repo owner and reviewers** (the repo is cited in a JetBrains application) — because the manager plugin and two manifests contradict the plugin's own "No Fluff / Owned" pillars in their own text:

- **Naming laws violated by the plugin that wrote them.** `manager/knowledge/command-naming.md:5` states *"Zero metaphor: reject abstract or evocative names (`fleet`, `swarm`, `orchestra`)"* — yet "fleet" is used in `manager/skills/implement/SKILL.md:3` (description **and** a trigger keyword), and in `manager/knowledge/fleet-rollup.md` (title *"# Fleet roll-up"*) and `parallel-dispatch.md`. `manager/knowledge/epic-decomposition.md:26` bans *"Ordinal naming / global epic counter"* with live drift evidence, mandating stable slugs — yet "Epic 1/2/4" ordinals appear in `manager/skills/implement/SKILL.md:11,:36,:53`, `parallel-dispatch.md:5,:34`, `autonomy-policy.md:38,:44`, and `serialized-merge.md:5`.

- **Version scaffolding rotting in instructional bodies.** `core/skills/flow-selector/SKILL.md:3` (and the `core` manifest) ends its description *"Renamed from `tier-selector` in `core` v0.5.2; the three flows were `T1`/`T2`/`T3`"*; `core/skills/output/SKILL.md` carries changelog notes in its body (`:184` *"removed in v0.13.0"*, `:71` a dated endorsement); `manager/knowledge/pitch-structure.md:16` says *"since management v0.6.0"* using the **old** plugin name; `command-naming.md:22` embeds *"manager v0.9.0"*.

- **Manifest drift.** The `lsa` manifest description still advertises the pre-0.21 dispatch-per-stage orchestrator, while `lsa/agents/orchestrator.md:3` now runs the authoring stages inline (0.21.0). The `core` manifest calls `output` *"7 format golden rules"* vs the current "one HARD rule + six GUIDANCE" (`core/skills/output/SKILL.md:12`).

- **A model name in instructional bodies.** "Sonnet" appears as rationale in `lsa/CORE.md:29` and `lsa/agents/orchestrator.md:30,:46` — each cites `.lsa/standards/code.md`, so it is defensible policy-cited rationale, but it is the exact string the policy is meant to keep out of bodies. Decision recorded above: generalize.

Current workaround: Opus masks the thresholds (a stronger model invents a plausible `N`, timeout, and role map) and the naming contradictions are simply tolerated and re-grounded on each read. On Sonnet the thresholds become latent nondeterminism, and the contradictions remain a standing "No Fluff / Owned" credibility gap.

Definition of success:
1. Every named threshold in scope resolves to a concrete default **plus an escape hatch**, with no inference required: the observer inactivity timeout and "persistently stuck" figure, the manager backlog-row selection, and the concurrency cap. (Reconcile's `N` is owned by the eval-coverage pitch.)
2. The three bundled artifacts are split one-action-per-step, each with an `Observable result:` line matching the reuse-first / verify-checkpoint house style, and `observe` kickoff gains a signal→role table.
3. `grep -ri fleet manager/` returns zero hits in behavior/knowledge/manifest files, and no "Epic N" ordinal remains in the same set — both match their own documented laws.
4. Version scaffolding is gone from instructional bodies (history lives in the CHANGELOGs); the `lsa` and `core` manifests match their current skills.
5. The "Sonnet" references are generalized to "the Pro-tier model (see `.lsa/standards/code.md`)" per the recorded decision.

## Appetite

One focused batch — a correction sweep, not a redesign. **Nothing new is built:** existing prose is aligned to existing laws and given the defaults it already implies. Bounded to prompt-file edits across four plugins (`lsa`, `observer`, `manager`, `core`). Every edit is behaviour-affecting, so each carries its per-plugin SemVer bump + CHANGELOG entry + any README delta in the same commit, and the `prompt-engineer` agent is the implementer (the repo's standing practice for prompt files, not `lsa:implement`). Naturally decomposes into ~4 independently-shippable epics (by fix class); prefer cutting them per-plugin-per-fix-class so each epic is a clean single-plugin SemVer bump.

Out of appetite: the enforcement layer (lint guards for model-pins / description-length / 500-line bodies, CI wiring, behavioral evals for lsa+manager) — those are the evaluation's separate P0/P1 pitches. Also out: any behaviour change to the parallel engine, autonomy ladder, or observer role model beyond naming and thresholds.

## Solution sketch

- **Key user interactions:** Mostly invisible to the end user — a Sonnet run now resolves every threshold deterministically and executes one action per step instead of guessing at a bundle. The visible change is credibility: consistent vocabulary (no `fleet`, no `Epic N`), manifests that match their skills, and no version cruft in the text a reader sees.
- **Main components** — four workstreams matching the four success criteria:
  1. **Thresholds with defaults** (`observer/skills/observe`, `observer/knowledge/roles.md`, `manager/skills/implement`) — give each undefined threshold a default value derived from an existing grounded source where one exists (observer's own 3-cycle figure; the vendor cap-of-8 → conservative 4) and the decided values elsewhere (inactivity timeout = 2 consecutive no-change `/loop` cycles), each with a `.lsa.yaml` escape hatch. Reconcile/N excluded (owned by eval-coverage pitch).
  2. **Split bundled steps** (`helper/agents/helper.md` Steps 1 & 4, `manager/skills/implement` Steps 4 & 5, `observer/skills/observe` kickoff) — one action per step, each with `Observable result:`; add a signal→role table to `observe` kickoff, copying the verify-checkpoint contract-table pattern.
  3. **Consistency rename** (`manager` plugin) — `fleet` → a concrete name (e.g. "parallel-implementation roll-up"), including the `fleet-rollup.md` filename and the trigger keyword; `Epic N` → the stable slugs `epic-decomposition.md` already mandates.
  4. **Version scaffolding + manifests** (`core/skills/flow-selector`, `core/skills/output`, `manager/knowledge/pitch-structure.md` & `command-naming.md`, `lsa` manifest, `core` manifest) — move history to CHANGELOGs, reconcile both manifests to current skills, apply the "Pro-tier model" generalization, and fold in the 2d minors (prompt-engineer `<example>` XML decision, ToCs for the two >100-line manager files).
- **Critical path:** the open forks are decided (recorded above) → the four workstreams run independently (they touch disjoint line ranges) → each lands as its own gated epic with a SemVer bump + CHANGELOG + README delta → a final grep-based check proves criteria 3 and the manifest reconciliation.

## Rabbit holes

1. **The "Sonnet" references were a genuine fork, not an implementer choice.** Decided in shaping: generalize (recorded above).
2. **Rename ripple into history.** Removing `fleet` / `Epic N` could tempt edits to commit messages, archived specs, and prior CHANGELOG entries. Mitigation: apply the repo's established "archive files don't rewrite" rule (already cited in `.lsa/roadmap.md` for the T1/T2/T3 rename) — only active behavior/knowledge/manifest files change; `.lsa/archive/**` and historical CHANGELOG entries stay as-is.
3. **Invented threshold values could be arbitrary.** Mitigation: derive from an existing grounded source wherever one exists (observer `scenarios.md` already says 3 cycles for "stuck"; `parallel-dispatch.md` notes the vendor cap ~8 → conservative default 4); the remaining values were decided in shaping (recorded above), not left to the implementer.
4. **Splitting a bundle could change behaviour if the bundle hid an ordering dependency.** Mitigation: splits preserve the exact sequence; a pure restructure is behaviour-preserving (patch), and only the added threshold default is the behaviour delta (minor). `lsa:reconcile` verifies no unintended behaviour change per epic.
5. **Scope creep into enforcement.** The broader evaluation wants lint guards and evals; it is tempting to add them here. Mitigation: explicitly no-go'd (below) — this pitch fixes the prose; enforcement is separate.

## No-gos

1. This pitch does NOT build enforcement (model-pin / description-length / 500-line lint guards, CI wiring, behavioral evals for `lsa`+`manager`) — those are the evaluation's P0/P1, separate pitches, because they are new capability, not a prose correction.
2. This pitch does NOT redesign the parallel-implementation engine, the autonomy ladder, or the observer role model — only their naming and thresholds change; behaviour is preserved.
3. This pitch does NOT rewrite archived specs (`.lsa/archive/**`) or historical CHANGELOG entries — per the established "archive files don't rewrite" rule; only active files change.
4. This pitch does NOT touch the UX/catalog-drift surfaces (`knowledge/index.md`, `marketplace.json`, the stale `helper/VERIFICATION.md` scope) — those are the separate catalog-surface-drift pitch.
5. This pitch does NOT edit `lsa/skills/reconcile` or define `N` — owned by `eval-coverage-tracks-complexity` (see Decisions).
