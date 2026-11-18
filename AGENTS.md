# Agent Guide

This repository is the iOS, iPadOS, and macOS app for Kano Navi, the
unofficial status board for Kano Mahoro (鹿乃まほろ). The board's service,
data, and public API live in the
[`kano-navi`](https://github.com/yexca/kano-navi) repository.

Read these first:

- `README.md`
- `docs/how-it-works.md`
- `docs/architecture/core-boundaries.md`
- `AGENTS.local.md` at the repository root when it exists (git-ignored
  machine-local notes: `kano-navi` checkout path, simulators, helper agents;
  keep machine-specific details there, never in tracked files)

Also read the `kano-navi` service docs in a local checkout when available:

- [`docs/how-it-works.md`](https://github.com/yexca/kano-navi/blob/main/docs/how-it-works.md)
- [`docs/architecture/public-api.md`](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
- [`docs/user/index.md`](https://github.com/yexca/kano-navi/blob/main/docs/user/index.md)

Before changing an area, read its docs:

| Area                                     | Main paths                                                                                   | Docs                                                                                    |
| ---------------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| App shell, routing, platform helpers     | `KanoNavi/App/`, `KanoNavi/Shared/Platform/`                                                 | `docs/architecture/targets-and-platforms.md`, `docs/architecture/core-boundaries.md`    |
| Now, Schedule, Posts, Videos, More       | `KanoNavi/Now/`, `KanoNavi/Schedule/`, `KanoNavi/Posts/`, `KanoNavi/Videos/`, `KanoNavi/More/`, `KanoNavi/Shared/Archive/`, `KanoNavi/Shared/MonthPicker/`, `KanoNavi/Shared/Timeline/` | `docs/architecture/board-and-timelines.md`, `docs/development/design.md`, `docs/user/index.md` |
| Journey, Works, LINE BLOG                | `KanoNavi/Journey/`, `KanoNavi/Works/`, `KanoNavi/LineBlog/`, `KanoNavi/Shared/Document/`    | `docs/architecture/archives.md`, `docs/architecture/api-and-caching.md`                 |
| Media loading and image viewer           | `KanoNavi/Shared/Media/`                                                                     | `docs/architecture/media-and-viewer.md`                                                 |
| Notifications and background refresh     | `KanoNavi/Notifications/`, `Packages/KanoNaviKit/Sources/KanoNaviCore/Notifications/`        | `docs/architecture/notifications.md`                                                    |
| Widgets                                  | `KanoNaviWidgets/`                                                                           | `docs/architecture/widgets.md`, `docs/architecture/targets-and-platforms.md`            |
| Shared core, API, cache, time, UI pieces | `Packages/KanoNaviKit/`                                                                      | `Packages/KanoNaviKit/README.md`, `docs/architecture/api-and-caching.md`, `docs/architecture/language.md` |
| Build config, entitlements, local server | `Config/`, `Tools/local-backend/`                                                            | `docs/development/local-dev.md`, `Tools/local-backend/README.md`                        |
| Outbound HTTP, privacy, secrets, signing | any of the above                                                                             | `SECURITY.md`, `docs/development/security.md`, `docs/security/index.md`                 |
| Tests and validation                     | `KanoNaviTests/`, `KanoNaviWidgetsTests/`, `KanoNaviUITests/`, `Packages/KanoNaviKit/Tests/`, `Tools/` | `docs/development/testing.md`                                                  |
| Commits and releases                     | `KanoNavi.xcodeproj`, `docs/history/`                                                        | `docs/development/commit-and-release.md`                                                |

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
- Claude Code loads skills from `~/.claude/skills/`. Other agents install them
  with `npx skills add https://github.com/twostraws/<repo> --skill <name>` from
  [SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill),
  [Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill),
  and [Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill).
- SwiftData Pro is not part of this setup; adopt it only if the app adopts
  SwiftData.

## Product Boundaries

Critical rule:

```text
The app reads the Kano Navi public API. It never fetches X, YouTube, Bilibili,
or model providers itself, and never calls admin or MCP control endpoints.
```

- The `kano-navi`
  [Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
  document owns the contract. Model responses on it and do not invent fields.
  When the app needs data the API does not offer, change `kano-navi` first
  instead of working around it here.
- A failed request keeps the last good data on screen and shows its status; it
  never blanks the view.
- The app is localized like the board: English is the base locale and fallback,
  plus Japanese and Simplified Chinese. Keep user-facing text in String
  Catalogs. Display codes from the API are translated in the app, never sent
  back as localized strings.
- Parse API timestamps as ISO 8601 and display event times in `Asia/Tokyo`
  (JST); date ranges and calendar days use Japan dates (`JapanDate`).
- Kano Navi is an independent fan project. Do not use official branding or
  imply affiliation.

## Data, State, and Platform Boundaries

- Require dashboard `projection.version == 1` and record `view` objects; do not
  re-derive server decisions locally. Decode closed code sets with an
  `unknown(String)` fallback.
- Keep `KanoNaviCore` Foundation-only (no SwiftUI or UIKit imports) and keep
  `KanoNaviComponents` free of UIKit, navigation, and interactive controls so
  both the app and widgets share them cleanly.
- Keep platform-specific SwiftUI/AppKit/UIKit adaptations inside
  `KanoNavi/Shared/Platform/` rather than scattering `#if os(...)` checks across
  screens.
- Keep macOS App Sandbox entitlements limited to outbound client connections
  (`Config/KanoNavi-macOS.entitlements`, `Config/Widgets-macOS.entitlements`).

## Security and Media Boundaries

- The app talks only to the selected Kano Navi server (a built-in one from
  `API_BASE_URL` or `MAINLAND_API_BASE_URL`, or an HTTPS one the person adds)
  and media URLs resolved against it. External provenance and watch links open via `openURL`
  only and are never fetched by the app.
- Use HTTPS only and add no App Transport Security exceptions. Register any new
  allowlisted repository host with a stated reason in
  `Tools/privacy-allowlist.json`; when the scanner reports a finding, fix the
  source rather than hiding it.
- Do not add analytics, tracking, advertising SDKs, or any third-party
  dependency without an explicit request.
- Keep `API_BASE_URL` and `MAINLAND_API_BASE_URL` in `Config/Base.xcconfig`
  (overridden only in git-ignored `Config/Local.xcconfig`). Never commit
  secrets, signing certificates, provisioning profiles, or personal paths.

## UI and Test Contracts

- Follow `docs/development/design.md` for UI work. Keep copy concise (labels,
  icons, short phrases), format platform links with logo and name (`YouTube`,
  `Bilibili`; X's logo alone), fold low-frequency provenance/rights notices
  behind an info control, and keep error, saved-copy, and empty states to one
  short line.
- Check affected UI across small and large iPhone simulators, iPad simulator,
  light and dark appearances, largest Dynamic Type (`AX5`), and small and large
  macOS windows in both appearances.
- Tests protect concrete behaviors and contracts. Choose the lowest sufficient
  layer: Swift Testing for unit/integration tests, XCTest for UI tests.
- Tests use synthetic records, reserved domains (`example.com`, `example.org`,
  `example.invalid`), and recorded or stubbed responses. They never call the
  live API or external platforms.

## Documentation

Docs describe the current application and its current decisions, not how it got
there. Where each topic belongs is in
[Documentation Rules](docs/README.md#documentation-rules).

- Write in present tense. Do not narrate change: no "previously", "no longer",
  "now", "as before", "was removed", "retired", "migration phase", version-dated
  asides, PR/issue/commit references, or before/after comparisons.
- When behavior changes, rewrite the affected section as if it had always been
  this way instead of appending a paragraph. Search for and remove every
  statement the change contradicts across architecture, user, and development
  pages.
- Reference docs contain no TODOs, plans, roadmaps, or dated measurement logs.
- State each rule or fact in one place and link to it instead of restating it.
  Keep one topic per architecture document; add a new document to its index
  rather than growing an unrelated one.
- The [User guide](docs/user/index.md) and `README.md` describe features as
  visitors see them without file paths, endpoints, or internal symbols. When
  visitor-visible behavior changes, update the matching user page.
- History belongs only in `docs/history/` (release notes, with pending changes
  in `unreleased.md`). Follow
  [Release Notes](docs/development/commit-and-release.md#release-notes).
- Documentation, including `README.md`, is English only. Run `make docs-check`
  after changing links.

## Validation Commands

The `Makefile` collects local validation commands alongside `xcodebuild`.

- Begin with `git status --short` and preserve existing user changes. Do not
  use destructive reset or checkout commands.
- Use the smallest sufficient check: `make ci-fast` for Swift formatting lint,
  Markdown link checking, tool tests, and the sensitive-information scan;
  `make docs-check` for docs; `make test-package` for `KanoNaviKit`;
  `make test-ios` / `make test-mac` (or `xcodebuild` reading schemes and
  destinations from `xcodebuild -list`, never guessing them) for app and widget
  targets; `make check` for the full local sequence.
- Format Swift with `make format` (`swift format format --in-place --recursive`
  using `.swift-format`, 4-space indentation, 110 columns) and verify with
  `make format-check`.
- Fix compiler and strict-concurrency warnings at their source. Do not silence
  them with `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency`
  unless a comment explains why it is safe.

## Commits, Release, and Handoff

- Before a routine commit, run `make ci-fast` and the affected test targets,
  review `make sensitive-check` output and `git diff --cached` manually, and
  stage only the requested scope.
- Before handoff, run proportional validation and `make sensitive-check`.
- Never commit `Config/Local.xcconfig`, `Tools/local-backend/.state/`, secrets,
  signing material, `xcuserdata/`, `DerivedData/`, build output, `.DS_Store`,
  or unrelated user changes. Ignore rules are not a secrecy boundary.
- Agents create commits, amend/rebase, push, or rewrite history only when the
  user explicitly requests it. Follow
  [Commit and release](docs/development/commit-and-release.md) for the exact
  Conventional Commit format, signed commit policy (keep the configured signing
  path; never disable signing to work around a missing signer), and release
  rules.
- When merging into `main`, judge whether the branch's commits are worth
  keeping: squash merge when they are not (the usual case, and when unsure),
  and create a merge commit only when each commit is a focused, passing step
  worth reading or reverting on its own. See
  [Merging into Main](docs/development/commit-and-release.md#merging-into-main).
- Do not invent identifiers. Bundle ID, version, and build number come from
  `KanoNavi.xcodeproj` or the user.
