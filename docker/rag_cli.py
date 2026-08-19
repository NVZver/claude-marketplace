#!/usr/bin/env python3
"""rag_cli.py — structural chunker + local embedder + embedded vector store.

Runs inside the rag-index Docker image. Two subcommands:

  index --scope <path> --index-dir <dir>              build/update the index for <path>
  query --index-dir <dir> [--path <prefix>] "<text>"   return top-ranked cited chunks

Design notes (see .lsa/pitches/rag-context-engine-and-repo-indexing.md):
- Embeddings: fastembed (ONNX runtime, CPU-only, no persistent daemon). Model
  weights are baked into the image at build time (Dockerfile RUN step) so no
  network call ever happens at index/query runtime — HF_HUB_OFFLINE=1 below
  makes that a hard failure instead of a silent fetch, if anything tries.
- Vector store: LanceDB, embedded/file-based (a directory on disk, no server
  process). Cache keyed at chunk-content-hash granularity: a row's primary
  identity is (path, content_hash, embed_model, chunk_schema) so an unchanged
  chunk is never re-embedded (R2), and rows are namespaced by embed-model +
  schema version so a model/schema bump can't false-positive a cache hit.
- Path-scoped query (see .lsa/features/rag-context-engine-and-repo-indexing/
  path-scoped-query-fix/requirements.md): `query --path <prefix>` applies the
  prefix as a real LanceDB PRE-filter (`.where(..., prefilter=True)`) on the
  underlying table scan, evaluated BEFORE the ANN top-K search — not a
  Python-side check on an already-limited result list. Verified against the
  installed lancedb==0.25.0 (Dockerfile): `LanceVectorQueryBuilder.where`'s
  own docstring example is `.where("original_width > 1000", prefilter=True)`,
  and `cmd_index` below already relies on the same `.where(..., prefilter=
  True)` call for its per-path staleness scan. A post-filter (prefilter=
  False, or filtering client-side after `.limit()`) would be WRONG, not just
  suboptimal: if the single best whole-corpus match lies outside the target
  path and the true best in-path match ranks below TOP_K overall, a
  post-filter on an already-limited result set silently returns nothing
  useful even though a real in-path answer exists.
- Hybrid (dense + lexical) search (see .lsa/features/rag-context-engine-and-
  repo-indexing/hybrid-retrieval/requirements.md): `cmd_index` builds a
  native LanceDB full-text-search index on the `text` column
  (`create_fts_index`, default non-tantivy backend — confirmed no new pip
  dependency needed, `use_tantivy=False` works on this corpus size);
  `cmd_query` combines it with the existing dense-vector search via
  reciprocal rank fusion (`lancedb.rerankers.RRFReranker`), fixing dense-
  vector-only search's miss on queries whose relevant text is present
  literally but doesn't embed with high cosine similarity.

  The combination is built manually (vector sub-query + FTS sub-query +
  `RRFReranker().rerank_hybrid(...)`) rather than through LanceDB's
  `table.search(query, query_type="hybrid")` convenience builder
  (`LanceHybridQueryBuilder`), for one verified reason: that builder applies
  a single `.where(pred, prefilter=...)` call to BOTH sub-queries via the
  same prefilter flag, and the two signals need DIFFERENT prefilter
  handling once `--path` scoping is in play, verified directly against a
  real copy of this repo's index (`table.search(...).where(...)` at various
  `prefilter`/`limit` combinations):
    - Vector: `prefilter=True` is correct and unchanged from the
      path-scoped-query-fix epic above.
    - FTS: `prefilter=True` silently returns ZERO rows for an in-scope
      match that demonstrably exists (a real, disclosed limitation of this
      pinned LanceDB version's non-tantivy FTS backend — `create_fts_index`'s
      own docstring calls the whole API "highly experimental and... likely
      to change"). `prefilter=False` (postfilter) is also unsafe at a small
      `.limit()`: it truncates to the GLOBAL top-K by BM25 score BEFORE
      applying the path predicate, silently dropping an in-path match
      ranked outside that global top-K — the identical failure mode
      `prefilter=True` was chosen to avoid for vector search in the prior
      epic. The verified-safe fix: fetch FTS results generously
      (`FTS_OVERFETCH_LIMIT`, bounded only by this small ~1,200-chunk
      corpus — same `.limit(100000)` precedent as `cmd_index`'s own
      per-path scan below), filter by path in Python — safe because native
      Lance FTS computes an exact BM25 score over an inverted index, not an
      approximate/truncated ANN search, so over-fetch-then-filter loses no
      recall — THEN truncate to `TOP_K` to match the vector side's
      candidate size before RRF fusion.

  MIN_SIMILARITY (below) is now an OR-gate, not an AND-gate: a result
  clears the floor if its dense cosine similarity alone clears
  MIN_SIMILARITY (unchanged dense-only guarantee — no regression to
  existing wins), OR it is a genuine member of the FTS candidate set
  (a real literal/lexical match for this exact query, not a guess) — that
  second path is precisely the fix this epic exists to ship.
"""
import argparse
import hashlib
import json
import os
import re
import sys

