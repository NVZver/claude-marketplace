# Observation — YAML-ledger selective load: LSA + manager impact

Archived measurement / proof report. Epic: `yaml-ledger-selective-load/read-cutover`  
Parent pitch: [`.lsa/pitches/yaml-ledger-selective-load.md`](../pitches/yaml-ledger-selective-load.md)  
Epic specs: [`.lsa/features/2026-07-16-yaml-ledger-read-cutover/`](../features/2026-07-16-yaml-ledger-read-cutover/)  
Measured against commit `56b6c45` working tree (tokens = bytes÷4, same heuristic as [`manager/CHANGELOG.md`](../../manager/CHANGELOG.md) §`[0.18.0]`).

## Verdict (proved)

**The YAML roadmap cutover does not change LSA loop token performance today.**

Evidence below shows: (1) the epic explicitly excluded LSA runtime; (2) no LSA skill happy-path step loads the roadmap ledger; (3) the enforceable F9 gate only covers manager consumers; (4) `lsa` 0.25.1 is citation-only; (5) LSA’s real selective-load wins were already shipped in pro-tier WS1–WS3. The approach *can* move LSA numbers later — via pitch-ladder + request-scoped feature packs — but that is not this cutover.

---

## 1 · Scope proof — LSA was out of the epic

| Claim | Source | Quote |
|---|---|---|
| Roadmap-only; no LSA runtime | `features/…/requirements.md:7` | *"Roadmap-only: no LSA runtime change, no write-path change, no pitch-body ladder."* |
| LSA docs/scaffold deferred | `features/…/requirements.md:50` | *"LSA plugin runtime (`init`/`discover`/`verify`) and its generic `${specs_root}/roadmap.md` product docs → deferred"* |
| `lsa` ship is cite-sweep | `lsa/CHANGELOG.md:7` | *"Citation-only — no routing behavior changed → patch bump."* |
| Measured win owned by manager | `lsa/CHANGELOG.md:15` | *"Measured context win lives in `manager` 0.18.0"* |

---

## 2 · Instruction proof — LSA skills do not load the ledger

### 2a · Roadmap mentions in LSA skill / agent bodies

`rg 'roadmap\.(md|yaml)'` over `lsa/skills/*/SKILL.md` + `lsa/agents/orchestrator.md`:

| File | Hits | What it is |
|---|---:|---|
| `discover/SKILL.md` | 0 | — |
| `specify/SKILL.md` | 0 | — |
| `verify/SKILL.md` | 0 | — |
| `delegate/SKILL.md` | 0 | — |
| `reconcile/SKILL.md` | 0 | — |
| `revise-constitution/SKILL.md` | 0 | — |
| `orchestrator.md` | 0 | — |
| `init/SKILL.md` | 1 | **Write** scaffold: create `roadmap.md` (`init/SKILL.md:30`) — not a read/load path |

The only live LSA *runtime* reference retargeted in this epic is `lsa/knowledge/model-routing.md:63,83` (item name in `.lsa/roadmap.yaml`) — a citation, not a load instruction (`lsa/CHANGELOG.md:11`).

### 2b · Declared inputs (happy path)

| Stage | Declared inputs | Roadmap? | Source |
|---|---|---|---|
| discover | request; `.lsa.yaml`, constitution, code/specs the request touches | no | `discover/SKILL.md:22-25,29` |
| specify | intent + facts from discover | no | `specify/SKILL.md:22-24` |
| verify | spec + codebase + optional `gate:` | no | `verify/SKILL.md:22-26` |
| delegate | grounded spec + implementer + `paired_verify` | no | `delegate/SKILL.md:23-27` |
| reconcile | diff + spec + `gate:` + `reconcile.runs` | no | `reconcile/SKILL.md:22-27` |
| orchestrator | user request + skill registry | no | `orchestrator.md:25-26,33` |

Discover Step 1: *"Read `.lsa.yaml`, the constitution, and the code/specs the request touches — consult the project map"* (`discover/SKILL.md:29`). No ledger.

### 2c · F9 enforcement excludes LSA (by design)

`bash scripts/tests/no-wholefile-ledger-read.sh` — **PASS** (re-run for this report).

Consumers asserted by the test (`scripts/tests/no-wholefile-ledger-read.sh:34-37`):

- `manager/skills/next/SKILL.md`
- `manager/agents/project-manager.md`
- `manager/skills/implement/SKILL.md`
- `manager/skills/check/SKILL.md`

**Zero `lsa/` files in the consumer list.** F9 (`features/…/requirements.md:36`) names only manager read-consumers. That is proof the cutover’s enforceable context win is manager-scoped.

---

## 3 · Measured baselines — what LSA already loads

