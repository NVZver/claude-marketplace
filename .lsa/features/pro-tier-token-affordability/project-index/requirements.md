# Epic pro-tier-token-affordability/project-index — Requirements

Parent: ../../../pitches/pro-tier-token-affordability.md (WS2) · Status: approved · Date: 2026-07-15
Modules: lsa (discover read-protocol wiring). Repo-internal infra: `scripts/build-index.sh`, `.lsa/PROJECT-index.md`, `scripts/lint.sh` checks. Grounding: lsa:discover 2026-07-15.

## Functional requirements (EARS)

- **F1** (Ubiquitous) A repo-internal generator `scripts/build-index.sh` shall deterministically
  produce `.lsa/PROJECT-index.md` — a structural map of the repo's tracked markdown surface — with
  **no model calls** (same input ⇒ same output; aider repo-map precedent, pitch WS2).
- **F2** (Ubiquitous) The generated index shall carry a trace directive, a `GENERATED — DO NOT EDIT`
  banner, and a staleness marker, mirroring `scripts/build-vision-digest.sh` (the WS1 digest precedent).
- **F3** (Ubiquitous) The index shall stay within a **hard budget of ≤ 1000 tokens** (estimated
  `chars / 4`), enforced by a `scripts/lint.sh` check that is a gate, not advisory (rabbit hole 2).
- **F4** (Ubiquitous) Every description in the index shall be extracted **verbatim** — markdown H1
  headings for spine files; deterministic counts / slug-lists for plugin and historical trees — with
  **no model-written descriptions** (No-go 6; headings ARE the descriptions, pitch WS2).
- **F5** (Event) When `scripts/lint.sh` runs, the system shall FAIL if the committed
  `.lsa/PROJECT-index.md` differs from a fresh regeneration (missing or stale), naming the
  regeneration command `bash scripts/build-index.sh`.
- **F6** (Event) When an LSA skill scopes reads (discover Step 1 — "the code/specs the request
  touches"), it shall consult `.lsa/PROJECT-index.md` to locate the files the request touches
  **before** walking the tree, per the read protocol (`lsa/knowledge/conventions.md` §"Read protocol").
- **F7** (Unwanted) If the index is absent, or a source file lacks an H1, then the generator shall
  degrade gracefully (skip / blank that description) and the read protocol shall note the gap —
  never a hard error (`core/skills/ground-rules/SKILL.md` Rule 3).
- **F8** (Event) When the index is loaded, the system shall print its file-load trace line.

## Acceptance criteria (journey-shaped)

- **AC1** (F1, F4) Run `bash scripts/build-index.sh` twice ⇒ byte-identical output; the index lists
  the live `.lsa/` spine by H1 and collapses `features/` `pitches/` `archive/` to counts + slug lists.
- **AC2** (F3) `bash scripts/lint.sh` ⇒ the budget check prints the index token estimate ≤ 1000 and PASSes.
- **AC3** (F5) Add a tracked `*.md` file (or change an H1) without regenerating ⇒ lint FAILs the
  freshness check naming `bash scripts/build-index.sh`; regenerate ⇒ PASS.
- **AC4** (F6) Open `lsa/knowledge/conventions.md` §"Read protocol" and `lsa/skills/discover/SKILL.md`
  Step 1 ⇒ both name `.lsa/PROJECT-index.md` as the scoping map consulted before walking the tree.
- **AC5** (F2, F8) `.lsa/PROJECT-index.md` opens with the trace directive + `GENERATED — DO NOT EDIT`
  banner; loading it prints the trace line.

## Design decisions (resolved at the 2026-07-15 spec gate)

- **D1** Home: `.lsa/PROJECT-index.md` — an LSA-workspace artifact consumed by the LSA read protocol,
  sibling to `.lsa/VISION-digest.md`. `.lsa/` is excluded from `check-citations.sh` / `check-links.sh`
  (`scripts/check-links.sh:88`), so the generated index is **freshness-checked, not link-checked** —
  identical treatment to the digest.
- **D2** Generator home: `scripts/build-index.sh` — repo-internal, **NOT shipped in any plugin** (same
  class as `scripts/build-vision-digest.sh` and `scripts/lint.sh`); it lives outside every plugin's
  `artifact_paths`, so the script + index + lint checks trigger **no plugin version bump**.
- **D3** Staleness = **regenerate-and-diff**, not a single `source-sha256` (the index derives from a
  *set* of files, not one input): lint regenerates into a temp file and diffs against the committed
  index, catching added / removed / renamed files and changed H1s. This **diverges from the pitch's
  Fork D** (commit-hook + CI auto-rebuild): no git-hook infra exists in the repo (`.githooks/` absent),
  the WS1 digest set the staleness-lint precedent (`scripts/lint.sh` C12), and a hook that silently
  rebuilds inside the user's commit conflicts with the ownership-over-automation credo
  (`.lsa/VISION.md` §2 principle 7). CI already runs `lint.sh` (`.github/workflows/lint.yml:14`).
- **D4** Budget proxy = `chars / 4` (English rule-of-thumb ≈ 1 token per 4 chars); cap 1000 tokens
  (aider's default). Documented in the check comment.
- **D5** Owner plugin: `lsa` — only the discover read-protocol wiring is user-visible LSA behavior;
  it bumps `lsa` SemVer + CHANGELOG + README in the same commit (`.lsa/standards/code.md:18-22`).

## Non-functional

- Zero model tokens on generation (No-go 6; deterministic — research: LLM context files lowered
  success and raised cost ~20%).
- Backward-compatible: an absent index degrades the read protocol to today's tree-walk (F7), never a block.
- Repo-internal script / index / lint carry no plugin version bump (D2); only the `lsa` wiring bumps `lsa`.
