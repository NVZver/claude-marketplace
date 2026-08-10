#!/usr/bin/env python3
"""Link-resolution checker for the staged lift-and-shift tree.

Scans every .md file under staging/vendor-neutral-agent-skills-home/ for:
  - markdown links: [text](path)
  - inline-code repo-relative paths: `some/path/like/this.md` or `.lsa/x.md`
and verifies each resolves to a real file, either relative to the citing
file's directory or relative to the staged tree's root. Skips http(s) URLs,
pure anchors (#foo), and paths that don't look like a repo file reference.

Usage: python3 check-staged-links.py
Exit 0 = all resolve. Exit 1 = some don't (printed with citing file:line).
"""
import re
import sys
from pathlib import Path

STAGE = Path(__file__).parent / "vendor-neutral-agent-skills-home"

MD_LINK = re.compile(r"\]\(([^)]+)\)")
CODE_PATH = re.compile(r"`([A-Za-z0-9_./-]+\.(?:md|yaml|yml|json|sh|feature))`")

def looks_like_path(p: str) -> bool:
    if p.startswith("http://") or p.startswith("https://"):
        return False
    if p.startswith("#"):
        return False
    if " " in p:
        return False
    return "/" in p or p.endswith(".md")

def strip_anchor(p: str) -> str:
    return p.split("#", 1)[0]

def resolve(citing_file: Path, ref: str):
    ref = strip_anchor(ref)
    if not ref:
        return True  # pure anchor, already filtered mostly
    candidates = []
    if ref.startswith("/"):
        candidates.append(STAGE / ref.lstrip("/"))
    else:
        candidates.append((citing_file.parent / ref).resolve())
        candidates.append(STAGE / ref)
    for c in candidates:
        try:
            if c.exists():
                return True
        except OSError:
            pass
    return False

def main():
    failures = []
    for f in sorted(STAGE.rglob("*.md")):
        text = f.read_text(encoding="utf-8", errors="replace")
        for i, line in enumerate(text.splitlines(), 1):
            refs = set()
            for m in MD_LINK.finditer(line):
                refs.add(m.group(1))
            for m in CODE_PATH.finditer(line):
                refs.add(m.group(1))
            for ref in refs:
                if not looks_like_path(ref):
                    continue
                if ref.startswith("<") or ">" in ref or ref.startswith("$"):
                    continue
                if not resolve(f, ref):
                    failures.append((str(f.relative_to(STAGE)), i, ref))

    if not failures:
        print("ALL LINKS RESOLVE — 0 broken references.")
        return 0

    print(f"{len(failures)} unresolved reference(s):")
    for path, line, ref in failures:
        print(f"  {path}:{line} -> {ref}")
    return 1

if __name__ == "__main__":
    sys.exit(main())
