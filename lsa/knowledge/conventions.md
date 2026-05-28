> **Trace.** On load, print first: `=============== [lsa/knowledge/conventions.md] [lsa] ===============`

# LSA Conventions — Knowledge

Cross-cutting conventions every LSA skill applies. This file is **Knowledge**, not an Actor — it has no Goal / Input / Steps / Output / Constraints. LSA skills reference these conventions by section name rather than restating them.

For the operating constitution see [`../../.lsa/VISION.md`](../../.lsa/VISION.md). For fact-grounding rules see [`../../core/skills/ground-rules/SKILL.md`](../../core/skills/ground-rules/SKILL.md). For the `.lsa.yaml` schema see [`../ARCHITECTURE.md`](../ARCHITECTURE.md) §3.

---

## `.lsa.yaml` defaults

When `.lsa.yaml` is absent at the repo root, LSA applies these defaults:

```yaml
constitution: .lsa/VISION.md
specs_root: .lsa/
mode: code
modules: {}
```

The default workspace lives entirely under `.lsa/` so a user can `rm -rf .lsa/` to fully detach from LSA. The constitution sits inside that workspace as `.lsa/VISION.md`. Projects with a pre-existing `/CLAUDE.md` constitution or a `/specs/` spec tree should set `constitution` and `specs_root` explicitly in `.lsa.yaml`.

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

## Library documentation protocol

When any LSA skill needs to call a library API it is unsure about:

1. Check available tools for `resolve-library-id` (context7 MCP).
2. **If context7 available:** read `package.json` (or equivalent) for the library version → call `resolve-library-id` → call `query-docs` with the specific API question. Cite as `lib:<name>:<api> via context7`.
3. **If no context7:** use `WebSearch` for official docs (prefer `.md` over `.html`). Cite as `lib:<name>:<api> via <url>`.
4. **If nothing found:** state it. Use codebase patterns and types. Never guess API signatures.

Skills that perform discovery (`lsa:discover`) do this proactively; execution skills (`lsa:implement`) do this only when an unknown API is encountered mid-work.

---

## Output discipline

All LSA skill outputs follow [`core/output`](../../core/skills/output/SKILL.md) — citation by link, never restated. No LSA skill restates the seven golden rules inline; it cites `core/output` by section or rule number.

---

## AskUserQuestion convention

When a skill presents a decision to the human inside Claude Code, it uses `AskUserQuestion` per `core/CLAUDE.md` operational checkpoint #1. The decision block is formatted per [`core/output`](../../core/skills/output/SKILL.md) (Rule 5 for picker prompts, Rule 6 for verdicts). Skills cite this convention instead of restating the checkpoint reference and formatting instruction.

---

## Prompt voice convention

Picker prompts follow [`core/output`](../../core/skills/output/SKILL.md) Rule 5. The picker **question** names the feature subject in real-world terms (e.g., *"Approve the requirements for `<feature-name>`?"*), not internal jargon (e.g., not *"Approve F1/F2/F3?"*). Option **labels** name the outcome, not the mechanism. Skills cite this convention instead of inlining the Rule 5 coaching block.
