# App Design

Kano Navi for iOS shows what Kano Mahoro is up to: what airs next, the
schedule, recent videos and posts. It reads the Kano Navi public API and keeps
its own layout; it does not mirror the web board page by page. The rules in
[`AGENTS.md`](../AGENTS.md) apply throughout; this document describes how the
app is built on them.

## Principles

- **Glanceable first.** The first screen and the widgets answer "is she live,
  what is next, and when" without scrolling.
- **The server decides, the app renders.** The dashboard `projection` and each
  record's `view` carry focus order, live state, shelf groups and calendar
  entries as codes. The app joins records by ID, translates codes and lays
  them out. It never re-derives a decision the projection makes.
- **Old data survives a failure.** Every screen keeps the last good data and
  shows the failure beside it.
- **Japan time.** Event times are shown in Asia/Tokyo and labelled JST; date
  ranges, calendar days and "today" are Japan dates.

## Targets and Modules

| Target / module                 | Kind                     | Contents                                                                 |
| ------------------------------- | ------------------------ | ------------------------------------------------------------------------ |
| `KanoNavi`                      | App                      | Scenes, tabs, screens, settings                                          |
| `KanoNaviWidgets`               | Widget extension         | Calendar widgets and their timeline provider                             |
| `KanoNaviKit` → `KanoNaviCore`  | Local Swift package lib  | API models, client, caching, refresh scheduling, Japan time, content language, display-code labels |
| `KanoNaviKit` → `KanoNaviComponents` | Local Swift package lib | SwiftUI pieces shared by the app and widgets: state chips, platform marks, time labels, event rows |
| `KanoNaviTests`                 | Unit tests               | App-level tests (Swift Testing)                                          |
| `KanoNaviUITests`               | UI tests                 | Launch and navigation smoke tests (XCTest)                               |

The package lives in `Packages/KanoNaviKit` with the Swift Testing targets
`KanoNaviCoreTests` and `KanoNaviComponentsTests`. It depends on nothing
outside the Apple SDKs. `KanoNaviCore` does not import SwiftUI;
`KanoNaviComponents` depends on `KanoNaviCore`.

Folders inside `KanoNavi/` follow features: `App/`, `Now/`, `Schedule/`,
`Videos/`, `Posts/`, `More/`, `Settings/`, `Shared/`.

## API Contract

