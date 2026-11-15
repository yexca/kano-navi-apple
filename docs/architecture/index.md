# Architecture

Kano Navi for iOS and macOS is organized around a single rule:

```text
The server decides, the app renders. Every screen and widget reads the Kano
Navi public API and keeps the last good snapshot on failure.
```

## Architecture Topics

| Topic                                                  | Contents                                                                      |
| ------------------------------------------------------ | ----------------------------------------------------------------------------- |
| [Core boundaries](core-boundaries.md)                  | Principles, request and failure flow, external link policy, extension points  |
| [Targets and platforms](targets-and-platforms.md)      | App, widget, package and test targets, platform helpers, macOS sandbox        |
| [API and caching](api-and-caching.md)                  | Public API contract, ETag caching, SSE/polling, `DocumentModel`, stale notices |
| [Media and viewer](media-and-viewer.md)                | `MediaImage`, `MediaImageLoader`, size variants, disk/memory caches, `MediaViewer` |
| [Board and timelines](board-and-timelines.md)          | Tabs, Now, Schedule modes/drawing, Posts, Videos, Month Picker, More          |
| [Archives](archives.md)                                | Journey, Works, and the LINE BLOG reader, playback, and comments              |
| [Notifications](notifications.md)                      | On-device alerts, background refresh, timed reminders, `kanonavi://` routing  |
| [Widgets](widgets.md)                                  | Home Screen and Lock Screen layouts, colors, timeline provider, intents       |
| [Language](language.md)                                | Interface vs. content language, translation fallback, display-code catalogs   |

## When To Read What

- Read [Core boundaries](core-boundaries.md) before adding a network read,
  external link behavior, or new data contract.
- Read [Targets and platforms](targets-and-platforms.md) before changing targets,
  `Shared/Platform/` helpers, macOS behavior, or entitlements.
- Read [API and caching](api-and-caching.md) before modifying `KanoNaviCore`
  models, stores, caching, or stale-state UI notices.
- Read [Media and viewer](media-and-viewer.md) before changing image loading,
  width selection, or `MediaViewer`.
- Read [Board and timelines](board-and-timelines.md) or
  [Archives](archives.md) before changing a tab or archive screen.
- Read [Notifications](notifications.md) and [Widgets](widgets.md) before
  changing background refresh, reminders, deep links, or widget timelines.
- Read [Language](language.md) before changing localization or translation
  resolution.

## Runtime Topology

```text
kano-navi Public API (HTTPS + SSE)
  -> KanoNaviCore (APIClient, FileResponseCache, CalendarReader, DashboardStore)
  -> KanoNavi (SwiftUI screens, MediaImageLoader, NotificationController)
  -> KanoNaviWidgets (UpcomingProvider + extension cache)
  -- openURL --> System browser (X, YouTube, Bilibili, niconico, official sites)
```

## Related Docs

- [Documentation index](../README.md)
- [How it works](../how-it-works.md)
