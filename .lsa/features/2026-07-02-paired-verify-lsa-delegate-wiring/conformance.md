# Conformance — paired-verify/lsa-delegate-wiring (epic 2)

**Verdict: `reconcile: PASS @ 59ddaa5`**

Independent grader (did not author the impl). Graded impl commit `59ddaa5` against
`requirements.md` (G1–G14), `delegate-paired-verify.feature` (7 scenarios), and `grounding.md`.
Markdown-only plugin — no code / no test runner; "does it work" is reasoned over the `delegate`
SKILL prose and the D1–D7 eval probes.

## CRITICAL interlock check — WRITER ⇄ READER

The four fields `delegate` Step 4 instructs the implementer to **write**
(`lsa/skills/delegate/SKILL.md` field table) vs. the fields `verify-checkpoint` **reads**
(`observer/skills/verify-checkpoint/SKILL.md:21-26`):

| Field | Writer (delegate Step 4) | Reader (verify-checkpoint:21-26) | Match |
|---|---|---|---|
| `target` | F-id just completed (e.g. `F-K`), matching id in `requirements.md` | F-id the increment claims to complete, matching id in `requirements.md` | ✅ exact |
| `since` | previous checkpoint marker (commit SHA / change cursor / timestamp) bounding the increment | previous checkpoint marker (commit SHA, change cursor, timestamp) bounding changes | ✅ exact |
| `spec` | path to spec dir (`requirements.md` + `<flow>.feature` scenarios) | path to spec dir — `requirements.md` + `<flow>.feature` scenarios | ✅ exact |
| `status` | pause marker meaning "stopped, awaiting a verdict" | pause marker meaning "implementer stopped, awaiting a verdict" | ✅ exact |

**Interlock result: PASS.** Four fields, same names, same meanings, none missing / extra / renamed /
divergent. The two halves interlock.

## Fact-grounding spot-check

| Citation (in delegate) | Target | Result |
|---|---|---|
| `observer/skills/verify-checkpoint/SKILL.md:15-28` (signal contract) | line 15 = "## The checkpoint-signal contract" heading; field table 21-26; section ends 28 | ✅ resolves |
| `lsa/skills/reconcile/SKILL.md:44-45` (independence) | line 44 = "Independent grader"; line 45 = "Independence must be observable" | ✅ resolves |

## Three checks

### Does it work (7 Gherkin scenarios → delegate prose + D-probe)

| Scenario (G) | Delegate mechanism | Probe | Result |
|---|---|---|---|
| off reproduces today's delegation (G2) | Step 3 `off` branch: dispatch → await, no pause, no verifier, skip to Step 6 | D1 asserts no protocol / no verifier / not-treated-as-checkpoint | ✅ |
| async refused not degraded (G3) | Step 3 `async` branch: ERROR "not yet implemented", no fallback, stop | D2 asserts errors + no fallback + no dispatch | ✅ |
| checkpoint injects pause+signal (G4,G5) | Step 4 agent branch: after each F-K write 4-field note, then stop | D3 asserts all 4 fields, none dropped/renamed/added, stop instruction present | ✅ |
| CLEAR auto-advances (G6,G7) | Step 5: dispatch verifier; CLEAR → proceed, no human interrupt | D4 asserts dispatch + no picker/question/wait | ✅ |
| BLOCK surfaces before next task (G6,G7,G8) | Step 5: BLOCK → turn-final surface before next task; verdict a distinct artifact | D5 asserts surface-before-next + not-folded-into-authoring-context | ✅ |
| final reconcile still runs (G9) | Step 7 + constraint: checkpoint does not replace whole-diff reconcile | D7 asserts reconcile not skipped / not substituted | ✅ |
| non-agent advisory (G10) | Step 4 non-agent branch: ADVISORY, no enforcement claim, note as guidance | D6 asserts advisory + no enforcement claim + note kept | ✅ |

All 7 scenarios are produced by the SKILL Steps/Constraints; D1–D7 assert each with matching
"Aha" failure-mode probes. Suite self-flags 3 hardening gaps (rotate omitted field, round-trip seam
probe, mixed-verdict sequence) — noted as test-improvement backlog, not prompt defects.

### Only what's needed (every hunk → a G-requirement)

