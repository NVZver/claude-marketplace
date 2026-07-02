# Conformance — paired-verify/lsa-delegate-wiring (epics 2 + 3, combined)

**Verdict: `reconcile: PASS @ 4bc6fb7`**

Independent grader (did not author the impl). Graded the full delta `c473f01..4bc6fb7`
against `requirements.md` (G1–G16), `delegate-paired-verify.feature` (9 scenarios), and the
D1–D9 probes in `delegate-paired-verify-scenarios.md`. Covers epic 2 (delegate wiring, `59ddaa5`),
epic 3 (observer 0.2.1 harmonization, `8160554`), and the citation fix (`4bc6fb7`). Markdown-only
plugins — no code / no test runner; "does it work" is reasoned over the two SKILL prose surfaces and
the eval probes (`lsa:reconcile` execution-as-reasoning model, `lsa/skills/reconcile/SKILL.md:32`).

## CRITICAL RE-CHECK A — interlock survived the path addition

The four contract fields the WRITER (`delegate` Step 4 table, `lsa/skills/delegate/SKILL.md:51-56`)
instructs the implementer to write vs. the fields the READER
(`observer/skills/verify-checkpoint/SKILL.md:30-33`) reads:

| Field | Writer (delegate Step 4) | Reader (verify-checkpoint :30-33) | Match |
|---|---|---|---|
| `target` | F-id just completed (e.g. `F-K`), matching id in `requirements.md` | F-id the increment claims to complete, matching id in `requirements.md` | ✅ exact |
| `since` | previous checkpoint marker (commit SHA / change cursor / timestamp) bounding the increment | previous checkpoint marker (commit SHA, change cursor, timestamp) bounding changes | ✅ exact |
| `spec` | path to spec dir (`requirements.md` + `<flow>.feature` scenarios) | path to spec dir — `requirements.md` + `<flow>.feature` scenarios | ✅ exact |
| `status` | pause marker meaning "stopped, awaiting a verdict" | pause marker meaning "implementer stopped, awaiting a verdict" | ✅ exact |

**Interlock result: PASS.** Exactly four fields on both sides — `target`/`since`/`spec`/`status` —
byte-identical field names, same meanings; none missing / extra / renamed. The note-PATH was ADDED
**alongside** as prose on both sides (delegate Step 4 preamble + Constraints; verify-checkpoint
contract §:37), not as a fifth field and not replacing any field. Both sides describe the path
identically: **delegate-owned**, **ephemeral** (scratchpad / gitignored), **not committed**, passed
as the SAME path to writer and reader. The path locates the note; the four fields are its contents.

## CRITICAL RE-CHECK B — citation scan (no stale `:15-28`)

Worktree grep `verify-checkpoint/SKILL.md:15-28`:

| Occurrence | Surface | Verdict |
|---|---|---|
| `conformance.md:30` (prior grade of `59ddaa5`) | point-in-time record — the ONLY acceptable location | ✅ (superseded: this overwrite removes it) |

No `:15-28` on any LIVE surface (delegate SKILL, ARCHITECTURE, lsa/observer CHANGELOG, lsa/observer
README, observer module spec) and none in requirements / grounding / feature / scenarios. The stale
citation that `59ddaa5` carried in `delegate/SKILL.md` was corrected to `:22-37` in `4bc6fb7`.

`:22-37` resolves to the contract section: line 22 = `## The checkpoint-signal contract` (heading),
field table at 30-33, section ends at line 37 (last content line before `## Goal` at 39). All seven
live `:22-37` occurrences (requirements ×2, scenarios ×3, grounding ×1 → spec surfaces; ARCHITECTURE,
lsa CHANGELOG, delegate SKILL → live surfaces) point at the contract section. **Citation-scan result:
PASS.**

## COHERENCE — delegate ⇄ verify-checkpoint on the invocation model

- `verify-checkpoint` documents **two invocation modes with identical grading**
  (`observer/skills/verify-checkpoint/SKILL.md:13-18, 52, 99`): (a) per-increment dispatch (first-class,
  how `lsa:delegate` drives it) and (b) standalone self-paced `/loop` rider.
