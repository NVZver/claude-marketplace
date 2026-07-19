# Takeover prompt — marketplace AI-engineering audit remediation

Copy everything below the line into a new agent/session.

---

## Mission

Continue remediation planning and implementation for the NVZver `claude-marketplace` AI-engineering audit. Prior work **audited, saved, critiqued, and roadmapped**. Do **not** re-audit the whole marketplace from scratch. Do **not** impress with new architecture. Ship predictable, measured, product-useful improvements.

**Repo:** `/Users/nvz/github/claude-marketplace`  
**Primary feature pack:** `.lsa/features/marketplace-ai-engineering-audit/`  
**Roadmap slug (next Must after current work):** `marketplace-ai-engineering-audit`  
**Current in-flight work (finish or coordinate first):** `deterministic-work-scripted` on branch `feature/deterministic-work-scripted`

## Read these files first (in order)

1. `.lsa/features/marketplace-ai-engineering-audit/critique.md` — **authoritative correction** of the original ranking  
2. `.lsa/features/marketplace-ai-engineering-audit/report.md` — frozen findings (as-audited)  
3. `.lsa/features/marketplace-ai-engineering-audit/discover.md` — file:line quotes + suggested improvements F01–F10  
4. `.lsa/features/marketplace-ai-engineering-audit/requirements.md` + `grounding.md`  
5. `.lsa/roadmap.yaml` entries: `deterministic-work-scripted`, `marketplace-ai-engineering-audit`, `cursor-equal-support`

Optional twin (visual): workspace canvas  
`/Users/nvz/.cursor/projects/Users-nvz-github-claude-marketplace/canvases/marketplace-ai-engineering-audit.canvas.tsx`

## Hard constraints

- Follow LSA + core discipline: fact-grounding (source + searchable quote), flow-selector before non-trivial work, no scope creep.
- Prefer scripts for deterministic work (VISION principle 10). Models keep semantic judgment only.
- **Do not implement the original P0 stack blindly.** The critique demoted/killed several “clever” items.
- Distinguish **measured** token wins (bytes÷4 observations) from **estimates**.
- Per-plugin SemVer + CHANGELOG + README when shipping user-visible plugin changes.
- Push/commit only if the human asks.
- Consumer install path matters: prefer `${CLAUDE_PLUGIN_ROOT}` for shipped helpers; root `scripts/` often says `NOT shipped`.

## Authoritative priority (from critique — use this, not report.md’s original order)

| Rank | Work | Notes |
|---|---|---|
| 1 | **Pitch outline script + Mode 1 wiring** (old F06) | Only large remaining *measured* manager fan-out (~48.6k tok pitch corpus; Mode 1 full-reads). |
| 2 | **Inline manager shape/decompose/next/check** (old F07) | Standard already requires inline unless isolation is load-bearing (`.lsa/standards/code.md`). Benchmark = Agent dispatch count. |
| 3 | **Silence/trace exemption** (thin F03) | Real collision: hard trace vs verify-checkpoint zero-output. **No evidence ledger.** |
| 4 | **Ship roadmap helpers under manager** (narrow F01) | `roadmap-row.sh` / `roadmap-query.sh` via `CLAUDE_PLUGIN_ROOT`; root shim OK. |
| 5 | **product-manager pointer+summary hand-off** (thin F05) | Match existing `.lsa/standards/code.md` artifact hand-off; **no JSON Schema religion.** |
| 6 | Finish in-flight **coverage-skeleton** epic; optional prompt-lint extract | Do **not** re-pitch F08. |
| Extra | **Must-aware `roadmap-row.sh`** | Missed by audit: fast-path can return a Could while Must items exist. |

### Kill / defer unless human overrides

- **F02 Prompt ABI compiler** — architecture theater until session metrics exist  
- **F09 capability-class routing** — after F07 + dispatch logs only  
- **F10 cross-tier eval lab** — keep light Sonnet dogfood probes; no dual-tier research program  
- **Evidence ledger with stable IDs** — toxic indirection; skip  
- **Feature-pack resolver** — only after measuring actual over-read rate (~31× is headroom, not measured miss rate)

## 2-week ruthless cut (default execution plan)