### 3a · Artifact sizes (working tree)

| Artifact | Bytes | ~tokens |
|---|---:|---:|
| `.lsa/roadmap.yaml` (new SoT) | 102,352 | ~25,588 |
| `.lsa/roadmap.md` on `origin/main` (old SoT) | 91,834 | ~22,958 |
| `.lsa/VISION.md` (full constitution) | 32,790 | ~8,197 |
| `.lsa/VISION-digest.md` (mandatory read) | 1,693 | ~423 |
| `project-map.yaml` | 2,193 | ~548 |
| `.lsa.yaml` | 4,107 | ~1,026 |
| `.lsa/features/**` (md+feature) | 368,770 | ~92,192 |
| `.lsa/pitches/**` | 194,403 | ~48,600 |
| `.lsa/archive/**` | 288,022 | ~72,005 |
| This epic feature pack | 11,773 | ~2,943 |

### 3b · Mandatory LSA read floor (every stage via Read protocol)

Per `lsa/knowledge/conventions.md:29-37`:

1. `.lsa.yaml` → ~1,026 tok  
2. VISION-digest (not full VISION) → ~423 tok  
3. project-map as scoping atlas (not a full catalog read) → ≤ ~548 tok if consulted  

**Floor ≈ 1,998 tok** (yaml + digest + map) — **7.8%** of one mistaken whole-file `roadmap.yaml` read (~25,588 tok).

Digest alone vs full VISION: **~19.4× less** (~94.8% cut) — already shipped in pro-tier WS1 (`lsa/CHANGELOG.md:28`; `conventions.md:34`).

### 3c · Manager script slices (for contrast — not LSA load)

| Script | Bytes | ~tokens | Exit |
|---|---:|---:|---:|
| `roadmap-row.sh` | 129 | ~32 | 0 |
| `roadmap-query.sh backlog --limit 5` | 705 | ~176 | 0 |
| `roadmap-query.sh get <slug>` | 282 | ~70 | 0 |
| `roadmap-query.sh hygiene` | 741 | ~185 | 0 |

These feed **manager** surfaces. LSA stages do not call them on the happy path (grep proof in §2a).

---

## 4 · Stage-by-stage impact (today)

| Stage | Δ tokens from cutover | Proof |
|---|---|---|
| **discover** | **0** | Inputs exclude roadmap (`discover/SKILL.md:22-29`); OOS (`requirements.md:50`) |
| **specify** | **0** | Inputs = discover handoff only (`specify/SKILL.md:22-24`) |
| **verify** | **0** (gate may run new C14 — deterministic bash, not model context) | Inputs = spec + codebase + `gate:` (`verify/SKILL.md:22-33`) |
| **delegate** | **0** | Spec package + `paired_verify` (`delegate/SKILL.md:23-31`) |
| **reconcile** | **0** (same gate note as verify) | Diff + spec + `gate:` (`reconcile/SKILL.md:22-33`) |
| **orchestrator** | **0** | Inline discover→specify→verify; no ledger (`orchestrator.md:33,46`) |
| **init** | **0 runtime**; **doc/scaffold debt** | Still creates `roadmap.md` (`init/SKILL.md:30`) while SoT is YAML — deferred (`requirements.md:50`) |
| **revise-constitution** | **0** | Intentionally loads full constitution (`conventions.md:34`) |

### What *does* dominate LSA context (already mitigated)

| Lever | Effect | Status | Source |
|---|---|---|---|
| VISION-digest | ~8.2k → ~0.4k tok | shipped | `conventions.md:34` |
| project-map | dirs-only ≤1k tok atlas | shipped | `conventions.md:37`; `lsa/CHANGELOG.md:23` |
| `gate.sh` one-pass | bash vs model-orchestrated checks | shipped | `verify/SKILL.md:33`; `reconcile/SKILL.md:33` |
| Orchestrator inline | avoid N context reloads | shipped | `orchestrator.md:46`; `.lsa/standards/code.md:57-65` |
| Artifact hand-off | pointer + summary across agents | shipped standard | `.lsa/standards/code.md:67-77` |

---

## 5 · Indirect path — manager → LSA handoff

The cutover **does** shrink context on the path that *feeds* LSA when humans use manager first:

```
manager:next / check / implement-preview  →  (optional) pitch reads  →  lsa:discover
```

| Segment | Before cutover | After cutover | In LSA loop? |
|---|---|---|---|
| Roadmap ambient load | ~22,958 tok whole-file MD | ~32–185 tok script slice | **No** — manager only |
| Pitch bodies per candidate | full pitch per candidate (still) | **unchanged** (ladder OOS) | Indirect — still the dominant fan-out |
| Discover request-scope | request-touched files | unchanged | **Yes** — LSA |