- `delegate` Step 5 (`lsa/skills/delegate/SKILL.md:62-63`) dispatches it **in its per-increment mode**
  "not its standalone `/loop` mode."

The two read as coherent siblings: verify-checkpoint offers both modes and names per-increment
dispatch as first-class; delegate uses exactly that mode. No contradiction. The LOW invocation-model
seam flagged in the `59ddaa5` grade is resolved. **Coherence result: PASS.**

## Three checks — does · only · all

### Does it work (9 Gherkin scenarios → SKILL Steps/Constraints; probes D1–D9)

| Scenario (G) | Mechanism | Probe | Result |
|---|---|---|---|
| off reproduces today's delegation (G2) | delegate Step 3 `off` branch: dispatch → await, no pause, no verifier, skip to Step 6 | D1 | ✅ |
| async refused not degraded (G3) | Step 3 `async` branch + Constraint: ERROR "not yet implemented", no fallback, stop | D2 | ✅ |
| checkpoint injects pause+signal (G4,G5) | Step 4 agent branch: after each F-K write 4-field note, then stop | D3 | ✅ |
| CLEAR auto-advances (G6,G7) | Step 5: dispatch verifier per-increment; CLEAR → proceed, no interrupt | D4 | ✅ |
| BLOCK surfaces before next task (G6,G7,G8) | Step 5: BLOCK → turn-final surface; verdict a distinct artifact | D5 | ✅ |
| final reconcile still runs (G9) | Step 7 + Constraint: checkpoint does not replace whole-diff reconcile | D7 | ✅ |
| non-agent advisory (G10) | Step 4 non-agent branch: ADVISORY, no enforcement claim, note as guidance | D6 | ✅ |
| writer + reader share delegate-owned note path (G15) | Step 4 preamble owns path + passes same to both; Step 5 passes same path to reader; ephemeral/not-committed; 4 fields unchanged | D8 | ✅ |
| verifier dispatched per-increment, not a loop (G16) | Step 5 dispatches per-increment mode, cites "not its standalone `/loop` mode"; verify-checkpoint documents both modes | D9 | ✅ |

All 9 scenarios are produced by the SKILL Steps/Constraints across both halves; D1–D9 assert each with
matching "Aha" failure-mode probes. Suite self-flags 3 hardening gaps (rotate omitted field,
round-trip seam probe, mixed-verdict sequence) — test-improvement backlog, not prompt defects. The
round-trip seam gap is now partly closed: G15 pins the shared path both sides read/write.

### Only what's needed (every hunk → a G-requirement or mandatory discipline)

| Changed file (hunk) | Traces to |
|---|---|
| `lsa/skills/delegate/SKILL.md` frontmatter + Goal + Inputs + Steps 1-7 + Output + Constraints | G1–G10 (behavior), G15 (path ownership), G16 (per-increment mode) |
| `lsa/.claude-plugin/plugin.json` 0.22.0 → 0.23.0 | G11 |
| `lsa/CHANGELOG.md` `[0.23.0]` | G11 |
| `lsa/ARCHITECTURE.md` schema line + per-key bullet | G1, G13 |
| `lsa/knowledge/conventions.md` `paired_verify: off` default | G1, G13 |
| `lsa/README.md` delegate row + Configuration paragraph | G12 |
| `observer/skills/verify-checkpoint/SKILL.md` intro/Goal/Input/Step1/Step2 reframe + contract §path | G16 (two modes), G15 (path pinned) |
| `observer/.claude-plugin/plugin.json` 0.2.0 → 0.2.1 | per-plugin SemVer discipline (observer touched) |
| `observer/CHANGELOG.md` `[0.2.1]` | per-plugin CHANGELOG discipline |
| `observer/README.md` verify-checkpoint row + flow diagram | README discipline (G15/G16 user-visible) |
| `.lsa/modules/observer/spec.md` (v0.2.1, two-mode Actor line, two new invariants) | module-spec sync (G15/G16) |
| `.lsa/features/.../{requirements,grounding,feature,scenarios}.md` | spec commit `f846dd3` (out of impl scope) |

