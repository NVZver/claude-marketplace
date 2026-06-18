> **Trace.** On load, print first: `=============== [.lsa/modules/prompt-engineer/spec.md] [vision] ===============`

# Module Spec — `prompt-engineer`

Prompt-engineering discipline for the marketplace's own prompt files. An agent + commands enforce quality rules across Actors (agents, commands) and Knowledge files; the knowledge files hold the rule categories.

**Plugin manifest:** [`prompt-engineer/.claude-plugin/plugin.json`](../../../prompt-engineer/.claude-plugin/plugin.json) (v0.7.3)
**Plugin README** (install, command table, rule categories): [`prompt-engineer/README.md`](../../../prompt-engineer/README.md)
**Per-agent behavior** (source of truth): [`prompt-engineer/agents/prompt-engineer.md`](../../../prompt-engineer/agents/prompt-engineer.md)
**Per-command behavior** (source of truth): [`prompt-engineer/commands/`](../../../prompt-engineer/commands/) — `prompt-review`, `prompt-optimize`, `prompt-create`
**Knowledge** (six rule categories across three files): [`prompt-engineer/knowledge/`](../../../prompt-engineer/knowledge/)
**Verification probes:** [`prompt-engineer/VERIFICATION.md`](../../../prompt-engineer/VERIFICATION.md) and [`prompt-engineer/tests/repo-anchored.md`](../../../prompt-engineer/tests/repo-anchored.md)

## Role in the marketplace

`prompt-engineer` is the quality-enforcement surface for the marketplace's own prompt files. It reviews, optimizes, and scaffolds Actors and Knowledge files against a fixed rule set, reporting findings with severity + rule citation rather than rewriting silently.

Cites `core` for output discipline:

- `core/output` Rule 7 (show-changes-inline) — the `prompt-review` command carries the **author-time** enforcement (Step 3 item `l`). The prior claim of a PR-time half in `lsa:verify` was dropped in v0.7.0 (removed from `core` in v0.13.0 as unimplemented — no automated PR-time check exists today; the human reviewing the turn is the runtime backstop). Cited directly in all three of `prompt-engineer/commands/{prompt-review,prompt-optimize,prompt-create}.md` (linking `core/skills/output/SKILL.md`).

This relationship is reciprocal: `core`'s Rule 7 invariant (`.lsa/modules/core/spec.md`) names `prompt-engineer:prompt-review` as its sole warning-only regression check.

## Invariants

- **Versioning.** `prompt-engineer` evolves with its own SemVer + CHANGELOG (`.lsa/VISION.md` §1 *"Distribution + versioning"*). Currently v0.7.3.
- **Gate-delivery — show → approve → write (prompt-engineer v0.7.0).** Adopts `core` v0.13.0 (`.lsa/modules/core/spec.md`, Rule 7 *Authorization boundary*). `prompt-create` quotes the generated prompt content through a rendered channel, takes approval, and writes the file **only on approve** — a generated prompt is an approval-gated artifact, not written before its gate. Per `prompt-engineer/commands/prompt-create.md`.
- **Markdown-only.** No `/src/`; the plugin is pure Markdown plus the JSON manifest. Per `.lsa/standards/code.md`.
- **Spec source-of-truth.** Behavior is owned by `prompt-engineer/agents/prompt-engineer.md` + `prompt-engineer/commands/*.md` (Actors) and `prompt-engineer/knowledge/*.md` (rules); this module spec carries module-level invariants only — not a per-rule catalog (that's the knowledge files).
- **Separation of Concerns — self-applied.** Actors reference knowledge files and never restate their rules; the agent was de-inlined to satisfy its own doctrine (161 → 58 lines, v0.2.0). The doctrine is canonical in `prompt-engineer/knowledge/separation-of-concerns.md`; a boundary violation is always HIGH.
- **Rule categories are canonical in knowledge.** The six categories — actor ground rules (10), knowledge quality checks (6), separation of concerns (5 boundary violations), KISS/DRY (5), AI over-engineering (5), context budget (4) — live across the **three** `prompt-engineer/knowledge/*.md` files: `actor-ground-rules.md` (actor ground rules), `separation-of-concerns.md` (separation of concerns), and `quality-checks.md` (which bundles knowledge quality checks, KISS/DRY, AI over-engineering, and context budget). Commands reference them by path; they are not restated in Actors.
- **Show-changes-inline author-time check.** `prompt-review` Step 3 item `l` flags any write/edit/mark step in a `**/SKILL.md` or `**/agents/*.md` source that lacks a show-changes directive — warning-only, the author-time half of `core/output` Rule 7. Per `prompt-engineer/commands/prompt-review.md:39`.
- **Testability (v0.4.0).** `prompt-engineer/tests/repo-anchored.md` pins behavior to current repo files (each probe cites a `file:line` source of truth); `prompt-engineer/VERIFICATION.md` holds portable probes + a falsifiable trigger threshold, mirroring `core`'s harness. The B3/B4 behavioral probes were calibrated against a fresh reviewer.
