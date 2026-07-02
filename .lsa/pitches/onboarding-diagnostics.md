Shaped by: Nikita Zverev
Date: 2026-07-02
Status: approved
Role lens: developer-experience / onboarding product manager
Decisions:
- Fork A (doctor home): `core` — it ships in the required core+lsa install, so the diagnostic exists even in a minimal install, and it verifies the core discipline layer itself.
- Fork B (doctor surface): explicit command + description-matched skill trigger — matches `superclaude doctor` / `specify self check` while auto-triggering on "something's broken".
- Fork C (maintenance-signals scope): all four signals in this pitch — CI badge, per-plugin version column, CHANGELOG links, model-tier table (the sibling analysis flags the visible model table as a differentiation asset).
Why now: External adopters now install this (two field reports, population ≥2) and the repo is reviewer-facing in a live job application — so the install path's one silent-failure mode and the missing self-diagnostic (the only outright FAIL on the industry UX checklist) now cost real users, not just the author.

# Onboarding & diagnostics — a doctor, a numbered fragment step, and a recovery surface

Give the marketplace a user-runnable self-check, make the load-bearing install step un-skippable, and add a troubleshooting landing page — so a broken or half-wired install reports itself instead of failing silently.

## Problem

New installers — the author's second-party adopters and reviewers following the root README literally — hit one silent failure mode and have no recovery surface when anything goes wrong.

Evidence (verified 2026-07-02 against the live repo; full UX audit in the 2026-07-02 evaluation):
- The step that activates every always-on rule is a skippable trailing sentence. `README.md:33` — "Then merge the `core/CLAUDE.md` fragment into your project's `CLAUDE.md` to wire up the always-on rules." — follows an 8-line install block (`README.md:22-31`) as prose, not a numbered step. `core/CLAUDE.md:5` confirms the fragment is what declares the always-on rules. Skip it and the entire discipline layer never activates, with no error to signal the absence.
- No health-check / self-diagnostic exists. The audit scored this the *only* outright FAIL (checklist item F): "No `/doctor`, `self check`, or install-verify. `scripts/lint.sh` is contributor CI only." The industry pattern is explicit — SuperClaude ships `superclaude doctor`, spec-kit ships `specify self check` (2026-07-01 sibling analysis, Tier-B item 8: "Health-check / self-diagnostic command").
- No troubleshooting guidance exists anywhere. Error-recovery scored Partial (item I): `lsa/README.md:68` covers NOT-GROUNDED, but "install failed / skill won't trigger / fragment not applied / lint red" has no landing page.
- Maintenance signals are thin (items H, K): zero badges in `README.md` despite a green `.github/workflows/lint.yml`; no per-plugin version column in the six-plugin table (`README.md:11-18`); further-reading (`README.md:196-204`) links no CHANGELOGs; the model-tier story is prose-only (`README.md:181-185`), where the reference pattern is wshobson/agents' explicit tier table.

Current workaround: a stuck user reads `CONTRIBUTING.md` (contributor-oriented, not user-facing) or guesses. There is no evidence-based "is my install actually wired?" answer.

Definition of success:
1. The fragment-merge is a numbered install step no one skips.
2. A user-runnable diagnostic reports actionable per-check results — required plugins installed, fragment present in the project `CLAUDE.md`, plugin versions consistent with their source manifests, gate scripts pass — each showing evidence, not a bare "OK" (per Anthropic's "show evidence rather than asserting success").
3. A troubleshooting section covers the four named failure modes.
4. Maintenance signals (CI badge, per-plugin versions, CHANGELOG links, a model-tier table) are visible at root.

## Appetite

Small batch — this is the polish pitch, the smallest of the five. One real Actor to author (the doctor); everything else is doc edits to `README.md` and existing per-plugin READMEs. The doctor is designed from a diagnostic procedure run by hand end-to-end first (manual-before-automate), so the Steps reflect lived checks, not imagined ones.

Out of appetite: any auto-repair; any newly-shipped executable (script or hook); refreshing stale `marketplace.json` descriptions, `knowledge/index.md`, or observer docs (the separate catalog-surface-drift pitch); a prompt-behavior eval harness (the separate eval-coverage pitch).

## Solution sketch

- **Key user interactions:**
  - Runs a single diagnostic (e.g. `/core:doctor`) after install and gets a per-check report: each check is PASS / WARN / FAIL with the evidence it found and a one-line fix when it fails ("`core/CLAUDE.md` fragment not detected in your project `CLAUDE.md` — merge it, see README step 5").
  - Follows a numbered install list where the fragment-merge is its own step, not a trailing sentence.
  - Lands on a short troubleshooting section keyed to symptoms: install failed / skill won't trigger / fragment not applied / NOT-GROUNDED / lint red.
- **Main components:**
  - One new Actor (Goal/Input/Steps/Output/Constraints) — home is `core` (per Fork A). Surfaced as an explicit command plus a description-matched skill trigger on "health check / something's broken" (per Fork B).
  - The doctor drives read-only checks through the agent's own tools (Read/Grep/Bash on read-only git + `scripts/*.sh`) — it ships no new executable, preserving the "six pure-Markdown plugins plus one transparent SessionStart hook" trust boundary (`README.md:189`).
  - Doc edits: promote `README.md:33` to a numbered step; add a troubleshooting section; add a CI badge, a version column to the six-plugin table, CHANGELOG links to further-reading, and a model-tier table to "Plans & models" (per Fork C, all four).
  - Per repo rules: new skill ⇒ `core` minor version bump + CHANGELOG entry + README delta in the same commit; a roadmap row.
- **Critical path:** run the four diagnostic checks by hand on this repo → design the doctor Steps from that run → author the Actor → wire the command + skill trigger → land the doc edits alongside the version bump.

## Rabbit holes

1. Shipping the doctor as a new script or hook would break the pure-Markdown trust boundary (`README.md:189`, `SECURITY.md`). Mitigation: the doctor is a Markdown Actor that instructs the agent to run read-only checks with its existing tools — no new shipped executable, `SECURITY.md` unchanged.
2. Fragment-presence detection is fuzzy — users adapt or partially merge `core/CLAUDE.md`. Mitigation: check for the always-on rule anchors (per `core/CLAUDE.md:5`) by heading/citation, report per-rule, and treat a partial merge as WARN, not FAIL.
3. Doctor-vs-helper role overlap (disambiguation test). `helper` is free-form cited Q&A that answers "what is X?" (`helper/README.md:3-8`). The doctor is a deterministic procedural Actor with fixed Steps that emits PASS/WARN/FAIL evidence — it never answers open questions and helper never runs an install check. The boundary holds; state it explicitly in both READMEs.
4. Manual-before-automate: designing the doctor from imagined steps produces checks that don't match reality. Mitigation: run the four-check procedure by hand on this repo first and derive the Steps from that transcript.
5. The version-consistency check needs a source of truth for "expected" versions. Mitigation: compare each installed `plugin.json` version against its source in this repo — do not invent a new version manifest (marketplace.json holds descriptions, not versions).

## No-gos

1. This pitch does NOT auto-repair anything — the doctor reports and instructs; the human fixes. Auto-mutating a user's `CLAUDE.md` is a separate appetite decision.
2. This pitch does NOT ship a new script or SessionStart hook — the trust boundary stays "pure Markdown + one existing hook."
3. This pitch does NOT fix the stale `marketplace.json` descriptions, `knowledge/index.md` counts, or undocumented `observer:verify-checkpoint` — those are the catalog-surface-drift pitch.
4. This pitch does NOT build a prompt-behavior / plugin-eval harness — that is the eval-coverage-tracks-complexity pitch.
