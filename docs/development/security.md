# Secure Development

## Transport and Outbound Boundaries

- The app talks only to the selected Kano Navi HTTPS server and media routes
  resolved against it: a built-in one (`API_BASE_URL` and
  `MAINLAND_API_BASE_URL` in `Config/Base.xcconfig` or git-ignored
  `Config/Local.xcconfig`) or one the person adds, which must be HTTPS and
  serve a compatible dashboard ([Servers](../architecture/servers.md)).
- Use HTTPS only and add no App Transport Security (`NSAppTransportSecurity`)
  exceptions.
- External provenance and watch links (`x.com`, `youtube.com`, `bilibili.com`,
  `nicovideo.jp`, `lineblog.me`, official sites) are opened via the system's
  `openURL` only; the app never fetches them in code.
- Adding a new outbound host requires a stated reason and an entry in
  `Tools/privacy-allowlist.json`.
- Do not add analytics, tracking, advertising SDKs, or third-party
  dependencies without an explicit request.

## Sandboxing, Secrets, and Signing Material

- On macOS, `Config/KanoNavi-macOS.entitlements` and
  `Config/Widgets-macOS.entitlements` enable App Sandbox with
  `com.apple.security.network.client` only.
- Secrets, Apple Developer signing certificates, provisioning profiles,
  `Config/Local.xcconfig`, `.env`, `xcuserdata/`, `DerivedData/`, and
  `Tools/local-backend/.state/` never enter Git.
- Ignore rules are not a secrecy boundary: tracked files are always scanned even
  if listed in `.gitignore`.

## Sensitive-Information Scan

`Tools/check-sensitive.py` checks tracked and unignored repository files for:

- credential-like tokens (`ghp_`, `AKIA`, `Bearer`, private-key headers);
- literal values assigned to sensitive keys (`password`, `secret`, `token`,
  `apiKey`);
- credentials embedded in URLs or sensitive query parameters;
- personal machine paths and non-documentation IPv4 addresses;
- sensitive filenames (`Config/Local.xcconfig`, `.env` except `.env.example`,
  `.p12`, `.mobileprovision`, `.cer`, `.der`, `.pem`, `.key`, `.db`, `.sqlite`,
  `.log`);
- non-reserved HTTP(S) URLs whose host is missing from
  `Tools/privacy-allowlist.json`.

Run locally before handoff or commit:

```bash
make sensitive-check
make test-checks
```

When a finding appears, fix the source or document a justified public host in
`Tools/privacy-allowlist.json`. Never hide a finding with an allow comment or
string obfuscation.

## Related Docs

- [Security policy](../../SECURITY.md)
- [Targets, platforms, and entitlements](../architecture/targets-and-platforms.md)
- [Commit and release](commit-and-release.md)
