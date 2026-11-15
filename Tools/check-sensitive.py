#!/usr/bin/env python3
"""Scan repository files for secrets, credentials, private paths, and unapproved hosts."""

from __future__ import annotations

import ipaddress
import json
import re
import subprocess
import sys
import urllib.parse
from dataclasses import dataclass
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
PRIVACY_ALLOWLIST_FILE = "Tools/privacy-allowlist.json"

URL_RE = re.compile(r"\bhttps?://[^/\s<>\"'`][^\s<>\"'`]*", re.IGNORECASE)
IPV4_RE = re.compile(r"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\.?\d)")
KNOWN_TOKEN_RES = [
    re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"\bglpat-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    re.compile(r"\bAIza[0-9A-Za-z_-]{30,}\b"),
    re.compile(r"\bsk_(?:live|test)_[A-Za-z0-9]{16,}\b"),
    re.compile(r"\bBearer\s+[A-Za-z0-9._~+/=-]{20,}\b", re.IGNORECASE),
    re.compile(r"-----BEGIN(?: [A-Z]+)? PRIVATE KEY-----"),
]
ASSIGNMENT_RE = re.compile(
    r"\b(?P<key>[A-Za-z_][A-Za-z0-9_.-]*)\s*(?::=|=>|=|:)\s*(?P<value>\"[^\"\n]*\"|'[^'\n]*'|`[^`\n]*`|[^\s,;}#]+)"
)
SENSITIVE_KEY_RE = re.compile(
    r"(?:password|passwd|secret|token|api[-_]?key|access[-_]?key|private[-_]?key|client[-_]?secret|auth[-_]?token)",
    re.IGNORECASE,
)
SENSITIVE_QUERY_RE = re.compile(
    r"(?:password|passwd|secret|token|api[-_]?key|access[-_]?key|private[-_]?key|auth)",
    re.IGNORECASE,
)
PRIVATE_PATH_RE = re.compile(r"(?:[A-Za-z]:[\\/](?:Users|home)[\\/]|/(?:home|Users)/)")

RESERVED_HOSTS = {
    "localhost",
    "0.0.0.0",
    "::1",
    "example",
    "example.com",
    "example.net",
    "example.org",
    "example.invalid",
}

IGNORED_DIRECTORY_NAMES = {
    ".git",
    ".build",
    ".swiftpm",
    ".claude",
    ".codegraph",
    "DerivedData",
    "xcuserdata",
    ".state",
}

BINARY_EXTENSIONS = {
    ".7z",
    ".avi",
    ".bmp",
    ".gif",
    ".gz",
    ".ico",
    ".jpeg",
    ".jpg",
    ".mov",
    ".mp3",
    ".mp4",
    ".pdf",
    ".png",
    ".sqlite",
    ".svg",
    ".tar",
    ".webp",
    ".woff",
    ".woff2",
    ".zip",
}

SENSITIVE_EXTENSIONS = (
    ".db",
    ".sqlite",
    ".sqlite3",
    ".pem",
    ".key",
    ".p12",
    ".pfx",
    ".jks",
    ".keystore",
    ".mobileprovision",
    ".cer",
    ".der",
    ".log",
)

HOST_CHAR_RE = re.compile(r"^[a-z0-9.-]+$")


@dataclass(frozen=True)
class SensitiveFinding:
    file: str
    line: int | None
    kind: str


def normalize_path(file: str) -> str:
    return file.replace("\\", "/")


def is_ignored_path(file: str) -> bool:
    return any(part in IGNORED_DIRECTORY_NAMES for part in normalize_path(file).split("/"))


def is_binary_path(file: str) -> bool:
    return Path(normalize_path(file)).suffix.lower() in BINARY_EXTENSIONS


def is_sensitive_path(file: str) -> bool:
    normalized = normalize_path(file)
    if is_ignored_path(normalized):
        return False
    base = Path(normalized).name.lower()
    if base == ".env" or (base.startswith(".env.") and base != ".env.example"):
        return True
    if base == "local.xcconfig" or base == ".npmrc":
        return True
    if re.match(r"^(?:credentials?|secrets?)(?:\.[A-Za-z0-9._-]+)?$", base, re.IGNORECASE):
        return True
    return base.endswith(SENSITIVE_EXTENSIONS)


def canonical_host(value: str) -> str:
    return value.lower().rstrip(".")


