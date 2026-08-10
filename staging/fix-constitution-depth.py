#!/usr/bin/env python3
"""Fix markdown-link references to .lsa/constitution.md / .lsa/constitution-digest.md
whose relative-path depth is wrong (a sequencing artifact: the literal
VISION->constitution string rename ran between two relink.py passes, so
already-renamed-but-wrong-depth paths looked "no change needed" to relink).

For every [`X`](Y) where Y (anchor-stripped) ends in .lsa/constitution.md or
.lsa/constitution-digest.md, recompute the correct relative path from the
citing file's actual location in the staged tree and fix both bracket text
and href if wrong.
"""
import os
import re
from pathlib import Path

STAGE = Path(__file__).parent / "vendor-neutral-agent-skills-home"
PATTERN = re.compile(r"\[`([^`]*)`\]\(([^)]+)\)")
TARGETS = {".lsa/constitution.md", ".lsa/constitution-digest.md"}

fixed = 0
for f in sorted(STAGE.rglob("*.md")):
    text = f.read_text(encoding="utf-8")

    def sub(m):
        global fixed
        bracket, href = m.group(1), m.group(2)
        href_path, _, anchor = href.partition("#")
        basename = href_path.rstrip("/").split("/")[-1]
        target = None
        if basename == "constitution.md":
            target = ".lsa/constitution.md"
        elif basename == "constitution-digest.md":
            target = ".lsa/constitution-digest.md"
        else:
            return m.group(0)
        correct_rel = os.path.relpath(STAGE / target, start=f.parent)
        if href_path == correct_rel:
            return m.group(0)
        fixed += 1
        new_anchor = ("#" + anchor) if anchor else ""
        return f"[`{correct_rel}`]({correct_rel}{new_anchor})"

    new_text = PATTERN.sub(sub, text)
    if new_text != text:
        f.write_text(new_text, encoding="utf-8")

print(f"Fixed {fixed} wrong-depth constitution reference(s).")
