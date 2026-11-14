# Kano Navi for iOS and macOS

The iOS and macOS app for Kano Navi (鹿乃ナビ, 鹿乃 Navi), the unofficial fan status board
for Kano Mahoro (鹿乃まほろ). It reads the public API of the
[`kano-navi`](https://github.com/yexca/kano-navi) service; see its
[Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
document. Kano Navi is an independent fan project and is not affiliated with
Kano Mahoro or her agency.

## Requirements

- Xcode 27 or later
- iOS 26 or later; iPhone and iPad
- macOS 26 or later

## Project Layout

| Path              | Contents                                                    |
| ----------------- | ----------------------------------------------------------- |
| `KanoNavi/`       | App sources and resources, grouped by feature               |
| `KanoNaviTests/`  | Unit and integration tests (Swift Testing)                  |
| `KanoNaviUITests/`| UI tests (XCTest)                                           |
| `KanoNaviWidgets/`| The calendar widget extension                               |
| `Packages/KanoNaviKit/` | Shared code: `KanoNaviCore` (API, caching, time) and `KanoNaviComponents` (SwiftUI) |
| `Config/`         | `Base.xcconfig` build settings and the Info.plist additions |
| `Tools/`          | Local development helpers                                   |
| `docs/`           | [App design](docs/design.md)                                |

`Config/Base.xcconfig` sets `API_BASE_URL`, the service origin the app reads at
launch. It must be an HTTPS URL. An optional, git-ignored
`Config/Local.xcconfig` overrides it on one machine, for example to use a local
backend.

## Build and Test

The app, its widgets and the app-level tests:

```bash
xcodebuild test -project KanoNavi.xcodeproj -scheme KanoNavi -destination 'platform=iOS Simulator,name=iPhone 17e'
```

The same on the Mac, with the `KanoNaviMac` scheme, which leaves out the
iOS-only UI tests:

```bash
xcodebuild test -project KanoNavi.xcodeproj -scheme KanoNaviMac -destination 'platform=macOS,arch=arm64'
```

The shared package's tests, from `Packages/KanoNaviKit`:

```bash
xcodebuild test -scheme KanoNaviKit-Package -destination 'platform=iOS Simulator,name=iPhone 17e'
```

`swift test` in the same folder runs them on the Mac, which is faster while
iterating on `KanoNaviCore`.

Releases are unsigned IPAs for iPhone and iPad and an ad-hoc-signed `.app`
for the Mac, so the project has no development team or signing profile. On
a Mac other than the one that built it, macOS asks the user to approve the
app's first launch in System Settings ▸ Privacy & Security; see
[Signing and Distribution](docs/design.md#signing-and-distribution).
