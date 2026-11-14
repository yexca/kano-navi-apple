# Agent Guide

This repository is the iOS app for Kano Navi, the unofficial status board for
Kano Mahoro (鹿乃まほろ). The board's service, data and public API live in the
[`kano-navi`](https://github.com/yexca/kano-navi) repository.

Read these first, in a local checkout of `kano-navi` when there is one:

- [`docs/how-it-works.md`](https://github.com/yexca/kano-navi/blob/main/docs/how-it-works.md)
- [`docs/architecture/public-api.md`](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
- [`docs/user/index.md`](https://github.com/yexca/kano-navi/blob/main/docs/user/index.md)

This app's own architecture, screens and widget are described in
[`docs/design.md`](docs/design.md).

## Local Environment

Read `AGENTS.local.md` at the repository root when it exists. It is
git-ignored and describes one machine: where `kano-navi` is checked out, which
skills and helper agents are installed and how to call them, and which
simulators to use. Keep anything specific to one machine or person there, never
in this file or another tracked file.

## Agent Skills

Load the matching skill before writing or reviewing code in its area. When one
change spans several areas, load each one.

| Area                                                   | Skill                   | Invoke                   |
| ------------------------------------------------------ | ----------------------- | ------------------------ |
| SwiftUI views, navigation, layout, accessibility, i18n | `swiftui-pro`           | `/swiftui-pro`           |
| async/await, actors, `Task`, `Sendable`, isolation     | `swift-concurrency-pro` | `/swift-concurrency-pro` |
| Unit and integration tests                             | `swift-testing-pro`     | `/swift-testing-pro`     |

- Pass a focus for a partial review, for example
  `/swiftui-pro Check for deprecated API` or
  `/swift-concurrency-pro actor reentrancy`.
- Skills give general Swift guidance. When a skill and this file disagree, this
  file wins.
- Claude Code loads the skills from `~/.claude/skills/`. Other agents install
  them with `npx skills add https://github.com/twostraws/<repo> --skill <name>`
  from [SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill),
  [Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill)
  and [Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill).
- SwiftData Pro is not part of this setup. Add it only if the app adopts
  SwiftData.

## Product Boundaries

Critical rule:

```text
The app reads the Kano Navi public API. It never fetches X, YouTube, Bilibili
or model providers itself, and never calls admin or MCP control endpoints.
```

- The `kano-navi` [Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
  document owns the API contract. Model
  responses on it and do not invent fields. When the app needs data the API
  does not offer, change the service in `kano-navi` first instead of working
  around it here.
- A failed request keeps the last good data on screen and shows its state; it
  does not blank the view.
- The app is localized like the board: English is the base locale and the
  fallback, plus Japanese and Simplified Chinese. Keep user-facing text in
  String Catalogs. Display codes from the API are translated in the app, never
  sent back as localized strings.
- Parse API timestamps as ISO 8601 and show event times in Asia/Tokyo, as the
  board does.
- Kano Navi is an independent fan project. Do not use official branding or
  imply affiliation.

## Security and Privacy

- The app talks to the Kano Navi service and the media URLs it returns. A new
  outbound host needs a stated reason. Use HTTPS only and add no App Transport
  Security exceptions.
- Do not add analytics, tracking or advertising SDKs, or any third-party
  dependency, without an explicit request.
- Keep the API base URL in build configuration, not scattered through code.
  Secrets, signing certificates and provisioning profiles never enter the
  repository.

## UI and Test Contracts

- Keep the interface concise. Prefer a label, an icon or a short phrase to a
  sentence. A link to another platform is its logo and name (YouTube,
  Bilibili; X's logo alone, since it is the name), not "Open on …". Explanations few people need, such as data
  provenance, curation notes, rights notices or how a screen works, are left
  out or folded behind a control such as an info button. Error, saved-copy
  and empty states stay, each in one short line.
- Check affected UI in the iOS Simulator on a small and a large iPhone, in
  light and dark appearance, and at the largest Dynamic Type size.
- Tests protect concrete behaviors and contracts. Choose the lowest sufficient
  layer. Unit and integration tests use Swift Testing; UI tests use XCTest.
- Tests use synthetic records, reserved domains (`example.com`) and recorded
  or stubbed responses. They never call the live API.

## Documentation

- Documentation is English only and describes the current app in present
  tense. When behavior changes, rewrite the affected section instead of
  appending a note about what changed.
- State each rule in one place and link to it. Server behavior is documented in
  `kano-navi`; link there instead of restating it.

## Validation Commands

- Begin with `git status --short` and preserve existing user changes. Do not
  use destructive reset or checkout commands.
- Build and test with `xcodebuild`. Read the scheme and destinations from
  `xcodebuild -list` and the project; do not guess them.
- Format Swift with `swift format format --in-place --recursive <paths>`,
  which reads the repository's `.swift-format` (4-space indentation, 110
  columns), and check it with `swift format lint`.
- Fix compiler warnings, including strict-concurrency warnings, at their
  source. Do not silence them with `@unchecked Sendable`, `nonisolated(unsafe)`
  or `@preconcurrency` unless the change explains why it is safe.

## Commits, Release and Handoff

- Use Conventional Commits in the form `<type>(<scope>): <description>`: a
  lowercase imperative description of 72 characters or fewer with no period.
  Scopes are short subsystem names such as `app`, `ui`, `api`, `l10n`, `test`,
  `docs` or `ci`.
- Before committing, build, run the affected tests, and review
  `git diff --cached`. Stage only the requested scope.
- Never commit secrets, signing material, `xcuserdata/`, `DerivedData/`, build
  output or `.DS_Store`.
- Agents create commits, amend/rebase, push, or rewrite history only when the
  user explicitly requests it.
- Releases are unsigned IPAs. The project carries no development team, signing
  certificate or provisioning profile.
- Do not invent identifiers. Bundle ID, version and build number come from the
  Xcode project or the user.
