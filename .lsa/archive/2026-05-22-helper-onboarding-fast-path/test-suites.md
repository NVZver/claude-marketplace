> **Trace.** On load, print first: `=============== [.lsa/features/2026-05-22-helper-onboarding-fast-path/test-suites.md] [vision] ===============`

# Test Suites: Helper fast-path for onboarding questions

> Source: `.lsa/roadmap.md` §"2026-05-22 backlog detail" #2. Requirements: `./requirements.md`. Design: `./design.md`.

## Verification approach

Every Journey below is a **manual probe** run in a fresh Claude Code session (Helper-style — `helper/README.md:42-57` calls these *"V1 / V2 / V3 probes"*). Each Journey covers one or more ACs from `requirements.md`. The probes follow the V1 → V2 → V3 progression in `.lsa/standards/testing.md` (cited via `helper/README.md:57`).

**Latency measurement.** For Journeys 1-4 (fast-path positive paths), the probe captures wall-clock time from agent invocation to response body. Pass: ≤5s. Anything longer is a fail even if the response body is correct, because NF1 is the load-bearing requirement.

**Tool-call discipline check.** For Journeys 1-4, the probe also asserts which tools fired. Pass: exactly one `Read` of `helper/knowledge/onboarding-fast-path.md`, plus 1-2 `Read`s of the catalog-mapped README files, and the closing `AskUserQuestion`. Fail: any `Grep`, `Glob`, or `mcp__plugin_context7_context7__*` invocation. This protects F4.

---

## Journey 1: Golden test — "how do I get started with LSA"

**Goal:** prove the roadmap row's primary failure mode is fixed (`.lsa/roadmap.md:113` — *"~3 minutes (user-reported, 2026-05-22)"* → ≤5s).
**Covers:** AC1, NF1 (latency), F1 (classification), F2 (excerpt response), F4 (no deep-grep / no `context7`), F6 (catalog is data).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Fresh session, fast-path hit | `/help how do I get started with LSA` |
| 2 | Free-form phrasing variant | `how do I get going with LSA?` (mid-flow, no skill active — signal b) |
| 3 | Capitalized / punctuated variant | `Where do I START with LSA??` |

**Expected outcome (every path):**
- Response arrives ≤5s wall-clock.
- Response body quotes `README.md:73-83` (the install block) inline, then cites `lsa/README.md:49-60`, then provides the 3-word `LSA` gloss on first turn-use (e.g., *"LSA — Living Spec Architecture"*).
- Closing `AskUserQuestion` names a concrete subject (e.g., *"Run `/lsa:init` now? — Yes / Different question"*), no opaque IDs.
- Tool trace: `Read helper/knowledge/onboarding-fast-path.md`, `Read README.md`, `Read lsa/README.md`, `AskUserQuestion`. No `Grep`. No `Glob`. No `mcp__plugin_context7_context7__resolve-library-id`. No `mcp__plugin_context7_context7__query-docs`.

---

## Journey 2: Install onboarding pattern

**Goal:** verify the *install* trigger row.
**Covers:** AC2, F1, F2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Bare keyword | `/help install` |
| 2 | Full question | `/help how do I install the marketplace` |
| 3 | Empty-arg starter-picker → Install | `/help` → pick *"Install"* from the 3-option starter (`helper/commands/help.md:20`) |

**Expected outcome:**
- Response ≤5s, quotes `README.md:73-83` inline with citation.
- Closing `AskUserQuestion`: e.g., *"Install both `core` and `lsa` plugins now? — Yes / Different question"*.
- Tool trace: `Read` (catalog + README.md) + `AskUserQuestion` only.

---

## Journey 3: "What is X" onboarding triple

**Goal:** verify the *what-is + core/lsa/helper* trigger rows.
**Covers:** AC3, F1, F2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | What is core | `/help what is core` |
| 2 | What is LSA | `/help what is LSA` |
| 3 | What is helper | `/help what is helper` |
| 4 | Constitution-frame question | `/help what is this marketplace` |

**Expected outcome:**
- Path 1: ≤5s, quote from `README.md:25-49` (core opening + three always-on bullets), citation rendered, *core* gloss on first use.
- Path 2: ≤5s, quote from `README.md:51-68` + `lsa/README.md:1-9`, `LSA` re-glossed.
- Path 3: ≤5s, quote from `helper/README.md:1-10`.
- Path 4: ≤5s, quote from `README.md:1-12` + `.lsa/VISION.md:13-15`.
- All paths: closing `AskUserQuestion` subject-named (AC7).

---

## Journey 4: Multiple-trigger question

**Goal:** verify first-match-wins + follow-up offers (design.md OQ4 resolution).
**Covers:** AC1, AC2, F2, design §"Matching rules".

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Install + what-is in one question | `/help how do I install LSA and what does it do` |

**Expected outcome:**
- First-row-wins fires row 1 (*install*); response quotes `README.md:73-83`.
- Closing `AskUserQuestion` includes a labelled option for the second match (e.g., *"Want a definition of LSA next?"*).

---

