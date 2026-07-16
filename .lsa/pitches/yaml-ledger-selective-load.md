Shaped by: product-manager (agentic-systems PM)
Date: 2026-07-15
Status: approved
Why now: pro-tier WS1–WS3 shipped the floor/atlas/one-row extractor (`.lsa/roadmap.md:71`) but Mode 1 still whole-file-loads the ~92KB markdown roadmap (`manager/agents/project-manager.md:37-41`); hard rule is load into context only what is relevant right now.

# YAML ledger selective load

AI-primary roadmap becomes a YAML ledger; Manager (then LSA consumers) load it only via project-map scope → query script → relevant slice, with whole-file Read as fallback only. Extends shipped pro-tier patterns; does not invent a parallel indexing stack.

## Problem

Agents and skills that need roadmap state still pull far more into context than the current question requires.

Evidence:

- Roadmap today is `.lsa/roadmap.md` — **378 lines / ~91,834 bytes** of markdown tables (`wc` 2026-07-15).
- Manager Mode 1 reads the whole roadmap, then candidate pitches, then `features/*` (`manager/agents/project-manager.md:37-41`: *"Read roadmap… Read pitches… Read … `${specs_root}/features/*/`"*).
- A narrow fast-path already exists: `scripts/roadmap-row.sh` extracts the first backlog row with **zero model tokens** (`scripts/roadmap-row.sh:4-8`; wired in `manager/skills/next/SKILL.md:24`).
- LSA already practices progressive loading: VISION-digest, dirs-only `project-map.yaml`, Read protocol (`lsa/knowledge/conventions.md:29-37`).
- Standard already written: *"Artifact hand-off — pointer + summary, not full payload"* (`.lsa/standards/code.md:67-79`) — Manager shaping/roadmap agents called out as deliberate follow-on (`:79`).
- Parent affordability work shipped 2026-07-15 (`.lsa/roadmap.md:71`, pitch `.lsa/pitches/pro-tier-token-affordability.md`) — this pitch is **WS3 incomplete for Mode 1**, not a greenfield product.

Hard rule (owner intent): **load into context ONLY what is relevant right now.** Roadmap (and similar ledgers) are AI-primary / human-occasional, so a strict machine format is welcome; scripting is welcome.

Current workaround: Mode 0 / `roadmap-row.sh` for plain "what's next"; everything else pays the full markdown table (+ pitches + features) into context. Humans skim huge MD tables that agents parse poorly.

Definition of success:

1. Happy-path Manager roadmap reads never whole-file-Read the ledger unless the script path fails or the task explicitly needs the full ledger.
2. Load path is observable in skill steps: project-map scopes → script emits the relevant slice → model reads that slice (or a pointer+summary).
3. Mode 1 does not load full pitch bodies for every candidate — only paths/summaries until pick / top-K.
4. Consumers (`manager:next` Mode 0/1, `manager:check`, sequencing heuristics, serialized-merge ledger writers) speak the new format without silently falling back to full-file as the happy path.
5. YAML schema is lint-gated; a broken ledger fails deterministically.

## Appetite

Small-to-medium batch. One ledger vertical (roadmap) proves the pattern end-to-end: YAML SoT + query/load scripts + consumer rewire for manager roadmap reads + Mode 1 pitch ladder + lint/gate for format freshness.

**In appetite (required for the hard rule):** Mode 1 pitch-body ladder (path + one-liner → full pitch only for top-K / selected) — validation showed roadmap YAML alone is insufficient if every candidate pitch is still fully read (`project-manager.md:39`).

**Out of appetite:** converting every shared ledger in one go; redesigning pitch files as YAML; shipping the pending manager inline-dispatch work (`.lsa/roadmap.md:62`); rewriting the artifact-handoff *return* path beyond what selective *input* load requires; inventing a new indexing product alongside project-map.

**Minimal-core note (from triple validation):** the hard rule is solved by the load protocol + scripts + pitch ladder; YAML is the approved SoT (AI-primary, script-native), not a substitute for stopping whole-file Read. Shipping YAML without consumer rewire yields no context win.

## Solution sketch

### Format (SoT)

`${specs_root}/roadmap.yaml` replaces `${specs_root}/roadmap.md` as the only SoT. Migration is one-shot (MD table → YAML); delete the MD SoT in the same ship — no dual SoT.

Illustrative schema (discover may refine field names; shape is fixed):

```yaml
version: 1
items:
  - slug: library-spec-cache
    title: Library-spec cache
    priority: Could          # Must | Should | Could
    status: backlog          # backlog | not_started | in_progress | shipped | deferred
    pitch: pitches/library-spec-cache.md   # optional path under specs_root
    notes: ""                # short; long narrative stays in the pitch
    # optional: depends_on: [other-slug]
shipped_history: []          # former "Recently merged" — optional, not loaded by default
```

Occasional human read: raw YAML or `scripts/roadmap-print.sh` (pretty table to stdout — not a second SoT).

### Load protocol (hard rule)

Named in Manager skills/agents (and cited from LSA conventions as the ledger variant of the Read protocol):

