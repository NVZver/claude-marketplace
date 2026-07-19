# Core

Six domain-neutral discipline skills that make output trustworthy and any actor (skill / slash command / workflow) follow a single, observable shape. For the "why" behind this package, see [`../.lsa/VISION.md`](../.lsa/VISION.md).

## What's here

- **`ground-rules`** — Apply on every substantive task. Enforces 8 content rules — see [`core/CLAUDE.md`](./CLAUDE.md) for the canonical list — from fact-grounding (every claim carries a source + searchable quote) through *done is a gate-proven, cited predicate*: an agent may report a completion state (`tests green`, `merged @ <sha>`, `deployed`) only when a deterministic gate proved it and the report cites the gate artifact; anything unproven is reported `attempted`/`unknown` with evidence attached.
- **`output`** — Apply to every human-facing output. **One hard rule + six pieces of guidance** — see [`core/CLAUDE.md`](./CLAUDE.md). The hard rule is *Sourced* (Rule 4): every claim carries a source and citation, and the agent prints a one-line file-load trace for every marketplace instructional file it loads. The other six (structured, minimal, formatted, concrete, what-and-why preamble, show-changes-inline) are guidance — outcomes to aim for when they serve the answer, not a checklist every response must satisfy; a one-sentence factual reply needs a source, not a template. Two contracts worth knowing: every write/edit an agent performs is echoed back inline before commentary (**write → show → comment**), and approval-gated artifacts invert to **show → approve → write** — nothing lands on disk before its gate. This file is the single marketplace-wide source of truth for output discipline; other plugins cite it rather than restating it.
- **`actor-template`** — Apply when authoring or editing a Skill, slash command, or workflow. Enforces the Goal / Input / Steps / Output / Constraints shape and demands every Step produce an observable result.
- **`flow-selector`** — Apply before any non-trivial task. Classifies the work as Quick / Standard / Extended by chain-of-thought reasoning over Vision §4 boundary signals, then waits for human confirmation before any LSA ceremony fires.
- **`reuse-first`** — Apply on any coding task before writing code. Walks a 7-rung reuse ladder — understand the real flow → YAGNI → existing in-codebase helper (grep first) → stdlib/builtin → native platform feature → already-installed dependency → shortest working diff — and stops at the first rung that holds, so the change reuses over rewrites and adds only the minimum. Carries the root-cause-not-symptom bug rule (fix once in the shared path, not per-symptom). Silent on prose/analysis tasks that author no code.
- **`doctor`** — Run after install, or whenever something seems broken ("is my install wired?", "health check"). Four fixed read-only diagnostic checks — required plugins installed (`core` + `lsa`), the [`core/CLAUDE.md`](./CLAUDE.md) always-on fragment merged into the project `CLAUDE.md`, installed plugin versions vs their source manifests, and the marketplace gate scripts — reported as a per-check PASS / WARN / FAIL / SKIP table with the evidence actually observed and a one-line fix per failure. A check that isn't determinable in the current environment reports an honest WARN/SKIP, never a guessed PASS. Read-only: it reports and instructs, never repairs. Surfaced as `/core:doctor`.

Per-release history for every rule change lives in [`CHANGELOG.md`](./CHANGELOG.md).

## Knowledge

- **[`knowledge/output-vocabulary.md`](./knowledge/output-vocabulary.md)** — The canonical marketplace verdict labels (PROPOSED, DRIFT, APPLIED, PASS, FAIL, etc.) cited by `core/output`.
- **[`knowledge/fast-path-source-of-truth.md`](./knowledge/fast-path-source-of-truth.md)** — The shared single-source-of-truth navigation fast-path contract: a navigation-class question ("what's next", "how do I get started") maps to one source-of-truth file at a known path → direct `Read` + cited `file:line` quote-back, no sub-agent / `context7` / multi-round `Grep`. Exact-phrase detection (not semantic similarity); any failure falls through to the deep-research path unchanged. Cited by `manager:next` and the `project-manager` agent.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install core@NVZver
/reload-plugins
```

Invoke directly via `/core:ground-rules`, `/core:output`, `/core:actor-template`, `/core:flow-selector`, `/core:reuse-first`, or `/core:doctor`, or let Claude trigger them automatically by description match. Run `/reload-plugins` after editing skill files to pick up changes without restart.

### Merge the CLAUDE.md fragment

Copy the content of [`core/CLAUDE.md`](./CLAUDE.md) into your project's `/CLAUDE.md` (Claude Code) or `/AGENTS.md` (any other agent tool) — or whichever path your `.lsa.yaml` configures as the constitution. The fragment is the ONE always-on card (≤45 lines): the eight `ground-rules` one-liners, the hard `core/output` rule (source + quote, plus the file-load trace), `flow-selector`'s three flows with the five boundary signals, a `reuse-first` ladder pointer, a pointer to `.lsa/VISION.md` §2 principle 10 (*deterministic work is scripted*), and the loading discipline (cite-without-loading + escalation triggers). Discipline applies from the card alone; the full SKILL.md files load only on a card-listed escalation trigger.

## Install on Claude.ai

Each skill uploads separately (Claude.ai's native model). From the repo root:

```bash
cd core/skills && zip -r ground-rules.zip ground-rules/ && zip -r actor-template.zip actor-template/
```

Then in Claude.ai → **Settings → Features → Custom Skills**, upload `ground-rules.zip` and `actor-template.zip` separately.

Per Anthropic docs (`platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`): *"Custom Skills do not sync across surfaces. Skills uploaded to one surface are not automatically available on others."* The upload is one-time, per user; there is no organization-wide distribution path on Claude.ai today.
