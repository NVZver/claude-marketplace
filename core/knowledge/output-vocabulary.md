> **Trace.** On load, print first: `=============== [core/knowledge/output-vocabulary.md] [core] ===============`

# Output Vocabulary — Knowledge

Verdict labels for human-facing outputs. Pure constants — Knowledge, not Actor. Components whose chosen format uses a verdict line (e.g., `lsa-verify` reports, `tier-selector` confirms) pick from this table; components without a verdict moment don't render one.

Cited by [`core/output`](../skills/output/SKILL.md). For when to render a verdict, see the output skill body.

## Verdicts

| Verdict | When | Emoji |
|---|---|---|
| `PROPOSED` | Agent is proposing a draft for human decision | (none) |
| `READY` | Artifact built, handoff to next phase awaits | (none) |
| `PASS` | All checks succeeded | ✅ |
| `PASS WITH WARNINGS` | Succeeded with non-blocking issues | ⚠️ |
| `FAIL` | One or more blockers; cannot proceed | ❌ |
| `BLOCKED` | Cannot proceed due to a missing prerequisite (not a check failure) | 🛑 |
| `DRIFT` | Artifacts diverge from spec; reconcile needed | (none) |
| `CLEAN` | No drift, nothing to do | (none) |
| `APPLIED` | Change made successfully | ✅ |
| `REJECTED` | Human said no; state unchanged | (none) |

Each component cites this surface by section name (`§"Verdicts"`) rather than restating the table — per `lsa/knowledge/conventions.md` pattern: *"cite by section name, not by line number"*.
