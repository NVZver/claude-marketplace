Shaped by: product-manager (role lens: developer-tooling product manager, plugin-distribution / installer-bootstrap)
Date: 2026-08-19
Status: approved
Gate decisions:
  - Role: accepted (developer-tooling product manager, plugin-distribution / installer-bootstrap lens)
  - Packaging: run-in-place, no copy — RAG engine files stay inside the `lsa` plugin's own shipped tree; bootstrap invokes `docker build` with build context `$CLAUDE_PLUGIN_ROOT`, writing only small repo-owned config (gate: entries, .gitignore line, hook path) into the target repo
  - Bootstrap trigger: SessionStart hook detects + offers a single command; the actual build/index/wiring runs inside that command's skill invocation (unbounded time budget), not inside the capped hook
  - Canonical/historical config: moved to a `.lsa.yaml` config block (capped, like the existing `libs:` block), auto-seeded at bootstrap from the repo's own `modules.*.artifact_paths`
Why now: the RAG context engine works today but only as repo-local tooling for claude-marketplace itself (roadmap row `rag-context-engine-and-repo-indexing`, `.lsa/roadmap.yaml:562-580`); the owner wants it reusable in every repo `lsa@NVZver` installs into, not just this one, and raised the ask directly this session, before the repo-local shape hardens further and portability retrofitting gets more expensive.

# RAG plugin plug-and-play

Make the RAG context engine — currently repo-local tooling in claude-marketplace's own root — a true plug-and-play capability of the `lsa` plugin: install `lsa@NVZver` into any repo, Docker installed is the only external prerequisite, everything else happens automatically.

## Problem

`lsa:init` (`lsa/skills/init/SKILL.md:16`, Goal: *"Stand up the LSA spec tree"*) exists today and scaffolds `main.spec.md`, `roadmap.yaml`, `modules/`, `project-map.yaml` — it does nothing RAG-related. The entire RAG pipeline — `Dockerfile`, `docker/rag_cli.py`, `scripts/rag-index.sh`, `scripts/rag-query.sh`, `scripts/check-rag-index-fresh.sh`, `scripts/check-rag-index-matches-head.sh`, `.githooks/pre-commit` — lives at claude-marketplace's own repo root, not inside `lsa/`. Confirmed against `.lsa.yaml`'s `lsa` module `artifact_paths` (`.lsa.yaml:75-88`, `lsa/skills/**`, `lsa/knowledge/**`, `lsa/scripts/**`, `lsa/hooks/**`, etc.): none of it covers `docker/` or root-level `scripts/rag-*.sh`. Installing `lsa@NVZver` into any other repo today brings zero RAG capability with it.

Even the one currently-working piece needs a manual step: enabling the pre-commit hook is `git config core.hooksPath .githooks`, run by hand (`CONTRIBUTING.md:66-70`, *"One command enables it — no installer script, since that's the whole point of `core.hooksPath`"*). `.lsa.yaml`'s `gate:` entries (`rag-index-fresh`, `rag-index-matches-head`, `.lsa.yaml:21-22`) and the `.gitignore` entry for `.lsa/.rag-index/` (`.gitignore:18`) were both hand-authored for this repo, once.

A second, sharper blocker lives in the code itself: `docker/rag_cli.py`'s `CANONICAL_PATH_PREFIXES` (`docker/rag_cli.py:592-611`) hardcodes claude-marketplace's own directory names (`lsa/`, `core/`, `manager/`, `prompt-engineer/`, `observer/`, `.lsa/VISION.md`, `docker/`, `scripts/`, etc.) as the canonical-vs-historical classification table for search ranking. Dropped into an unrelated repo, this list is meaningless — every chunk would default to `"historical"` (the documented safety default, `docker/rag_cli.py:588`), silently degrading ranking quality with no signal that anything is wrong.

Current workaround: none exists. The only way to get RAG in a second repo today is to hand-copy seven files, hand-run `git config core.hooksPath`, hand-edit `.lsa.yaml`'s `gate:` block, and hand-edit `.gitignore` — a multi-file, multi-step manual runbook. That is precisely what's explicitly rejected for this pitch.

**Definition of success:** installing `lsa@NVZver` into any git repo where Docker is installed results in — with no file copying and no manual setup steps beyond invoking the resolved bootstrap trigger — a working local Docker image, an initial repo index, active git-hook wiring, `.lsa.yaml gate:` entries, and a `.gitignore` entry, all present and correct.

## Appetite

**Big batch — a full cycle.** This is packaging + bootstrap + genericization of already-working logic, not new retrieval engineering. Reuse, don't rebuild: this repo already has real, working two-tier Docker rebuild logic, gitignore-aware exclusion, hybrid dense+lexical retrieval, and path-scoped/sha-pinned query modes (`docker/rag_cli.py`, `scripts/rag-index.sh:72-143`) — none of that is in appetite to redesign.

