# RAG Context Engine — Prior-Art Spike

- **Date:** 2026-08-13
- **Source pitch:** [`.lsa/pitches/rag-context-engine-and-repo-indexing.md`](../pitches/rag-context-engine-and-repo-indexing.md)
- **Roadmap row:** `.lsa/roadmap.yaml:562-580`
- **Purpose:** Before finalizing the sync/cache design (paused mid-discussion after the owner correctly identified that eager per-edit reindexing wastes work on AI edit-churn, and that branch switches / parallel worktrees aren't file edits at all), check how the industry actually solves "find the relevant code without reading everything," and give a **build / borrow / hybrid** verdict per component, following the format of [`parallel-agent-delivery-prior-art.md`](./parallel-agent-delivery-prior-art.md).
- **Doc-mode note:** Research artifact, ships no code. Does not edit the pitch or epics — that happens after this is reviewed.
- **Structural note carried through every verdict below:** every tool researched (Cursor, Continue.dev, Windsurf) runs a **persistent background process** — an IDE extension or a remote server — that can poll or watch files continuously and amortize indexing cost across the whole session. We have no such process: `lsa:discover`/`verify`/`reconcile` invoke `rag-query.sh` as a one-shot CLI call from inside an agent turn, with nothing running between calls. Several mechanisms below are flagged as **not directly portable** for exactly this reason.

## Method

Sources rated primary vendor docs/blog > DeepWiki (community-maintained code documentation, treated as secondary) > inferred. Two components (worktree object-sharing, LanceDB validation) are grounded against official docs and the pitch's own tech pick respectively.

---

## Component 1 — Chunking strategy

Our pitch: structural chunking (Markdown H2/H3, bash by function/block, fixed-window fallback).

- **Verdict:** **Hybrid** — borrow the parsing substrate for code, build the domain-specific boundary rules.
- **Borrowed primitive:** Cursor confirms the general pattern independently — "When a file changes, Cursor splits it into syntactic chunks" (not fixed windows) (https://cursor.com/blog/secure-codebase-indexing). Aider goes further and names the actual tool: tree-sitter, for language-agnostic AST parsing, feeding a PageRank-ranked symbol graph — "Tree-sitter provides fast, language-agnostic AST parsing" (https://aider.chat/2023/10/22/repomap.html).
- **Net-new to build:** No tool documents a Markdown-header-boundary chunker or a bash-function-boundary chunker specifically — those rules are ours to write. For the bash/code side, Aider's proven use of tree-sitter is a legitimate library pick rather than hand-rolled block detection.
- **Reason:** the "structural, not fixed-window" instinct is industry-validated; the specific boundary rules for our two content types are not available off the shelf.

## Component 2 — Vector store

Our pitch: LanceDB (embedded, file-based, native upsert/delete-by-key).

- **Verdict:** **Borrow — independently validated**, no change needed.
- **Evidence:** Continue.dev, a local-first coding-agent tool with the closest constraint match to ours (local embeddings, no hosted requirement), uses LanceDB in production: "LanceDbIndex handles the generation and storage of embeddings... Rows are stored in LanceDB with schema... `uuid`, `path`, `cachekey`, `vector`" (https://deepwiki.com/continuedev/continue/3.4-codebase-indexing). This is independent confirmation from a real shipped tool, not just our own reasoning from LanceDB's feature list.
- **Reason:** the pick already matches what a comparable local-only tool ships.

## Component 3 — Change detection: the two-level hash pattern (confirms and refines our hypothesis)

- **Verdict:** **Borrow the pattern, build our instance of it.**
- **What we find, sourced:**
  - Cursor hashes at **two levels**: a whole-file Merkle hash to cheaply detect "did anything change" ("a cryptographic hash of every file, along with hashes of each folder"), then, only for changed files, a **second, finer cache keyed by chunk content** — "Cursor caches embeddings by chunk content" (https://cursor.com/blog/secure-codebase-indexing). A one-line edit to a 500-line file re-walks that one file but re-embeds only the chunks that actually changed.
  - Continue.dev's `cachekey` column in its LanceDB row schema (cited above) is the same pattern under a different name: a content-derived key that lets identical chunk content skip re-embedding.
- **Refines our hypothesis:** we proposed keying by **git blob hash** (whole-file granularity). Neither tool does this — both hash at (or after) chunk granularity specifically so a small edit inside a large file doesn't invalidate everything downstream of it. **Correction: key the embedding cache by chunk-content hash, computed after chunking, not by the whole-file git blob hash.** File-level hashing (ours or git's own tree/blob shas) is still useful as the cheap first-pass "did this file change at all" filter — just not as the unit the embedding cache itself is keyed on.

## Component 4 — Reindex trigger / sync cadence (the component our pre-pause hypothesis was weakest on)

- **Verdict:** **Hybrid**, and the one place our hypothesis needs a real course-correction, not just refinement.
- **What the industry actually does, and why it doesn't port directly:**
  - Cursor: a background **server-side periodic poll**, roughly every 5 minutes, diffing the client's Merkle tree against the server's last-known state (https://towardsdatascience.com/how-cursor-actually-indexes-your-codebase/, corroborated by the Cursor blog above). Requires a live client-server connection.
  - Windsurf: **continuous, event-driven** background reindexing — "it continuously updates its vector index as files change... an event-driven architecture where specific user actions (like saving a file or changing text) trigger the AI to re-run its reasoning" (https://markaicode.com/windsurf-flow-context-engine/). Requires a persistent IDE process watching the filesystem.
  - Continue.dev: an incremental diff function (`getComputeDeleteAddRemove`) that "compares the current file system state against the tag_catalog in SQLite" (https://deepwiki.com/continuedev/continue/3.4-codebase-indexing) — closer to ours, but still runs inside a long-lived IDE extension process, not a one-shot CLI.
  - **None of the three do "reindex synchronously inline with every single edit event"** — which validates the owner's original objection to naive `PostToolUse`-eager-reindex. But none of them do **pure lazy-at-query-time** either, because all three have a background process to amortize the cost across — a resource we don't have.
- **What this means for us, concretely:** neither "eager on every edit" nor "purely lazy at query time" has real precedent. The mechanisms we do have access to (`PostToolUse`, `SessionStart` — both fire on harness events, no persistent process) are structurally closer to a **debounced, opportunistic reconciliation** than to any of the three patterns above: `PostToolUse` marks dirty cheaply (no embedding work happens there — this part of our original design was already right), and the actual reconciliation runs once per session boundary (`SessionStart`, which also naturally catches branch switches and external edits — see Component 5) plus, if unreconciled, lazily before the *first* `rag-query.sh` call of a session rather than before every call. A pre-commit hook then warms the cache for whatever's about to become a stable, shareable commit — this part of the owner's instinct is well-placed and has no direct industry precedent to borrow from (all three tools are single-user, uncommitted-state-aware by design, and don't treat "committed" as a special moment worth extra work).
- **Net-new to build:** the debounce/batch logic itself, and the pre-commit cache-warming hook — genuinely ours, not borrowed.

## Component 5 — Branch-switch handling

- **Verdict:** **Borrow directly** — this replaces our content-hash-unification hypothesis with something simpler and already shipped.
- **Evidence:** Continue.dev tags every indexed row by `IndexTag = (directory, branch, artifact ID)` — "Branch switching is explicitly supported through the `IndexTag` structure... enabling seamless switching without reindexing" (https://deepwiki.com/continuedev/continue/3.4-codebase-indexing). A branch switch just changes which logical partition a query reads from; a previously-indexed branch is instantly available again, no rehash needed.
- **Correction to our hypothesis:** we proposed unifying branches purely through content-hash equality (identical file content on two branches shares one embedding). That's still true and worth keeping *underneath* — but the simpler, proven, much-lower-engineering-cost layer on top is **tag rows by branch explicitly**, don't try to make cross-branch dedup do all the work alone. Recommend both: branch as an explicit tag (cheap, proven, handles the common case), content-hash cachekey underneath for the free dedup when branches do share content (Component 3).

## Component 6 — Cache sharing across worktrees / separate clones

- **Verdict:** **Build (thin)** — the technical anchor is real and doc-confirmed, but nothing in the industry validates the mechanism itself; treat with more caution than the borrowed components above.
- **What's confirmed:** official git docs state worktrees "share the same Git history and object database... reflog, and configuration as the main tree," and the shared `.git` location is resolvable from any worktree via `git rev-parse --git-common-dir` (https://git-scm.com/docs/git-worktree, https://git-scm.com/docs/gitrepository-layout). Our anchor-the-cache-there idea is technically sound.
- **What's not confirmed by anyone:** none of Cursor, Continue.dev, or Windsurf document multi-worktree or multi-clone cache sharing at all — they're built for one IDE window on one checkout. This is genuinely novel territory for us, not a borrowed pattern with a track record. Separate full clones (no shared `.git`) still have no answer here beyond "key by origin remote URL," which is untested anywhere we found.
- **Reason for caution:** this is the one place in the whole design where we'd be ahead of documented industry practice, not behind it. Worth a smaller, testable slice (start with worktrees, which have a real git-level guarantee; defer full-clone sharing) rather than committing to the general case up front.

## Component 7 — Pure-vector-RAG vs. hybrid retrieval (surfaces a tension with an already-approved pitch decision)

- **Verdict:** **Flag, don't resolve here** — this bears directly on the owner's already-approved decision to drop `project-map.yaml` and make RAG the sole search-scoping mechanism, so it's surfaced for review rather than decided unilaterally in this research spike.
- **Evidence:** Sourcegraph's own account of building Cody explicitly layers three retrievers, not one — "Keyword retriever using Zoekt... Embedding-based retriever... Graph-based retriever using static analysis" (https://sourcegraph.com/blog/how-cody-understands-your-codebase). SWE-agent's published RAG baseline is BM25 (sparse keyword search), not embeddings at all (https://proceedings.neurips.cc/paper_files/paper/2024/file/5a7c947568c1b1328ccc5230172e1e7c-Paper-Conference.pdf). OpenHands' primary search tool is a literal directory grep, `search_dir(search_term, dir_path)` (https://github.com/OpenHands/OpenHands/issues/2798) — even a well-funded generalist agent platform leans on plain text search as a first-class mechanism, not a last-resort fallback.
- **What this means:** at least one serious production system (Cody) found pure embedding search insufficient on its own and kept keyword + graph retrieval as permanent, parallel layers — not fallback-on-miss, but always-on complements. Our pitch already keeps `Grep`/`Read` as a fallback-on-miss (good, and consistent with what OpenHands/SWE-agent do as their primary mechanism), but the pitch's Epic 6 (`retire-project-map`) goes further than any tool researched here by removing the *only remaining* non-RAG scoping signal. This doesn't mean the decision is wrong — but it's not validated by prior art either, and it's worth the owner seeing this evidence before that epic ships, not after.

---

## Verdict roll-up

| # | Component | Verdict | Borrowed primitive | Net-new to build |
|---|---|---|---|---|
| 1 | Chunking strategy | **Hybrid** | tree-sitter (Aider) for code; "structural not fixed-window" pattern (Cursor) | Markdown H2/H3 + bash function boundary rules |
| 2 | Vector store | **Borrow — validated** | LanceDB, independently shipped by Continue.dev with our exact local-only constraint | none |
| 3 | Change-detection hashing | **Borrow the pattern** | two-level hash: file-level cheap filter + chunk-content cache key (Cursor, Continue.dev) | our own chunk-content hash implementation |
| 4 | Reindex trigger/cadence | **Hybrid — real correction** | none directly portable (all three require a persistent daemon we don't have) | debounced session-boundary reconciliation + pre-commit cache-warming |
| 5 | Branch-switch handling | **Borrow directly** | tag-by-branch (`IndexTag`, Continue.dev) | none — simpler than our original hypothesis |
| 6 | Worktree/clone cache sharing | **Build (thin)** | `git rev-parse --git-common-dir` (official git docs) confirms the anchor point is real | the sharing mechanism itself — no prior art anywhere |
| 7 | Pure-RAG vs. hybrid retrieval | **Flag for owner review** | Cody's 3-retriever design; SWE-agent/OpenHands lean on keyword/grep as primary, not fallback | n/a — decision point, not a build task |

**Headline:** four of seven components borrow directly or with minor adaptation. The two genuinely novel pieces are the session-boundary reconciliation cadence (Component 4 — nothing else runs on our CLI-only, no-daemon model) and multi-worktree cache sharing (Component 6 — nothing else needs to solve it). Component 7 isn't a build/borrow question at all — it's evidence that the already-approved "RAG as sole scoping mechanism" decision is a bigger bet than any researched tool has made, worth the owner seeing before `retire-project-map` ships.

## Open questions / risks

- **O1 (Component 3/4).** Confirm before implementation whether chunk-content hashing should run over pre- or post-normalization text (whitespace/line-ending differences would otherwise cause spurious cache misses) — not addressed by any source found.
- **O2 (Component 4).** "Debounced session-boundary reconciliation" still leaves a real question the pitch's Rabbit hole 3 (reconcile's sha-pinning) already anticipates: within one long session, is a single lazy catch-up at first-query sufficient, or does `reconcile` specifically need a stronger guarantee given it grades a fixed sha? Recommend `reconcile`'s sha-pinned reads bypass session-level caching entirely and always resolve fresh against the graded sha — cheaper to special-case than to make the general cadence rule work for the one consumer with a stricter contract.
- **O3 (Component 6).** No source addresses cache corruption/contention if two worktrees write to the shared LanceDB store concurrently (e.g., two agent sessions in two worktrees both discover the same never-before-seen file at the same moment). LanceDB's own concurrency guarantees need checking directly against its docs before this ships — out of scope for this spike.
- **O4 (Component 7).** This is a decision for the owner, not resolved here: keep Epic 6 as approved (RAG becomes sole scoping mechanism), or add a permanent lightweight keyword-search layer alongside RAG (closer to Cody's model) rather than `Grep`/`Read` being purely a miss-fallback. Flagged, not decided.
