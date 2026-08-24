Reconcile: marketplace-mcp-server/core-server

Independent grader run. Diff graded is **uncommitted** in the working tree (`git status --short`: `M .lsa.yaml`, `?? mcp-server/`). Requirements and `.feature` files were read directly as ground truth, not via `grounding.md` prose.

## Coverage skeleton

`bash scripts/coverage-skeleton.sh .lsa/features/marketplace-mcp-server/core-server` enumerated F1-F7 as rows and every changed-in-repo file as a candidate hunk (git-status-wide, so it also listed unrelated pre-existing untracked items — `.lsa/.rag-index/`, `scripts/opencode-dist-*.sh`, `.lsa/pitches/marketplace-mcp-server.md` — which mtime-predate the `mcp-server/` implementation by hours and are out of scope for this epic's diff; see Step 4 below for the scoping rationale). The candidate hunks actually belonging to this epic's diff:

```
- [ ] .lsa.yaml
- [ ] mcp-server/.gitignore
- [ ] mcp-server/package-lock.json
- [ ] mcp-server/package.json
- [ ] mcp-server/src/index.js
- [ ] mcp-server/src/registry.js
- [ ] mcp-server/test/fixtures/malformed-skill/fixture-plugin/skills/bad-skill/SKILL.md
- [ ] mcp-server/test/fixtures/malformed-skill/fixture-plugin/skills/good-skill/SKILL.md
- [ ] mcp-server/test/verify.mjs
```

`git add -n mcp-server` stages exactly these 8 `mcp-server/` files (node_modules is `.gitignore`-excluded, confirmed via `git check-ignore -v`) — matching `.lsa.yaml`'s new `modules.mcp-server.artifact_paths` exactly.

## Does it work — scenario runs (3/3 required, N defaults to 3 since `reconcile.runs` is unset in `.lsa.yaml`)

Primary evidence: `node mcp-server/test/verify.mjs`, run 3 separate times, spawning a fresh real server over real stdio each run.

**Run 1:**
```
PASS  tools/list returns 18 tools — got 18: [actor-template, check, decompose, delegate, discover, doctor, flow-selector, ground-rules, implement, init, next, output, reconcile, reuse-first, revise-constitution, shape, specify, verify]
PASS  resources/list returns 17 resources — got 17
PASS  calling "ground-rules" tool returns byte-identical body — expected 11145 bytes, got 11145 bytes
PASS  reading lsa/knowledge/conventions.md resource returns byte-identical content — expected 6074 bytes, got 6074 bytes
[marketplace-mcp-server] skipping .../fixtures/malformed-skill/fixture-plugin/skills/bad-skill/SKILL.md: missing frontmatter "name"
[marketplace-mcp-server] registered 1 tools, 0 resources from fixture-plugin
PASS  malformed SKILL.md (missing frontmatter name) is skipped, startup does not crash — startup succeeded; registered tools: [good-skill]

ALL CHECKS PASSED
EXIT:0
```

**Run 2:** identical PASS lines and `ALL CHECKS PASSED`, `EXIT:0`.

**Run 3:** identical PASS lines and `ALL CHECKS PASSED`, `EXIT:0`.

3/3 for all four scenarios (`server-startup.feature` scenario 1 = tools/list=18 + resources/list=17 checks; scenario 2 = the malformed-skill fixture check; `tool-invocation.feature` = the ground-rules byte-identical check; `resource-read.feature` = the conventions.md byte-identical check).

Independent corroboration: a throwaway script written for this grading pass (`@modelcontextprotocol/sdk`'s `StdioClientTransport`, spawning `mcp-server/src/index.js` directly, not the implementer's `verify.mjs`), spot-checking a *different* tool (`doctor`, not `ground-rules`) and a *different* resource (`manager/knowledge/autonomy-policy.md`, not `lsa/knowledge/conventions.md`) than the implementer's own script exercised:

```
tools/list count: 18
tool names: actor-template, check, decompose, delegate, discover, doctor, flow-selector, ground-rules, implement, init, next, output, reconcile, reuse-first, revise-constitution, shape, specify, verify
resources/list count: 17
resource names: core/knowledge/fast-path-source-of-truth.md, core/knowledge/output-vocabulary.md, lsa/knowledge/conventions.md, lsa/knowledge/migration-instructions-ai.md, lsa/knowledge/model-routing.md, lsa/knowledge/pinned-library-specs.md, lsa/knowledge/quality-gate-contract.md, manager/knowledge/autonomy-policy.md, manager/knowledge/command-naming.md, manager/knowledge/epic-decomposition.md, manager/knowledge/parallel-dispatch.md, manager/knowledge/parallel-rollup.md, manager/knowledge/pitch-structure.md, manager/knowledge/roadmap-orchestration.md, manager/knowledge/role-adaptation.md, manager/knowledge/sequencing-heuristics.md, manager/knowledge/serialized-merge.md
doctor tool byte-identical: true (expected 7420, got 7420)
resource manager/knowledge/autonomy-policy.md byte-identical: true (expected 7313, got 7313)
INDEPENDENT CHECK: PASS
EXIT:0
```

Counts match the spec's stated inventory exactly: 18 = 6 core + 7 lsa + 5 manager tools; 17 = 2 core + 5 lsa + 10 manager resources.

## Quality gate

`bash scripts/gate.sh`:
```
=== .lsa.yaml gate: block ===
  PASS  docs-invariants  bash scripts/lint.sh → exit 0
  PASS  citations        bash scripts/check-citations.sh → exit 0
  PASS  links            bash scripts/check-links.sh → exit 0
  PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
  PASS  tests            bash scripts/run-tests.sh → exit 0
  PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0

gate: PASS — every configured check exited 0
```
Exit code: 0 (overall and every individual check).

## Requirement coverage (F1-F7)

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | register one tool per `SKILL.md`, name/description from frontmatter — `mcp-server/src/registry.js` (`scanSkills`), `mcp-server/src/index.js` (`registerTool` loop) | 3/3 (`tools/list` = 18, both implementer's `verify.mjs` and independent check) | ✅ |
| F2 | register one resource per knowledge file, keyed by source path — `mcp-server/src/registry.js` (`scanKnowledge`), `mcp-server/src/index.js` (`registerResource` loop) | 3/3 (`resources/list` = 17, both scripts) | ✅ |
| F3 | tool call returns byte-identical `SKILL.md` body — `mcp-server/src/index.js` (`skill.read()` = raw `readFileSync`, no transform) | 3/3 (`ground-rules` check via implementer's script) + independently confirmed on `doctor` via my own script | ✅ |
| F4 | resource read returns byte-identical knowledge content — `mcp-server/src/index.js` (`kf.read()` = raw `readFileSync`, no transform) | 3/3 (`lsa/knowledge/conventions.md` via implementer's script) + independently confirmed on `manager/knowledge/autonomy-policy.md` via my own script | ✅ |
| F5 | no outbound network / LLM API call while serving — `mcp-server/package.json` (only direct deps: `@modelcontextprotocol/sdk`, `gray-matter`), `mcp-server/src/index.js`, `mcp-server/src/registry.js` | Static: `grep -rn "fetch(\|https\?\.request\|axios\|XMLHttpRequest\|WebSocket\|anthropic\|openai" src/ test/verify.mjs` → no matches. `@hono/node-server`/`hono` present in `node_modules` only as a transitive dependency of the pinned `@modelcontextprotocol/sdk@1.30.0` (its package-lock `dependencies` block) — never imported by this repo's code (`index.js` imports only `server/mcp.js` and `server/stdio.js`), so its HTTP-transport code path is dead in this server. | ✅ |
| F6 | stdio only, no network listener — `mcp-server/src/index.js` (`StdioServerTransport` is the only transport constructed) | Static: `grep -rn "listen(\|createServer\|http\.\|net\.\|require(['\"]http\|require(['\"]net\|from ['\"]http\|from ['\"]net" src/ test/*.mjs` → no matches | ✅ |
| F7 | malformed frontmatter skipped, startup doesn't crash — `mcp-server/src/registry.js` (`name`/`description` type+non-empty checks, `continue` on failure), fixtures `mcp-server/test/fixtures/malformed-skill/fixture-plugin/skills/bad-skill/SKILL.md` (real missing-`name` frontmatter) and `.../good-skill/SKILL.md` (control), test `mcp-server/test/verify.mjs` Check 6 (spawns `buildServer` in-process against the fixture dir over a linked `InMemoryTransport`, asserts exactly 1 tool registered = `good-skill`, and that startup does not throw) | 3/3 (ran as part of every `verify.mjs` invocation) | ✅ |

Note on F7: verified this is tested against a genuine fixture, not merely asserted — read `mcp-server/test/fixtures/malformed-skill/fixture-plugin/skills/bad-skill/SKILL.md` directly: it has `description:` in frontmatter but no `name:` key at all, and `good-skill/SKILL.md` is a well-formed control in the same fixture tree. `verify.mjs` Check 6 builds a real server against this fixture directory and asserts only `good-skill` registers.

## Orphan hunks

- `mcp-server/package.json`, `mcp-server/package-lock.json` — dependency manifest for F1/F2/F7 (`gray-matter` parses frontmatter) and F5 (only two direct deps, both audited above). Not requirement-implementing code but necessary build surface, explicitly listed in `.lsa.yaml`'s `modules.mcp-server.artifact_paths`. Not treated as an orphan.
- `mcp-server/.gitignore` (`node_modules/`) — necessary Node-project scaffolding (keeps vendored deps out of git); zero business logic; explicitly listed in `.lsa.yaml`'s `modules.mcp-server.artifact_paths`. Not treated as an orphan.
- `mcp-server/test/verify.mjs`, `mcp-server/test/fixtures/malformed-skill/fixture-plugin/skills/{bad-skill,good-skill}/SKILL.md` — covering tests for F1-F4, F7 (see table above), not orphans.
- `.lsa.yaml` diff (new `modules.mcp-server` entry) — not a numbered F-requirement, but explicitly anticipated by `requirements.md`'s "Open assumption" section (a new `mcp-server` entry in `.lsa.yaml`'s `modules:` map, confirmed at `lsa:verify`). Not an orphan.

No file in the diff implements behavior outside F1-F7. No dead/unused source beyond the two files above, both accounted for as infrastructure.

Orphan hunks: none.

## All of the plan

F1-F7 each map to at least one implementing hunk and a passing (3/3) scenario or static check, per the table above. No requirement is unimplemented.

## Gate results

`bash scripts/gate.sh` → `gate: PASS — every configured check exited 0` (all 6 checks: docs-invariants, citations, links, project-map, tests, lib-pins — each exit 0).

## Verdict

reconcile: PASS @ uncommitted (repo HEAD at grading time: `c95b43a4632e3079829f9591a0f0fcc115cc1907` — this SHA predates the graded diff; nothing has been committed for this epic yet, so the diff graded is the working tree, not this SHA)
