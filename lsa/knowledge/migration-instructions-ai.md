# Migration instructions (AI) — markdown roadmap → YAML ledger

> **Trace.** On load, print first: `=============== [lsa/knowledge/migration-instructions-ai.md] [lsa] ===============`

**Audience:** an AI agent migrating a consumer project (or this marketplace) from `${specs_root}/roadmap.md` to `${specs_root}/roadmap.yaml`.  
**Goal:** one source-of-truth YAML ledger; consumers query via scripts; markdown deleted; citations cleaned; gates green.  
**Do not** keep dual SoT. **Do not** invent a parallel index. **Do not** whole-file-Read the ledger on the happy path after migration.

Default `${specs_root}` = `.lsa/` (read from repo-root `.lsa.yaml` `specs_root:` when present).

---

## When to run this

Run **all** steps below when **any** of these hold:

1. `${specs_root}/roadmap.md` exists and `${specs_root}/roadmap.yaml` does **not**.
2. Both exist (dual SoT) — treat as broken; finish migration and delete the MD.
3. The project still has agent/skill instructions that say `Read …/roadmap.md` on the happy path.

**Skip migration Steps 2–6** (already done) when: only `roadmap.yaml` exists, query scripts work, and no live happy-path `roadmap.md` load instructions remain in skills/agents you own.

**Even on skip:** still run **Step 7** (final verification gate) once — catches stale indexes, dangling links, and F9 regressions without re-migrating. If Step 7 fails, fix those defects; do **not** re-run `roadmap-migrate.sh` against a missing MD.

Greenfield / new projects: do **not** migrate — `/lsa:init` scaffolds `roadmap.yaml` directly (empty `items:`).

---

## Prerequisites

- Repo root is a git checkout; you can run `bash`.
- Prefer the marketplace’s scripts when present at repo root:
  - `scripts/roadmap-migrate.sh`
  - `scripts/roadmap-query.sh`
  - `scripts/roadmap-row.sh`
  - `scripts/roadmap-print.sh`
  - `scripts/tests/no-wholefile-ledger-read.sh` (optional F9)
- If this is a **consumer** project without those scripts: copy them from the `NVZver/claude-marketplace` checkout (`scripts/roadmap-*.sh` and, if you enforce F9, `scripts/tests/no-wholefile-ledger-read.sh`) into the consumer’s `scripts/` **before** Step 2. Adjust paths only if `specs_root` is non-default (scripts already read `.lsa.yaml`).

---

## Steps (execute in order)

### Step 1 — Detect and report

Observable result: a one-line status printed to the human.

```bash
SPECS="$(awk '/^specs_root:[[:space:]]*/ { sub(/^specs_root:[[:space:]]*/,""); gsub(/[[:space:]]+$/,""); print; exit }' .lsa.yaml 2>/dev/null)"
SPECS="${SPECS:-.lsa/}"
SPECS="${SPECS%/}"
echo "specs_root=${SPECS}"
ls -la "${SPECS}/roadmap.md" "${SPECS}/roadmap.yaml" 2>&1 || true
```

- If only `.yaml` → **skip Steps 2–6**; print “migration already complete”; continue at **Step 7**.
- If only `.md` or both → continue from Step 2.

### Step 2 — Migrate (lossless)

```bash
bash scripts/roadmap-migrate.sh "${SPECS}/roadmap.md" "${SPECS}/roadmap.yaml"
```

Observable result: script prints `roadmap-migrate: wrote …/roadmap.yaml` and exits 0.  
On exit ≠ 0: **stop** — do not delete the MD; report the error.

### Step 3 — Verify content (required)

Run **all** checks. Any failure → **stop** before cleanup (MD stays).

**3a · File exists and parses as YAML structure (required keys)**

```bash
test -f "${SPECS}/roadmap.yaml"
# C14-style structural gate (same idea as marketplace scripts/lint.sh C14):
awk '
  BEGIN{v=0;i=0}
  /^version:[[:space:]]/ {v=1}
  /^items:[[:space:]]*$/ {i=1}
  END{ if(!v||!i){ exit 1 } }
' "${SPECS}/roadmap.yaml"
```

Optional stronger parse when Ruby is available:

```bash
ruby -ryaml -e 'd=YAML.load_file(ARGV[0]); abort "bad" unless d.is_a?(Hash)&&d["items"].is_a?(Array)' "${SPECS}/roadmap.yaml"
```

**3b · Query scripts return slices (zero model tokens)**

```bash
bash scripts/roadmap-row.sh
bash scripts/roadmap-query.sh backlog --limit 5
bash scripts/roadmap-query.sh hygiene
```

Each must exit 0 when the ledger has backlog/not_started rows (or print an empty/NONE contract the script defines — still exit 0 for backlog/hygiene when the file loads). `get <slug>` may exit 1 only for a missing slug.