In appetite: packaging mechanism (how plugin-shipped files reach a repo the plugin doesn't own), a bootstrap trigger, genericizing `CANONICAL_PATH_PREFIXES`/`ARCHIVE_PATH_PREFIX`, and migrating this repo itself onto the new mechanism (first dogfood consumer).

Out of appetite: any container runtime other than Docker; rebuilding chunking/embedding/retrieval logic; auto-upgrade/resync of an already-bootstrapped repo when the plugin ships a newer RAG version; non-git repos; repos that have never run `lsa:init`.

## Solution sketch

- **Key user interactions:** install `lsa@NVZver` (already the existing install step, `AGENTS.md` "Default plugins") into any repo with Docker running → the `SessionStart` hook detects "Docker present, RAG not yet bootstrapped" and offers a single command → invoking it runs the image build, initial index, hook wiring, gate entries, and `.gitignore` entry unattended → the user never opens `docker/rag_cli.py` or copies a file.
- **Main components:** `lsa/.claude-plugin/plugin.json` (currently v0.36.0, `lsa/.claude-plugin/plugin.json:4`), `.lsa.yaml`'s `modules.lsa.artifact_paths` (`.lsa.yaml:75-88`) and `gate:` block (`.lsa.yaml:14-22`), `lsa/hooks/hooks.json` (`SessionStart`, currently one entry, `lsa/hooks/hooks.json:4-15`), the RAG pipeline files (relocated into the plugin's own shipped tree, run in place via `$CLAUDE_PLUGIN_ROOT` — packaging fork resolved), a new `.lsa.yaml` canonical-paths config block (auto-seeded from `modules.*.artifact_paths` — config fork resolved).
- **Critical path:** plugin installs → `SessionStart` hook detects "Docker present, RAG not yet bootstrapped in this repo" and prints a one-line offer → invoking the offered command builds the image (context `$CLAUDE_PLUGIN_ROOT`), runs the initial full-repo index, wires the git hook, writes `.lsa.yaml gate:` + canonical-paths config + `.gitignore` entries → a search-heavy skill's next `rag-query.sh` call succeeds.

## Rabbit holes

1. **SessionStart hook timeout vs. Docker build time.** This repo's existing `SessionStart` hook caps at 10 seconds (`lsa/hooks/hooks.json:11`) and must exit fast — a first-time Docker image build (base image pull, pip installs, baking embedding-model weights) is realistically multi-minute. Resolved: heavy bootstrap work stays inside a normal skill invocation (unbounded time budget, real progress, resumable) — the hook only detects and offers.
2. **Docker build context outside the target repo is untested in this codebase.** Every existing plugin-shipped script (`lsa/scripts/project-map-build.sh`, `lsa/hooks/session-start-drift-check.sh`) only reads the target repo and writes small text/YAML into it — none invokes `docker build`/`docker run` against a path outside the repo it's scoped to. Needs a spike before the packaging mechanism epic locks its exact implementation.
3. **Migrating this repo's own dogfood instance mid-flight** without breaking already-wired `.lsa.yaml gate:` entries (`.lsa.yaml:21-22`) or the CI check in `.github/workflows/lint.yml` that depends on them — this repo becomes the first consumer of its own new mechanism, so the cutover itself needs a non-breaking sequencing plan.
4. **Silent-weak default.** `CANONICAL_PATH_PREFIXES` defaulting unconfigured repos to "historical" (deliberate safety default, `docker/rag_cli.py:588`) is safe but silently weak — a freshly bootstrapped repo gets zero canonical-boost until the auto-seeded config lands. Mitigation: an explicit first-run notice, not a silent no-op.
5. **No uninstall/opt-out story addressed here.** Plugin uninstall does not automatically undo `git config core.hooksPath`, the `.gitignore` entry, or the built Docker image. Flagged as a real gap, deliberately out of this pitch's appetite.

## No-gos

1. This pitch does NOT support any container runtime other than Docker — Docker is the owner's explicitly locked-in only external prerequisite.
2. This pitch does NOT rebuild chunking, embedding, vector-store, or hybrid-retrieval logic — reused as-is from the existing working implementation.
3. This pitch does NOT auto-upgrade or resync an already-bootstrapped repo when the plugin later ships a newer RAG version — first-bootstrap only; a separate roadmap item if drift becomes a real problem.
4. This pitch does NOT handle non-git repos, or repos that have never run `lsa:init` — bootstrap assumes (or itself runs) `lsa:init` first.
