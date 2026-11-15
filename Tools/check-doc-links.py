#!/usr/bin/env python3
"""Check local Markdown links in README, SECURITY, AGENTS, and docs."""

from __future__ import annotations

import os
import re
import sys
import urllib.parse
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
EXTERNAL_TARGET_RE = re.compile(r"^(?:[a-z][a-z0-9+.-]*:|//)", re.IGNORECASE)
LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")


def markdown_files(directory: Path, relative_directory: str = "") -> list[str]:
    if not directory.exists():
        return []
    files: list[str] = []
    for entry in sorted(directory.iterdir(), key=lambda p: p.name):
        relative = (
            f"{relative_directory}/{entry.name}" if relative_directory else entry.name
        )
        if entry.is_dir():
            files.extend(markdown_files(entry, relative))
        elif entry.is_file() and entry.name.lower().endswith(".md"):
            files.append(relative)
    return files


def target_path(raw_target: str) -> str | None:
    stripped = raw_target.strip()
    if stripped.startswith("<") and ">" in stripped:
        target = stripped[1 : stripped.index(">")]
    else:
        target = stripped.split(None, 1)[0] if stripped else ""
    if not target or EXTERNAL_TARGET_RE.match(target) or target.startswith("#"):
        return None
    without_fragment = re.split(r"[?#]", target, maxsplit=1)[0]
    if not without_fragment:
        return None
    try:
        return urllib.parse.unquote(without_fragment)
    except Exception:
        return without_fragment


def check_markdown_links(root: Path = REPOSITORY_ROOT) -> int:
    candidates = [
        "README.md",
        "SECURITY.md",
        "AGENTS.md",
        "Packages/KanoNaviKit/README.md",
        "Tools/local-backend/README.md",
        *markdown_files(root / "docs", "docs"),
    ]
    files: list[str] = []
    for item in candidates:
        if item not in files and (root / item).exists():
            files.append(item)

    missing: list[tuple[str, int, str]] = []
    links_checked = 0

    for rel_file in files:
        file_path = root / rel_file
        contents = file_path.read_text(encoding="utf-8")
        for line_no, line in enumerate(contents.splitlines(), start=1):
            for match in LINK_RE.finditer(line):
                rel_target = target_path(match.group(1))
                if rel_target is None:
                    continue
                links_checked += 1
                resolved = (file_path.parent / rel_target).resolve()
                if not resolved.exists():
                    missing.append((rel_file, line_no, rel_target))

    if missing:
        print(
            f"Documentation link check found {len(missing)} missing target(s):",
            file=sys.stderr,
        )
        for rel_file, line_no, target in missing:
            print(f"- {rel_file}:{line_no}: {target}", file=sys.stderr)
        return 1

    print(
        f"Documentation link check passed ({len(files)} Markdown file(s), {links_checked} local link(s))."
    )
    return 0


if __name__ == "__main__":
    sys.exit(check_markdown_links())
