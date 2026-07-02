# Grounding — paired-verify/lsa-delegate-wiring

Verdict: **GROUNDED**. Spec `requirements.md` (G1–G14) + `delegate-paired-verify.feature` grounds against the repo. No blockers.

## Reference map

| Spec reference | Status |
|---|---|
| delegate skill to modify (G2,G4,G6,G7,G10) | exists @ `lsa/skills/delegate/SKILL.md` (3 steps; `allowed-tools: Read, Write, Bash, Agent, AskUserQuestion`) |
| checkpoint-signal contract, 4 fields (G5) | exists @ `observer/skills/verify-checkpoint/SKILL.md:22-37` (target/since/spec/status) — epic 1, now on main |
| verify-checkpoint verifier to dispatch (G6) | exists @ `observer/skills/verify-checkpoint/SKILL.md` (observer 0.2.0 present at base) |
| independence constraint (G8) | exists @ `lsa/skills/reconcile/SKILL.md:44-45` |
| schema block to extend (G1,G13) | exists @ `lsa/ARCHITECTURE.md:79-120` (`gate:` + `autonomy:` pattern: YAML block + per-key bullet) |
| defaults section (G13) | exists @ `lsa/knowledge/conventions.md:11` ("`.lsa.yaml` defaults") |
| README delegate section (G12) | exists @ `lsa/README.md:19,31,49` |
| lsa version (G11) | exists @ `lsa/CHANGELOG.md:5` `[0.22.0]` → bump to 0.23.0 |
| `paired_verify` key | **new** — `off`/`checkpoint`/`async`, default off |
| checkpoint pause+signal-write protocol | **new** — the injected implementer instruction (delegate is the writer-of-the-instruction; the implementer emits the note) |
| epic-2 eval probes (G14) | **new**, in the FEATURE dir (see decision below) |

## Feasibility notes for delegate
- **lsa has no `tests/` path.** The `lsa` module's `.lsa.yaml` `artifact_paths` cover skills/agents/knowledge/hooks/plugin.json/ARCHITECTURE/README/CORE/CHANGELOG — no `tests/**`. Decision: epic-2 adversarial eval probes live in the feature dir (`.lsa/features/2026-07-02-paired-verify-lsa-delegate-wiring/delegate-paired-verify-scenarios.md`) as spec-level acceptance probes, NOT `lsa/tests/`. This avoids broadening the `lsa` module surface (no `.lsa.yaml` edit) and keeps the acceptance evals with the spec.
- **Markdown-only.** delegate is a prose skill; epic 2 edits its prose to branch on `paired_verify` and inject the protocol. No code/test-runner. The dispatch + gate are prose steps delegate executes via its existing `Agent` tool.
- **delegate's "no production code" constraint holds.** delegate orchestrates the checkpoint loop but writes no production code itself — the implementer writes code; the verifier grades read-only. Consistent with `lsa/skills/delegate/SKILL.md:40`.
- **Agent-vs-external implementer (G10).** The pause protocol is enforceable only when delegate dispatches an agent implementer via the Agent tool; for human/Cursor/Copilot it is advisory. Spec states this rather than silently claiming enforcement.

All 7 scenarios buildable on what exists. The `async` value ships documented + erroring (not built) per the pitch's Fork C / No-go #1.
