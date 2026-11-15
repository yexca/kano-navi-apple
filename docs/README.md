# Kano Navi Documentation

These documents are organized by reader: visitors who use the iPhone, iPad, and
Mac app, developers who change it, and maintainers who test and release builds.
They describe the current application only.

## For Visitors

- [User guide](user/index.md): the Now board, schedule, posts, videos, Journey,
  Works, the LINE BLOG archive, widgets, and notifications.

## For Developers

- [How it works](how-it-works.md): goals, data flow, caching, and known limits.
- [Architecture](architecture/index.md): targets, platforms, API contract,
  caching, media loading, screens, notifications, widgets, and language rules.
- [Development](development/index.md): local setup, design, testing, security,
  commits, and releases.
- [Repository agent guide](../AGENTS.md): boundaries and validation rules.

## For Maintainers

- [Security](security/index.md): reporting policy and security boundaries.
- [Release history](history/index.md): release notes and upgrade guidance.

## Documentation Rules

Where each topic belongs:

- Features as visitors see them belong in the [User guide](user/index.md),
  without file paths, endpoints, or internal symbols.
- How the app works belongs in [How it works](how-it-works.md); target,
  platform, API, caching, media, screen, widget, notification, and language
  contracts belong in [Architecture](architecture/index.md), one topic per
  document.
- Local setup, design rules, testing, secure development, and commit/release
  rules belong in [Development](development/index.md).
- Security reporting belongs in [SECURITY.md](../SECURITY.md); technical
  boundaries belong in [Secure development](development/security.md).
- Release notes and pending unreleased items belong in
  [History](history/index.md). Every other page describes only the current
  application; follow the writing rules in the
  [repository agent guide](../AGENTS.md#documentation).
- [Config/Base.xcconfig](../Config/Base.xcconfig) owns the default service
  origin; document build configuration overrides in
  [Local development](development/local-dev.md).
- Documentation is English only. Use repository-relative paths, synthetic
  examples, and `make docs-check` after changing links.
