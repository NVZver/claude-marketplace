# Conformance — observer

`reconcile: PASS @ working-tree (pass 1, pre-hardening)`
`reconcile: PASS @ working-tree (pass 2, post-hardening + drift absorbed)`

## Pass 2 — re-grade after the prompt-hardening loop

Re-ran does·only·all against the current tree (observer 0.1.1 + test suite).

- **Does ✅** — behavior independently graded by the adversarial eval workflow
  (separate agent contexts): iter1 8/8 probes; iter2 4/5 guards prompt-forced,
  caught the S2 silence-leak + S4 example regression; iter3 both closed
  (`allClosed: true`). Evidence for F3.2 (silence), F3.4 (interviewer ordering /
  non-destructive), F3.5 (difficulty).
- **Only — drift absorbed (not flagged):** three behavioral refinements the spec
  hadn't captured were absorbed into `requirements.md`:
  - F3.2 → silence redefined as zero user-facing output (no narration/placeholder).
  - F3.4 → lens levels defined (solution/bugs/performance/style) + "direction, not
    corrected code".
  - Out-of-Scope → the `observer/tests/` behavioral suite recorded as legitimate
    verification scaffolding (consistent with `core/tests`, `prompt-engineer/tests`).
- **All ✅** — every F-requirement still covered.

### Independence (honest limitation)
The original build was authored by the `prompt-engineer` subagent (independent of
this grader). The **hardening hunks** (roles.md / SKILL.md guard edits) were authored
by the main orchestrator, so for those hunks this reconcile is NOT an independent
grader at the authoring layer. The independent grader for the hardening **behavior**
is the adversarial eval workflow (distinct agent contexts, `tests/eval-findings`).
At commit time, keep the eval artifacts + this conformance in a commit separate from
the implementation/hardening hunks so the separation is provable at the git layer.

---

(Original pass-1 record below.)


Graded by the orchestrator context (independent of the `prompt-engineer` implementer
subagent that authored the diff). Files were read and checked directly — not taken
from the implementer's self-report. **Commit guidance:** land the implementation in
one commit and this conformance artifact in a separate commit so grader independence
is provable at the git layer (reconcile Constraint, *Independence must be observable*).

## Does · Only · All

### DOES — every requirement maps to a satisfying change

| Req | Satisfied by |
|---|---|
| F1.1 infer + propose role | `observe/SKILL.md` Step 1 (AskUserQuestion proposal) |
| F1.2 named role adopted as-is | Step 1 ("adopt without proposing") |
| F1.3 offer full role set on override | Step 1 (override options) |
| F1.4 custom requires lens line | Step 2 (custom-role lens gate) + `roles.md` custom |
| F1.5 no observe without confirmed role | Step 1 observable result + Constraint "No observing without a confirmed role" |
| F2.1 red exercise (statement+placeholder+failing tests) | Step 4 (Write exercise, fails first run) |
| F2.2 request lang/topic if missing | Step 4 (request via AskUserQuestion first) |
| F2.3 scaffold interviewer-only | Step 4 + Constraint "Scaffold is interviewer-only" |
| F3.1 per-wake read + role feedback | Step 5 (start loop) + Step 6 (read changes, apply bundle) |
| F3.2 pair-programmer silence | Step 6d + `roles.md` pair-programmer cadence "quiet" |
| F3.3 project-wide consult before flagging | `roles.md` pair-programmer lens "searches existing deps + prior code" |
| F3.4 interviewer solution→bugs→perf→style, non-destructive | `roles.md` interviewer lens order + voice |
| F3.5 interviewer difficulty adaptation | Step 6e + `roles.md` interviewer difficulty rules + session-state note |
| F4.1 role-switch, next cycle, no restart | Step 7 |
| F5.1 stop on request | Step 8 |
| F5.2 stop on self-conclude / inactivity + report | Step 8 |

11/11 Gherkin scenarios are satisfiable against the written Actor + Knowledge.

### ONLY — every changed hunk traces

- `observer/**` (5 files) → F1–F5 + distribution discipline (manifest/README/CHANGELOG).
- `marketplace.json`, `.lsa.yaml`, `.lsa/modules/observer/spec.md` → registration discipline (grounding.md reference map).
- `CLAUDE.md`, `.lsa/main.spec.md`, `SECURITY.md`, `knowledge/index.md`, `helper/knowledge/onboarding-fast-path.md` (+ helper bump/CHANGELOG) → **drift closed**: the README heading rename (`The five plugins`→`The six plugins`) broke every `#the-five-plugins` link and the "five plugins" count was canonical in three repo-level docs. Living-docs + per-plugin-bump discipline.
- No unrelated features, no scope creep.

### ALL — no requirement left uncovered

Every F-requirement and every distribution requirement maps to a change above.
Under-delivery found during reconcile (cross-cutting "six plugins" references the
narrow delegate scope missed) was **completed**, not waived.

## Invariants

- **Knowledge ≠ Actor (NFR5, highest severity):** `roles.md` holds only lens/voice/cadence/difficulty *data*, no Goal/Steps; `observe/SKILL.md` Step 6 applies the active bundle generically with a Constraint forbidding inline per-role logic. Verified by reading both files. ✅
- **DRY/KISS/SoC:** one loop (Steps 5–6); adding a role = adding a bundle, no new branches. ✅
- **Substrate-native (VISION principle 9):** rides `/loop`; no scheduler. ✅
- **Lint harness:** `scripts/lint.sh` C1–C6 all PASS. ✅
