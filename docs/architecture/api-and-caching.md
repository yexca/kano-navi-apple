# API and Caching

## API Contract

The [`kano-navi` Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
owns the server contract, and `kano-navi`'s
[`src/types.ts`](https://github.com/yexca/kano-navi/blob/main/src/types.ts)
defines the exact JSON shapes and closed code sets.

- The app requires dashboard `projection.version` `1` and the event and video
  `view` objects. A dashboard without them, or with another version, is an
  incompatible response: the app keeps its last good snapshot and displays
  that the service needs an update, with no local fallback derivation.
- Closed code sets decode into Swift enums with an `unknown(String)` case so a
  new server code degrades to a neutral label instead of failing the response.
  Open strings (`typeCode`, milestone `kind`, store `platform`) stay strings with
  a label table and neutral fallback. A LINE BLOG block or inline of an unknown
  `type` decodes as an unknown case while the rest of the article renders.
- Timestamps decode as ISO 8601 with and without fractional seconds. Japan
  dates (`YYYY-MM-DD`) decode into `JapanDate`, not `Date`.
- A Journey milestone `date` preserves its stored precision (`YYYY`, `YYYY-MM`,
  or `YYYY-MM-DD`, matching `datePrecision`) in a `JourneyDate` without guessing
  a day, and `dateEnd` decodes as `JapanDate`.
- Archive reads (Journey, Works, LINE BLOG) supply localized text as
  `{"ja", "zh-CN", "en"}` objects with `null` for missing languages.
  `LocalizedText.resolved(for:fallback:)` selects the content language when
  non-empty, falling back to English, Japanese, then Chinese (or Japanese,
  English, Chinese for LINE BLOG). Release titles, names, and upload fields are
  plain strings shown as written.
- Relative media URLs (`/media/...`) resolve against `API_BASE_URL`. Third-party
  addresses (`sourceUrl`, `sourcePage`, `archiveUrl`, `watchUrl`, link `href`s,
  and X/YouTube/Bilibili pages) are never resolved against the service or
  fetched; they open via `openURL`. Watch pages for Works platform IDs are built
  in-app (`PlatformVideoIDs`) to match the web board.
- `/api/health`'s `lastSync.message` is never displayed; only `status` is used.

Endpoints read by the app and widgets:

- `/api/dashboard?days=7`
- `/api/dashboard/events`
- `/api/dashboard/revision`
- `/api/calendar`
- `/api/posts`, `/api/posts/months`
- `/api/videos`, `/api/videos/months`
- `/api/works`, `/api/works/upload-list`, `/api/works/uploads`
- `/api/journey`
- `/api/lineblog`, `/api/lineblog/posts/{id}`, `/api/lineblog/posts/{id}/comments`
- `/api/calendar.ics` (subscription link only)

Journey, Works, and LINE BLOG reads carry no `revision` and revalidate through
ETags alone.

## Networking, Caching, and Refresh

- `APIClient` is a `Sendable` value built from the base URL and a `URLSession`.
  Requests send `If-None-Match` with the cached ETag; HTTP `304` preserves the
  cached body. Failures map to typed `APIError` values (`offline`,
  `http(status)`, `decoding`, `incompatible`).
- `FileResponseCache` stores raw JSON bodies, ETags, and fetch timestamps in
  the caches directory (one JSON file per request); unreadable files are
  removed. `ResponseCache.loadImmediately(key:)` and
  `CalendarReader.cachedResultImmediately(from:to:)` read synchronously on the
  caller's thread at launch so the first frame draws saved data and shows
  "Loading…" only when nothing is cached.
- `CalendarReader` fetches all pages of a date range in server order and builds
  both Coming Up / widget 14-day ranges and Schedule's 42-day month grids. When
  the network fails and all pages in range are cached, it returns the cached
  pages marked stale (`isStale` / `isFromCache`) with the oldest page's
  `fetchedAt`. The widget extension runs `CalendarReader` against its own
  container cache directory. `APIClient.readResult(_:)` provides the same
  stale-cache fallback for single requests.
- While a scene is active, `DashboardStore` (`@MainActor @Observable`):
  - opens an SSE connection (`URLSessionRevisionStream` + `SSEDecoder`) to
    `/api/dashboard/events`, waits a random 0–3 second jitter when a pushed
    revision differs from the current snapshot before reloading, and falls back
    to polling `/api/dashboard/revision` every 30 seconds after three consecutive
    stream errors or HTTP `503` (retrying the stream after five minutes, or
    `Retry-After` when longer); without a stream source, it polls every 30
    seconds;
  - schedules a reload at `projection.nextTransitionAt` for time-dependent
    transitions without a revision bump;
  - revalidates every minute via ETag;
  - reloads on foreground entry and pull to refresh.
- Streaming and polling stop when the scene leaves the foreground. When local
  notifications are enabled, `BackgroundRefreshScheduler` queues a
  `BGAppRefreshTask` (`<bundle-id>.refresh`) on iOS or an
  `NSBackgroundActivityScheduler` activity on macOS; widgets refresh on their
  own timeline.
- `DashboardStore` exposes `snapshot`, `phase` (`idle`, `loading`,
  `refreshing`, `failed(error)`), `fetchedAt`, and `source` (`cache` until a
  refresh succeeds, then `network`). A refresh that returns an equal dashboard
  leaves `snapshot` and `source` untouched; Coming Up keeps its range when
  entries match, so foreground returns avoid redundant animation. Returning to
  the foreground does not overwrite the live snapshot with disk cache, and a
  failed phase stays visible while the next refresh runs.
- `DocumentModel` (`KanoNavi/Shared/Document/`) wraps single-document archive
  reads (`Journey`, `Works`, `LINE BLOG` index, article, and comments) on
  `APIClient.cached(_:)` and `APIClient.readResult(_:)`. These documents do not
  poll; pull to refresh, **Try Again**, and re-appearing after a failure
  trigger a reload. `DocumentStatusNotice`, `DocumentUnavailableView`, and
  `DocumentView` present saved-copy and error states uniformly; `StatusNotice`
  is shared with `PostTimelineStatusNotice` and `VideoTimelineStatusNotice`.

## Cached and Stale Data on Screen

Every screen preserves what it displays and states where the data came from:

- **Now:** Draws the cached snapshot in place at launch without shifting
  layout. If the first refresh runs longer than one second, an "Updating…"
  capsule floats over the bottom of the list (VoiceOver announces "Showing data
  saved on this device from \<JST date and time\>") and disappears on
  completion. A failed refresh shows an error banner with **Try Again** above
  the content and a footer noting the saved copy or last received snapshot with
  its JST time. Coming Up displays its cached 14-day range while loading and
  shows "Couldn't update the schedule. Showing the copy from \<JST date and
  time\>" with **Try Again** when cached fallback is used.
- **Schedule:** Retains loaded months and day entries on failure, displaying
  each month's notice above it (List shows the active month's notice) with the
  saved JST timestamp and **Try Again**.
- **Posts and Videos:** Read their cached first page synchronously when built,
  displaying "Loading…" only with an empty cache. Failed initial loads, reloads,
  or next-page fetches keep the timeline on screen and display a one-line notice
  with **Try Again** (at the end of the list for a failed next page).
- **Single documents:** `DocumentStatusNotice` shows "Couldn't update this
  page. Showing the copy from \<JST date and time\>" for cached copies, or notes
  that the data already on screen remains visible, with **Try Again**;
  `DocumentUnavailableView` explains offline, HTTP status, decoding, or
  update-needed failures when nothing is cached.
- **Widgets:** Show cached data with a cloud mark and "As of \<JST time\>"
  (mark alone in small and rectangular layouts), or "Schedule unavailable" when
  nothing is cached.

## Related Docs

- [Core boundaries](core-boundaries.md)
- [Media and viewer](media-and-viewer.md)
- [Board and timelines](board-and-timelines.md)
- [Archives](archives.md)