os.environ.setdefault("HF_HUB_OFFLINE", "1")
os.environ.setdefault("TRANSFORMERS_OFFLINE", "1")

EMBED_MODEL_NAME = "BAAI/bge-small-en-v1.5"
EMBED_MODEL_VERSION = "fastembed:BAAI/bge-small-en-v1.5:v1"
CHUNK_SCHEMA_VERSION = "1"
EMBED_DIM = 384
FASTEMBED_CACHE_DIR = os.environ.get("FASTEMBED_CACHE_DIR", "/opt/fastembed-cache")

TABLE_NAME = "chunks"

# Fixed-size overlapping window fallback parameters (lines).
FALLBACK_WINDOW = 60
FALLBACK_OVERLAP = 15

MAX_FILE_BYTES = 2 * 1024 * 1024  # skip anything bigger; not in scope for v1
# `dist` (index-lsa-content epic, found during its own stress-test verification):
# gitignored Cursor-export build output (.gitignore:7, scripts/generate-for-cursor.sh)
# containing duplicate copies of already-indexed source files -- not dot-prefixed, so
# untouched by the R2/R3 changes above/below. Same rationale this repo's own
# scripts/coverage-skeleton.sh already applies to the identical directory (.gitignore:7's
# own comment: "untracked build output... silently inflates" whatever counts it).
#
# `.remember` (found the same way, same stress-test pass): entirely gitignored by its own
# nested .remember/.gitignore ("* .remember/"), private-mode on disk (0700) -- personal,
# machine-local session-continuity notes (the `remember` plugin), not project content.
# PRAGMATIC PATCH, not the real fix: this is the SECOND gitignored directory found
# leaking into the index this same pass (after `dist`) -- the actual root cause is that
# this indexer does not consult .gitignore at all, so any future gitignored directory
# will keep needing the identical one-line patch. A real fix (host-side git ls-files
# --others --exclude-standard, or equivalent) is a larger change, flagged for the human
# to decide on rather than built unilaterally here -- see this epic's conformance.md.
SKIP_DIR_NAMES = {".git", "node_modules", ".rag-index", "__pycache__", "dist", ".remember"}

# Path-prefix exclusion (index-lsa-content epic, R3): frozen historical
# record, excluded by its exact repo-root-relative path — NOT by basename,
# so an unrelated directory elsewhere in the tree that happens to be named
# "archive" is NOT excluded. Repo-root-relative, POSIX-separated (this CLI
# only ever runs inside the Linux container, but the comparison is written
# separator-safe regardless via the `.replace(os.sep, "/")` below).
ARCHIVE_PATH_PREFIX = ".lsa/archive"


# --------------------------------------------------------------------------
# Chunkers
# --------------------------------------------------------------------------

def chunk_markdown(text):
    """Split on H2 (##) / H3 (###) heading boundaries."""
    lines = text.splitlines()
    heading_re = re.compile(r"^(##|###)\s+\S")
    boundaries = [i for i, l in enumerate(lines) if heading_re.match(l)]
    chunks = []
    if not boundaries:
        if text.strip():
            chunks.append((1, len(lines) or 1, text))
        return chunks
    # Preamble before the first heading.
    if boundaries[0] > 0:
        pre = "\n".join(lines[0:boundaries[0]])
        if pre.strip():
            chunks.append((1, boundaries[0], pre))
    for idx, start in enumerate(boundaries):
        end = boundaries[idx + 1] if idx + 1 < len(boundaries) else len(lines)
        body = "\n".join(lines[start:end])
        if body.strip():
            chunks.append((start + 1, end, body))
    return chunks


