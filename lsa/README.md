# LSA — Living Spec Architecture

Spec-first development methodology installable as a Claude Code plugin. Specs are the permanent source of truth; every code change traces to a spec requirement; human gates at every phase. For the design rationale, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## What's here

- **`lsa-init`** — Initialize `/specs/` structure on a project. Greenfield or brownfield.
- **`lsa-specify`** — Create a feature spec from a description, with hard/soft confirm gates per file.
- **`lsa-plan`** — Decompose an approved spec into ≤5 parallel-safe epics.
- **`lsa-verify`** — Verify every code change traces to a spec requirement. Block untraced changes.
- **`lsa-sync`** — Extract delta into permanent module specs; archive feature spec.
- **`lsa-revise-constitution`** — Propose and apply changes to `/CLAUDE.md` and `/specs/standards/` only.

## Install on Claude Code

```
/plugin marketplace add NVZver/claude-marketplace
/plugin install lsa@nz-vision
/reload-plugins
```

Invoke directly via `/lsa:init`, `/lsa:specify`, etc., or let Claude trigger by description match.

## Install on Claude.ai

LSA writes spec files to disk and reads `/CLAUDE.md` — it depends on a filesystem. **Not recommended for Claude.ai** in v0.1.0; the skills will trigger by description but cannot complete their I/O.

## Naming note

LSA's `/specs/standards/` directory holds technical standards (`code.md`, `testing.md`, `agents.md`) extracted from the project's `/CLAUDE.md`. It is **not** the same as the [`core/ground-rules`](../core/skills/ground-rules/) skill — Core's `ground-rules` enforces four discipline rules (fact-grounding, no fake-confidence hedging, read-the-source, only-required-output) on every prompt. The two coexist in the marketplace and are independently installable.
