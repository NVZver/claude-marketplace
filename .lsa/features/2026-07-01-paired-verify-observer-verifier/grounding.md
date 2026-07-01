# Grounding — paired-verify/observer-verifier

Verdict: **GROUNDED**. Spec at `requirements.md` (F1–F17) + `verify-checkpoint.feature` grounds against the repo. No blockers.

## Reference map

| Spec reference | Status |
|---|---|
| "read changes since a marker" (increment-read, F5) | exists @ `observer/skills/observe/SKILL.md:37` (step 6b: "read the file changes since the last-cycle marker") |
| silence discipline (F4) | exists @ `observer/skills/observe/SKILL.md:37` (step 6d: "silence means producing NO user-facing text") |
| "does" check (F6) | exists @ `lsa/skills/reconcile/SKILL.md:32` |
| "only" check (F7) | exists @ `lsa/skills/reconcile/SKILL.md:33` |
| "all" check deferred (F8) | exists @ `lsa/skills/reconcile/SKILL.md:34` (whole-plan completeness — correctly kept OUT of the per-increment grader) |
| independence / read-only (F11) | exists @ `lsa/skills/reconcile/SKILL.md:44-45` |
| observer version 0.1.1 → 0.2.0 (F14) | exists @ `observer/.claude-plugin/plugin.json` `"version": "0.1.1"` |
| single-Actor claim to revise (F17) | exists @ `.lsa/modules/observer/spec.md:14` ("exposes a single Actor and a single Knowledge file") |
| stale version header (F17) | exists @ `.lsa/modules/observer/spec.md:7` (`(v0.1.0)`) **and** `:26` ("Currently v0.1.0") — BOTH must be corrected |
| Substrate-native / no-scheduler invariant (F2) | exists @ `.lsa/modules/observer/spec.md:30` |
| Knowledge≠Actor invariant | exists @ `.lsa/modules/observer/spec.md:29` |
| roles.md untouched (F13) | exists @ `observer/knowledge/roles.md` |
| evals alongside scenarios (F16) | exists @ `observer/tests/scenarios.md` (+ `eval-findings-2026-06-27.md`) |
| `observer:verify-checkpoint` skill | **new** — `observer/skills/verify-checkpoint/SKILL.md` |
| checkpoint-signal contract | **new** — defined by this epic; the writer ships in `paired-verify/lsa-delegate-wiring` |
| F-requirement→scenario mapping | **new**, buildable — the `.feature` already annotates each scenario with its F-numbers (`# F6,F7,F9`), so the scoping map reuses that convention |
| adversarial eval file | **new** — under `observer/tests/` |

## Feasibility notes for delegate
- **Markdown-only module.** observer carries no `/src/` (module invariant). The "does" check (F6) is the verifier-agent reasoning about whether the increment satisfies the target requirement's scoped scenarios — the same execution-as-reasoning model reconcile uses ("run each Gherkin scenario", `lsa/skills/reconcile/SKILL.md:32`). The implementer must NOT build a test-runner harness; the skill is prose that directs an agent.
- **Two-Actor module is a documented shape change**, not a mechanism change — F17 updates the spec prose (`:7`, `:14`, `:26`) to describe observe + verify-checkpoint.
- **Implement via the prompt-engineer agent** (plugin prompt file), not raw coding — per marketplace practice for authoring skill/agent Markdown.

All 6 user-flow scenarios are buildable on what exists. No `[ASSUMPTION]` left implicit; the two "new" surfaces (the skill + the signal contract) are expected net-new for this epic.