def chunk_bash(text):
    """Split by function/block boundaries."""
    lines = text.splitlines()
    func_re = re.compile(
        r"^\s*(function\s+[A-Za-z_][A-Za-z0-9_]*\s*(\(\))?|[A-Za-z_][A-Za-z0-9_]*\s*\(\))\s*\{"
    )
    chunks = []
    i = 0
    n = len(lines)
    pending_start = 0
    while i < n:
        if func_re.match(lines[i]):
            # Flush any pending preamble content before this function.
            if i > pending_start:
                pre = "\n".join(lines[pending_start:i])
                if pre.strip():
                    chunks.append((pending_start + 1, i, pre))
            # Brace-match to find the end of this function block.
            depth = lines[i].count("{") - lines[i].count("}")
            j = i + 1
            while j < n and depth > 0:
                depth += lines[j].count("{") - lines[j].count("}")
                j += 1
            body = "\n".join(lines[i:j])
            chunks.append((i + 1, j, body))
            i = j
            pending_start = j
        else:
            i += 1
    if pending_start < n:
        tail = "\n".join(lines[pending_start:n])
        if tail.strip():
            chunks.append((pending_start + 1, n, tail))
    if not chunks and text.strip():
        # No function boundaries found at all — whole file is one chunk.
        chunks.append((1, n or 1, text))
    return chunks


def chunk_fallback(text):
    """Fixed-size overlapping window, in lines."""
    lines = text.splitlines()
    n = len(lines)
    if n == 0:
        return []
    if n <= FALLBACK_WINDOW:
        return [(1, n, text)]
    chunks = []
    stride = FALLBACK_WINDOW - FALLBACK_OVERLAP
    start = 0
    while start < n:
        end = min(start + FALLBACK_WINDOW, n)
        body = "\n".join(lines[start:end])
        if body.strip():
            chunks.append((start + 1, end, body))
        if end == n:
            break
        start += stride
    return chunks


def chunk_file(path, text):
    if path.endswith(".md") or path.endswith(".markdown"):
        return chunk_markdown(text)
    if path.endswith(".sh") or path.endswith(".bash"):
        return chunk_bash(text)
    return chunk_fallback(text)