| Changed file (hunk) | Traces to |
|---|---|
| `delegate/SKILL.md` frontmatter + Goal + Inputs + Steps 1-7 + Output + Constraints | G2–G10 (behavior), G1 (reads `paired_verify`) |
| `plugin.json` 0.22.0 → 0.23.0 | G11 |
| `CHANGELOG.md` `[0.23.0] — 2026-07-02` | G11 |
| `ARCHITECTURE.md` schema line + per-key bullet | G1, G13 |
| `knowledge/conventions.md` `paired_verify: off` default | G1, G13 |
| `README.md` delegate row + Configuration paragraph | G12 |
| `delegate-paired-verify-scenarios.md` (new, feature dir) | G14 |

No over-delivery. No new `allowed-tools` beyond the pre-existing set. **No `observer/` file modified**
(epic 1 stays untouched — `git show 59ddaa5 --name-only | grep observer/` = 0). Result: **PASS.**

### All of the plan (G1–G14)

| G | Requirement | Satisfying change / assertion | Result |
|---|---|---|---|
| G1 | schema `paired_verify: off\|checkpoint\|async` (default off), ARCH §3 + conventions | ARCHITECTURE schema block + bullet; conventions default line | ✅ |
| G2 | absent/off = today's behavior | delegate Step 3 `off` branch; D1 | ✅ |
| G3 | async errors, no degradation | delegate Step 3 `async` branch + Constraint; D2 | ✅ |
| G4 | checkpoint + agent → inject after-each-F-K write-then-stop | delegate Step 4 agent branch; D3 | ✅ |
| G5 | note emits exactly target/since/spec/status per reader contract | Step 4 field table (interlock PASS); D3 | ✅ |
| G6 | dispatch `observer:verify-checkpoint` per increment | delegate Step 5 dispatch; D4/D5 | ✅ |
| G7 | CLEAR proceeds no interrupt / BLOCK surfaces before next task | delegate Step 5 gate; D4/D5 | ✅ |
| G8 | verifier independent, verdict never folded into authoring context | Step 5 + Constraint, cites reconcile:44-45; D5 | ✅ |
| G9 | reconcile unchanged — still runs after delegation | delegate Step 7 + Constraint; D7 | ✅ |
| G10 | non-agent → advisory, no enforcement claim | delegate Step 4 non-agent branch + Constraint; D6 | ✅ |
| G11 | plugin.json 0.23.0 + CHANGELOG `[0.23.0]` 2026-07-02 | plugin.json + CHANGELOG diff | ✅ |
| G12 | README documents paired_verify modes | README delegate row + Configuration para | ✅ |
| G13 | ARCH §3 YAML block + per-key bullet AND conventions default | ARCHITECTURE + conventions diffs | ✅ |
| G14 | eval probes in feature dir (not lsa/tests/) asserting all modes | `delegate-paired-verify-scenarios.md` D1–D7 in feature dir | ✅ |

Result: **PASS** — 14/14 mapped.

## Findings (severity-ranked)

No blocking or high-severity findings.

- **[LOW / informational] Invocation-model impedance.** `verify-checkpoint`'s own Goal is framed as a
  `/loop`-riding cyclic verifier that re-reads a scratchpad note each wake
  (`observer/skills/verify-checkpoint/SKILL.md:11,32`), whereas `delegate` Step 5 dispatches it "via
  the `Agent` tool" per signalled increment. Both are reasonable orchestrations and the *field*
  contract interlocks, so this is not a conformance failure; noted for future harmonization of how
  the reader is invoked.
- **[LOW / informational] Note storage location unpinned on the writer side.** The reader expects the
  note as "a scratchpad file re-read each cycle" (`verify-checkpoint:19`). Delegate Step 4 instructs
  the implementer to "write a checkpoint-signal note" with the correct fields but does not pin its
  path/medium. Field-level interlock (the epic's G5 scope) holds; the shared location is left to the
  round-trip probe the suite already flags as a hardening gap.

## Independence

This conformance artifact is authored in a separate grader context (no write access to the graded
files) and committed in a **separate commit** from impl `59ddaa5`, per
`lsa/skills/reconcile/SKILL.md:45` ("independence must be observable, not asserted").
