> **Trace.** On load, print first: `=============== [helper/knowledge/knowledge-scope.md] [helper] ===============`

# Knowledge scope — knowledge

What the Helper agent is allowed to read when answering, and in what order. Per the absorbed helper module spec [`.lsa/modules/helper/spec.md`](../../.lsa/modules/helper/spec.md).

## Scope order

Read in this order; stop after enough sources to ground the answer:

1. **This repo.** All of `.lsa/`, `core/`, `lsa/`, the repo `README.md`, `CONTRIBUTING.md`, `lsa/ARCHITECTURE.md`, every `SKILL.md`, every `CHANGELOG.md`. Use `Read` for known paths; `Grep` / `Glob` for keyword searches.

2. **Other installed plugins** (best-effort). Read `~/.claude/plugins/cache/**/README.md`, `**/SKILL.md`, `**/plugin.json`. Helper does not modify installed-plugin caches — read-only.

3. **External docs via `context7` MCP.** Only when the subject is a third-party library, framework, SDK, API, CLI, or cloud service that does not appear in scope 1 or 2. Use `mcp__plugin_context7_context7__resolve-library-id` to find the library identifier, then `mcp__plugin_context7_context7__query-docs` for the actual docs. Cite the URL returned by `context7`.

## When to skip scope levels

- **In-repo subject** (user asks about LSA, `core/output`, the constitution, a feature spec). Stop at scope 1; do not query other plugins or `context7`.
- **Other-plugin subject** (user asks about `dev-plugin`, `atlassian`, `supabase`, `frontend-design`, etc.). Skip scope 1 if irrelevant; go to scope 2.
- **External library** (user asks about `React`, `Next.js`, `Prisma`, `tailwindcss`, `Drizzle`, etc.). Skip scopes 1 and 2 if the question is clearly about a third-party tool; go straight to scope 3.

## When to declare "cannot verify"

If after scope 1 + 2 + (3 when relevant) no grounded source is found, respond exactly `"I cannot verify this."`, name the sources checked, and offer `AskUserQuestion` next steps. Do not fabricate an answer. Per `core/ground-rules` Rule 2.

## Bounded read budget

Helper does not exhaustively scan the codebase. One bounded round per response:

- Read the user's question.
- Pick the smallest set of source files that could plausibly ground the answer (3–5 files max).
- Read those (with `Read` or `Grep`).
- If insufficient, expand once (3–5 more files). If still insufficient, declare cannot-verify.

Two-round cap keeps response within the ≤1.5-screen budget and prevents context bloat.

## What Helper does NOT read

- The user's other open tabs / IDE state. Out of substrate reach.
- Files outside the repo unless they're in installed-plugin caches.
- Network resources outside `context7` (no arbitrary `WebFetch`).
- Anything Helper would have to *guess* about. If the source isn't readable, it's not knowable; declare cannot-verify.
