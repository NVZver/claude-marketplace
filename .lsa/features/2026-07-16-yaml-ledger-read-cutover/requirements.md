# Requirements — yaml-ledger-selective-load/read-cutover

Epic: `yaml-ledger-selective-load/read-cutover` · Pitch: [yaml-ledger-selective-load](../../pitches/yaml-ledger-selective-load.md) · Date: 2026-07-16

## Summary

Convert this repo's roadmap from a 92 KB markdown table (`.lsa/roadmap.md`, 378 lines / 91,834 bytes) to a YAML ledger (`.lsa/roadmap.yaml`) that AI consumers load **on demand via scripts** — only the rows a question needs — instead of whole-file reads. One-shot lossless migration; the markdown is deleted in the same ship (single source-of-truth). Roadmap-only: no LSA runtime change, no write-path change, no pitch-body ladder.

## User Flows

| Flow | Success | I/O | Scenario |
|---|---|---|---|
| **A · Migrate** | `roadmap.yaml` holds every row losslessly; MD gone; single SoT | `roadmap.md` → `roadmap.yaml`; MD removed | `migrate.feature` |
| **B · Query on demand** | Caller gets only requested rows; zero model tokens; non-zero exit ⇒ fallback | query args → stdout rows (`path:line`) \| exit≠0 | `query.feature` |
| **C · Consumer selective-load** | No happy-path whole-file read by any manager consumer | consumer intent → script call → slice | `consumer-load.feature` |
| **D · Human read** | Readable table to stdout; not a 2nd SoT | `∅` → stdout table | `human-read.feature` |
| **E · Schema gate** | Malformed ledger fails deterministically | `roadmap.yaml` → lint exit 0/1 | `schema-gate.feature` |
| **F · Reference integrity** | No dangling `roadmap.md` ref; gates green | deleted MD → `check-*` exit 0 | `reference-integrity.feature` |

## Functional Requirements (EARS)

### Migration
- **F1** — When the migration runs, the system shall produce `${specs_root}/roadmap.yaml` with one `items` entry per `## Feature Backlog` row and one `shipped_history` entry per `## Recently merged` row of the former `roadmap.md`.
- **F1b** — When the roadmap carries narrative sections beyond the two tables (the dated `## …backlog detail` appendices and `## Tech Picture adoption — 2026-05-20`, lines 95–332 of the former `roadmap.md`), the migration shall preserve each section's content verbatim — associated with the backlog item it documents where such a mapping exists, otherwise under a preserved appendix — so migration loses no content.
- **F2** — When migrating a row, the system shall preserve that row's full Notes text verbatim in the item's `notes` field, with no truncation.
- **F3** — When the migration completes, the system shall remove `${specs_root}/roadmap.md` so exactly one roadmap source-of-truth exists.
- **F4** — Each `items` entry shall carry `slug`, `title`, `priority` (Must|Should|Could) and `status` (backlog|not_started|in_progress|shipped|deferred); `pitch`, `notes`, `depends_on` are optional.

### Query
- **F5** — When a caller requests the first actionable backlog row, the system shall emit that row with a `path:line` citation to stdout using zero model tokens, or exit non-zero if there is none.
- **F6** — When a caller requests a bounded backlog slice (`backlog --limit N`, optionally `--fields`), the system shall emit at most N `backlog`/`not_started` rows to stdout.
- **F7** — When a caller requests a record by slug (`get <slug>`), the system shall emit only that record, or exit non-zero if absent.
- **F8** — When a query script exits non-zero, the calling consumer shall fall through to a whole-file read of the ledger (fallback only), matching the existing `roadmap-row.sh` fallback contract.

### Consumer rewire
- **F9** — On the happy path, no roadmap read-consumer (`manager:next` Mode 0, `project-manager` Mode 0/1, `manager:check`, `manager:implement` preview) shall whole-file-read the ledger; each obtains its slice via a query script.

### Human view
- **F10** — When a human requests a readable view, the system shall pretty-print the ledger to stdout as a table; this view is not a source-of-truth.

### Gate
- **F11** — While the ledger is malformed or missing a required key, the schema check in `scripts/lint.sh` shall exit non-zero; while it is well-formed, the check shall pass.

### Reference integrity
- **F12** — When `roadmap.md` is deleted, the system shall leave no literal `.lsa/roadmap.md` path reference that breaks `scripts/check-links.sh` or `scripts/check-citations.sh` (both exit 0).
- **F13** — When the format changes, the system shall rewrite the roadmap-format citation in `manager/knowledge/sequencing-heuristics.md:9`, the callers table in `core/knowledge/fast-path-source-of-truth.md:46-47`, and `.lsa/modules/manager/spec.md:42` to name `roadmap.yaml`/the schema; `grep` shall find no live `roadmap.md` reference across `manager/`.

## Out of Scope

- LSA plugin runtime (`init`/`discover`/`verify`) and its generic `${specs_root}/roadmap.md` product docs → deferred to the separate LSA-format-aware pitch.
- The serialized-merge **write** path → epic `yaml-ledger-selective-load/merge-write`.
- The Mode 1 pitch-body ladder → epic `yaml-ledger-selective-load/pitch-ladder`.
- Converting CHANGELOG / `plugin.json` / any non-roadmap ledger.
