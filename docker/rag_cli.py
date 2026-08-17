#!/usr/bin/env python3
"""rag_cli.py — structural chunker + local embedder + embedded vector store.

Runs inside the rag-index Docker image. Two subcommands:

  index --scope <path> --index-dir <dir>   build/update the index for <path>
  query --index-dir <dir> "<query text>"   return top-ranked cited chunks

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
SKIP_DIR_NAMES = {".git", "node_modules", ".rag-index", "__pycache__"}


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

def iter_scope_files(scope_path):
    if os.path.isfile(scope_path):
        yield scope_path
        return
    for root, dirs, files in os.walk(scope_path):
        dirs[:] = [d for d in dirs if d not in SKIP_DIR_NAMES and not d.startswith(".")]
        for fn in files:
            yield os.path.join(root, fn)


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

    embedded_count = 0
    skipped_count = 0
    deleted_count = 0
    files_seen = 0

    for fs_path in iter_scope_files(scope_fs):
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

    summary = {
        "files_seen": files_seen,
        "chunks_embedded": embedded_count,
        "chunks_skipped_unchanged": skipped_count,
        "chunks_deleted_stale": deleted_count,
        "embed_model": EMBED_MODEL_VERSION,
        "chunk_schema": CHUNK_SCHEMA_VERSION,
    }
    print(json.dumps(summary))
    return 0


# --------------------------------------------------------------------------
# query
# --------------------------------------------------------------------------

# Cosine distance threshold (LanceDB "cosine" metric reports distance =
# 1 - cosine_similarity on L2-normalized vectors). Below this similarity, a
# result is not considered a real match — R4: a miss must be an empty result,
# never a guess. Empirically tuned against BAAI/bge-small-en-v1.5's baseline
# same-domain noise floor (short-text bi-encoder similarity rarely drops
# below ~0.45-0.6 even for unrelated queries); 0.65 leaves margin above that
# floor while still passing genuine paraphrastic matches (~0.75+ observed).
# This is a coarse, mechanism-level default, not a tuned retrieval-quality
# target — that measurement is out of scope for this epic (separate
# `code-review-eval-harness` roadmap row); revisit with real corpus data.
MIN_SIMILARITY = 0.65
TOP_K = 5


def cmd_query(args):
    db = open_db(args.index_dir)
    if TABLE_NAME not in db.table_names():
        print(json.dumps({"results": []}))
        return 0
    table = db.open_table(TABLE_NAME)

    if table.count_rows() == 0:
        print(json.dumps({"results": []}))
        return 0

    qvec = embed_query(args.query_text)
    hits = (
        table.search(qvec, vector_column_name="vector")
        .metric("cosine")
        .limit(TOP_K)
        .to_list()
    )

    results = []
    for h in hits:
        distance = h.get("_distance", 1.0)
        similarity = 1.0 - distance
        if similarity < MIN_SIMILARITY:
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

    p_query = sub.add_parser("query")
    p_query.add_argument("query_text")
    p_query.add_argument("--index-dir", required=True)

    args = parser.parse_args()
    if args.cmd == "index":
        sys.exit(cmd_index(args))
    elif args.cmd == "query":
        sys.exit(cmd_query(args))


if __name__ == "__main__":
    main()
