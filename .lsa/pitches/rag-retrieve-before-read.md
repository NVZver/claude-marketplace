Shaped by: product-manager (role lens: agent-platform retrieval / token-efficiency PM)
Date: 2026-08-04
Status: approved
Gate decisions: role confirmed (agent-platform retrieval PM); Fork A = dogfood-first personal spike before any marketplace packaging [recommended, owner prior]; Fork B = options A+B+C (thin retrieve CLI + session cache + project-map path scope) — LangGraph optional later; Fork C = third-party trusted libs allowed for the spike (LangChain + local vector store + embeddings); Fork D = packaging = observation → opt-in scripts/recipe only after numeric keep-gate; final approve implied by owner ask to "make a pitch".
Why now: selective-load wins shipped for known query shapes (YAML ledger scripts, project-map, VISION digest) but free-form search still burns tokens via whole-file Read + multi-round Grep + cross-stage re-extraction; owner wants a measured dogfood of RAG before any "for everyone" ship.

# RAG retrieve-before-read (dogfood → measure → optional pack)

Personal-first retrieve layer (LangChain index + thin query CLI + session cache, scoped by `project-map`) so agents load cited chunks instead of whole files when hunting; ship nothing marketplace-wide until Before/After numbers clear a keep-gate.

## Problem

Who has it: the marketplace owner (and later any agent session on this repo) during Standard/Extended work — especially `lsa:discover` and free-form “where is X?” questions.

What goes wrong: the model searches by trial-and-error — Grep → whole-file `Read` → wrong/too-broad file → repeat — and sub-agents / later LSA stages **re-pay** the same extraction. That is retrieval paid in context tokens.

Evidence (repo-grounded, current tree 2026-08-04 unless noted):

- Whole-file roadmap load was already measured as the failure mode this family of work fights: ~22,958 tok vs script slices ~70–185 tok ([`README.md`](../../README.md) §"Manager — selective roadmap load"; proof [`.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md`](../observations/2026-07-16-yaml-ledger-selective-load-impact.md)).
- Constitution selective load: full `VISION.md` ~8,197 tok vs digest ~423 tok ([`README.md`](../../README.md) §"LSA — selective constitution + scoping").
- Discovery still says read “the code/specs the request touches” after consulting dirs-only `project-map.yaml` ([`lsa/skills/discover/SKILL.md`](../../lsa/skills/discover/SKILL.md); [`lsa/knowledge/conventions.md`](../../lsa/knowledge/conventions.md) §project map) — the map scopes **directories**, not needles inside skill/spec bodies.
- Principle 10: deterministic work of meaningful complexity is scripted; the model cites script output ([`.lsa/VISION.md`](../VISION.md) §2 principle 10). Semantic “find the relevant slice” is still mostly model-orchestrated Grep/Read.
- Working-tree size anchors for the dogfood corpus (bytes via `wc -c` / `du` 2026-08-04): `README.md` 15,590 B; `.lsa/VISION.md` 37,472 B; `project-map.yaml` 2,640 B; `.lsa/` ~2.4M; `lsa/` ~372K; `core/` ~232K.

Current workaround: scripted fast-paths for **known** shapes (`roadmap-row.sh` / `roadmap-query.sh`, resolve-refs, digests); everything **semantic / fuzzy** falls through to unbounded Grep + whole-file Read. Personal CLAUDE overlays cannot fix missing chunk-level retrieve.

Definition of success (numeric keep-gate — see Solution sketch §Evaluation harness):

1. **Before/After on a fixed probe set (N≥10)** in this repo: median **whole-file `Read` count per probe** drops by **≥50%** on the After path, OR median **approx context tokens attributed to search/read** (tool stdout + file bodies pulled for search, bytes÷4) drops by **≥50%**, without raising confirm-Read miss rate above **20%**.
2. Every retrieve hit used for a claim is either confirmed by a bounded `Read` of the cited `path:start-end` or discarded (fact-grounding intact).
3. Cross-stage repeat extraction on a 3-stage replay (discover-like → follow-up → follow-up) shows cache hit rate **≥40%** of retrieve calls served from session cache ids (option B), or documented why cache did not apply.
4. **Keep / Narrow / Drop** decided in a written observation under `.lsa/observations/` with the raw table — no marketplace packaging until **Keep** or intentional **Narrow**.
5. Happy path stays Pro-safe locally: ingest + query run on the owner machine with **no required hosted vector SaaS** (local store allowed; API embeddings allowed only as an explicit owner choice recorded in the observation).

## Appetite

