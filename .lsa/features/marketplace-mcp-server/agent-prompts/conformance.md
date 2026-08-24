Reconcile: marketplace-mcp-server/agent-prompts

Independent grader run. Diff graded is **uncommitted** in the working tree
(`git status --short` at grading time: `M mcp-server/src/index.js`,
`M mcp-server/src/registry.js`, `M mcp-server/test/verify.mjs`,
`?? mcp-server/test/fixtures/malformed-agent/`, plus `?? .lsa/features/marketplace-mcp-server/agent-prompts/`
which is this epic's own spec directory — excluded from the graded diff,
same convention as `core-server`'s reconcile). `requirements.md`,
`prompt-startup.feature`, and `prompt-request.feature` were read directly
as ground truth, not via `grounding.md` prose. This is an additive change
on top of the already-reconciled `core-server` epic
(`.lsa/features/marketplace-mcp-server/core-server/conformance.md`:
`reconcile: PASS` — 18 tools + 17 resources).

## Coverage skeleton

`bash scripts/coverage-skeleton.sh .lsa/features/marketplace-mcp-server/agent-prompts`
is git-status-wide (mirrors `core-server`'s reconcile), so it also listed
unrelated pre-existing untracked items out of scope for this epic:
`.lsa/.rag-index/` (hundreds of index-artifact entries) and
`scripts/opencode-dist-deploy.sh` / `scripts/opencode-dist-generate.sh`
(unrelated concurrent workstream). The candidate hunks actually belonging
to this epic's diff:

```
- [ ] mcp-server/src/index.js
- [ ] mcp-server/src/registry.js
- [ ] mcp-server/test/fixtures/malformed-agent/bad-agent.md
- [ ] mcp-server/test/fixtures/malformed-agent/good-agent.md
- [ ] mcp-server/test/verify.mjs
```

`git status --short mcp-server/` confirms exactly these 5 files changed or
added (no `.lsa.yaml` change this cycle — the `mcp-server` module entry
already exists from `core-server`; `artifact_paths` already covers
`mcp-server/src/**/*.js`, `mcp-server/test/**/*.mjs`, and
`mcp-server/test/fixtures/**/*.md`, so no config change was needed for
this epic).

## Does it work — scenario runs (3/3 required, N defaults to 3 since `reconcile.runs` is unset in `.lsa.yaml`)

Three scenarios total: `prompt-startup.feature` has 2 ("Registers one
prompt per first-slice agent file", "Skips a malformed agent file without
crashing startup"); `prompt-request.feature` has 1 ("Requesting a
registered prompt returns the exact source Markdown, with no server-side
execution").

**Primary evidence:** `node mcp-server/test/verify.mjs`, run 3 separate
times, spawning a fresh real server over real stdio each run.

**Run 1:**
```
PASS  tools/list returns 18 tools — got 18: [...]
PASS  resources/list returns 17 resources — got 17
PASS  calling "ground-rules" tool returns byte-identical body — expected 11145 bytes, got 11145 bytes
PASS  reading lsa/knowledge/conventions.md resource returns byte-identical content — expected 6074 bytes, got 6074 bytes
PASS  prompts/list returns exactly 3 prompts (product-manager, project-manager, orchestrator) — got 3: [orchestrator, product-manager, project-manager]
PASS  requesting the "project-manager" prompt returns byte-identical content — expected 14434 bytes, got 14434 bytes
PASS  no outbound network / LLM SDK call in src/index.js or src/registry.js — no match for fetch/http/net/axios/websocket/anthropic/openai patterns
PASS  malformed SKILL.md (missing frontmatter name) is skipped, startup does not crash — startup succeeded; registered tools: [good-skill]
PASS  malformed agent file (missing frontmatter name) is skipped, startup does not crash — startup succeeded; registered prompts: [good-agent]

ALL CHECKS PASSED
EXIT:0
```

**Run 2:** identical PASS lines and `ALL CHECKS PASSED`, `EXIT:0`.

**Run 3:** identical PASS lines and `ALL CHECKS PASSED`, `EXIT:0`.

3/3 for the prompt-related checks (`prompts/list` == 3, byte-identical
`project-manager` prompt, static no-network check, malformed-agent skip)
and 3/3 for the pre-existing `core-server` checks (`tools/list` == 18,
`resources/list` == 17, byte-identical `ground-rules` tool,
byte-identical `conventions.md` resource, malformed-`SKILL.md` skip) —
confirming this diff does **not** regress `core-server`.

**Independent corroboration:** a throwaway script written for this grading
pass (`/private/tmp/.../scratchpad/independent-check.mjs`), using
`@modelcontextprotocol/sdk`'s `StdioClientTransport` to spawn
`mcp-server/src/index.js` directly (a separate process from the
implementer's `verify.mjs`), requesting **two prompts the implementer's
own script never checked** — `orchestrator` and `product-manager` (the
implementer's script only checked `project-manager`) — run 3 separate
times:

```
PASS  tools/list == 18 — got 18
PASS  resources/list == 17 — got 17
PASS  prompts/list == 3 — got 3: [orchestrator, product-manager, project-manager]
PASS  requesting "orchestrator" prompt returns byte-identical content — expected 4963 bytes, got 4963 bytes, equal=true
PASS  requesting "product-manager" prompt returns byte-identical content — expected 6673 bytes, got 6673 bytes, equal=true
PASS  orchestrator prompt has a non-empty description from frontmatter — description: "LSA conductor — the agent the user talks to. ..."

INDEPENDENT CHECK: PASS
EXIT:0
```
Identical on all 3 runs. Combined with the implementer's `project-manager`
check, all 3 registered prompts (`product-manager`, `project-manager`,
`orchestrator`) have now been independently confirmed byte-identical
against their source files by someone other than the implementer.

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

## Requirement coverage (F1-F5)

| Req | Implementing hunks/files | Proving runs | Verdict |
|---|---|---|---|
| F1 | register one prompt per agent file, name/description from frontmatter — `mcp-server/src/registry.js` (`AGENT_FILES` list, `scanAgents`), `mcp-server/src/index.js` (`server.registerPrompt` loop in `buildServer`) | 3/3 (`prompts/list` == 3, both implementer's `verify.mjs` Check 7 and my independent script) | ✅ |
| F2 | prompt request returns byte-identical agent-file body, no reformatting — `mcp-server/src/registry.js` (`agent.read = () => readFileSync(filePath, "utf8")`, raw read, no transform), `mcp-server/src/index.js` (prompt callback returns `agent.read()` verbatim as `content.text`) | 3/3 on `project-manager` (implementer's `verify.mjs` Check 8) + 3/3 on `orchestrator` and `product-manager` independently (my script) — all 3 registered prompts now cross-checked | ✅ |
| F3 | no outbound network/LLM call while serving prompts; server does not execute the agent's instructions — `mcp-server/src/index.js` prompt callback (`async () => ({ messages: [{ role: "user", content: { type: "text", text: agent.read() } }] })`) is read directly: it contains nothing but a call to `agent.read()` (a `readFileSync`) and an object literal return — no `fetch`, `http`, `net`, `child_process`, `exec`, `spawn`, dynamic `import()`, or LLM-SDK call anywhere in `src/index.js` or `src/registry.js`, confirmed by reading both files in full (not just trusting `verify.mjs`'s regex-based Check 9, which was also run and also passed) | 3/3 (regex static check, `verify.mjs` Check 9) + manual full-file read of the actual callback and `scanAgents`/`registerPrompt` code paths, confirming genuinely nothing but file-read-and-return | ✅ |
| F4 | malformed agent file (missing frontmatter `name`) is skipped, startup does not crash — `mcp-server/src/registry.js` (`scanAgents`: `typeof name !== "string" \|\| name.trim() === ""` → `continue`, same for `description`), fixtures `mcp-server/test/fixtures/malformed-agent/bad-agent.md` (confirmed by direct read: has `description:` in frontmatter but genuinely no `name:` key) and `good-agent.md` (well-formed control), test `mcp-server/test/verify.mjs` Check 10 (calls the real `buildServer(agentFixtureRoot, [], ["good-agent.md", "bad-agent.md"])` against the fixture dir over a linked `InMemoryTransport`, asserts exactly 1 prompt registered = `good-agent`, and that startup does not throw — a real build, not a bare assertion) | 3/3 (ran as part of every `verify.mjs` invocation) | ✅ |
| F5 | prompts exposed over the same stdio transport already used for tools/resources, no additional listener or second server process — `mcp-server/src/index.js`: `scanAgents`/`registerPrompt` loop is added to the same `buildServer()` function and the same `server` (`McpServer`) instance that already registers tools and resources; `main()` still constructs exactly one `StdioServerTransport` and calls `server.connect(transport)` once, unchanged from `core-server` | 3/3 (`tools/list` == 18 and `resources/list` == 17 unaffected by prompt registration, confirmed alongside `prompts/list` == 3 in both scripts every run) + confirmed by reading `main()`: no new transport construction, no `http`/`net` listener anywhere in the diff | ✅ |

Note on F4: only the missing-`name` branch has a Gherkin scenario and a
fixture (`bad-agent.md` omits `name`, keeps `description`) — matching
`prompt-startup.feature`'s scenario exactly ("no frontmatter `name`
key"). The missing-`description` branch in `scanAgents` is symmetric code
(same `continue`-on-invalid pattern) but has no dedicated fixture/test;
this mirrors the precedent already reconciled in `core-server` for
`scanSkills`, where only the missing-`name` case is fixture-tested. Not a
gap introduced by this diff — an established, previously-accepted pattern
in this codebase.

## Regression check — `core-server` not broken by this diff

Re-verified directly (not trusting the implementer's own claim):
`tools/list` still returns exactly 18 tools, `resources/list` still
returns exactly 17 resources, the `ground-rules` tool call and
`lsa/knowledge/conventions.md` resource read are still byte-identical,
and the malformed-`SKILL.md` fixture is still skipped without crashing
startup — all 3/3 across both the implementer's `verify.mjs` runs and my
own independent script's runs (which also asserts `tools/list == 18` and
`resources/list == 17` on every run, spawning the server itself rather
than reusing the implementer's process).

## Orphan hunks

- `mcp-server/src/index.js`, `mcp-server/src/registry.js` — F1, F2, F3, F5 implementing code (see table above). Not orphans.
- `mcp-server/test/verify.mjs` — covering tests for F1, F2, F3, F4 (Checks 7-10). Not an orphan.
- `mcp-server/test/fixtures/malformed-agent/bad-agent.md`, `mcp-server/test/fixtures/malformed-agent/good-agent.md` — fixtures proving F4 (real missing-`name` frontmatter + well-formed control). Not orphans.

No file in the diff implements behavior outside F1-F5. No dead/unused
source. `.lsa.yaml` was not touched this cycle (no config change needed —
`modules.mcp-server.artifact_paths` already covers every changed path from
the prior `core-server` cycle).

Orphan hunks: none.

## All of the plan

F1-F5 each map to at least one implementing hunk and a passing (3/3)
scenario, static check, or fixture-backed test, per the table above. No
requirement is unimplemented. The `core-server` epic's proven behavior
(18 tools, 17 resources, byte-identical tool/resource passthrough,
malformed-`SKILL.md` skip) is independently re-verified as not regressed.

## Gate results

`bash scripts/gate.sh` → `gate: PASS — every configured check exited 0`
(all 6 checks: docs-invariants, citations, links, project-map, tests,
lib-pins — each exit 0).

## Verdict

reconcile: PASS @ uncommitted (repo HEAD at grading time:
`4622295d85d5c9965ed375a369b1c61294bb2628` — nothing has been committed
for this epic yet, so the diff graded is the working tree, not this SHA)