**Week 1**
1. `scripts/pitch-query.sh outline` (or `manager/scripts/…`) + Mode 1 change in `manager/agents/project-manager.md` + wiring test mirroring `scripts/tests/no-wholefile-ledger-read.sh`.  
2. Trace/silence exemption in `core/skills/output` + `observer/skills/verify-checkpoint` (+ fix Example Output that violates silence).  
3. `product-manager` writes pitch to scratch/path and returns pointer + pending_gates (dispatcher still gates/writes on approve).

**Week 2**
4. Inline smallest manager surfaces first (`check`, then `next` non-fast-path); keep implement/reconcile/delegate boundaries.  
5. Must-aware ordering in `roadmap-row.sh` (Must → Should → Could).  
6. Dogfood log for one canonical flow: approx file-bytes Read + Agent dispatch count (shape → decompose → discover).

Success criteria (falsifiable):
- Mode 1 with 5 candidates loads ≪ full pitch corpus (target order-of-magnitude: outlines only until pick).  
- shape→decompose→discover Agent dispatches → 0 before implementation.  
- no-signal verify-checkpoint cycle → zero user-facing bytes.  
- fast-path “what’s next” never returns Could while a Must backlog item exists.

## Key evidence anchors (do not re-derive)

| Claim | Cite |
|---|---|
| Roadmap scripts NOT shipped | `scripts/roadmap-query.sh:6`, `scripts/roadmap-row.sh:12` |
| Manager requires root scripts | `manager/skills/next/SKILL.md:24` |
| Manager package is `./manager` only | `.claude-plugin/marketplace.json:17-18` |
| Pitch full-read Mode 1 | `manager/agents/project-manager.md:39` |
| Pitch corpus ~48.6k tok | `.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md:155` |
| Feature over-read is “if”, not measured rate | same observation `:165` |
| Inline standard | `.lsa/standards/code.md:57-65` |
| Manager still dispatches shape | `manager/skills/shape/SKILL.md:26` |
| Trace hard | `core/skills/output/SKILL.md:26` |
| Silence zero-output | `observer/skills/verify-checkpoint/SKILL.md:54` |
| Full pitch in payload | `manager/agents/product-manager.md:33` |
| Pointer+summary standard | `.lsa/standards/code.md:69` |
| Coverage skeleton already wired (branch) | `lsa/skills/reconcile/SKILL.md:36` |

## Coordination with in-flight branch work

Branch `feature/deterministic-work-scripted` already contains / is landing:
- `scripts/coverage-skeleton.sh` + reconcile Step 4 wiring  
- possibly `cursor-equal-support` generator work  
- audit prep files under `.lsa/features/marketplace-ai-engineering-audit/`

Before starting audit remediation:
1. Check `git status` / branch tip.  
2. Do not duplicate coverage-skeleton.  
3. Prefer a **new branch** for audit remediation off updated main/deterministic work, unless the human says to continue on the same branch.  
4. Roadmap says: do not start audit remediation until `deterministic-work-scripted` lands or the human explicitly yields.

## How to work

1. Run `core/flow-selector` for the unit you pick; wait for human confirm.  
2. Implement **one** ranked unit at a time (LSA discover→specify→verify→delegate→reconcile when non-trivial).  
3. After each unit: show changes inline; run `bash scripts/gate.sh`; record dogfood metric if applicable.  
4. Update roadmap row status when a unit ships (`marketplace-ai-engineering-audit` notes can track sub-progress).  
5. If you disagree with the critique ranking, **argue with citations and ask the human** — do not silently restore F02/F09/F10 as P0.

## Out of scope unless asked

- Re-running a full five-plugin audit  
- Building Prompt ABI / evidence ledger / capability router / cross-tier lab  
- Rewriting VISION for the sake of vocabulary  
- Parallel `manager:implement` of the entire F01–F10 list  

## First message suggestion for the new model

> Read `.lsa/features/marketplace-ai-engineering-audit/TAKEOVER.md` and `critique.md`. Confirm branch state vs `deterministic-work-scripted`. Propose the first remediation unit from the critique ranking (likely pitch-outline + Mode 1), with flow-selector recommendation, then wait for my confirm before editing.
