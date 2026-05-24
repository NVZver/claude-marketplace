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

## Library documentation protocol

When any LSA skill needs to call a library API it is unsure about:

1. Check available tools for `resolve-library-id` (context7 MCP).
2. **If context7 available:** read `package.json` (or equivalent) for the library version → call `resolve-library-id` → call `query-docs` with the specific API question. Cite as `lib:<name>:<api> via context7`.
3. **If no context7:** use `WebSearch` for official docs (prefer `.md` over `.html`). Cite as `lib:<name>:<api> via <url>`.
4. **If nothing found:** state it. Use codebase patterns and types. Never guess API signatures.

Skills that perform discovery (`lsa:discover`) do this proactively; execution skills (`lsa:implement`) do this only when an unknown API is encountered mid-work.