Pitch ladder remains out of scope (`requirements.md:52`). Pitch corpus ≈ **48.6k tok**; Mode 1 still *"For each candidate item, read its linked pitch"* (`manager/agents/project-manager.md` Mode 1). So manager→LSA handoffs get a cheaper roadmap step, but **not** a cheaper pitch fan-out yet.

---

## 6 · Potential if the approach spreads into LSA

Same discipline: *scope → script/query → stdout only → full Read as fallback*.

| Candidate | Corpus | Est. LSA impact | Why |
|---|---:|---|---|
| Active feature pack only | this epic ~2.9k tok vs features corpus ~92k tok (**~31×** over-read if agents pull the whole tree) | **large** | Discover already *intends* request-scope (`discover/SKILL.md:29`); enforcement is soft |
| Pitch-body ladder | ~48.6k tok corpus | **large** on handoff path | Deferred epic `pitch-ladder` |
| Keep archive out of map | ~72k tok | **large if touched** | Map builder already excludes archive (`lsa/CHANGELOG.md:23`) |
| Init → scaffold `roadmap.yaml` | n/a | **correctness**, not tokens | Closes greenfield dual-format debt (`init/SKILL.md:30`) |

**Not a high-value LSA lever:** more roadmap query scripts for discover/verify/reconcile — those stages never ambient-loaded the ledger.

---

## 7 · Risks specific to LSA

| Risk | Severity | Evidence |
|---|---|---|
| Fallback whole-file YAML heavier than old MD | low–med on miss path | 102,352 vs 91,834 B (~+11%); F8 still allows fallthrough (`requirements.md:33`) |
| Stale LSA product docs / init scaffold | med (correctness) | `init/SKILL.md:30`, `lsa/ARCHITECTURE.md:64`, `lsa/README.md:40`, `lsa/CORE.md:94` still say `roadmap.md`; deferred (`requirements.md:50`) |
| Pitch fan-out still dominates Mode 1 | med | Ladder OOS (`requirements.md:52`); pitch corpus ~48.6k tok |
| Awk-only C14 schema gate | low for LSA loop tokens | Deterministic gate cost, not model context |

---

## 8 · Bottom line

| Horizon | LSA performance effect | Confidence |
|---|---|---|
| **Today (this cutover)** | **≈ 0** on discover→specify→verify→delegate→reconcile token floors | **High** — OOS + zero skill load instructions + F9 consumer list + cite-only changelog |
| **Indirect (manager first)** | Roadmap step ~124–328× cheaper; pitches unchanged | **High** — measured manager slices; ladder deferred |
| **Next LSA lever** | Pitch-ladder + enforced feature-pack slicing (~31× headroom vs full features corpus on this epic) | **Medium** — sizes measured; agent over-read rate not instrumented |

**Proved claim for messaging:** the selective-load *approach* is already how LSA reads its constitution and scopes discovery (digest + project-map + `gate.sh`). The YAML roadmap cutover **proves the ledger pattern on manager**; it does **not** rewrite LSA’s loop cost. Spreading the pattern to pitches and feature packs is the LSA-side performance story — tracked as deferred epics, not delivered by `56b6c45`.

---

## Appendix A · Repro commands

```bash
# F9 (manager-only consumers)
bash scripts/tests/no-wholefile-ledger-read.sh

# LSA skill roadmap hits (expect only init scaffold)
rg -n 'roadmap\.(md|yaml)' lsa/skills/*/SKILL.md lsa/agents/orchestrator.md

# Sizes
wc -c .lsa/roadmap.yaml .lsa/VISION.md .lsa/VISION-digest.md project-map.yaml .lsa.yaml
git show origin/main:.lsa/roadmap.md | wc -c

# Script slices
bash scripts/roadmap-row.sh | wc -c
bash scripts/roadmap-query.sh backlog --limit 5 | wc -c
bash scripts/roadmap-query.sh get library-spec-cache-for-top-3-5-libraries | wc -c
bash scripts/roadmap-query.sh hygiene | wc -c
```

## Appendix B · Related artifacts

- Manager measured win: [`manager/CHANGELOG.md`](../../manager/CHANGELOG.md) §`[0.18.0]` *Notes — measured context win*
- Public framing: [`README.md`](../../README.md) §*Scripts do the deterministic work*
- Epic requirements / OOS: [`../features/2026-07-16-yaml-ledger-read-cutover/requirements.md`](../features/2026-07-16-yaml-ledger-read-cutover/requirements.md)
- LSA Read protocol: [`lsa/knowledge/conventions.md`](../../lsa/knowledge/conventions.md) §*Read protocol*