def parse_privacy_allowlist(contents: str) -> dict[str, str]:
    try:
        parsed = json.loads(contents)
    except json.JSONDecodeError as exc:
        raise ValueError(f"invalid JSON: {exc}") from exc

    if not isinstance(parsed, dict) or sorted(parsed.keys()) != ["hosts", "version"]:
        raise ValueError("root must contain only version 1 and a hosts array")
    if parsed["version"] != 1 or not isinstance(parsed["hosts"], list):
        raise ValueError("root must contain only version 1 and a hosts array")

    hosts: dict[str, str] = {}
    for idx, entry in enumerate(parsed["hosts"], start=1):
        if not isinstance(entry, dict) or sorted(entry.keys()) != ["host", "reason"]:
            raise ValueError(f"host {idx} must contain only host and reason")
        raw_host = entry["host"]
        raw_reason = entry["reason"]
        if not isinstance(raw_host, str) or raw_host.strip() == "":
            raise ValueError(f"host {idx} has an invalid host")
        host = canonical_host(raw_host)
        if host != raw_host or "/" in host or ":" in host or not HOST_CHAR_RE.match(host):
            raise ValueError(f"host {idx} must be a lowercase hostname without a scheme")
        if not isinstance(raw_reason, str) or raw_reason.strip() == "":
            raise ValueError(f"host {idx} must have a reason")
        if host in hosts:
            raise ValueError(f"host {idx} duplicates an approved host")
        hosts[host] = raw_reason
    return hosts


def load_privacy_allowlist(root: Path = REPOSITORY_ROOT) -> dict[str, str]:
    allowlist_path = root / PRIVACY_ALLOWLIST_FILE
    try:
        return parse_privacy_allowlist(allowlist_path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise RuntimeError(f"{PRIVACY_ALLOWLIST_FILE}: {exc}") from exc


def is_allowed_host(host: str, approved_hosts: dict[str, str]) -> bool:
    normalized = canonical_host(host).strip("[]")
    if normalized in RESERVED_HOSTS or normalized.startswith("127."):
        return True
    if normalized.endswith((".localhost", ".test", ".invalid", ".example.com", ".example.org", ".example.net")):
        return True
    for approved in approved_hosts:
        if normalized == approved or normalized.endswith(f".{approved}"):
            return True
    return False


def is_valid_ipv4(value: str) -> bool:
    try:
        ipaddress.IPv4Address(value)
        return True
    except ValueError:
        return False


def is_documentation_ipv4(value: str) -> bool:
    if not is_valid_ipv4(value):
        return False
    octets = [int(part) for part in value.split(".")]
    return (
        (octets[0] == 192 and octets[1] == 0 and octets[2] == 2)
        or (octets[0] == 198 and octets[1] == 51 and octets[2] == 100)
        or (octets[0] == 203 and octets[1] == 0 and octets[2] == 113)
    )


def is_allowed_ipv4(value: str) -> bool:
    return value == "0.0.0.0" or value.startswith("127.") or is_documentation_ipv4(value)


def normalized_value(value: str) -> str:
    stripped = value.strip()
    if stripped and stripped[0] in ("'", '"', "`"):
        stripped = stripped[1:]
    while stripped and stripped[-1] in ("'", '"', "`", ",", ";"):
        stripped = stripped[:-1]
    return stripped


def is_safe_placeholder(value: str) -> bool:
    normalized = normalized_value(value).lower()
    if normalized == "":
        return True
    if re.match(
        r"^(?:false|true|null|nil|undefined|none|unset|unknown|any|boolean|number|string(?:\[\])?)$",
        normalized,
    ):
        return True
    if re.match(
        r"^(?:change-me|redacted|placeholder|dummy|example(?:[-_].*)?|synthetic(?:[-_].*)?|replace(?:[-_].*)?|your(?:[-_].*)?|not-a-real(?:[-_].*)?)$",
        normalized,
    ):
        return True
    if re.match(r"^\$\{\{[^}]+\}\}$|^\$\{[^}]+\}$|^\$[A-Za-z_][A-Za-z0-9_]*$", normalized):
        return True
    if re.match(r"^(?:process\.env|os\.environ|os\.getenv|env\.)", normalized):
        return True
    if re.match(r"^<[^>]+>$|^\*{3,}$", normalized):
        return True
    return False


def is_literal_sensitive_value(value: str) -> bool:
    normalized = normalized_value(value)
    if is_safe_placeholder(normalized):
        return False
    return bool(re.match(r"^['\"`]", value.strip()) or re.match(r"^[A-Za-z0-9+/_=-]{8,}$", normalized))


def parse_url(candidate: str) -> urllib.parse.ParseResult:
    cleaned = re.sub(r"\$\([^)]*\)|\$\{[^}]+\}|\{[^}]+\}|%s", "example.invalid", candidate)
    cleaned = re.sub(r"[),.;!?\]}]+$", "", cleaned)
    parsed = urllib.parse.urlparse(cleaned)
    if not parsed.scheme or not parsed.netloc:
        raise ValueError("missing scheme or host")
    return parsed


def scan_line(
    file: str,
    line_no: int,
    text: str,
    findings: list[SensitiveFinding],
    approved_hosts: dict[str, str],
) -> None:
    if PRIVATE_PATH_RE.search(text):
        findings.append(SensitiveFinding(file, line_no, "private local path"))

    for pattern in KNOWN_TOKEN_RES:
        if pattern.search(text):
            findings.append(SensitiveFinding(file, line_no, "credential-like value"))
            break

    for match in ASSIGNMENT_RE.finditer(text):
        key = match.group("key")
        value = match.group("value")
        if SENSITIVE_KEY_RE.search(key) and is_literal_sensitive_value(value):
            findings.append(SensitiveFinding(file, line_no, "literal value assigned to a sensitive key"))

    for match in URL_RE.finditer(text):
        raw_url = match.group(0)
        try:
            parsed = parse_url(raw_url)
            if parsed.username or parsed.password:
                findings.append(SensitiveFinding(file, line_no, "URL contains embedded credentials"))
            if not parsed.hostname or not is_allowed_host(parsed.hostname, approved_hosts):
                findings.append(SensitiveFinding(file, line_no, "non-approved service URL"))
            for name, value in urllib.parse.parse_qsl(parsed.query, keep_blank_values=True):
                if SENSITIVE_QUERY_RE.search(name) and not is_safe_placeholder(value):
                    findings.append(
                        SensitiveFinding(file, line_no, "URL query contains a sensitive parameter")
                    )
                    break
        except Exception:
            findings.append(SensitiveFinding(file, line_no, "malformed URL requires review"))

    for match in IPV4_RE.finditer(text):
        candidate = match.group(0)
        if is_valid_ipv4(candidate) and not is_allowed_ipv4(candidate):
            findings.append(SensitiveFinding(file, line_no, "non-documentation IPv4 address"))
            break


def repository_files(root: Path = REPOSITORY_ROOT) -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=root,
        capture_output=True,
        check=False,
    )
    if result.returncode == 0:
        return [
            normalize_path(item)
            for item in result.stdout.decode("utf-8").split("\0")
            if item
        ]
    files: list[str] = []
    for path in root.rglob("*"):
        if path.is_file():
            rel = normalize_path(str(path.relative_to(root)))
            if not is_ignored_path(rel):
                files.append(rel)
    return sorted(files)


