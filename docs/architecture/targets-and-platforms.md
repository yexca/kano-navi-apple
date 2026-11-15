# Targets and Platforms

## Targets and Modules

| Target / module                        | Kind                    | Contents                                                                                                        |
| -------------------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `KanoNavi`                             | App                     | Scenes, tabs, screens, settings, local notifications                                                            |
| `KanoNaviWidgets`                      | Widget extension        | Calendar widgets and their timeline provider                                                                    |
| `KanoNaviKit` → `KanoNaviCore`         | Local Swift package lib | API models, client, SSE revision streaming, caching, refresh scheduling, notification planning, Japan time, content language, display-code labels |
| `KanoNaviKit` → `KanoNaviComponents`   | Local Swift package lib | SwiftUI pieces shared by the app and widgets: state chips, platform marks, time labels, event rows              |
| `KanoNaviTests`                        | Unit tests              | App-level unit and integration tests (Swift Testing)                                                            |
| `KanoNaviWidgetsTests`                 | Unit tests              | Widget timeline and layout tests (Swift Testing)                                                                |
| `KanoNaviUITests`                      | UI tests                | Launch and navigation smoke tests (XCTest), iPhone and iPad only                                                |

Every target except `KanoNaviUITests` builds for iOS (iPhone and iPad) and as a
native macOS app from the same sources. `Packages/KanoNaviKit` contains the
Swift Testing targets `KanoNaviCoreTests` and `KanoNaviComponentsTests` and
depends on nothing outside the Apple SDKs. `KanoNaviCore` does not import
SwiftUI; `KanoNaviComponents` depends on `KanoNaviCore`.

Folders inside `KanoNavi/` are organized by feature: `App/`, `Now/`,
`Schedule/`, `Videos/`, `Posts/`, `Journey/`, `Works/`, `LineBlog/`, `More/`,
`Notifications/`, and `Shared/`. The app icon in `Resources/Assets.xcassets` is
the web board's avatar (`public/assets/kano-avatar.jpg` in `kano-navi`) scaled
to 1024 px, with the Mac's rounded square sizes in the same `AppIcon` set.

## Shared iOS, iPadOS, and macOS Platforms

The app runs on iPhone, iPad, and natively on the Mac (not Mac Catalyst and
not the iPad app on Apple Silicon). All three share every screen; where an API
exists on one platform only, a small helper in `KanoNavi/Shared/Platform/`
provides the counterpart so screens carry no platform checks of their own:

| Helper                                              | iOS / iPadOS                              | macOS                                                        |
| --------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------ |
| `ToolbarItemPlacement.barLeading`/`barTrailing`     | `topBarLeading`/`topBarTrailing`          | `navigation`/`primaryAction`                                 |
| `inlineNavigationTitle()`                           | `navigationBarTitleDisplayMode(.inline)`  | No-op (a window title is inline)                             |
| `insetGroupedListStyle()`                           | `.insetGrouped`                           | `.inset`                                                     |
| `SearchFieldPlacement.alwaysInBar`                  | Navigation bar drawer, always shown       | Toolbar                                                      |
| `Color.groupedBackground`/`groupedCellBackground`   | System grouped backgrounds                | Light gray and white; window background and lifted gray in dark |
| `Pasteboard.copy(_:)`                               | `UIPasteboard`                            | `NSPasteboard`                                               |
| `SystemSettingsURL`                                 | App settings and notification settings    | Language & Region, and the app's Notifications settings      |
| `refreshableScreen(action:)`                        | Pull to refresh and View ▸ Refresh (`⌘R`) | View ▸ Refresh (`⌘R`)                                        |

On macOS:

- The app opens in one window (minimum 720 × 520 points, default 1100 × 760
  points). Tabs appear in the sidebar of the sidebar-adaptable tab view (see
  [Board and timelines](board-and-timelines.md)), links and notifications open
  inside that window, and File has no New Window command.
- View ▸ Refresh (`⌘R`) reads the screen in front again through
  `FocusedValues.screenRefresh`.
- Sheets close with their Close button or `Esc`. The image viewer is a large
  sheet (see [Media and viewer](media-and-viewer.md#image-viewer)).
- Settings is a sidebar tab rather than a separate Settings window. **App
  Language** opens Language & Region in System Settings.
- Notifications and background refresh run as on iOS (see
  [Notifications](notifications.md)).
- Widgets offer Home Screen sizes on the desktop and in Notification Center
  without Lock Screen layouts.
- The LINE BLOG video player needs no audio session on macOS.
- Dark Berry uses `#FF768E` in place of `#FF7088` in both Journey and Schedule
  color sets so text keeps at least 4.5:1 contrast against macOS's `#1E1E1E`
  dark background.

## Signing, Sandboxing, and Schemes

The project carries no Apple development team, signing certificate, or
provisioning profile:

- iOS releases are unsigned IPAs.
- The Mac app is ad-hoc signed (`CODE_SIGN_IDENTITY[sdk=macosx*] = -`, "Sign to
  Run Locally"). On another Mac, Gatekeeper requires the user to approve the
  first launch in System Settings ▸ Privacy & Security.
- On macOS, both the app and the widget extension run in the App Sandbox with
  outgoing network access only (`Config/KanoNavi-macOS.entitlements` and
  `Config/Widgets-macOS.entitlements`); macOS loads widget extensions only when
  sandboxed.

The `KanoNavi` scheme builds and tests on iOS; the `KanoNaviMac` scheme omits
the iOS-only `KanoNaviUITests` target and runs on macOS.

## Related Docs

- [Core boundaries](core-boundaries.md)
- [Testing and validation](../development/testing.md)
- [Commit and release](../development/commit-and-release.md)