No over-delivery. `delegate` frontmatter `allowed-tools` (`Read, Write, Bash, Agent, AskUserQuestion`)
pre-existed (grounding.md:9) — no new tool grant. The observer 0.2.1 bump + CHANGELOG + README + module
spec are the mandatory per-plugin discipline consequence of harmonizing observer files for G15/G16, not
scope creep. Result: **PASS.**

### All of the plan (G1–G16)

| G | Requirement | Satisfying change | Result |
|---|---|---|---|
| G1 | schema `paired_verify` (default off), ARCH §3 + conventions | ARCHITECTURE schema block + bullet; conventions default line | ✅ |
| G2 | absent/off = today's behavior | delegate Step 3 `off` branch; D1 | ✅ |
| G3 | async errors, no degradation | delegate Step 3 `async` branch + Constraint; D2 | ✅ |
| G4 | checkpoint + agent → inject after-each-F-K write-then-stop | delegate Step 4 agent branch; D3 | ✅ |
| G5 | note emits exactly target/since/spec/status per reader contract | Step 4 field table (interlock PASS); D3 | ✅ |
| G6 | dispatch `observer:verify-checkpoint` per increment | delegate Step 5 dispatch; D4/D5 | ✅ |
| G7 | CLEAR proceeds no interrupt / BLOCK surfaces before next task | delegate Step 5 gate; D4/D5 | ✅ |
| G8 | verifier independent, verdict never folded into authoring context | Step 5 + Constraint, cites reconcile:44-45; D5 | ✅ |
| G9 | reconcile unchanged — still runs after delegation | delegate Step 7 + Constraint; D7 | ✅ |
| G10 | non-agent → advisory, no enforcement claim | delegate Step 4 non-agent branch + Constraint; D6 | ✅ |
| G11 | lsa plugin.json 0.23.0 + CHANGELOG `[0.23.0]` | plugin.json + CHANGELOG diff | ✅ |
| G12 | README documents paired_verify modes | README delegate row + Configuration para | ✅ |
| G13 | ARCH §3 YAML block + per-key bullet AND conventions default | ARCHITECTURE + conventions diffs | ✅ |
| G14 | eval probes in feature dir asserting all modes | `delegate-paired-verify-scenarios.md` D1–D9 (now 9 probes) | ✅ |
| G15 | note-path interlock — delegate owns path, same to writer+reader, ephemeral, 4 fields unchanged | delegate Step 4 preamble + Step 5 + Constraint; verify-checkpoint contract §:37; D8; interlock PASS | ✅ |
| G16 | invocation model reconciled — verify-checkpoint documents 2 modes; delegate dispatches per-increment | verify-checkpoint :13-18/52/99; delegate Step 5 :62-63; D9; coherence PASS | ✅ |

Result: **PASS** — 16/16 mapped.

Non-scenario checks: G11 (lsa 0.23.0 + CHANGELOG) ✅; G12 (README) ✅; G13 (ARCHITECTURE + conventions)
✅; G14 (probes, now D1–D9) ✅; observer 0.2.1 bump + CHANGELOG for the harmonization ✅.

## Findings (severity-ranked)

No blocking, high, or medium findings.

- **[INFO] Prior-grade LOW seams resolved.** The two LOW/informational seams the `59ddaa5` grade
  flagged — invocation-model impedance and unpinned note location — are both closed by epic 3
  (G16 documents two modes with delegate on per-increment; G15 pins the delegate-owned shared
  ephemeral path). Interlock re-confirmed byte-identical after the path addition.
- **[INFO] Suite hardening backlog persists.** The scenarios file still self-flags rotate-omitted-field,
  full round-trip, and mixed-verdict-sequence probes as test improvements (not prompt defects). Track
  as eval hardening, not a conformance gap.

## Independence

This conformance artifact is authored in a separate grader context (no write access to the graded
skills, `.feature` scenarios, or `.lsa.yaml`) and committed in a commit **separate** from every impl
commit (`59ddaa5`, `8160554`, `4bc6fb7`), per `lsa/skills/reconcile/SKILL.md:45` — independence is
observable at the git layer, not asserted.