**3c · Human view (optional but recommended)**

```bash
bash scripts/roadmap-print.sh | head -40
```

**3d · Lossless spot-check**

- Count backlog rows in the old MD table vs `items:` entries that are not solely `shipped` history if you can still read the MD.
- Spot-check one long Notes cell: must appear verbatim under that item’s `notes: |` in YAML.
- If the MD had `## Recently merged`, confirm `shipped_history:` exists.
- If the MD had appendix/`backlog detail` sections, confirm `appendix:` or item-associated notes preserved them.

Observable result: quote one `path:line` from `roadmap-row.sh` and one item slug from YAML back to the human.

### Step 4 — Rewire consumers (AI-owned instruction files)

In **this** project’s skills/agents/knowledge that load the roadmap:

1. Replace happy-path `Read ${specs_root}/roadmap.md` (or whole-file `roadmap.yaml` reads) with:
   - first backlog row → `bash scripts/roadmap-row.sh`
   - backlog slice → `bash scripts/roadmap-query.sh backlog --limit N`
   - one record → `bash scripts/roadmap-query.sh get <slug>`
   - hygiene hints → `bash scripts/roadmap-query.sh hygiene`
2. Keep whole-file `Read` of `roadmap.yaml` **only** as fallback when a script exits non-zero (mark the line with fallback / fall-through / non-zero language).
3. Update schema docs to the YAML shape in [`manager/knowledge/sequencing-heuristics.md`](../../manager/knowledge/sequencing-heuristics.md) §"Roadmap ledger format" (or the local equivalent).
4. Write targets (serialized merge / status updates) must name `roadmap.yaml`, not `roadmap.md`.

Marketplace reference consumers (already migrated): `manager/skills/next`, `manager/agents/project-manager`, `manager/skills/implement`, `manager/skills/check`.

Observable result: `rg -n 'roadmap\.md' <your-skills-agents-knowledge>` shows **no** live happy-path load of the MD ledger (CHANGELOG/archive/history may still mention it).

### Step 5 — Cite-sweep product docs

Update any **current** (non-archive) doc that still presents `roadmap.md` as the live SoT — README, ARCHITECTURE, init examples, module specs — to `roadmap.yaml`.  
Leave `.lsa/archive/**` and historical CHANGELOG entries untouched.

### Step 6 — Cleanup (destructive — only after Steps 3–5 pass)

```bash
# Dual-SoT is forbidden. Delete the markdown ledger.
rm -f "${SPECS}/roadmap.md"
test ! -f "${SPECS}/roadmap.md"
```

Observable result: only `${SPECS}/roadmap.yaml` remains as the roadmap SoT.

### Step 7 — Final verification gate

```bash
bash scripts/roadmap-row.sh
bash scripts/roadmap-query.sh backlog --limit 5
# If the marketplace lint suite is present:
bash scripts/lint.sh          # includes roadmap schema C14 when wired
bash scripts/check-citations.sh
bash scripts/check-links.sh
# If F9 test is present:
bash scripts/tests/no-wholefile-ledger-read.sh
```

Observable result: all invoked checks exit 0. Report PASS with the commands + exits cited (gate-proven done).

### Step 8 — Report to the human

Print a short close-out:

1. Migrated path: `roadmap.md` → `roadmap.yaml`
2. Item count (and shipped_history / appendix if present)
3. Scripts used
4. Files rewired
5. Cleanup: MD deleted (yes/no)
6. Gate commands + exit codes

---

## Hard rules

| Rule | Meaning |
|---|---|
| Single SoT | Never leave both `roadmap.md` and `roadmap.yaml` as live ledgers after Step 6 |
| No happy-path whole-file Read | Scripts first; `Read` YAML only on non-zero script exit |
| No silent failure | Failed verify ⇒ keep MD, do not cleanup |
| Scripts stay Pro-safe | Prefer the shipped awk/bash migrator; do not require yq/python to migrate |
| Greenfield | New projects get empty `roadmap.yaml` from `lsa:init` — do not create `roadmap.md` |

---

## Starter ledger (greenfield / empty)

If you must create a ledger without migrating (no MD source):

```yaml
version: 1
items: []
shipped_history: []
```

Add items later via `manager:shape` / roadmap write path — do not invent backlog rows.

---

## Related

- Schema / query usage: [`manager/knowledge/sequencing-heuristics.md`](../../manager/knowledge/sequencing-heuristics.md)
- Measured impact: [`.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md`](../../.lsa/observations/2026-07-16-yaml-ledger-selective-load-impact.md)
- Epic requirements: [`.lsa/features/2026-07-16-yaml-ledger-read-cutover/requirements.md`](../../.lsa/features/2026-07-16-yaml-ledger-read-cutover/requirements.md)
- Init (YAML default): [`../skills/init/SKILL.md`](../skills/init/SKILL.md)
