> **Trace.** On load, print first: `=============== [lsa/knowledge/conventions.md] [lsa] ===============`

# LSA Conventions — Knowledge

Cross-cutting conventions every LSA skill applies. This file is **Knowledge**, not an Actor — it has no Goal / Input / Steps / Output / Constraints. LSA skills reference these conventions by section name rather than restating them.

For the operating constitution see [`../../vision/VISION.md`](../../vision/VISION.md). For fact-grounding rules see [`../../core/skills/ground-rules/SKILL.md`](../../core/skills/ground-rules/SKILL.md). For the `.lsa.yaml` schema see [`../ARCHITECTURE.md`](../ARCHITECTURE.md) §3.

---

## `.lsa.yaml` defaults

When `.lsa.yaml` is absent at the repo root, LSA applies these defaults:

```yaml
constitution: /CLAUDE.md
specs_root: /specs/
mode: code
modules: {}
```

LSA skills cite this section instead of restating the defaults inline.

---

## Read protocol

Every LSA skill begins with the same protocol — read in this order, print a one-line read-summary per source:

1. `.lsa.yaml` at repo root (or apply the defaults above).
2. The configured `${constitution}` (mandatory).
3. The skill-specific source list — each skill names its own list under its Steps.

If a source does not exist, note the gap rather than guessing. Per `core/skills/ground-rules/SKILL.md` Rule 3.

Observable result: per-source one-liner printed back to the human.

---

## Confirm gate types

Two gate shapes govern every human-in-the-loop interaction:

- **Hard Confirm.** Stop completely. Present the artifact. Do not proceed until the human explicitly approves. No implicit approval accepted.
- **Soft Confirm.** Present the artifact. Wait for approval or corrections. Human may approve, correct inline, or delegate corrections to agent. Proceed once human is satisfied.

Used by:
- **Hard:** `discover` Extended flow (`requirements.md`, `test-suites.md`), `plan` (`tasks.md`), `reconcile` (per module), `revise-constitution` (per change).
- **Soft:** `discover` Extended flow (`contract.yaml`, `design.md`).
