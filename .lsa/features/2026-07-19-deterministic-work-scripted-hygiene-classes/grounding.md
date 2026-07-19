# Grounding — hygiene classes

Verdict: **GROUNDED** @ 2026-07-19 (branch feature/deterministic-work-scripted).

## Reference map

Produced by `bash scripts/resolve-refs.sh …` (epic 3's deliverable — verify Step 1's
scripted resolver; one call, zero Grep rounds):

```
scripts/roadmap-query.sh                        → exists @ scripts/roadmap-query.sh
manager/agents/project-manager.md:53            → exists @ manager/agents/project-manager.md:53
manager/.claude-plugin/plugin.json              → exists @ manager/.claude-plugin/plugin.json
.lsa/roadmap.yaml                               → exists @ .lsa/roadmap.yaml
scripts/tests/roadmap-query-hygiene-test.sh     → new
items_tsv                                       → exists @ scripts/roadmap-query.sh:45
```

Additional grounded facts:

| Fact | Evidence |
|---|---|
| hygiene emits 3 classes today (1 missing-pitch · 2 backlog-but-branch · 3 stale-in-progress) | `scripts/roadmap-query.sh` hygiene awk block |
| Step 6 lists 4 conditions; 3–4 still model-side | `manager/agents/project-manager.md:49-53` |
| item schema has NO date/updated field (R3 boundary) | `.lsa/roadmap.yaml` items: `slug·title·priority·status·status_detail·notes` |
| `items_tsv` field order for awk | `scripts/roadmap-query.sh:45-57` → slug(1) line(2) prio(3) status(4) sd(5) title(6) notes(7) |
| merged branches exist but match no roadmap slug | `git branch --merged main` → `feature/pro-tier-always-on-card`, `feature/yaml-ledger-read-cutover`; neither slug is in the ledger |
| manager current version (R8 target) | `0.18.0` → **0.19.0** |

## Feasibility

Buildable: extend the existing awk pipeline (git+awk only) + one agent-doc edit + a
hermetic test. No infeasible flow.

**Flagged for the implementer:** class 4 cannot be proven on live data — no merged branch
matches a roadmap slug, so `hygiene` will emit zero class-4 hints on the real tree. R7
therefore *requires* a hermetic fixture; a green run on the live repo proves nothing.

## Gate

`bash scripts/gate.sh` → exit 0 (project-map re-synced + committed `89fe9fd`).

## Blockers

None.
