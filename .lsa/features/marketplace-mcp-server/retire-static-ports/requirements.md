Parent: [Marketplace-as-MCP-server](../../../pitches/marketplace-mcp-server.md)
Epic: marketplace-mcp-server/retire-static-ports
Date: 2026-08-25
Status: draft

# Retire static per-client ports

Remove `dist/cursor/`, `dist/opencode/`, and their generate/deploy scripts
now that the live MCP server covers the core+lsa+manager scope those ports
targeted, and fix the one live dangling-reference consequence this
deletion creates.

## User flow

### Flow 1 — Static per-client ports retired, no dangling references left behind

- **Flow:** A maintainer removes the now-superseded static distribution
  mechanism (`dist/cursor/`, `dist/opencode/`, and their generate/deploy
  scripts) now that the live MCP server covers the clients they targeted.
- **Success:** `dist/cursor/`, `dist/opencode/`,
  `scripts/opencode-dist-generate.sh`, `scripts/opencode-dist-deploy.sh`
  are gone. `mcp-server/UNSUPPORTED-MECHANISMS.md`'s two citations into
  the now-deleted script are fixed so the repo gate stays green.
  README/CONTRIBUTING need no edit (verified: no references exist).
- **I/O:** Input = current repo state (`dist/` untracked, scripts now
  committed); Output = repo with the static-port mechanism removed and
  zero dangling references.
- **Test:** The files/directories no longer exist;
  `bash scripts/check-citations.sh` and `bash scripts/check-links.sh`
  still exit 0; `bash scripts/gate.sh` stays green.

## Requirements (EARS)

1. **The system shall** remove the directories `dist/cursor/` and
   `dist/opencode/`.
2. **The system shall** remove the files
   `scripts/opencode-dist-generate.sh` and
   `scripts/opencode-dist-deploy.sh`.
3. **The system shall** update `mcp-server/UNSUPPORTED-MECHANISMS.md`'s two
   citations into `scripts/opencode-dist-generate.sh` (the markdown link
   and the bare `path:line` citation) so neither references a path that no
   longer exists — the already-inline blockquote of the policy text is
   preserved unchanged; only the dangling citation wording is corrected
   (e.g. framed as historical precedent, no live link).
4. **The system shall not** modify `README.md` or `CONTRIBUTING.md`, since
   neither contains any reference to the retired mechanism (verified at
   discover: zero matches for `dist/cursor`, `dist/opencode`,
   `opencode-dist`, "OpenCode", "Cursor").
5. **The system shall not** modify `.lsa/roadmap.yaml`'s unrelated
   `cursor-equal-support` planning note (a different, never-shaped
   initiative referencing a different, nonexistent script name) or any
   file under `.lsa/features/marketplace-mcp-server/*` or `.lsa/pitches/*`
   (frozen historical record, exempt from the live-citation gate by
   `scripts/check-citations.sh`'s own documented scope).
6. **After the removal**, **the system shall** confirm
   `bash scripts/check-citations.sh`, `bash scripts/check-links.sh`, and
   `bash scripts/gate.sh` all still exit 0.

## Facts this spec is grounded on (from discover)

- `dist/` is entirely gitignored (`.gitignore:7` "dist/") with zero
  git-tracked files (`git ls-files dist/ | wc -l` → 0) — `dist/cursor/`
  (59 files, hand-maintained per `scripts/opencode-dist-generate.sh:5`
  "Companion to dist/cursor/ (hand-maintained, no generator)") and
  `dist/opencode/` (17 files, script-generated) are both local-only build
  artifacts, never part of repo history.
- `scripts/opencode-dist-generate.sh` and `scripts/opencode-dist-deploy.sh`
  were uncommitted (working-tree-only) at discover time; committed as a
  preservation record this session (commit `a82bd3d`) before this epic's
  deletion, per explicit user decision — so their deletion in this epic
  IS a real, git-recoverable diff.
- `README.md` and `CONTRIBUTING.md`: zero references to `dist/cursor`,
  `dist/opencode`, `opencode-dist`, "OpenCode", or "Cursor" (`grep -n`
  across both files, zero matches) — the epic's original DoD phrase
  "redirect README/CONTRIBUTING references" is moot; there is nothing to
  redirect in either file.
- Repo-wide grep (excluding `dist/` itself and the `.lsa/` spec+archive
  tree, which `scripts/check-citations.sh`'s own scope explicitly exempts
  as frozen historical record) found exactly one live, gate-checked file
  with dangling-reference risk: `mcp-server/UNSUPPORTED-MECHANISMS.md`
  (shipped in the already-reconciled `unsupported-mechanism-gap-list`
  epic) cites `scripts/opencode-dist-generate.sh` twice — a markdown link
  and a bare `path:line` citation, both at `scripts/opencode-dist-generate.sh:50-52`.
  Deleting the script would break both under `scripts/check-citations.sh`
  and `scripts/check-links.sh` (both part of the `.lsa.yaml` `gate:`
  block) — this epic must fix both references as a direct, in-scope
  consequence of its own deletion, not scope creep.
- The policy text these two citations point to is already quoted verbatim
  in `mcp-server/UNSUPPORTED-MECHANISMS.md` (a blockquote) — the citations
  can be safely dropped/reworded to reference the quote as historical
  precedent, without losing any information, since the substance is
  already inline.
- `.lsa/roadmap.yaml:588` mentions a different, unrelated, never-shaped
  "cursor-equal-support" pitch referencing a different script name
  (`scripts/generate-for-cursor.sh`, which does not exist) — historical
  planning prose for an abandoned initiative, unrelated to the
  scripts/dist being retired here; out of this epic's scope, not touched.