**Small batch — dogfood spike + measurement only** (owner Phases 0–2). One vertical on **this marketplace repo** (primary corpus: `lsa/` + `core/` + selected `.lsa/` specs/knowledge — exclude `.lsa/archive`, binaries, secrets).

**In appetite:**

- Options **A+B+C**: thin `rag-query` CLI (budgeted top-k + `path:line`), gitignored session cache (query → chunk ids), path filter via `project-map` / path prefix.
- Third-party **trusted** libraries for the spike (pinned in a personal/project venv): LangChain (ingest/split/retrieve), a local vector store (FAISS or Chroma or LanceDB — pick one in spike setup), embeddings (local `fastembed` / Ollama **or** one API provider if owner prefers quality).
- Optional LangGraph **only if** single-shot retrieve + one refine fails the hop-cap story in measurement (default: **no** LangGraph in v0).
- Personal always-on / Claude overlay instruction: retrieve-before-whole-file under scoped path; fallback to Grep on miss/stale.
- Evaluation harness + observation writeup with Before/After numbers.
- Freshness stamp: index keyed by `(git_sha or tree hash, embed_model_id, chunk_schema_version)`; refuse or rebuild when dirty.

**Out of appetite (this pitch):**

- Shipping a new marketplace plugin or making `/plugin install` pull Python/LangChain.
- Rewriting LSA skills in-tree as the default for all users (personal overlay / local notes only until Keep).
- Replacing scripted ledger fast-paths (roadmap YAML queries stay SoT for those shapes).
- Hosted vector DB / multi-tenant retrieval service.
- Full LangGraph research agent, auto-MCP distribution, or “RAG on every Quick question.”

**Promote-later (explicit non-goals now, candidates after Keep):** opt-in repo scripts + runbook; optional doctor checks; thin skill citations — separate pitch/epic.

## Solution sketch

- **Key user interactions:** Owner bootstraps a local venv + index once; before hunting in Standard/Extended work, agent calls `rag-query` (scoped) and reads **stdout slices only**; confirms cited ranges with short `Read`s; session reuse goes through cache ids; after the probe battery, owner reads the observation and chooses Keep / Narrow / Drop.
- **Main components:**
  1. **Ingest** — LangChain loaders + structure-aware Markdown split (header/section boundaries for `SKILL.md` / knowledge); embed; write local vector store under gitignored `.lsa/rag/` (or `~/.cache/claude-marketplace-rag/`).
  2. **Query (A)** — CLI `rag-query "<q>" [--path PREFIX] [--k 6] [--max-tokens 1200]` → chunks + `path:start-end` + scores; hard fail if over budget.
  3. **Cache (B)** — `.lsa/rag/session-cache.json` (gitignored): `(embed_model, query_hash) → chunk_ids`; rehydrate via CLI by id; store ids not full text in prompts.
  4. **Scope (C)** — resolve directory via `project-map.yaml` / explicit `--path`; never default to whole-repo semantic search for discover-like tasks.
  5. **Eval harness** — fixed probe list + Before/After runner notes (manual or scripted logging of tool receipts).
- **Critical path:** build index → run Before battery (no RAG) → run After battery (RAG+cache+scope) → confirm-Read audit → write observation → Keep-gate.

### Trusted libraries (spike allow-list)

Pinned in the dogfood venv; exact pins recorded in the observation (and later a lockfile if promoted):

| Role | Allowed candidates (pick one per row in setup) |
|---|---|
| Orchestration / retrieve API | `langchain`, `langchain-community` (and/or `langchain-text-splitters`) |
| Optional hop router | `langgraph` — **deferred** unless measurement demands a hard 2-hop cap |
| Vector store | `faiss-cpu` **or** `chromadb` **or** `lancedb` |
| Embeddings | local: `fastembed` and/or Ollama embeddings; API: one owner-chosen provider (e.g. OpenAI / Voyage) — record model id in index stamp |
| Token accounting | prefer tiktoken or provider tokenizer if available; else **bytes÷4** (same heuristic as [`.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md`](../observations/2026-07-16-yaml-ledger-selective-load-impact.md)) |

No other SaaS vector hosts in this appetite.

### Evaluation harness (Before / After — real numbers)

**Corpus under test:** `lsa/` + `core/` + `.lsa/VISION.md` + `.lsa/standards/` + `.lsa/modules/` (exclude `.lsa/archive`, `.git`, binaries). Record file count + total bytes at measurement commit.

**Probe set (N≥10, fixed text — freeze in the observation):** mix of (a) symbol/exact (“`reconcile.runs` default”), (b) procedural (“where does discover consult project-map”), (c) cross-cutting (“does·only·all meaning”), (d) negative/miss bait (phrase that should miss). Include at least 2 probes that today typically trigger multi-file Grep in dogfood experience.