## Journey 5: Fall-through — non-onboarding deep-research question

**Goal:** prove the fast-path adds zero latency to non-onboarding paths.
**Covers:** AC4, F3, NF6 (no regressions).

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Skill-mechanism question | `/help what does lsa-verify's orphan-AC predicate do` |
| 2 | Configuration question | `/help how do I configure .lsa.yaml` |
| 3 | History question | `/help why was flow-selector renamed` |

**Expected outcome:**
- Step 1.5 classifies *non-onboarding* and falls through. Step 2 scope-order read fires (`helper/agents/helper.md:33`).
- Tool trace includes `Grep` and/or additional `Read`s beyond the catalog + top-level READMEs.
- Response cites a non-README source (e.g., `lsa/skills/lsa-verify/SKILL.md`, `lsa/ARCHITECTURE.md`, or a CHANGELOG entry).
- Latency >5s is acceptable here; the budget applies only to fast-path-hit responses.

---

## Journey 6: Negative example — trigger matches but excerpt missing

**Goal:** verify F7 (excerpt-missing → fall-through, no fabrication).
**Covers:** AC5, F3, F7.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Install + un-cataloged subject | `/help install context7` — *install* trigger fires, no catalog row maps it. |

**Expected outcome:**
- Step 1.5 detects no concrete excerpt mapping; falls through to Step 2.
- Step 2 routes through scope-order read (in this case scope 3 — `context7` MCP).
- No fabricated install instructions.

---

## Journey 7: Cannot-verify backstop

**Goal:** confirm the existing `"I cannot verify this"` fallback path is not regressed.
**Covers:** AC6, F7.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Fully unknown subject | `/help what is the snorgleblat` |

**Expected outcome:**
- Step 1.5: no catalog match → fall through.
- Step 2 scope-order read: returns no source.
- Step 3 composes the exact response `"I cannot verify this."` + sources checked + closing `AskUserQuestion`.
- Unchanged from today's behavior. This Journey is a regression test, not a new behavior.

---

## Journey 8: Cooldown precedes fast-path

**Goal:** verify F5 — Step 1 (cooldown) runs before Step 1.5.
**Covers:** AC8, F5.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Signal-b decline, then re-trigger same signal-type with onboarding question | (i) free-form `what is LSA?` → Helper auto-engages (signal b), user picks *No*. (ii) Same session, no other signal yet: `how do I install LSA?` — also signal b. |

**Expected outcome:**
- Step 1 detects cooldown for signal b → Helper silently exits per `helper/knowledge/friction-signals.md:17-25`.
- Step 1.5 does NOT run (the fast-path catalog read does not happen).
- Tool trace shows zero `Read` calls for the second question.

---

## Journey 9: Signal-a auto-engage path unaffected

**Goal:** confirm the friction-auto-engage path (signal a) is unaffected by Step 1.5.
**Covers:** AC8 (cooldown), cross-module contract with `lsa-specify`, NF6.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Trigger signal a via two consecutive `[c] reject` at any `lsa-specify` User Verification, then accept Helper's *"Want me to explain…?"* with Yes. |

**Expected outcome:**
- Step 1 proceeds (signal a, no cooldown yet).
- Step 1.5: classifies the User-Verification-explanation request as non-onboarding (no catalog match for *"explain this verification"*) and falls through.
- Steps 2-5 run as today — Helper re-grounds the Verification with `file:line` citations from `lsa/skills/lsa-specify/SKILL.md` per `helper/agents/helper.md:34`.

---

## Journey 10: Catalog freshness — drift detection (probe-only)

**Goal:** detect catalog rot when a README's line numbers shift after a future edit. Not an AC; informational probe.
**Covers:** design.md OQ2.

**Paths:**

| # | Path | Actions |
|---|------|---------|
| 1 | Edit `README.md` to add one line above line 73 (the install block). Run Journey 1 again. |

**Expected outcome:**
- Helper quotes the wrong range (off by one line) OR Step 1.5 errors out reading a now-shifted heading anchor.
- This probe is acknowledged drift, not a test failure. The fix is a manual catalog re-pin OR (deferred) a `lsa-reconcile`-style drift hook per OQ2. Documented in `design.md`; not blocking for v1 merge.

## Open Questions

- **OQ1.** **Wall-clock measurement mechanism.** Manual probe with a stopwatch is crude. Could parse Claude Code's session transcript timestamps. **Tentative resolution: stopwatch is fine for v1; if Journey 1 ever fails on latency, automate then.**
- **OQ2.** **Should Journeys 1-3 each run all three signal types (a / b / c)?** Currently they only run signal (b) and (c). Signal (a) is covered in Journey 9 separately. **Tentative resolution: keep separation — signal a's content space is constrained to Verification-explanation, so a separate Journey is clearer than expanding 1-3.**
- **OQ3.** **Regression test for AC7 (subject-named closing picker).** Manually-eyeballed for now. Could be auto-asserted if Claude Code exposes `AskUserQuestion` payload in the transcript. **Tentative resolution: manual review v1.**
