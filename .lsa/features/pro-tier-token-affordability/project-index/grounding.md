# Grounding — project-index → project-map (amended)

Feature: pro-tier-token-affordability/project-index · Date: 2026-07-15

## Codebase facts (post-amendment)

| Fact | Evidence |
|---|---|
| Builder ships in lsa plugin | `lsa/scripts/project-map-build.sh` |
| Checker ships in lsa plugin | `lsa/scripts/project-map-check.sh` |
| Output path | repo-root `project-map.yaml` |
| Discover consults map | `lsa/skills/discover/SKILL.md` Step 1 |
| Read protocol names map | `lsa/knowledge/conventions.md` §"Read protocol" |
| Init runs builder | `lsa/skills/init/SKILL.md` Step 4 |
| Gate wired | `.lsa.yaml` `gate.project-map` |
| artifact_paths includes scripts | `.lsa.yaml` `lsa.artifact_paths` → `lsa/scripts/**/*.sh` |
| Real-flow tests | `lsa/scripts/tests/test-project-map.sh` (12 checks) |
| CI | `.github/workflows/lint.yml` runs tests + check |
| Old index removed | `.lsa/PROJECT-index.md`, `scripts/build-index.sh` deleted |

## Buildability

- Flow 1 (generate): buildable — deterministic YAML, depth ≤ 3.
- Flow 2 (discover): buildable — conventions + discover cite `project-map.yaml`.
- Flow 3 (freshness): buildable — check rebuilds then porcelain-clean gate.
