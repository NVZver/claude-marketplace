#!/usr/bin/env python3
"""Fix markdown links of the form [`<old-path>`](<new-path>) where the bracket
display text still shows the pre-migration path but the href was already
corrected by relink.py. This repo's convention is self-mirroring links --
the bracket text always matches the href -- so the fix is: replace the
bracket text with the href's own value whenever they differ and both look
like repo-relative paths (never touches external URLs or genuinely
different link-text-vs-target pairs, which this repo doesn't use)."""
import re
from pathlib import Path

STAGE = Path(__file__).parent / "vendor-neutral-agent-skills-home"
PATTERN = re.compile(r"\[`([^`]+)`\]\(([^)]+)\)")

def looks_like_path(s: str) -> bool:
    return ("/" in s or s.endswith(".md")) and not s.startswith("http")

changed = 0
for f in sorted(STAGE.rglob("*.md")):
    text = f.read_text(encoding="utf-8")

    def sub(m):
        global changed
        bracket, href = m.group(1), m.group(2)
        href_path, _, anchor = href.partition("#")
        bracket_path, _, bracket_anchor = bracket.partition("#")
        if bracket_path == href_path:
            return m.group(0)
        if not (looks_like_path(bracket_path) and looks_like_path(href_path)):
            return m.group(0)
        # only fix when they clearly refer to the same target (same basename)
        if bracket_path.split("/")[-1] != href_path.split("/")[-1]:
            return m.group(0)
        changed += 1
        new_bracket = href_path + (("#" + bracket_anchor) if bracket_anchor else "")
        return f"[`{new_bracket}`]({href})"

    new_text = PATTERN.sub(sub, text)
    if new_text != text:
        f.write_text(new_text, encoding="utf-8")

print(f"Fixed {changed} mismatched link-text/href pair(s).")
