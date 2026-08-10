#!/usr/bin/env python3
"""Mechanical re-linker for the lift-and-shift staging tree.

Two distinct reference styles exist in this repo, resolved differently:
  - markdown links `[text](path)` are relative to the CITING FILE's directory.
  - inline-code citations `` `path` `` (e.g. `.lsa/VISION.md`, `core/skills/x/SKILL.md`)
    are REPO-ROOT-relative, regardless of where they're cited from.
Conflating these two (an earlier version of this script did) corrupts every
root-relative code citation. Fixed here: each is resolved with its own rule.

For every reference, resolves what it pointed to in the ORIGINAL repo layout,
looks up where that target now lives in the NEW staged layout (MAP_RULES),
and rewrites the reference: markdown links get a recomputed relative path;
code citations get the new root-relative path (matching their original style).
References this script cannot confidently remap (external URLs, [illustrative]
placeholders, memory citations, §C leave-behind paths) are left untouched.
"""
import os
import re
import sys
from pathlib import Path

STAGE = Path(__file__).parent / "vendor-neutral-agent-skills-home"

PACKS_WITH_SKILLS = {"core", "lsa", "manager", "observer"}
PACKS_WITH_KNOWLEDGE = {"core", "lsa", "manager", "observer", "prompt-engineer"}
PACKS_WITH_AGENTS = {"lsa", "manager", "prompt-engineer"}
PACKS_WITH_COMMANDS = {"prompt-engineer"}

RENAMES = {
    ".lsa/VISION.md": ".lsa/constitution.md",
    ".lsa/VISION-digest.md": ".lsa/constitution-digest.md",
}

LEAVE_AS_IS_PREFIXES = (
    ".claude-plugin/",
    ".claude/",
    "dist/cursor/",
    "docs/client.md",
    "feature/X",
    "feedback_verifiable_done_predicate.md",
)


def map_old_repo_path(old_path: str):
    if old_path in RENAMES:
        return RENAMES[old_path]
    if any(old_path.startswith(p) for p in LEAVE_AS_IS_PREFIXES):
        return None  # leave-as-is: don't rewrite, don't flag
    parts = old_path.split("/")
    if len(parts) >= 3 and parts[1] == "skills" and parts[0] in PACKS_WITH_SKILLS:
        return "skills/" + parts[0] + "/" + "/".join(parts[2:])
    if len(parts) >= 3 and parts[1] == "knowledge" and parts[0] in PACKS_WITH_KNOWLEDGE:
        return "skills/" + parts[0] + "/knowledge/" + "/".join(parts[2:])
    if len(parts) >= 3 and parts[1] == "agents" and parts[0] in PACKS_WITH_AGENTS:
        return "skills/" + parts[0] + "/agents/" + "/".join(parts[2:])
    if len(parts) >= 3 and parts[1] == "commands" and parts[0] in PACKS_WITH_COMMANDS:
        return "skills/" + parts[0] + "/commands/" + "/".join(parts[2:])
    if old_path.startswith(".lsa/"):
        return old_path
    if old_path == "knowledge/index.md":
        return old_path
    if len(parts) == 2 and parts[1] in ("CORE.md", "ARCHITECTURE.md", "README.md", "CHANGELOG.md", "VERIFICATION.md") and parts[0] in PACKS_WITH_SKILLS | {"prompt-engineer"}:
        return "skills/" + parts[0] + "/" + parts[1]
    return None


MD_LINK = re.compile(r"(\]\()([^)]+)(\))")
CODE_PATH = re.compile(r"(`)((?:\.lsa|core|lsa|manager|observer|prompt-engineer|knowledge)/[A-Za-z0-9_./-]+\.(?:md|yaml|yml|json|sh|feature))(`)")