def read_text_file(path: Path) -> str | None:
    if path.is_symlink() or not path.is_file() or is_binary_path(path.name):
        return None
    raw = path.read_bytes()
    if b"\x00" in raw:
        return None
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return None


def run_sensitive_check(root: Path = REPOSITORY_ROOT) -> int:
    approved_hosts = load_privacy_allowlist(root)
    files = [f for f in repository_files(root) if not is_ignored_path(f)]
    findings: list[SensitiveFinding] = [
        SensitiveFinding(f, None, "sensitive runtime or credential file")
        for f in files
        if is_sensitive_path(f)
    ]

    scanned_text = 0
    skipped_binary = 0

    for rel_file in files:
        contents = read_text_file(root / rel_file)
        if contents is None:
            skipped_binary += 1
            continue
        scanned_text += 1
        for line_no, text in enumerate(contents.splitlines(), start=1):
            scan_line(rel_file, line_no, text, findings, approved_hosts)

    unique = list(dict.fromkeys(findings))
    if unique:
        print(
            f"Sensitive-information scan found {len(unique)} item(s):",
            file=sys.stderr,
        )
        for finding in unique:
            location = finding.file if finding.line is None else f"{finding.file}:{finding.line}"
            print(f"- {location}: {finding.kind}", file=sys.stderr)
        print(
            f"Remove the sensitive value or document a public host in {PRIVACY_ALLOWLIST_FILE}.",
            file=sys.stderr,
        )
        return 1

    print(
        f"Sensitive-information scan passed ({scanned_text} text file(s), {skipped_binary} binary file(s) skipped)."
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(run_sensitive_check())
    except Exception as exc:
        print(exc, file=sys.stderr)
        sys.exit(2)
