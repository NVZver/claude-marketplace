# Epic pro-tier-token-affordability/project-index — Requirements

Parent: ../../../pitches/pro-tier-token-affordability.md (WS2) · Status: approved · Date: 2026-07-15
Amended: 2026-07-15 — ship `project-map.yaml` out of the box (breaking vs first WS2 landing).
Modules: lsa (discover / init / conventions + shipped scripts). Grounding: plan ship-project-map.

## Functional requirements (EARS)

- **F1** (Ubiquitous) The lsa plugin shall ship `lsa/scripts/project-map-build.sh` that deterministically
  produces repo-root `project-map.yaml` — a 3-level tree of **directories** under the repo root (a
  navigational map, not a file catalog) — with **no model calls** (same tracked tree ⇒ same output).
- **F2** (Ubiquitous) The generated map shall open with a `GENERATED — DO NOT EDIT` comment naming the
  regen command; it shall not list itself as a tree entry.
- **F3** (Ubiquitous) The map shall include only directory paths of depth ≤ 3 (`a`, `a/b`, `a/b/c`).
  Directories deeper than level 3 truncate. Depth is one size control; the ≤1k-token budget (F9) is the
  binding cap.
- **F4** (Ubiquitous) Entries shall be **directories only** — no files, no model-written descriptions.
  Directory keys nest to depth 3; a leaf directory carries a null value.
- **F5** (Event) When `lsa/scripts/project-map-check.sh` runs, it shall rebuild then FAIL if
  `project-map.yaml` has any git porcelain status (modified / deleted / untracked), else PASS.
- **F6** (Event) When an LSA skill scopes reads (discover Step 1), it shall consult `project-map.yaml`
  **before** walking the tree, per the read protocol (`lsa/knowledge/conventions.md` §"Read protocol").
- **F7** (Unwanted) If the map is absent, the read protocol shall note the gap and fall back to a
  tree-walk — never a hard error. If the builder is not in a git work tree, it shall exit non-zero.
- **F8** (Event) `lsa:init` shall run the builder when available so new projects get `project-map.yaml`
  out of the box.
- **F9** (Ubiquitous) The generated map shall stay within a **1k-token budget** (parent pitch success
  criterion, `../../../pitches/pro-tier-token-affordability.md`; ≈ 4096 chars via the chars/4 heuristic),
  enforced by `scripts/lint.sh` C13 — hard-fail, not advisory. Restores the pitch cap the first
  amendment (former D4) wrongly deleted.

## Acceptance criteria (journey-shaped)

- **AC1** (F1, F3, F4) Run `bash lsa/scripts/project-map-build.sh` twice ⇒ byte-identical YAML; no
  filenames appear (directories only); depth-4 directories do not appear; leaf directories are
  null-valued keys.
- **AC2** (F5) `bash lsa/scripts/project-map-check.sh` PASSes on a committed fresh map; FAILs after a
  tracked tree change without committing an updated map.
- **AC3** (F6) `lsa/knowledge/conventions.md` §"Read protocol" and `lsa/skills/discover/SKILL.md` Step 1
  both name `project-map.yaml`.
- **AC4** (F8) `lsa/skills/init/SKILL.md` includes a step that runs the builder when available.
- **AC5** (F2) `project-map.yaml` opens with the GENERATED banner; does not list `project-map.yaml` in `tree:`.
- **AC6** (F9) `bash scripts/lint.sh` C13 PASSes with the map under the 1k-token budget; FAILs if the map
  exceeds ~4096 chars.

## Design decisions (amended 2026-07-15)

- **D1** Home: repo-root `project-map.yaml` (whole-repo atlas; name encodes purpose).
- **D2** Generator + checker ship in **`lsa/scripts/`** (plugin `artifact_paths`); available to every
  marketplace consumer. Reverses the first WS2 D2 ("not shipped").
- **D3** Staleness = **rebuild then porcelain must be clean** (`project-map-check.sh`), not silent
  auto-commit. Wire as `.lsa.yaml gate: project-map` + CI. Ownership stays with the human.
- **D4** Size control = **directories-only + depth ≤ 3 + a hard 1k-token budget** (F9, `lint.sh` C13).
  The 2026-07-15 amendment that dropped the budget in favour of depth-only was **reverted**: a
  file-level depth-3 map reached ~1,570 tokens (57% over the pitch cap) and could not scope past
  directories, so the budget is restored as the binding control and the map is directories-only.
- **D5** Owner plugin: `lsa` — SemVer + CHANGELOG + README bump with the shipping change.
- **D6** Content is repo-generic (no LSA-only spine/slug/H1 collapse). Skip `node_modules`; skip the
  map file itself; skip index paths missing from the working tree; skip historical subtrees via
  `EXCLUDE_GLOBS` (`.lsa/archive/*`) so the token budget buys navigable signal.

## Non-functional

- Zero model tokens on generation.
- Backward-compatible degrade: absent map ⇒ tree-walk (F7).
- Breaking vs first WS2 landing: `.lsa/PROJECT-index.md` and `scripts/build-index.sh` removed.
