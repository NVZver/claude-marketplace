Epic: marketplace-mcp-server/agent-prompts
Verdict: GROUNDED
Date: 2026-08-24

## Reference map (`bash scripts/resolve-refs.sh`)

| Symbol | Resolution |
|---|---|
| `manager/agents/product-manager.md:1` | exists |
| `manager/agents/project-manager.md:1` | exists |
| `lsa/agents/orchestrator.md:1` | exists |
| `mcp-server/src/index.js:1` | exists |
| `mcp-server/src/registry.js` | exists |
| `mcp-server/package.json` | exists |

## Feasibility (per user flow)

- **Flow 1 (startup & prompt registration):** buildable — the installed
  `@modelcontextprotocol/sdk` (`mcp-server/package.json`) already exposes
  `McpServer.registerPrompt`, confirmed in the installed package source
  (`mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/server/mcp.js:727-733,
  397-420`). No new dependency needed.
- **Flow 2 (prompt request, no server-side execution):** buildable —
  returning a file's body unchanged as prompt content is the same mechanism
  already proven for tools/resources in the `core-server` epic
  (`reconcile: PASS`); "no server-side execution" is a negative property
  (absence of any LLM/agent-dispatch call in the callback), directly
  checkable by reading the implementation.

No flow is infeasible on what exists.

## Scope note (not an assumption — a recorded decision)

The epic as originally decomposed named only `product-manager` and
`project-manager`. At discover time, `lsa/agents/orchestrator.md` was
identified as also being in the pitch's confirmed first-slice scope
(core+lsa+manager) and was flagged as omitted from decomposition by
oversight. Per this session's gate decision, it is included — requirements.md
and both `.feature` files reflect all 3 agents.

## Gate (`.lsa.yaml` `gate:` block, docs-mode repo)

First run (2026-08-24) — `bash scripts/gate.sh`:

```
FAIL  project-map  bash lsa/scripts/project-map-check.sh → exit 1
```

Root cause: `project-map.yaml` (script-generated, depth-3 directory tree)
was stale after the `core-server` epic added `mcp-server/` and this epic's
own new `.lsa/features/marketplace-mcp-server/agent-prompts/` directory —
neither had been reflected via a regeneration commit. Fixed by running
`bash lsa/scripts/project-map-build.sh` (which the check script already
runs) and committing the regenerated `project-map.yaml` (commit `4622295`).

Second run (2026-08-24, post-fix) — `bash scripts/gate.sh`:

```
PASS  docs-invariants  bash scripts/lint.sh → exit 0
PASS  citations        bash scripts/check-citations.sh → exit 0
PASS  links            bash scripts/check-links.sh → exit 0
PASS  project-map      bash lsa/scripts/project-map-check.sh → exit 0
PASS  tests            bash scripts/run-tests.sh → exit 0
PASS  lib-pins         bash scripts/check-lib-pins.sh → exit 0
gate: PASS — every configured check exited 0
```

## Verdict

**GROUNDED.** Every cited reference resolves, both flows are buildable on
the existing server + installed SDK, and the gate block exits 0. Cleared
for `lsa:delegate`.
