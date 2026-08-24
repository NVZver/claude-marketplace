---
name: bootstrap-rag
description: Bootstrap RAG search for a target repo in one invocation — build the plugin-shipped image, run the initial index, wire the portable git hook, seed canonical-paths config, and write gate: entries + .gitignore. Output — a fully working, unattended RAG setup for the target repo.
---

> **Trace.** On load, print first: `=============== [lsa/skills/bootstrap-rag/SKILL.md] [lsa] ===============`

# LSA Bootstrap RAG

See [CORE.md](../../CORE.md).

## Role

RAG setup installer.

## Goal

Given a target repo with Docker installed and `lsa:init` already run, make RAG search a working, plug-and-play capability of that repo in one invocation — no further manual step from the user.

## Inputs

| Input | Source |
|-------|--------|
| Target repo path (default: current repo root) | `self` / caller |
| `.lsa.yaml` (`modules:` block from `lsa:init`) | target repo |
| Docker installed and reachable | environment |

## Steps

1. Resolve the target repo path — default to the current repo root (`git rev-parse --show-toplevel`) unless the caller names a different one.
2. Run the shipped bootstrap script — prefer `bash "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-rag.sh" <target-repo-path>` when `CLAUDE_PLUGIN_ROOT` points at the installed `lsa` plugin; otherwise `bash lsa/scripts/bootstrap-rag.sh <target-repo-path>` from a marketplace checkout (same dual-mode precedent `lsa/skills/init/SKILL.md` Step 5 uses). It builds the plugin-shipped image and runs the initial full index (`lsa/scripts/rag-index.sh`), seeds `rag: canonical_paths:` (`lsa/scripts/seed-canonical-paths.sh`, epic 2 — reused, not reimplemented), sets `git config core.hooksPath` to this plugin's own hooks directory, appends `rag-index-fresh`/`rag-index-matches-head` to the target's `.lsa.yaml` `gate:` block, and appends a `.lsa/.rag-index/` entry to the target's `.gitignore`. (→ working RAG setup)
3. Report the script's final one-line summary verbatim. On a non-zero exit, surface the script's stderr message as-is — do not retry silently, do not swallow the failure, do not claim success.

## Output

A target repo with: a built `rag-index-plugin:local` Docker image, a fresh index at `<target-repo>/.lsa/.rag-index/`, `core.hooksPath` wired to the plugin's own hooks directory, `.lsa.yaml`'s `gate:` block carrying `rag-index-fresh`/`rag-index-matches-head`, `.lsa.yaml`'s `rag: canonical_paths:` seeded, and `.gitignore` carrying a `.lsa/.rag-index/` entry — or a clear, cited failure naming which step did not complete.

## Constraints

- **Requires `lsa:init` already run** against the target repo (a `.lsa.yaml` with a `modules:` block) — this skill does not scaffold the spec tree itself; `bootstrap-rag.sh` errors out by name if `.lsa.yaml` is missing.
- **Requires Docker** installed and reachable — a build/index failure (including Docker unreachable) is a real, reported failure, never swallowed.
- **Targets the repo you're pointed at.** The default target is the CURRENT repo the skill is invoked from, same as any other LSA skill — do not run this against a repo the caller did not name or confirm.
- **Idempotent by construction.** Re-running is safe: `seed-canonical-paths.sh` merges (never destroys) existing entries, and the `gate:`/`.gitignore` appends skip entries that are already present rather than duplicating them.

---

`/lsa:bootstrap-rag` — manual invocation.