**Before protocol (RAG off):**

1. Fresh session (or cleared context budget accounting).
2. For each probe: allow Grep + Read only; **forbid** rag-query.
3. Stop when the operator would hand facts to specify/verify (or after a fixed max of 8 tool calls).
4. Log per probe: tool call list, paths whole-file-Read, bytes read (sum of Read bodies + Grep outputs), approx tokens (`bytes/4` and/or tokenizer), whether the final cited facts were correct (human grade: PASS/FAIL).

**After protocol (RAG on):**

1. Index at known `git_sha` + `embed_model_id` + `chunk_schema_version`.
2. Same probes; agent **must** call `rag-query` with path scope before whole-file Read; Grep only on miss/stale; confirm-Read cited ranges (≤N lines each).
3. Log the same fields + retrieve stdout bytes + cache hit/miss + confirm-Read PASS/FAIL.

**Derived metrics (required table in the observation):**

| Metric | Definition |
|---|---|
| `whole_file_reads` | Count of Read calls whose body was a full file (or >K lines; record K, default 200) |
| `search_tokens_approx` | (Grep stdout + Read bodies used for search + retrieve stdout) / 4 |
| `confirm_miss_rate` | confirm-Read failures / retrieve hits relied upon |
| `cache_hit_rate` | cache hits / retrieve calls on the 3-stage replay |
| `time_to_first_correct_cite` | optional wall-clock; secondary |

**Keep-gate (all must hold for Keep):**

- Median `search_tokens_approx` **or** median `whole_file_reads` ≤ **50%** of Before (same probe set, same commit).
- `confirm_miss_rate` ≤ **0.20**.
- No silent stale-index use in After (stamp matches HEAD or After run records forced rebuild).
- Observation committed (or attached) with raw per-probe rows — not summary-only.

**Narrow:** Keep only for Markdown skills/knowledge; exclude large code trees — record the boundary.  
**Drop:** Either ratio miss or miss-rate breach, or ops pain (rebuild/hooks disabled in practice).

**3-stage replay (cache B):** pick 3 probes that share corpus overlap; run as Q1→Q2→Q3 in one session After; report `cache_hit_rate`.

### Promotion rule (everyone later)

Only after **Keep** (or documented **Narrow**): write a follow-on pitch/epic for opt-in scripts + runbook (contract: CLI shape, freshness stamp, doctor smoke). Default-on for all plugin users is **out of appetite** until that follow-on clears its own appetite.

## Rabbit holes

1. **Wrong neighbors look “sourced”** — Mitigation: confirm-Read required for any claim; unconfirmed hits dropped; miss-rate is a keep-gate input.
2. **Stale index after edits** — Mitigation: stamp `(sha, embed_model, chunk_schema)`; query refuses or rebuilds on porcelain/HEAD mismatch; session cache invalidated when chunk hashes change.
3. **Naive character chunking shreds skills** — Mitigation: header/section-aware split for Markdown; chunk_schema_version bump forces re-ingest.
4. **Cache B reprints full text into the prompt** — Mitigation: cache stores ids only; rehydrate through CLI with `--max-tokens` budget.
5. **LangChain dependency sprawl / supply chain** — Mitigation: pin versions; allow-list above; no hosted vector SaaS in this pitch; record SBOM-ish pins in the observation.
6. **Measurement bias (After tries harder)** — Mitigation: fixed probe text, fixed max tool calls, same commit, same stop rule; log raw tool traces.
7. **Double tax (RAG + old Grep habit)** — Mitigation: personal overlay forbids whole-file Read before retrieve on scoped tasks; After protocol enforces order.
8. **Embed model swap invalidates index** — Mitigation: model id in stamp; full rebuild on change; do not compare Before/After across embed models without re-baselining.

## No-gos

1. This pitch does NOT make RAG part of default `/plugin install core|lsa` — packaging is a later pitch after Keep.
2. This pitch does NOT replace `roadmap-query.sh` / fast-path SoT navigation ([`core/knowledge/fast-path-source-of-truth.md`](../../core/knowledge/fast-path-source-of-truth.md)) — scripts remain first for known shapes.
3. This pitch does NOT require LangGraph in v0 — only if measurement shows unbounded multi-hop retrieve.
4. This pitch does NOT allow retrieve output as fact without `path:line` + confirm-Read (or explicit `[assumption]`).
5. This pitch does NOT index secrets, `.env`, or `.lsa/archive`.
6. This pitch does NOT claim marketplace-wide token savings from the spike alone — only dogfood numbers on the freeze commit + probe set.