The [Public API](https://github.com/yexca/kano-navi/blob/main/docs/architecture/public-api.md)
owns the contract; the web board's
[`src/types.ts`](https://github.com/yexca/kano-navi/blob/main/src/types.ts)
shows the exact JSON shapes and closed code sets.

- The app requires dashboard `projection.version` 1 and the event and video
  `view` objects. A dashboard without them, or with another version, is an
  incompatible response: the app keeps its last good snapshot and shows that
  the service needs an update. There is no local fallback derivation.
- Closed code sets decode into Swift enums with an `unknown(String)` case, so
  a new server code degrades to a neutral label instead of failing the whole
  response. Open strings (such as `typeCode`) stay strings with a label table
  and a neutral fallback.
- Timestamps decode as ISO 8601 with and without fractional seconds. Japan
  dates (`YYYY-MM-DD`) decode into a `JapanDate` value, not `Date`.
- Relative media URLs (`/media/...`) resolve against the API base URL.
  External links (X, YouTube, Bilibili pages) are only ever opened for the
  user with `openURL`; the app never fetches them.
- `/api/health`'s `lastSync.message` is not displayed; only `status` is.

Endpoints the app uses: `/api/dashboard?days=7`, `/api/dashboard/revision`,
`/api/calendar`, `/api/posts`, `/api/posts/months`, `/api/videos`,
`/api/videos/months`, `/api/works/uploads`, `/api/calendar.ics` (as a
subscription link only).

## Networking, Caching and Refresh

- `APIClient` is a `Sendable` value built from the base URL and a
  `URLSession`. Requests send `If-None-Match` with the cached ETag; a 304
  keeps the cached body. Errors are typed (`offline`, `http(status)`,
  `decoding`, `incompatible`).
- The last good dashboard and calendar pages are stored as raw JSON plus ETag
  in the caches directory, so launch shows them at once and then revalidates.
- While a scene is active, the dashboard store:
  - polls `/api/dashboard/revision` every 30 seconds and reloads when it
    changes;
  - reloads at `projection.nextTransitionAt`, when a time-dependent decision
    changes without a stored revision;
  - revalidates once a minute through the ETag;
  - reloads on foreground and on pull to refresh.
- Polling stops when the scene goes to the background. There is no background
  refresh in the app; the widgets refresh on their own timeline.
- A store exposes `snapshot` (last good data, possibly stale), `phase`
  (`idle`, `loading`, `refreshing`, `failed(error)`), `fetchedAt` and
  `source` (`cache` until a refresh succeeds, then `network`), so a view can
  show data and an error at the same time and say whether the data is cached.

### Cached and Stale Data on Screen

Every screen keeps what it shows and says where it came from:

- **Now** marks the snapshot read from the cache at launch with "Showing data
  saved on this device from <JST date and time>", plus "Updating…" while the
  first refresh runs; the mark goes away once a refresh succeeds. A failed
  refresh shows a banner with the reason and a Try Again button over the data,
  and its footnote says whether the data is the saved copy or the last data
  received since launch, with its JST time.
- **Schedule** keeps the month grid and day list when a read fails. A month
  that comes from the cache because the service could not be read shows
  "Couldn't update the schedule. Showing the copy from <JST date and time>"
  with Try Again; a failed reload of a month already on screen, or a first
  load with nothing cached, says so with Try Again.
- **Widgets** show cached data after a failed read with a cloud mark and "As
  of <JST time>" (the mark alone in the small and rectangular layouts), and
  "Schedule unavailable" when nothing is cached.

`KanoNaviCore` exposes these reads through `APIClient` request values. `FileResponseCache`
stores raw response bodies, ETags and fetch times; `CalendarReader` consumes all
calendar pages in server order and provides both the widget's 14-day range and
the Schedule screen's 42-day month grid. When the service cannot be read, the
reader returns the cached pages marked stale with their fetch time. The widget
uses the same reader with a cache directory owned by its extension.

## Language

- The interface language follows the system's per-app language (English base,
  Japanese, Simplified Chinese). Settings links to the iOS settings page for
  it.
- The content language is a separate in-app setting: **Same as app** (default),
  English, 日本語 or 简体中文. It chooses the language of post text and video
  and event titles. The API's locale `zh-CN` maps to the app's `zh-Hans`.
- Resolution for content locale `L`: use `translations[L]` when it exists,
  except that Japanese keeps wording whose `sourceLanguage` is `ja` as
  written; otherwise show the source wording. A translated text shows a small
  "Translated" mark naming its origin (manual, platform, machine) and can be
  switched to the original in place.
- Display codes (states, types, tags, platforms, forms) are translated in the
  app's String Catalogs for the interface language, never for the content
  language.

## Screens

The app is a `TabView` with five tabs.

1. **Now** — the spotlight ticket (live now, or next up, with a countdown and
   its platform links), Bilibili `liveNow` when present, today's and
   tomorrow's entries, on-sale items, the latest video, and a freshness line
   (last collection result and per-source read times, marking a source not
   read for a day). Pull to refresh.
2. **Schedule** — a Monday-first month calendar of Japan dates with a mark per
   day from `dayCounts`, and the selected day's entries below it. Day lists
   come from each event's `view.calendarEntries`, not its `startsOn`, so a
   sale is listed on its opening day and on its closing day with the matching
   chip; within a day, entries without a time come first, then by start, ties
   in server order. An entry opens a detail sheet: title, time in JST, state,
   type and tag, platforms and links, Auto-detected or Confirmed (Confirmed
   when `provenance` is `manual` or `manualLocked` is set, the board's rule),
   sale window, and a link to the original announcement. The toolbar offers the calendar subscription
   (`webcal://` link to `/api/calendar.ics` in the interface language).
3. **Posts** — recent posts with quotes and images, and a month archive with
   the account filter. Promoted posts are marked as the agency's.
4. **Videos** — the projection shelf (lead, reservations, works, archives,
   Shorts) and a month archive with the category filter.
5. **More** — Works, Journey, LINE BLOG archive, Settings and About. About
   states that the app is an unofficial fan project and links the web board
   and the `kano-navi` repository.

Delivery order: Now, Schedule, widgets, Settings and About first; Videos and
Posts next; Works, Journey and LINE BLOG last.

## Widgets

`KanoNaviWidgets` holds the calendar widgets, the app's one required feature.

- **Upcoming** (`systemSmall`, `systemMedium`, `systemLarge`): small shows the
  next entry with its JST time and a countdown, or the live entry; medium lists
  the next entries grouped by Japan day; large shows the seven Japan days from
  today, each with its entries or "No entries". At accessibility text sizes
  medium and large list the next entries by day, each time above its title,
  instead of a time column or seven rows.
- **Lock Screen** (`accessoryRectangular`, `accessoryInline`): the next entry
  and its time. The rectangular layout has three fixed lines, so its text
  stops growing at the `xxxLarge` Dynamic Type size.
- The widgets draw the live state, JST times and dates with the shared
  `KanoNaviComponents` views and formatting. Sale, members and cancellation
  marks stay widget-specific, compact one-word capsules, because the shared
  chips (icon plus caption text) leave no room for titles in a one-line row at
  large text sizes.
- The timeline provider reads `/api/calendar` for today through 13 days ahead
  (Japan dates) itself, so the widget needs no App Group. It caches the last
  good response in the extension's own container and shows it, marked stale,
  when a read fails.
- Timeline entries are created at each entry's start and at sale openings and
  closes, and the reload policy asks again at the next such time or within 30
  minutes, whichever is sooner.
- An `AppIntentConfiguration` parameter selects the content language, since
  the widget cannot read the app's settings without an App Group.
- Tapping an entry opens `kanonavi://event/<id>`; tapping elsewhere opens
  `kanonavi://schedule?date=<YYYY-MM-DD>`. The app routes both to the
  Schedule tab.

## Visual Language

- System fonts, SF Symbols and semantic colors; light and dark appearance.
- Live state uses a red dot and the word "Live" (never color alone). Members
  entries carry a members chip. Cancelled and suspected cancellations are
  struck through or marked, with their state in words.
- No official artwork, logos or branding. Media from the API is shown as the
  API serves it.
- Every screen works at the largest accessibility text size; rows wrap rather
  than truncate important times.

## Local Integration

`Tools/local-backend/` runs the latest local `kano-navi` checkout with
synthetic data behind a local HTTPS endpoint, and `Config/Local.xcconfig`
(git-ignored, optional) points `API_BASE_URL` at it. See
[Tools/local-backend/README.md](../Tools/local-backend/README.md).