def content_hash(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


# --------------------------------------------------------------------------
# Filesystem walk
# --------------------------------------------------------------------------

def load_ignored_list(path):
    """Parse the host-computed gitignore list (index-freshness epic, R4/R5).

    `path` is the container-side path to a file written by scripts/rag-
    index.sh from `git ls-files --others --ignored --exclude-standard
    --directory` — verified directly against this repo to return a MIX of
    whole-directory entries (trailing "/", e.g. "dist/") and individual-file
    entries (no trailing "/", e.g. ".DS_Store"). A directory with its own
    nested .gitignore (this repo's `.remember/`, which ignores itself via
    "* .remember/") produces BOTH the directory entry AND per-file entries
    beneath it — not one clean collapsed entry — so both shapes are handled,
    not assumed deduplicated.

    Returns (dirs, files): `dirs` holds directory entries with the trailing
    "/" stripped (repo-root-relative, "/"-separated), for prefix matching in
    _is_excluded_dir; `files` holds file entries as-is, for exact matching
    in _is_ignored_file. Missing/unreadable `path` (None, --ignored-list
    omitted, or the host's git command failed) yields two empty sets — the
    hardcoded SKIP_DIR_NAMES/ARCHIVE_PATH_PREFIX safety net still applies
    regardless.
    """
    dirs = set()
    files = set()
    if not path:
        return dirs, files
    try:
        with open(path, "r", encoding="utf-8") as fh:
            for line in fh:
                entry = line.strip()
                if not entry:
                    continue
                if entry.endswith("/"):
                    dirs.add(entry.rstrip("/"))
                else:
                    files.add(entry)
    except OSError:
        pass
    return dirs, files


def _is_excluded_dir(root, name, repo_root, ignored_dirs=frozenset()):
    """True if the directory `name` under walk-root `root` must be skipped.

    Three checks, the first two hardcoded (index-lsa-content epic, R1/R3)
    and always applied regardless of `ignored_dirs`:
      - basename, anywhere in the tree (SKIP_DIR_NAMES — pure tool/VCS
        internals: `.git`, `node_modules`, `.rag-index`, `__pycache__`).
      - repo-root-relative PATH PREFIX, exact match only (`.lsa/archive`) —
        deliberately NOT a basename check, so a directory named "archive"
        anywhere else in the tree is left alone.
      - repo-root-relative PATH PREFIX against the dynamic `ignored_dirs`
        set (index-freshness epic, R4/R5) — supplementing, not replacing,
        the two hardcoded checks above, so a missing/empty `ignored_dirs`
        (--ignored-list omitted, or the host's git command failed) still
        leaves the hardcoded safety net intact.

    All three use the same repo-root-relative, "/"-normalized `rel`,
    computed via `os.path.relpath` against `repo_root` (not against the
    walk's own top, which may itself be a subdirectory when `--scope`
    narrows the walk).
    """
    if name in SKIP_DIR_NAMES:
        return True
    rel = os.path.relpath(os.path.join(root, name), repo_root).replace(os.sep, "/")
    if rel == ARCHIVE_PATH_PREFIX or rel.startswith(ARCHIVE_PATH_PREFIX + "/"):
        return True
    for ignored_dir in ignored_dirs:
        if rel == ignored_dir or rel.startswith(ignored_dir + "/"):
            return True
    return False


def _is_ignored_file(rel_path, ignored_files=frozenset()):
    """True if `rel_path` (repo-root-relative, "/"-normalized) is an exact
    match in the dynamic ignored-files set (index-freshness epic, R4/R5) —
    the individual-file-entry half of load_ignored_list's output (e.g.
    ".DS_Store", ".claude/settings.local.json" at paths not already pruned
    by a whole-directory exclusion).
    """
    return rel_path in ignored_files


def iter_scope_files(scope_path, repo_root, ignored_dirs=frozenset(), ignored_files=frozenset()):
    if os.path.isfile(scope_path):
        rel_path = os.path.relpath(scope_path, repo_root).replace(os.sep, "/")
        if _is_ignored_file(rel_path, ignored_files):
            return
        yield scope_path
        return
    for root, dirs, files in os.walk(scope_path):
        dirs[:] = [d for d in dirs if not _is_excluded_dir(root, d, repo_root, ignored_dirs)]
        for fn in files:
            fs_path = os.path.join(root, fn)
            rel_path = os.path.relpath(fs_path, repo_root).replace(os.sep, "/")
            if _is_ignored_file(rel_path, ignored_files):
                continue
            yield fs_path


def read_text_file(fs_path):
    try:
        if os.path.getsize(fs_path) > MAX_FILE_BYTES:
            return None
        with open(fs_path, "rb") as fh:
            raw = fh.read()
        return raw.decode("utf-8")
    except (UnicodeDecodeError, OSError):
        return None


# --------------------------------------------------------------------------
# Embedding
# --------------------------------------------------------------------------

_model = None


def get_model():
    global _model
    if _model is None:
        from fastembed import TextEmbedding
        _model = TextEmbedding(
            model_name=EMBED_MODEL_NAME,
            cache_dir=FASTEMBED_CACHE_DIR,
            local_files_only=True,
        )
    return _model


def _normalize(vecs):
    import numpy as np
    out = []
    for v in vecs:
        v = np.asarray(v, dtype="float32")
        norm = float(np.linalg.norm(v))
        if norm > 0:
            v = v / norm
        out.append(v.tolist())
    return out


def embed_passages(texts):
    """Embed chunk text for storage (asymmetric bge passage encoding)."""
    if not texts:
        return []
    return _normalize(list(get_model().passage_embed(texts)))


# BAAI/bge-* models are asymmetric: the official model card instructs
# prepending this exact string to queries (not to indexed passages) for
# retrieval. fastembed's OnnxTextEmbedding.query_embed() does not apply this
# for the plain (non-"-instruct") bge-small checkpoint, so it is applied here.
BGE_QUERY_INSTRUCTION = "Represent this sentence for searching relevant passages: "


def embed_query(text):
    return _normalize(list(get_model().embed([BGE_QUERY_INSTRUCTION + text])))[0]


# --------------------------------------------------------------------------
# Vector store (LanceDB)
# --------------------------------------------------------------------------

def open_db(index_dir):
    import lancedb
    os.makedirs(index_dir, exist_ok=True)
    return lancedb.connect(os.path.join(index_dir, "lancedb"))


def get_or_create_table(db):
    import pyarrow as pa
    schema = pa.schema([
        pa.field("id", pa.string()),
        pa.field("path", pa.string()),
        pa.field("start_line", pa.int64()),
        pa.field("end_line", pa.int64()),
        pa.field("content_hash", pa.string()),
        pa.field("embed_model", pa.string()),
        pa.field("chunk_schema", pa.string()),
        pa.field("text", pa.string()),
        pa.field("vector", pa.list_(pa.float32(), EMBED_DIM)),
    ])
    if TABLE_NAME in db.table_names():
        return db.open_table(TABLE_NAME)
    return db.create_table(TABLE_NAME, schema=schema)


def row_id(rel_path, start, end, chash):
    return f"{rel_path}:{start}-{end}:{chash[:12]}"


# --------------------------------------------------------------------------
# index
# --------------------------------------------------------------------------

def cmd_index(args):
    repo_root = args.repo_root.rstrip("/")
    scope_fs = os.path.join(repo_root, args.scope) if args.scope not in ("", ".") else repo_root
    scope_fs = os.path.normpath(scope_fs)

    db = open_db(args.index_dir)
    table = get_or_create_table(db)

    ignored_dirs, ignored_files = load_ignored_list(getattr(args, "ignored_list", None))

    embedded_count = 0
    skipped_count = 0
    deleted_count = 0
    files_seen = 0

    for fs_path in iter_scope_files(scope_fs, repo_root, ignored_dirs, ignored_files):
        rel_path = os.path.relpath(fs_path, repo_root)
        text = read_text_file(fs_path)
        if text is None:
            continue
        files_seen += 1
        chunks = chunk_file(rel_path, text)

        want = {}
        for start, end, body in chunks:
            chash = content_hash(body)
            want[chash] = (start, end, body)

        try:
            existing_rows = (
                table.search()
                .where(
                    f"path = '{rel_path}' AND embed_model = '{EMBED_MODEL_VERSION}' "
                    f"AND chunk_schema = '{CHUNK_SCHEMA_VERSION}'",
                    prefilter=True,
                )
                .limit(100000)
                .to_list()
            )
        except Exception:
            existing_rows = []
        existing_hashes = {r["content_hash"] for r in existing_rows}

        stale_ids = [
            r["id"] for r in existing_rows if r["content_hash"] not in want
        ]
        if stale_ids:
            id_list = ", ".join(f"'{i}'" for i in stale_ids)
            table.delete(f"id IN ({id_list})")
            deleted_count += len(stale_ids)

        to_embed_hashes = [h for h in want if h not in existing_hashes]
        skipped_count += len(want) - len(to_embed_hashes)

        if to_embed_hashes:
            texts = [want[h][2] for h in to_embed_hashes]
            vectors = embed_passages(texts)
            new_rows = []
            for h, vec in zip(to_embed_hashes, vectors):
                start, end, body = want[h]
                new_rows.append({
                    "id": row_id(rel_path, start, end, h),
                    "path": rel_path,
                    "start_line": start,
                    "end_line": end,
                    "content_hash": h,
                    "embed_model": EMBED_MODEL_VERSION,
                    "chunk_schema": CHUNK_SCHEMA_VERSION,
                    "text": body,
                    "vector": vec,
                })
            table.add(new_rows)
            embedded_count += len(new_rows)

    # R1 (hybrid-retrieval): build/rebuild the full-text search index on the
    # chunk `text` column alongside the vector index. This corpus is small
    # (~1,200 chunks) so a full FTS rebuild every `cmd_index` run is an
    # acceptable simplification (no incremental FTS update) — verified
    # `create_fts_index` works on an empty table too (0 rows), so this is
    # safe to call unconditionally, including on a freshly-created table.
    # `replace=True` because `create_fts_index` errors on an already-present
    # index otherwise (its default is `replace=False`).
    fts_index_built = False
    if table.count_rows() > 0:
        table.create_fts_index("text", replace=True)
        fts_index_built = True

    summary = {
        "files_seen": files_seen,
        "chunks_embedded": embedded_count,
        "chunks_skipped_unchanged": skipped_count,
        "chunks_deleted_stale": deleted_count,
        "embed_model": EMBED_MODEL_VERSION,
        "chunk_schema": CHUNK_SCHEMA_VERSION,
        "fts_index_built": fts_index_built,
    }
    print(json.dumps(summary))
    return 0


# --------------------------------------------------------------------------
# query
# --------------------------------------------------------------------------

# Cosine similarity threshold for the DENSE signal alone (LanceDB "cosine"
# metric reports distance = 1 - cosine_similarity on L2-normalized vectors).
# Empirically tuned against BAAI/bge-small-en-v1.5's baseline same-domain
# noise floor (short-text bi-encoder similarity rarely drops below ~0.45-0.6
# even for unrelated queries); 0.65 leaves margin above that floor while
# still passing genuine paraphrastic matches (~0.75+ observed). This is a
# coarse, mechanism-level default, not a tuned retrieval-quality target —
# that measurement is out of scope for this epic (separate
# `code-review-eval-harness` roadmap row); revisit with real corpus data.
#
# hybrid-retrieval epic: this is now an OR-gate, not the sole gate — see
# `cmd_query` below and the module docstring's "Hybrid (dense + lexical)
# search" note. A result clears the floor if EITHER its dense cosine
# similarity alone clears MIN_SIMILARITY (unchanged dense-only guarantee),
# OR it is a genuine member of the FTS candidate set for this exact query
# (a real literal/lexical match, not a guess) — R1/R5.
MIN_SIMILARITY = 0.65
TOP_K = 5

# canonical-source-weighting epic, R2/R3: pre-fusion candidate pool widened
# from TOP_K to CANDIDATE_K on both the vector and FTS sub-queries (see the
# two call sites below) so a genuinely relevant canonical chunk that would
# have been truncated out of a naive top-TOP_K window on either signal (the
# SP4 stress-probe failure mode: a real match ranked 6th-20th, not present
# in either raw top-5) still reaches RRF fusion and the R4 canonical boost
# below. The FINAL result count returned to the caller is unchanged — still
# exactly TOP_K (R3); only the pre-fusion working set grows. 20 (4x TOP_K)
# is a coarse, mechanism-level choice, not a tuned constant: large enough to
# comfortably cover this corpus's observed near-miss depth (SP4/SP9/SP3 in
# stress-probes.md — none of those chunks were even raw top-5 candidates on
# either signal), small enough that RRF fusion over up to
# 2*CANDIDATE_K=40 candidates stays cheap on this ~1,200-chunk corpus.
CANDIDATE_K = 20

# FTS sub-query over-fetch bound before path-filtering in Python (see the
# module docstring's "Hybrid" note for why: LanceDB 0.25.0's native FTS
# `.where(..., prefilter=True)` silently drops in-scope matches, and
# `prefilter=False` at a small `.limit()` truncates before filtering).
# Bounded only by this repo's own corpus size (~1,200 chunks;
# `cmd_index` above already uses the same 100000 bound for its own
# per-path scan) — cheap because Lance's native FTS is an exact BM25
# computation over an inverted index, not an approximate search.
FTS_OVERFETCH_LIMIT = 100000

# canonical-source-weighting epic, R1: query-time-only classification (R7 —
# no schema change, no reindex, no new stored field) of each candidate's
# already-stored `path` into "canonical" (this repo's own maintained specs
# and tooling) or "historical" (everything else — pitches, dated
# observations, superseded drafts, etc.). Same path-prefix-matching shape as
# ARCHIVE_PATH_PREFIX above (line 126): repo-root-relative, exact match OR
# startswith-with-trailing-slash for directory-shaped entries — so "lsa/"
# matches both the bare "lsa" path and anything under "lsa/", while
# ".lsa/VISION.md" matches only that one file, not everything under
# ".lsa/". Safe to compare as-is (no separator normalization needed, unlike
# ARCHIVE_PATH_PREFIX's os.walk-time check): this CLI only ever runs inside
# the Linux container, and `path` is stored exactly as `cmd_index` wrote it
# — already "/"-separated. UNMATCHED DEFAULTS TO "historical" — a deliberate
# safety default (requirements.md R1), not a bug: an unlisted path (e.g. a
# new top-level directory added later) does not silently get
# canonical-boosted without an explicit decision to add it here.
CANONICAL_PATH_PREFIXES = (
    "lsa/",
    "core/",
    "manager/",
    "prompt-engineer/",
    "observer/",
    ".lsa/VISION.md",
    ".lsa/main.spec.md",
    ".lsa.yaml",
    ".lsa/roadmap.yaml",
    ".lsa/standards/",
    ".lsa/modules/",
    "README.md",
    "AGENTS.md",
    "CLAUDE.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "docker/",
    "scripts/",
)


def classify_doc_class(path):
    """Classify a stored chunk `path` as "canonical" or "historical" (R1).

    A match is an exact match against a `CANONICAL_PATH_PREFIXES` entry
    (with any trailing "/" stripped), or `path` starting with that stripped
    entry plus "/" — the same exact-or-directory-prefix rule
    `_is_excluded_dir` already applies to `ARCHIVE_PATH_PREFIX`. Any path
    that matches none of the entries defaults to "historical" (see the
    module-level comment above `CANONICAL_PATH_PREFIXES` for why that
    default is deliberate).
    """
    for prefix in CANONICAL_PATH_PREFIXES:
        base = prefix.rstrip("/")
        if path == base or path.startswith(base + "/"):
            return "canonical"
    return "historical"


# canonical-source-weighting epic, R4/R5: how far (in pre-boost fused rank
# positions) a canonical hit is allowed to overtake historical hits. Tied to
# TOP_K rather than an independent magic number: a canonical hit can only
# move up past historical hits within one TOP_K-window's worth of rank
# distance immediately above it, which is what "near-equal relevance" means
# here — see `_boost_canonical_ranking`'s docstring for the exact mechanism.
CANONICAL_BOOST_WINDOW = TOP_K


def _boost_canonical_ranking(pre_boost_hits):
    """Reorder RRF-fused hits (R4) to favor canonical (R1) chunks over
    historical ones at equal or near-equal fused relevance, without letting
    a historical chunk that is unambiguously more relevant get pulled below
    a weaker canonical one (R4's explicit "no override" clause).

    `pre_boost_hits` is the fused hit list in `RRFReranker`'s own sorted
    order (its own fused-relevance ranking, best first) — that list index
    IS each hit's original relevance rank; no extra column is needed
    (`RRFReranker().rerank_hybrid(...)`'s output is verified sorted by its
    own fused rank already, per `cmd_query`'s call site below).

    Mechanism (fully deterministic — R5, no randomness anywhere): a
    canonical hit's ORIGINAL rank `idx` is adjusted to
    `idx - CANONICAL_BOOST_WINDOW`; a historical hit's rank is left
    unadjusted. Stable-sorting by (adjusted_rank, is_historical, idx) lets a
    canonical hit overtake ONLY the historical hits within
    CANONICAL_BOOST_WINDOW ranks immediately above its original position —
    e.g. with CANONICAL_BOOST_WINDOW=5, a canonical hit at rank 15
    (adjusted 10) still sorts BELOW a historical hit at rank 1 (distance 14,
    unambiguously more relevant, per R4), but a canonical hit at rank 8
    (adjusted 3) overtakes a historical hit at rank 5 (near-equal, within
    the window). The `is_historical` tie-break (0 for canonical, 1 for
    historical) means an exact tie in adjusted rank favors canonical, per
    R4's "at equal ... relevance" clause; the final `idx` tie-break makes
    the ordering fully deterministic and explicit rather than relying
    incidentally on Python's stable-sort behavior.

    This is deliberately NOT a hard two-tier partition (all canonical
    hits before all historical hits regardless of relevance) — SP6 in
    requirements.md documents why that was rejected during spec review: a
    hard partition would let a barely-related canonical doc outrank a
    clearly-relevant historical one, which is not what "boost at near-equal
    relevance" means. Bounding the overtake distance to
    CANONICAL_BOOST_WINDOW is what keeps this a boost, not a partition.
    """
    def sort_key(item):
        idx, hit = item
        is_canonical = classify_doc_class(hit["path"]) == "canonical"
        adjusted_rank = idx - CANONICAL_BOOST_WINDOW if is_canonical else idx
        return (adjusted_rank, 0 if is_canonical else 1, idx)

    indexed = sorted(enumerate(pre_boost_hits), key=sort_key)
    return [hit for _, hit in indexed]


def cmd_query(args):
    db = open_db(args.index_dir)
    if TABLE_NAME not in db.table_names():
        print(json.dumps({"results": []}))
        return 0
    table = db.open_table(TABLE_NAME)

    if table.count_rows() == 0:
        print(json.dumps({"results": []}))
        return 0

    import numpy as np
    import pyarrow.compute as pc
    from lancedb.rerankers import RRFReranker

    path_prefix = getattr(args, "path", None)
    qvec = embed_query(args.query_text)

    # --- Dense (vector) sub-query — unchanged from path-scoped-query-fix:
    # prefilter=True pushes the path predicate into the table scan BEFORE
    # the ANN top-K, so an in-path match ranked 6th-20th in the whole corpus
    # still surfaces. See the module docstring's "Path-scoped query" note.
    vec_search = (
        table.search(qvec, vector_column_name="vector")
        .metric("cosine")
        .with_row_id(True)
    )
    if path_prefix:
        # LIKE-escape single quotes only, matching this file's existing
        # level of SQL interpolation rigor (cmd_index does the same).
        escaped_prefix = path_prefix.replace("'", "''")
        vec_search = vec_search.where(f"path LIKE '{escaped_prefix}%'", prefilter=True)
    vector_arrow = vec_search.limit(CANDIDATE_K).to_arrow()

    # --- Lexical (FTS) sub-query — see the module docstring for why this is
    # fetched generously and filtered by path in Python rather than via
    # `.where(..., prefilter=...)` directly (both prefilter modes verified
    # unsafe for FTS + path scoping in this LanceDB version).
    fts_arrow = (
        table.search(args.query_text, query_type="fts")
        .with_row_id(True)
        .limit(FTS_OVERFETCH_LIMIT)
        .to_arrow()
    )
    if path_prefix and fts_arrow.num_rows > 0:
        fts_arrow = fts_arrow.filter(pc.starts_with(fts_arrow["path"], path_prefix))
    if fts_arrow.num_rows > CANDIDATE_K:
        fts_arrow = fts_arrow.slice(0, CANDIDATE_K)
    lexical_rowids = set(fts_arrow["_rowid"].to_pylist()) if fts_arrow.num_rows > 0 else set()

    # --- Combine via LanceDB's default reciprocal-rank-fusion reranker (R2).
    combined = RRFReranker().rerank_hybrid(args.query_text, vector_arrow, fts_arrow)

    # canonical-source-weighting epic, R4/R5: apply the deterministic
    # canonical boost (`_boost_canonical_ranking`, above) to the full fused
    # candidate list — BEFORE the final TOP_K slice, per requirements.md R4
    # and grounding.md's identified insertion point — then trim to exactly
    # TOP_K (R3: the widened CANDIDATE_K pool never changes the returned
    # count).
    pre_boost_hits = combined.to_pylist()
    hits = _boost_canonical_ranking(pre_boost_hits)[:TOP_K]

    qv = np.asarray(qvec, dtype="float32")
    results = []
    for h in hits:
        # Vectors are L2-normalized at embed time (embed_query/
        # embed_passages), so a plain dot product IS the cosine similarity —
        # computed directly from each row's own stored vector rather than
        # relying on the reranker's `_distance`/`_score` columns, which are
        # null/absent for rows that matched via only one of the two signals.
        row_vec = np.asarray(h["vector"], dtype="float32")
        similarity = float(np.dot(qv, row_vec))
        is_lexical_hit = h["_rowid"] in lexical_rowids
        if similarity < MIN_SIMILARITY and not is_lexical_hit:
            continue
        results.append({
            "path": h["path"],
            "start_line": h["start_line"],
            "end_line": h["end_line"],
            "citation": f"{h['path']}:{h['start_line']}-{h['end_line']}",
            "similarity": round(similarity, 4),
            "text": h["text"],
        })

    print(json.dumps({"results": results}))
    return 0


# --------------------------------------------------------------------------
# entrypoint
# --------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(prog="rag_cli.py")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_index = sub.add_parser("index")
    p_index.add_argument("--scope", default=".")
    p_index.add_argument("--index-dir", required=True)
    p_index.add_argument("--repo-root", default="/repo")
    p_index.add_argument(
        "--ignored-list",
        default=None,
        help=(
            "container-side path to a host-computed gitignore list "
            "(scripts/rag-index.sh; index-freshness epic R4/R5) — one path "
            "per line, directories with a trailing '/'. Optional: omitted "
            "or unreadable falls back to the hardcoded SKIP_DIR_NAMES/"
            "ARCHIVE_PATH_PREFIX safety net only."
        ),
    )

    p_query = sub.add_parser("query")
    p_query.add_argument("query_text")
    p_query.add_argument("--index-dir", required=True)
    p_query.add_argument("--path", default=None)

    args = parser.parse_args()
    if args.cmd == "index":
        sys.exit(cmd_index(args))
    elif args.cmd == "query":
        sys.exit(cmd_query(args))


if __name__ == "__main__":
    main()
