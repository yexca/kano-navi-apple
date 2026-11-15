# Core Boundaries

Kano Navi for iOS and macOS is an independent client for the
[`kano-navi`](https://github.com/yexca/kano-navi) public API. It keeps its own
native layout and does not mirror the web board page by page.

## Principles

- **Glanceable first.** The Now screen and the widgets answer "is she live,
  what is next, and when" without scrolling.
- **The server decides, the app renders.** The dashboard `projection` and each
  record's `view` carry focus order, live state, shelf groups, and calendar
  entries as codes. The app joins records by ID, translates codes, and lays
  them out. It never re-derives a decision the projection makes.
- **Old data survives a failure.** Every screen and widget keeps its last good
  data and displays the failure beside it; it never blanks the view.
- **Japan time.** Event times appear in `Asia/Tokyo` and are labelled JST; date
  ranges, calendar days, and "today" are Japan dates.
- **Public API boundary.** The app reads only the configured Kano Navi HTTPS
  service and the media routes it serves. It never fetches X, YouTube,
  Bilibili, shops, LINE BLOG captures, or model providers directly, and never
  calls `/admin` or `/mcp` control endpoints.

## Request and Failure Flow

1. Launch-visible stores (`DashboardStore`, Coming Up's `CalendarReader` range,
   `PostTimelineModel`, `VideoTimelineModel`) read cached JSON synchronously on
   the caller's thread when created so the first frame shows saved data
   immediately.
2. `APIClient` sends conditional requests (`If-None-Match`) to the service over
   HTTPS. An HTTP `304` preserves the cached body and updates fetch metadata.
3. While a scene is active, `DashboardStore` subscribes to
   `/api/dashboard/events` (SSE), jitters 0–3 seconds on a new revision before
   reloading, falls back to `/api/dashboard/revision` polling every 30 seconds
   when the stream fails three times or returns `503`, and revalidates at
   `projection.nextTransitionAt` and every minute.
4. When a request fails, the store or `DocumentModel` retains the current
   snapshot (or falls back to cached data marked stale with its JST fetch time)
   and exposes the typed `APIError` for a one-line notice with **Try Again**.
5. External URLs (`sourceUrl`, `sourcePage`, `archiveUrl`, `watchUrl`, link
   `href`s, X/YouTube/Bilibili pages) open in the system browser via `openURL`
   and are never fetched by the app.

## Extension Points

- When the app needs data the Kano Navi public API does not provide, propose
  and implement the endpoint or field in `kano-navi` first instead of working
  around it in the client.
- Keep Foundation-only networking, models, caching, time, content-language
  resolution, and notification diffing in `KanoNaviCore` without importing
  SwiftUI or UIKit.
- Keep shared UI primitives free of UIKit, navigation, and interactive controls
  in `KanoNaviComponents` so both `KanoNavi` and `KanoNaviWidgets` render them.
- Keep platform-specific API choices inside `KanoNavi/Shared/Platform/` rather
  than scattering `#if os(...)` conditionals across feature views.

## Related Docs

- [Targets and platforms](targets-and-platforms.md)
- [API and caching](api-and-caching.md)
- [Secure development](../development/security.md)