1. **Scope** — resolve `specs_root` from `.lsa.yaml`; consult `project-map.yaml` for `.lsa/`, `pitches/`, `features/` presence before walking (`lsa/knowledge/conventions.md:37`). Project-map is directories-only — it locates *where*, not *which rows*.
2. **Query** — run a roadmap script with an intent-specific query. Model reads **stdout only**.
3. **Ladder** — from script rows, open linked pitch/feature bodies only as required (summary → full).
4. **Fallback** — if script exits non-zero or query unsupported, `Read` the whole YAML once and note fall-through (same contract as `roadmap-row.sh` F7 in `.lsa/features/pro-tier-token-affordability/script-offload/requirements.md`).

```text
specs_root / project-map  →  locate ledger + related dirs
roadmap query script      →  emit relevant rows (or path:line slices)
Read ONLY script output   →  then optional pitch/feature bodies by ladder
full-file Read            →  fallback only (script miss / explicit full-ledger task)
```

### Script surface (extend `roadmap-row.sh`, do not fork a new stack)

Repo-internal bash (same class as pro-tier WS3 — outside plugin `artifact_paths` unless later shipped):

| Command | Emits (to context) | Used by |
|---|---|---|
| `roadmap-row.sh` (migrate to YAML) | first backlog row + path:line | `manager:next` Mode 0 |
| `roadmap-query.sh backlog --limit N --fields slug,priority,status,pitch` | N rows | Mode 1 / implement preview |
| `roadmap-query.sh get <slug>` | one record | decompose / status updates |
| `roadmap-query.sh hygiene` | deterministic mismatch hints (missing pitch path, etc.) | `manager:check` |
| `roadmap-print.sh` | human pretty-print | occasional human |

Zero model tokens on the happy path. Exit non-zero → fallback.

### Consumer rewire

- `project-manager` Mode 0/1/1b: replace “Read roadmap.md” with query calls; Mode 1 pitch step becomes “for each candidate: path + title from YAML; full pitch only for top-K or selected.”
- `manager:implement` preview: `--limit 5` query (already wants ~5 backlog rows).
- `sequencing-heuristics.md`, `serialized-merge.md`, and `core/knowledge/fast-path-source-of-truth.md`: path/format update.
- Lint: schema check (version + required keys) in `scripts/lint.sh` or a dedicated checker on the `.lsa.yaml` `gate:` block.

### Critical path

Migrate content → YAML SoT → scripts speak YAML → `manager:next` Step 0 still zero-token → Mode 1 / `check` use queries + pitch ladder → delete MD → cite-sweep → gate green.

### Key user interactions

Ask "what's next" / "sequence the backlog" / "check roadmap" and receive answers grounded in a **script-selected slice** — not a 90KB table dump. Occasional humans read YAML (or pretty-print); no parallel MD novel.

### Main components

1. `${specs_root}/roadmap.yaml` (SoT) + one-shot migrator; delete `roadmap.md` in the same ship.
2. Query/print scripts extending the `roadmap-row.sh` contract.
3. Manager agent/skill load-protocol rewire + Mode 1 pitch ladder.
4. Schema/format gate so a broken ledger fails deterministically.

## Rabbit holes

1. **Consumer blast radius** — dozens of `roadmap.md` string refs across manager + serialized-merge + pitches. Mitigation: one epic owns a cite-sweep + tests that assert no happy-path whole-file Read of the ledger; keep migration script one-shot and delete MD SoT in the same ship.
2. **Parallel-merge / shared-ledger lock** — `serialized-merge.md` names `${specs_root}/roadmap.md` as a shared ledger. Mitigation: update the lock contract to the new path/format; do not change who may write (still merge-step only).
3. **Mode 1 pitch fan-out** — even with a slim roadmap slice, reading every candidate pitch can re-blow context (`project-manager.md:39`). Mitigation: load pitch **paths + one-line summaries** first; full pitch only for the top-ranked / user-selected item (composes with artifact-handoff standard `.lsa/standards/code.md:67-75`). **In appetite** — not a follow-on footnote.
4. **Human muscle memory** — occasional humans lose markdown tables. Mitigation: YAML is the SoT; optional `scripts/roadmap-print.sh` for terminal pretty-print — no second SoT.
5. **Confusing this with inline-dispatch** — `.lsa/roadmap.md:62` is about *when* to spawn agents; this pitch is about *what* enters context. Mitigation: No-go below; cross-link only.
6. **YAML without rewire** — format change alone does not stop whole-file Read. Mitigation: definition of success #1–#3; critical path orders scripts + consumer rewire with the migrate, not after.

## No-gos

1. This pitch does NOT keep markdown tables as source-of-truth with a sidecar index — dual-write and sync debt.
2. This pitch does NOT convert CHANGELOG / `plugin.json` / other shared ledgers in the same batch — pattern is documented for reuse; conversion is follow-on.
3. This pitch does NOT own manager shape/decompose/next/check **inline-dispatch** rollout (`.lsa/roadmap.md:62`) — orthogonal token lever.
4. This pitch does NOT replace pitches or feature specs with YAML — ledgers only (status/priority/sequencing records), not narrative shaping artifacts.
5. This pitch does NOT make whole-file Read the default “just in case” — fallback only, per owner hard rule.
6. This pitch does NOT invent a new indexing product — compose project-map + query scripts + digest/handoff patterns only (reuse pro-tier WS2/WS3).
