# Testing and Validation

All tests use manually authored synthetic records, reserved domains
(`example.com`, `example.org`, `example.invalid`), fixed timestamps, and
stubbed or recorded transports. Tests never call the live Kano Navi API, X,
YouTube, Bilibili, or model providers.

## Validation Commands

The `Makefile` collects the fast local checks and Xcode test entry points. Always
verify schemes and destinations with `xcodebuild -list` when targeting a new
simulator or device.

| Change or task                                       | Command              | Notes                                                             |
| ---------------------------------------------------- | -------------------- | ----------------------------------------------------------------- |
| Fast format, doc-link, tool tests, and privacy scan  | `make ci-fast`       | Runs `format-check`, `docs-check`, `test-checks`, `sensitive-check` |
| Format Swift sources in place                        | `make format`        | Applies `.swift-format` across all Swift targets                  |
| Lint Swift formatting                                | `make format-check`  | `swift format lint --recursive ...`                               |
| Verify Markdown relative links                       | `make docs-check`    | Runs `Tools/check-doc-links.py`                                   |
| Scan for secrets, private paths, and unapproved hosts| `make sensitive-check` | Runs `Tools/check-sensitive.py` against `Tools/privacy-allowlist.json` |
| Unit tests for check tools                           | `make test-checks`   | Runs `Tools/test_checks.py`                                       |
| Shared package unit tests (`KanoNaviCore` & `Components`) | `make test-package` | `swift test --package-path Packages/KanoNaviKit`                 |
| App, widget, unit, and UI tests on iOS Simulator     | `make test-ios`      | `xcodebuild test -project KanoNavi.xcodeproj -scheme KanoNavi ...` |
| App, widget, and unit tests on macOS                 | `make test-mac`      | `xcodebuild test -project KanoNavi.xcodeproj -scheme KanoNaviMac ...` |
| Full local validation suite                          | `make check`         | Runs `ci-fast`, `test-package`, `test-ios`, and `test-mac`        |

For `Packages/KanoNaviKit` on iOS Simulator specifically, run:

```bash
xcodebuild test -scheme KanoNaviKit-Package -destination 'platform=iOS Simulator,name=iPhone 17e'
```

from `Packages/KanoNaviKit`.

If a first UI-test launch fails with "Busy / preflight", re-run:

```bash
xcodebuild test-without-building -project KanoNavi.xcodeproj -scheme KanoNavi -destination 'platform=iOS Simulator,name=iPhone 17e' -only-testing:KanoNaviUITests
```

## Test Scope and Layers

Choose the lowest sufficient test layer that protects the contract:

- **Unit and integration tests** use **Swift Testing** (`import Testing`):
  - `KanoNaviCoreTests`: model decoding (`Dashboard`, `ScheduleEvent`, `Video`,
    `Post`, `CalendarPage`, archives), `APIClient` ETag revalidation and error
    mapping, `FileResponseCache`, `CalendarReader`, `DashboardStore` (launch,
    SSE, polling, concurrency), `JapanTime`, `ContentLanguageResolver`,
    `DisplayCodeLabels`, and `NotificationPlanner`.
  - `KanoNaviComponentsTests`: shared strings, event presentation,
    `EventTicketTiming`, `JSTTimeFormat`, and platform logos.
  - `KanoNaviTests`: app-level models and stores (`Now`, `Schedule`, `Posts`,
    `Videos`, `Journey`, `Works`, `LineBlog`, `More`, `Notifications`,
    `DocumentModel`, `MediaImageLoader`, `MediaViewerZoom`, `MonthGrid`).
  - `KanoNaviWidgetsTests`: widget timeline building, schedule selection,
    content language intent handling, deep links, and rendering layouts (Home,
    Lock Screen, Monochrome).
- **UI tests** (`KanoNaviUITests`, iOS/iPadOS only) use **XCTest**: launch
  smoke, tab navigation, iPad sidebar tabs, Schedule mode switching, and
  notification settings flows.

Do not add tests for prose changes or purely visual styling without an
observable contract or interaction rule.

## Local Integration Verification

To inspect real UI behavior against a running server without modifying
production data, run `Tools/local-backend/local-backend start` and configure
`Config/Local.xcconfig` as described in
[Tools/local-backend/README.md](../../Tools/local-backend/README.md). Clone
simulators (`xcrun simctl clone`) when running automated visual passes so base
simulators stay clean, and delete temporary clones afterwards.

## Related Docs

- [Local setup](local-dev.md)
- [Design and interaction](design.md)
- [Secure development](security.md)
