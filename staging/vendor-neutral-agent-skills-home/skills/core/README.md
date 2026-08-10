# Core

Six domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../../.lsa/constitution.md`](../../.lsa/constitution.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces 8 content rules — see the root [`AGENTS.md`](../../AGENTS.md) for the canonical list — from fact-grounding (every claim carries a source + searchable quote) through *done is a gate-proven, cited predicate*: an agent may report a completion state (`tests green`, `merged @ <sha>`, `deployed`) only when a deterministic gate proved it and the report cites the gate artifact; anything unproven is reported `attempted`/`unknown` with evidence attached.
- **`output`** — Apply to every human-facing output. **One hard rule + six pieces of guidance** — see the root [`AGENTS.md`](../../AGENTS.md). The hard rule is *Sourced* (Rule 4): every claim carries a source and citation, and the agent prints a one-line file-load trace for every marketplace instructional file it loads. The other six (structured, minimal, formatted, concrete, what-and-why preamble, show-changes-inline) are guidance — outcomes to aim for when they serve the answer, not a checklist every response must satisfy; a one-sentence factual reply needs a source, not a template. Two contracts worth knowing: every write/edit an agent performs is echoed back inline before commentary (**write → show → comment**), and approval-gated artifacts invert to **show → approve → write** — nothing lands on disk before its gate. This file is the single marketplace-wide source of truth for output discipline; other plugins cite it rather than restating it.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.
- **`flow-selector`** — Apply before any non-trivial task. Classifies the work as Quick / Standard / Extended by chain-of-thought reasoning over Vision §4 boundary signals, then waits for human confirmation before any LSA ceremony fires.
- **`reuse-first`** — Apply on any coding task before writing code. Walks a 7-rung reuse ladder — understand the real flow → YAGNI → existing in-codebase helper (grep first) → stdlib/builtin → native platform feature → already-installed dependency → shortest working diff — and stops at the first rung that holds, so the change reuses over rewrites and adds only the minimum. Carries the root-cause-not-symptom bug rule (fix once in the shared path, not per-symptom). Silent on prose/analysis tasks that author no code.
- **`doctor`** — Run after install, or whenever something seems broken ("is my install wired?", "health check"). Four fixed read-only diagnostic checks — required packs discoverable (`core` + `lsa`), the always-on card present in the project's `AGENTS.md`, installed skill content vs the source repo, and the repo's own gate scripts — reported as a per-check PASS / WARN / FAIL / SKIP table with the evidence actually observed and a one-line fix per failure. A check that isn't determinable in the current environment reports an honest WARN/SKIP, never a guessed PASS. Read-only: it reports and instructs, never repairs. Surfaced as `/core:doctor`.

Per-release history for every rule change lives in [`CHANGELOG.md`](CHANGELOG.md).

## Knowledge

- **[`knowledge/output-vocabulary.md`](knowledge/output-vocabulary.md)** — The canonical marketplace verdict labels (PROPOSED, DRIFT, APPLIED, PASS, FAIL, etc.) cited by `core/output`.
- **[`knowledge/fast-path-source-of-truth.md`](knowledge/fast-path-source-of-truth.md)** — The shared single-source-of-truth navigation fast-path contract: a navigation-class question ("what's next", "how do I get started") maps to one source-of-truth file at a known path → direct `Read` + cited `file:line` quote-back, no sub-agent / `context7` / multi-round `Grep`. Exact-phrase detection (not semantic similarity); any failure falls through to the deep-research path unchanged. Cited by `manager:next` and the `project-manager` agent.

## Install

```
npx skills add <org>/<repo> --skill core/ground-rules --skill core/output --skill core/actor-template --skill core/flow-selector --skill core/reuse-first --skill core/doctor
```

Fans the six `core` skills into your agent host's own skills directory. See the root [`CONTRIBUTING.md`](../../CONTRIBUTING.md) for the manual-copy fallback if `npx skills` isn't available. Once installed, invoke directly (`/core:ground-rules`, `/core:output`, etc., on hosts with slash-command support) or let the host trigger them by description match.

### Add the always-on card

Copy the "Ground rules" / "Output" / "Flow selection" / "Reuse-first" sections from the root [`AGENTS.md`](../../AGENTS.md) into your project's own `AGENTS.md` (or your host's equivalent always-on file) — or whichever path your `.lsa.yaml` configures as the constitution. It's the ONE always-on card (≤45 lines): the eight `ground-rules` one-liners, the hard `core/output` rule (source + quote, plus the file-load trace), `flow-selector`'s three flows with the five boundary signals, a `reuse-first` ladder pointer, a pointer to `.lsa/constitution.md` §2 principle 10 (*deterministic work is scripted*), and the loading discipline (cite-without-loading + escalation triggers). Discipline applies from the card alone; the full SKILL.md files load only on a card-listed escalation trigger.

## Manual install (no CLI)

Each skill is a self-contained directory — copy what you need directly:

```bash
cp -r skills/core/ground-rules /path/to/your/project/.agents/skills/
```

No build step, no zip, no upload flow — the skill directory (`SKILL.md` + any bundled `references/`/`scripts/`/`assets/`) is the whole artifact. Where your host scans for skills (`.agents/skills/`, `.claude/skills/`, or another path) depends on the host — see its own docs.
