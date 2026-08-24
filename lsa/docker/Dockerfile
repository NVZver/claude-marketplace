# Dockerfile — RAG index/query pipeline for this repo.
#
# This repo's first-ever containerization and first-ever runtime dependency
# of any kind (owner-approved, .lsa/pitches/rag-context-engine-and-repo-
# indexing.md gate decisions). Packages a structural chunker, a local
# CPU-only embedding step, and an embedded/file-based vector store into a
# single image. Host-side, `scripts/rag-index.sh` and `scripts/rag-query.sh`
# are thin wrappers that `docker run` this image, mounting the repo read-only
# and a local, gitignored index directory (`.lsa/.rag-index/`) read-write.
#
# Local-only: no hosted/SaaS vector DB, no hosted embedding API, no network
# call at index/query runtime. The embedding model's weights are downloaded
# once at BUILD time (below) and baked into the image layer; `HF_HUB_OFFLINE`
# and `local_files_only=True` (docker/rag_cli.py) turn any accidental runtime
# network attempt into a hard failure instead of a silent fetch.
#
# [ASSUMPTION resolved] Embedding: fastembed (ONNX runtime, CPU-only, ships
# no persistent daemon) running BAAI/bge-small-en-v1.5 — small (~130MB),
# well-established, actively maintained as of this build. Chosen over Ollama
# (requires a persistent background server, rejected by the pitch) and any
# hosted embedding API (network dependency, rejected by the pitch's no-go 3).
#
# [ASSUMPTION resolved] Vector store: LanceDB — embedded, file-based (a plain
# directory on disk under the mounted index volume), no separate server
# process, and supports delete-by-predicate for the stale-chunk garbage
# collection this pipeline needs (docker/rag_cli.py cmd_index). Chosen over
# FAISS (no native delete-by-key) and Chroma (heavier embedded-mode
# dependency surface) per the pitch's own comparison.
FROM python:3.11-slim

RUN pip install --no-cache-dir \
    fastembed==0.7.1 \
    lancedb==0.25.0 \
    pyarrow==17.0.0 \
    numpy

ENV FASTEMBED_CACHE_DIR=/opt/fastembed-cache
RUN mkdir -p "${FASTEMBED_CACHE_DIR}"

# Prefetch the embedding model at build time so index/query runs never need
# network access — this is the one and only network-touching step in the
# whole image build.
RUN python -c "from fastembed import TextEmbedding; TextEmbedding(model_name='BAAI/bge-small-en-v1.5', cache_dir='${FASTEMBED_CACHE_DIR}')"

COPY rag_cli.py /app/rag_cli.py

ENTRYPOINT ["python", "/app/rag_cli.py"]