def staged_path_to_old_path(staged_file: Path) -> str:
    rel = staged_file.relative_to(STAGE).as_posix()
    parts = rel.split("/")
    if parts[0] == "skills" and len(parts) >= 3:
        pack = parts[1]
        if parts[2] in ("knowledge", "agents", "commands", "tests", "scripts") and len(parts) >= 4:
            return f"{pack}/{parts[2]}/{'/'.join(parts[3:])}"
        if len(parts) == 3:
            # a bare file directly under skills/<pack>/ (README.md, CHANGELOG.md,
            # ARCHITECTURE.md, CORE.md, VERIFICATION.md) -- a pack-level doc,
            # not a skill subdirectory. Old location: <pack>/<file> (no "skills/").
            return f"{pack}/{parts[2]}"
        return f"{pack}/skills/{'/'.join(parts[2:])}"
    return rel


def resolve_relative(base_repo_path: str, ref: str):
    """Resolve a markdown-link target (true relative-to-file) to an old repo-root path."""
    ref = ref.split("#", 1)[0]
    if not ref or ref.startswith("http://") or ref.startswith("https://") or ref.startswith("mailto:"):
        return None
    base_dir = Path(base_repo_path).parent
    combined = os.path.normpath(str(base_dir / ref))
    if combined.startswith(".."):
        return None  # escapes repo root - not our concern
    return combined.replace(os.sep, "/")


def process_file(staged_file: Path, log: list):
    old_base = staged_path_to_old_path(staged_file)
    text = staged_file.read_text(encoding="utf-8")

    def md_sub(m):
        ref = m.group(2)
        anchor = ""
        core_ref = ref
        if "#" in ref:
            core_ref, anchor = ref.split("#", 1)
            anchor = "#" + anchor
        old_target = resolve_relative(old_base, core_ref)
        if old_target is None:
            return m.group(0)
        new_target = map_old_repo_path(old_target)
        if new_target is None or new_target == old_target:
            return m.group(0)
        new_rel = os.path.relpath(STAGE / new_target, start=staged_file.parent)
        log.append((str(staged_file.relative_to(STAGE)), core_ref, new_rel, "md-link"))
        return m.group(1) + new_rel + anchor + m.group(3)

    def code_sub(m):
        ref = m.group(2)
        old_target = ref.split("#", 1)[0]
        new_target = map_old_repo_path(old_target)
        if new_target is None or new_target == old_target:
            return m.group(0)
        log.append((str(staged_file.relative_to(STAGE)), old_target, new_target, "code-path"))
        return m.group(1) + new_target + m.group(3)

    new_text = MD_LINK.sub(md_sub, text)
    new_text = CODE_PATH.sub(code_sub, new_text)
    if new_text != text:
        staged_file.write_text(new_text, encoding="utf-8")
    return len(log)


def main():
    dry_run = "--apply" not in sys.argv
    log = []
    for f in sorted(STAGE.rglob("*.md")):
        if dry_run:
            # process a throwaway copy of the text in-memory only
            old_base = staged_path_to_old_path(f)
            text = f.read_text(encoding="utf-8")
            tmp_log = []

            def md_sub(m, old_base=old_base, tmp_log=tmp_log, f=f):
                ref = m.group(2)
                core_ref = ref.split("#", 1)[0]
                old_target = resolve_relative(old_base, core_ref)
                if old_target is None:
                    return m.group(0)
                new_target = map_old_repo_path(old_target)
                if new_target is None or new_target == old_target:
                    return m.group(0)
                tmp_log.append((str(f.relative_to(STAGE)), core_ref, new_target, "md-link"))
                return m.group(0)

            def code_sub(m, tmp_log=tmp_log, f=f):
                ref = m.group(2)
                old_target = ref.split("#", 1)[0]
                new_target = map_old_repo_path(old_target)
                if new_target is None or new_target == old_target:
                    return m.group(0)
                tmp_log.append((str(f.relative_to(STAGE)), old_target, new_target, "code-path"))
                return m.group(0)

            MD_LINK.sub(md_sub, text)
            CODE_PATH.sub(code_sub, text)
            log.extend(tmp_log)
        else:
            process_file(f, log)

    print(f"{'[DRY RUN] Would rewrite' if dry_run else 'Rewrote'} {len(log)} reference(s).")
    for entry in log[:40]:
        print(f"  {entry[0]}: {entry[1]!r} -> {entry[2]!r} ({entry[3]})")
    if len(log) > 40:
        print(f"  ... and {len(log) - 40} more")


if __name__ == "__main__":
    main()
