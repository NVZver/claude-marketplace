# LSA — Living Spec Architecture

> **A technology-agnostic spec layer: ground the spec in your codebase *before* you build, verify the diff *after*. Bring your own coding agent.**

AI coding agents are fast but unanchored — specs live in chat, drift from the codebase, and nobody checks the diff against what was agreed. LSA owns the two ends no coder agent does:

- **`verify` (before)** — every reference in the spec resolves to real code; every flow is buildable. No fantasy specs.
- **`reconcile` (after)** — the returned diff is checked **does · only · all** against the spec, and drift is absorbed. On PASS it also appends a row to `.lsa/metrics.md`.

The agent in the middle is yours: **Claude Code, Cursor, Copilot, or a human.** LSA never writes production code.

> [!NOTE]
> LSA is **not** a coding agent — it's the spec-and-verification layer that wraps one. It adopts industry-standard formats (**EARS** for requirements, **Gherkin** for acceptance) so it interoperates with Spec Kit, Kiro, and Cursor instead of competing with them.

**Contents:** [The loop](#the-loop) · [Quick start](#quick-start) · [How LSA compares](#how-lsa-compares) · [Skills](#skills) · [The two checks](#the-two-checks--the-product) · [Standards](#standards) · [Configuration](#configuration) · [Install](#install)

## The loop

`discover → specify → verify → delegate → reconcile`, driven by the `orchestrator`. Ceremony scales to weight — a typo skips the spec; a new feature runs the full spine.

```mermaid
flowchart TD
    you([you]) --> orch[orchestrator<br/>drives the loop]
    subgraph lsa["LSA — you own this · technology-agnostic"]
        direction LR
        d["① discover<br/>intent + facts"] --> s["② specify<br/>EARS + Gherkin"]
        s --> v["③ verify ✓ GROUNDED<br/>BEFORE — refs resolve? buildable?"]
        rec["⑤ reconcile ✓ PASS<br/>AFTER — does · only · all<br/>→ conformance.md"]
    end
    orch -.-> d
    v -->|"④ delegate — spec + .feature"| agent[["YOUR coding agent<br/>Claude · Cursor · Copilot · human"]]
    agent -->|returns a diff| rec
    rec -.->|"drift → spec absorbs reality"| s
```

**A run, end to end:**

```text
> /lsa:discover "add a /status command that lists in-flight features"
[discover] intent + facts — roadmap.yaml exists @ .lsa/roadmap.yaml; one read-only flow.

> /lsa:specify
[specify] F1 (EARS): WHEN status runs, the system SHALL print in-flight features.
          status.feature: Given the roadmap has in-flight rows / When status runs / Then a table is printed.

> /lsa:verify                         ← the BEFORE check (ground vs codebase)
[verify] GROUNDED — roadmap reader exists @ src/roadmap.ts:12; flow buildable.

> /lsa:delegate                       ← hand off to YOUR agent
[delegate] spec + status.feature → your implementer. Awaiting the diff…

> /lsa:reconcile                      ← the AFTER check (does · only · all)
[reconcile] does ✓ 5/5 runs · only ✓ hunks trace to F1 · all ✓ F1 covered
            → PASS + conformance.md
```

## Quick start

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/plugin install lsa@NVZver
```

1. **Initialize** — `/lsa:init` scaffolds the spec tree (greenfield or brownfield), including an empty **`roadmap.yaml`** ledger (never `roadmap.md`). Migrating an old markdown roadmap: [`knowledge/migration-instructions-ai.md`](./knowledge/migration-instructions-ai.md).
2. **Discover** — `/lsa:discover "<what you want>"` extracts intent + gathers codebase facts.
3. **Specify** — `/lsa:specify` drafts EARS requirements + Gherkin `.feature` scenarios, shows you the full draft, and writes the files only after you approve (since v0.17.0).
4. **Verify** — `/lsa:verify` grounds the spec against your codebase; fix anything `NOT-GROUNDED` before building.
5. **Delegate** — `/lsa:delegate` hands the spec to your coding agent.
6. **Reconcile** — `/lsa:reconcile` checks the returned diff **does · only · all** and writes `conformance.md`; on a PASS verdict it also writes a `.lsa/metrics.md` row.

> [!TIP]
> You don't have to run the steps by hand — talk to the `orchestrator` and it drives the whole loop, resolving each step's inputs via `discover`.

## How LSA compares

LSA deliberately does **less** than a full SDD toolkit — it owns the two grounding checks and delegates everything else, so it layers *on top of* the others rather than replacing them.

| | **LSA** | Spec Kit | OpenSpec | Kiro |
|---|---|---|---|---|
| Writes the code | ✗ — bring any agent | ✓ orchestrates | via your agent | ✓ (AWS IDE) |
| Tool-agnostic | ✓ | ✓ | ✓ | ✗ |
| Grounds the spec in the codebase *before* build | ✓ `verify` | — | — | partial |
| Verifies the diff vs the spec *after* (does · only · all) | ✓ `reconcile` (blocking) | — | `/opsx:verify` — non-blocking, no hunk trace | — |
| Permanent, drift-absorbing spec | ✓ | branch-per-change | ✓ living `specs/` (delta-merge) | ✓ |
| Formats | EARS + Gherkin | spec / plan / tasks | change proposals | EARS |

*LSA's read of the landscape — see [Spec Kit](https://github.com/github/spec-kit), [OpenSpec](https://github.com/Fission-AI/OpenSpec), [Kiro](https://kiro.dev). You can run LSA's `verify` / `reconcile` on top of any of them.*

OpenSpec is the closest neighbour: it ships an after-the-fact `/opsx:verify` and a living `specs/` set merged via deltas, so it is no more drift-prone than LSA. LSA's edge is narrower and specific — `reconcile` is a **blocking PASS gate** (`/opsx:verify` "won't block archive, but it surfaces issues"), its `only` check maps **every changed hunk to a requirement**, and its `does` check runs each Gherkin scenario **N times for ≥95%** (N = 3 by default — all 3 runs must pass). OpenSpec's verify is single-pass and non-blocking with no hunk→requirement trace.

## Skills

| Skill | Purpose |
|---|---|
| **`discover`** | Extract user intent and gather the codebase facts the spec rests on — consulting the script-generated project map ([`project-map.yaml`](../project-map.yaml), 3-level directory tree) to scope reads before walking the tree. Also the universal input-resolver other skills call. |
| **`specify`** | Draft the grounded spec — EARS requirements, user flows, and Gherkin `.feature` scenarios — show it in full, then write the files only on approval (show → approve → write). |
| **`verify`** | **Before** delegating: ground the spec against the codebase, and run the `.lsa.yaml` `gate:` block — citing each command + exit code (a non-zero gate blocks `GROUNDED`). Step 1 resolves the model-identified symbols via `scripts/resolve-refs.sh` (per-symbol `exists @ file:line` / `new` / `MISSING` / `OUT-OF-RANGE`) instead of multi-round `Grep`; the model still identifies which symbols the spec names and owns the `GROUNDED` verdict. Output: `GROUNDED` / `NOT-GROUNDED` + `grounding.md`. |
| **`delegate`** | Hand the grounded spec + `.feature` files to your implementer; collect the returned diff. Code-writing happens outside LSA. Optionally gates the build **per-increment** via `.lsa.yaml paired_verify` — `off` (default, unchanged), `checkpoint` (inject a pause+signal protocol and dispatch `observer:verify-checkpoint` after each plan task; CLEAR auto-proceeds, BLOCK surfaces), or `async` (not yet implemented — errors). |
| **`reconcile`** | **After** the diff returns: check it **does · only · all** — each Gherkin scenario run **3 times** by default (`.lsa.yaml` `reconcile.runs`; pass at the default = all 3 runs) — and write `conformance.md` around a **requirement ↔ hunk coverage table** (one row per requirement ID × the hunks that implement it × the runs that prove it × verdict; orphan hunks are drift), then absorb drift. Step 4 first runs `scripts/coverage-skeleton.sh` to enumerate the table's two axes deterministically (requirement rows × candidate hunks); the grader fills only the semantic mapping and reads off orphans / uncovered. The `.lsa.yaml` `gate:` block is required input — a repo with no `gate:` block gets an explicit `NOT-RUNNABLE` gate status, never a silent skip. On a PASS verdict, also runs `scripts/metrics-harvest.sh` against that `conformance.md` and appends one descriptive row to `.lsa/metrics.md` (never on FAIL; never changes the verdict). Runs as the **independent grader** — a context with no write access to the tests, `.feature` scenarios, or `.lsa.yaml` `gate:` it judges (the work cannot edit its own grader). Also surfaced by the SessionStart drift hook. |
| **`init`** | Initialize LSA on a project (greenfield or brownfield). Greenfield scaffolds **`roadmap.yaml`** (empty YAML ledger) — never `roadmap.md`. Existing markdown roadmaps: follow [`knowledge/migration-instructions-ai.md`](./knowledge/migration-instructions-ai.md). |
| **`revise-constitution`** | Promote a finished feature's lessons into permanent constitution / standards rules. |

Plus the **`orchestrator`** agent — the entry point that drives the loop. Since v0.21.0 it runs the spec-authoring stages (`discover` → `specify` → `verify`) **inline in one context**, reusing accumulated facts instead of re-reading, and crosses a context boundary only at `delegate` (the external implementer) and `reconcile` (an independent grader) — one context floor and one file-read pass instead of one per stage, so a full cycle stays affordable on the Pro-tier model (see [`.lsa/standards/code.md`](../.lsa/standards/code.md) §"Model policy"). Since v0.17.0 it surfaces every sub-agent's output to you verbatim before any gate (a sub-agent transcript is invisible to the human), and returns pending gates instead of attempting pickers when it runs as a subagent itself. See [`CORE.md`](./CORE.md) for the one-page contract every skill follows.

## The two checks — the product

Everything else is table stakes; these two are why LSA exists.

**`verify` — before you build (grounding).** Every module / function / type the spec names resolves to real code (cited `file:line`) or is explicitly `new`; every flow is buildable. An ungrounded spec is **blocked** — you never delegate a fantasy.

**`reconcile` — after the diff returns (correctness).** Three questions:
- **does** — every Gherkin scenario passes, run **3 times** by default (`.lsa.yaml` `reconcile.runs`; agents are stochastic; ≥95% — at the default, all 3 runs must pass).
- **only** — every changed hunk traces to a requirement (no scope creep).
- **all** — every requirement maps to a change or a covering test (nothing skipped).

Output is `conformance.md` — a **requirement ↔ hunk coverage table**, in substance a requirements traceability matrix (RTM; see §Standards): one row per requirement ID mapping the diff hunks that implement it, the scenario runs that prove it, and a verdict — *what actually changed vs. the plan*, with orphan hunks (in the diff, in no row) surfaced as drift. Drift → the spec absorbs reality; the code is never reverted.

## Standards

LSA adopts industry standards rather than inventing formats — **EARS** ("While `<state>` / when `<event>`, the system shall …") for requirements, and **Gherkin** (`Given / When / Then`, from [Specification by Example](https://gojko.net/books/specification-by-example/)) for acceptance scenarios. Authored tech-agnostically; your implementer wires execution.

`reconcile`'s `conformance.md` coverage table is, in substance, a **requirements traceability matrix (RTM)** — the conventional instrument for demonstrating the traceability property IEEE 830-1998 and its successor ISO/IEC/IEEE 29148 require of an SRS. `[unverified]` — both standards are paywalled and were not read directly; cited by name/number/year only. The claim is the practice, not conformance: LSA has been audited against neither standard.

## Configuration

<details>
<summary><code>.lsa.yaml</code> schema (optional — sensible defaults when absent)</summary>

```yaml
constitution: .lsa/VISION.md         # default: .lsa/VISION.md
specs_root: .lsa/                    # default: .lsa/
mode: docs                           # docs | code | mixed. default: code

modules:
  lsa:
    spec: .lsa/modules/lsa/spec.md
    artifact_paths:
      - lsa/skills/**/SKILL.md
      - lsa/hooks/**/*

gate:                                # optional — quality-gate script contract
  test: <command>                    # check name → command; passes iff exit 0, cited as the gate artifact

reconcile:
  runs: 3                            # optional — scenario-run count N for reconcile's "does" check. default: 3 (pass at 3 = all 3 runs; at a larger N = ≥95% of runs)

autonomy: manual                     # optional — manual | semi | auto. default: manual
paired_verify: off                   # optional — off | checkpoint | async. default: off

routing:                             # optional — per-dispatch model tier map. absent ⇒ inherit everywhere
  manager:next: sonnet               # surface-key → tier (inherit | sonnet | haiku)
```

The optional `gate:` block is the **quality-gate script contract** — per-check name → command, consumed by both `verify` (before — grounding) and `reconcile` (after — correctness), and mapped to GitHub required-check slots in parallel runs. It is the configuration side of `core/ground-rules` Rule 7 *"done is a gate-proven, cited predicate"*; LSA hardcodes no tool. This repo's own `gate:` (a `mode: docs` example) runs three repo-internal structural probes — `docs-invariants` (`scripts/lint.sh`), `citations` (`scripts/check-citations.sh`), `links` (`scripts/check-links.sh`). Full contract: [`knowledge/quality-gate-contract.md`](./knowledge/quality-gate-contract.md).

The optional `reconcile.runs` knob sets N for `reconcile`'s *does* check — default **3** when absent (pass = all 3 runs succeed); raise it for high-stakes epics, where pass = ≥95% of runs. Note that `reconcile` treats the `gate:` block itself as required input: when a repo defines none, it reports an explicit `NOT-RUNNABLE` gate status instead of silently skipping the gate step.

The optional `autonomy:` knob (`manual | semi | auto`, default `manual`) sets how much human-in-the-loop a parallel `manager:implement` run uses at the merge boundary — `manual` = human merges, `semi` = auto-merge on green, `auto` = + deploy + healthcheck. The gate is identical at every level. Semantics: `manager/knowledge/autonomy-policy.md`.

The optional `paired_verify:` knob (`off | checkpoint | async`, default `off`) controls whether `delegate` gates the build increment-by-increment. `off` reproduces today's delegation exactly. `checkpoint` injects a pause+signal protocol — after each plan task the implementer writes a checkpoint-signal note (`target`/`since`/`spec`/`status`) and stops, and `delegate` dispatches [`observer:verify-checkpoint`](../observer/skills/verify-checkpoint/SKILL.md) to grade the increment (CLEAR auto-proceeds with no human interrupt; BLOCK surfaces before the next task). The per-increment verifier is independent and read-only; the final whole-diff `reconcile` still runs. `async` (concurrent-interrupt) is **not yet implemented** — `delegate` errors rather than degrading. For a non-agent implementer the pause-protocol is advisory. See [`ARCHITECTURE.md`](./ARCHITECTURE.md) §3.

The optional `routing:` map sets which model each Agent-dispatch surface runs on (Pro-tier affordability — cheapest capable tier per dispatch). Keys are dispatch surface-keys (`manager:check`, `lsa:delegate.verify-checkpoint`, …); values are `inherit | sonnet | haiku`. Read at dispatch time — **zero `model:` pins ship in any plugin frontmatter**. An absent key, or a model the active plan lacks, degrades to `inherit` (never a hard error); the `lsa:reconcile` grader, the `lsa:delegate` implementer, and the `manager:implement` fan-out are **floored** and never route below `inherit`. Full contract + the per-dispatch tier table: [`knowledge/model-routing.md`](./knowledge/model-routing.md).

When `.lsa.yaml` is absent, LSA applies the defaults documented in [`knowledge/conventions.md`](./knowledge/conventions.md) §"`.lsa.yaml` defaults": `constitution: .lsa/VISION.md`, `specs_root: .lsa/`, `mode: code`, `modules: {}`. The workspace lives entirely under `.lsa/` so you can `rm -rf .lsa/` to fully detach. See [`ARCHITECTURE.md`](./ARCHITECTURE.md) §3 for the full schema.

A SessionStart drift hook compares each module's `artifact_paths` against the baseline SHA (the last commit that modified the module's spec) and surfaces a one-line notice pointing at `/lsa:reconcile`.
</details>

## Install

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver         # required dependency
/plugin install lsa@NVZver
/reload-plugins
```

LSA depends on [`core`](../core/) for fact-grounding discipline ([`core/ground-rules`](../core/skills/ground-rules/SKILL.md)); Claude Code auto-installs it. Invoke skills directly via `/lsa:discover`, `/lsa:specify`, `/lsa:verify`, `/lsa:delegate`, `/lsa:reconcile`, or let Claude trigger by description match.

> [!IMPORTANT]
> LSA writes spec files to disk and reads `/CLAUDE.md` — it needs a filesystem. Use it in Claude Code (or any filesystem-backed agent), not the web app.

### Security & least privilege

The `orchestrator` agent carries no `Write` / `Edit` / `Bash` tools — only `Read, Grep, Glob, Agent, AskUserQuestion` ([`agents/orchestrator.md`](./agents/orchestrator.md) frontmatter `tools:`). LSA delegates all code-writing to an external implementer, so its autonomous write surface is bounded to spec files. Gates are advisory, not coercive — Level 2.5 lets the developer edit code and absorbs the drift rather than forbidding it ([`.lsa/VISION.md`](../.lsa/VISION.md) §7 decision 1, *"RESOLVED: Level 2.5"*). For the full threat model, see [`SECURITY.md`](../SECURITY.md).

---

> *"LSA doesn't automate your thinking — it makes you own it."*

Every gate is a decision asked of the human with explicit consequences; every artifact traces to a human-owned requirement; every reconcile keeps the human in the loop. See [`../core/skills/ground-rules/SKILL.md`](../core/skills/ground-rules/SKILL.md) Rule 0 (Ownership over automation).
