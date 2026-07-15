# Grounding — project-index (verify, before-check, 2026-07-15)

Verdict: **GROUNDED**

## Reference map

| Spec reference | Status |
|---|---|
| Generated-artifact precedent (script + trace + DO-NOT-EDIT banner + staleness marker) | exists @ `scripts/build-vision-digest.sh:43-67` |
| Staleness-lint precedent (regenerate/compare, name the fix command) | exists @ `scripts/lint.sh` C12 (`:362-384`) |
| Lint C-check owner + structure (`pass_line`/`fail_line`, exit 1 on any fail) | exists @ `scripts/lint.sh:27-28,386-392` |
| `.lsa/` excluded from citation + link checks (⇒ index freshness-checked, not link-checked) | exists @ `scripts/check-links.sh:88`, `scripts/check-citations.sh:124` |
| CI runs `lint.sh` (freshness + budget gate enforced in CI) | exists @ `.github/workflows/lint.yml:14` |
| Discover Step 1 "the code/specs the request touches" (F6 wiring point) | exists @ `lsa/skills/discover/SKILL.md:29` |
| Read protocol (mandatory-read list; F6 wiring point) | exists @ `lsa/knowledge/conventions.md:29-39` |
| No-model-descriptions / deterministic index (No-go 6) | exists @ pitch `pro-tier-token-affordability.md:66-75,157-158` |
| 1k-token cap lint-enforced (rabbit hole 2) | exists @ pitch `pro-tier-token-affordability.md:134-135` |
| Markdown surface to index (208 tracked `.md`; 129 in `.lsa/`: 22 feature slugs, 20 pitches, 28 archive) | verified via `git ls-files '*.md'` 2026-07-15 |
| Ownership-over-automation (grounds D3's no-auto-hook choice) | exists @ `.lsa/VISION.md` §2 principle 7 |
| `scripts/build-index.sh` (F1 generator) | **new** — repo-internal, no plugin bump |
| `.lsa/PROJECT-index.md` (F1 output) | **new** — generated, DO-NOT-EDIT |
| `scripts/lint.sh` C13 (freshness) + C14 (budget) | **new** — additive checks |
| read-protocol + discover Step 1 index wiring | **new** — `lsa` behavior (bumps lsa) |

## Feasibility

- Flow 1 (deterministic generate): buildable — `git ls-files` + `grep` H1 + `awk`; zero model calls; identical to the digest generator's shape.
- Flow 2 (discover consults index): buildable — additive read-protocol clause + discover Step 1 clause; absent index falls back to tree-walk (F7), so backward-compatible.
- Flow 3 (freshness + budget gate): buildable — C13 regenerates to a temp and diffs (mirrors C12 idea, adapted to a multi-file source); C14 measures `chars/4 ≤ 1000`.

## Divergence from pitch (recorded at spec gate, D3)

Fork D ("commit hook + CI mirror auto-rebuild the index") is **not** implemented as an auto-rebuild
hook. Instead: staleness-lint (regenerate-and-diff, C13) + the existing CI `lint.sh` run. Rationale:
(1) no git-hook infra exists (`.githooks/` absent); (2) the WS1 digest set the staleness-lint
precedent (C12); (3) a hook silently rebuilding inside the user's commit conflicts with
ownership-over-automation (`.lsa/VISION.md` §2 principle 7). Net effect is the pitch's intent —
"rebuild is free; staleness cannot ship" — achieved with a gate rather than a silent write.

## Gate results (quality-gate-contract; command + exit code) — pre-implementation baseline

- `bash scripts/lint.sh` → exit 0 (C1–C12 PASS)
- `bash scripts/check-citations.sh` → exit 0
- `bash scripts/check-links.sh` → exit 0

## Blockers

None.
