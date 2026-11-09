# Kano Navi for iOS

The iOS app for Kano Navi (鹿乃ナビ, 鹿乃 Navi), the unofficial fan status board
for Kano Mahoro (鹿乃まほろ). It reads the public API of the
[`kano-navi`](https://github.com/yexca/kano-navi) service; see its
[Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
document. Kano Navi is an independent fan project and is not affiliated with
Kano Mahoro or her agency.

## Requirements

- Xcode 27 or later
- iOS 26 or later; iPhone only

## Project Layout

| Path              | Contents                                                    |
| ----------------- | ----------------------------------------------------------- |
| `KanoNavi/`       | App sources and resources, grouped by feature               |
| `KanoNaviTests/`  | Unit and integration tests (Swift Testing)                  |
| `KanoNaviUITests/`| UI tests (XCTest)                                           |
| `Config/`         | `Base.xcconfig` build settings and the Info.plist additions |

`Config/Base.xcconfig` sets `API_BASE_URL`, the service origin the app reads at
launch. It must be an HTTPS URL.

## Build and Test

```bash
xcodebuild test -project KanoNavi.xcodeproj -scheme KanoNavi -destination 'platform=iOS Simulator,name=iPhone 17e'
```

Releases are unsigned IPAs, so the project has no development team or signing
profile.
