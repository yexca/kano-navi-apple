#!/usr/bin/env python3
"""Unit tests for Tools/check-doc-links.py and Tools/check-sensitive.py."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    import sys

    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


check_doc_links = load_module("check_doc_links", TOOLS_DIR / "check-doc-links.py")
check_sensitive = load_module("check_sensitive", TOOLS_DIR / "check-sensitive.py")


class DocLinksTests(unittest.TestCase):
    def test_passes_when_links_exist(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "README.md").write_text("[Guide](docs/guide.md)\n", encoding="utf-8")
            (root / "docs" / "guide.md").write_text("[Home](../README.md#top)\n", encoding="utf-8")
            self.assertEqual(check_doc_links.check_markdown_links(root), 0)

    def test_fails_when_target_is_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "README.md").write_text("[Missing](docs/missing.md)\n", encoding="utf-8")
            self.assertEqual(check_doc_links.check_markdown_links(root), 1)


class SensitiveCheckTests(unittest.TestCase):
    def test_parse_allowlist_validates_schema(self) -> None:
        hosts = check_sensitive.parse_privacy_allowlist(
            '{"version": 1, "hosts": [{"host": "kano.fans", "reason": "Public API"}]}'
        )
        self.assertEqual(hosts["kano.fans"], "Public API")

        with self.assertRaises(ValueError):
            check_sensitive.parse_privacy_allowlist('{"version": 2, "hosts": []}')

        with self.assertRaises(ValueError):
            check_sensitive.parse_privacy_allowlist(
                '{"version": 1, "hosts": [{"host": "https://kano.fans", "reason": "Bad"}]}'
            )

    def test_scan_line_flags_sensitive_values_and_allows_reserved(self) -> None:
        approved = {"kano.fans": "API"}

        findings: list = []
        check_sensitive.scan_line("a.swift", 1, 'let u = "https://api.example.com/v1"', findings, approved)
        check_sensitive.scan_line("a.swift", 2, 'let u = "https://kano.fans/api/health"', findings, approved)
        check_sensitive.scan_line("a.swift", 3, 'let token = "<REDACTED>"', findings, approved)
        self.assertEqual(findings, [])

        bad: list = []
        private_path = "".join(["/", "Users", "/alice/secret"])
        unknown_url = "".join(["https", "://private.fan/endpoint"])
        key_name = "".join(["api", "Key"])
        bad_ip = ".".join(["8", "8", "8", "8"])
        check_sensitive.scan_line("a.swift", 1, f'let p = "{private_path}"', bad, approved)
        check_sensitive.scan_line("a.swift", 2, f'let u = "{unknown_url}"', bad, approved)
        check_sensitive.scan_line("a.swift", 3, f'let {key_name} = "abcd1234efgh5678"', bad, approved)
        check_sensitive.scan_line("a.swift", 4, 'let ip = "198.51.100.42"', bad, approved)
        check_sensitive.scan_line("a.swift", 5, f'let ip = "{bad_ip}"', bad, approved)
        kinds = [item.kind for item in bad]
        self.assertEqual(
            kinds,
            [
                "private local path",
                "non-approved service URL",
                "literal value assigned to a sensitive key",
                "non-documentation IPv4 address",
            ],
        )

    def test_sensitive_paths(self) -> None:
        self.assertTrue(check_sensitive.is_sensitive_path("Config/Local.xcconfig"))
        self.assertTrue(check_sensitive.is_sensitive_path("certs/dev.p12"))
        self.assertTrue(check_sensitive.is_sensitive_path(".env.local"))
        self.assertFalse(check_sensitive.is_sensitive_path(".env.example"))
        self.assertFalse(check_sensitive.is_sensitive_path("Config/Base.xcconfig"))


if __name__ == "__main__":
    unittest.main()
