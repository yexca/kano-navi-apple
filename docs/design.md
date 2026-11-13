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
  Coming Up shows its range cached on this device while its first read
  runs. When the service cannot be read and the range comes from the cache,
  it says "Couldn't update the schedule. Showing the copy from <JST date and
  time>" with Try Again; a failed reload of entries already on screen, or a
  first load with nothing cached, says so with Try Again.
- **Schedule** keeps the month grid and day list when a read fails. A month
  that comes from the cache because the service could not be read shows
  "Couldn't update the schedule. Showing the copy from <JST date and time>"
  with Try Again; a failed reload of a month already on screen, or a first
  load with nothing cached, says so with Try Again.
- **Videos** and **Posts** mark the shelf and the recent posts, which come
  from the dashboard, with the same notices as Now. Their month archives keep
  the month on screen when a read fails. A month read from the cache because
  the service could not be read shows "Couldn't update this month. Showing the
  copy from <JST date and time>" with Try Again; a failed reload of a month
  already on screen, a first load with nothing cached, and a failed next page
  (at the end of the list) each say so with Try Again.
- **Widgets** show cached data after a failed read with a cloud mark and "As
  of <JST time>" (the mark alone in the small and rectangular layouts), and
  "Schedule unavailable" when nothing is cached.

`KanoNaviCore` exposes these reads through `APIClient` request values. `FileResponseCache`
stores raw response bodies, ETags and fetch times; `CalendarReader` consumes all
calendar pages in server order and provides both the widget's 14-day range and
the Schedule screen's 42-day month grid; the Now tab reads the widget's
14-day range with it. When the service cannot be read, the reader returns the
cached pages marked stale with their fetch time. The widget
uses the same reader with a cache directory owned by its extension.
`APIClient.readResult(_:)` does the same for one request, such as an archive
page or month index.

## Images and Single Documents

The Journey, Works and LINE BLOG screens share three pieces in
`KanoNavi/Shared/`: image loading, a full-screen image viewer and the loading
of a read that is one whole document.

### Images

`MediaImage` (`Shared/Media/`) draws one file of the service's media route
from a `MediaImageSource`: the absolute URL and, when the API states it, the
original's pixel size.

- **Shape.** A fitted image takes the width it is offered and the height its
  pixel size gives before the file arrives, so a list does not jump; without
  a known size it holds a 3:2 box until the file is read. A cropped image
  fills the frame its screen gives it and keeps an anchor in view the way CSS
  `object-position` does; `UnitPoint(objectPosition:)` reads the Journey's
  `focus`.
- **Copy.** `MediaImageVariant` picks the `w` to ask for, following
  [Resized Copies](https://github.com/yexca/kano-navi/blob/main/docs/architecture/media-cache.md#resized-copies):
  the smallest listed width that covers the pixels drawn (points times the
  display scale; for a cropped image, the width it is scaled to) and is at or
  below the original's width. With an unknown width, or when no listed width
  qualifies, it loads the original without `w`.
- **Loading.** `MediaImageLoader` is an actor read from the environment. It
  fetches with a `URLSession` of its own whose 512 MB `URLCache` lives in the
  caches directory; archive files are immutable, so a file seen once is
  answered from disk without asking the server. It decodes with ImageIO to
  the size drawn, away from the main actor, and keeps decoded images in a
  128 MB least-recently-used memory cache that empties on a memory warning.
  Views drawing the same file at the same size share one fetch and one
  decoded image, and a load stops once every view waiting for it has gone.
- **States.** A file the server does not have (404 `media_not_found`) or
  that is not an image draws "Image unavailable"; a failed fetch draws a Try
  Again button. The screen keeps the provenance link beside the image in
  both.
- **Accessibility.** An image carries a label, or is marked decorative and
  hidden from VoiceOver; the unavailable and failed states are its
  accessibility value.

### Image Viewer

`mediaViewer(item:in:source:label:caption:)` presents `MediaViewer` full
screen over a list of pictures, opening on the one given.

- Swiping sideways turns the page. A pinch or a double tap zooms and a drag
  moves the zoomed picture; while a picture is zoomed, dragging neither turns
  the page nor closes the viewer.
- The Close button, a drag downwards and the VoiceOver escape gesture close
  it. A tap hides and shows the bars; they stay while VoiceOver is on.
- A page loads the copy that fits the screen by the same width rule and
  shows a smaller copy already in memory, such as the thumbnail, meanwhile.
- The screen supplies the caption under each picture (title, credit,
  provenance link). The viewer is dark in both appearances; a caption taller
  than two fifths of the screen scrolls, so the largest text sizes leave the
  picture in view.

### Single Documents

`DocumentModel` (`Shared/Document/`) holds one read that is a whole
document: the Journey, the Works collection, the LINE BLOG index, one article
or its comments. It is generic over an `APIRequest` and built on
`APIClient.cached(_:)` and `APIClient.readResult(_:)`.

- Loading shows the copy cached on this device at once and then reads the
  service. The model exposes the value, a phase (`idle`, `loading`, `loaded`,
  `failed`), whether the value is the cached copy because the service could
  not be read, when it was fetched, and the failure.
- These documents change only with a server release, so nothing polls. Pull
  to refresh and Try Again read again; so does a screen that appears again
  after a failed read.
- A failed read keeps what is on screen. `DocumentStatusNotice` says
  "Couldn't update this page. Showing the copy from <JST date and time>" for
  the cached copy, or that what was loaded before is shown, each with Try
  Again. With nothing to show, `DocumentUnavailableView` gives the reason
  (offline, the service's error status, unreadable data, update needed) with
  Try Again. `DocumentView` puts the two together for a screen.
- `StatusNotice` is the notice's layout; the month archives word it through
  `ArchiveStatusNotice`.

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

1. **Now** — from top to bottom:
   - The spotlight ticket (live now, or next up, with a countdown and its
     platform links), and Bilibili `liveNow` on its own card when the
     spotlight does not show it.
   - **Coming Up**: the next five entries of today and the 13 Japan days
     after it, read with `CalendarReader` (the widgets' range) and built from
     each event's `view.calendarEntries`, so a sale appears at its opening
     and at its close. Entries are grouped under "Today", "Tomorrow" or the
     weekday and date; days without entries do not appear. An entry is
     listed when it is live, on a later day, date-only today, or today and
     not started yet; an entry of today that has started stays for three
     hours after its end (its start when it has no end time). The section
     ends with See Full Schedule, which opens the Schedule tab. When nothing
     is listed it says "Nothing scheduled in the next two weeks", offers the
     calendar subscription, and lists under "Recently" the two entries of the
     dashboard's events that ended last (done, with a clock time, one per
     event).
   - Each entry is an `EventTicketRow`: a stub with the large JST time
     ("About …" for an estimate, "Time TBA" without one) and a relative
     phrase ("in 3 hours", "tomorrow", "in 4 days"; a clock phrase on today's
     date or within 12 hours, otherwise Japan days), beside the title in the
     content language and one line of platform, type and tag, and members
     and sale marks. A live entry's stub turns red with "● Live" and its end
     time; a done entry is dimmed; a cancelled one is struck through and
     says so. Tapping an entry opens it in the Schedule tab.
   - On Sale: the projection's sales with their opening and closing times.
   - The latest video.
   - A one-line freshness footer: when the service last collected data and,
     when there is one, a summary (collecting, some sources had warnings,
     some data not read for a day, last collection failed). It turns orange
     with a warning symbol when the last run failed or the run or a source
     has not been read for a day. Tapping it opens a sheet with the last
     collection result and time, each source's last read and when this app
     last checked.

   Pull to refresh reloads the dashboard and then Coming Up's range; Coming
   Up also reloads whenever the dashboard is received.
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
3. **Posts** — the dashboard's posts in its order: the account (`@handle` on
   X; a Bilibili account by its platform, never its mid), JST time, text in
   the content language with Show Original, the ready images (up to four,
   "+N" for the rest), the quoted post nested in it (a deleted or withheld
   quote says so and still links to it) and Open on X or Open on Bilibili.
   A promoted related-account post carries an Agency Post chip. Past Posts
   opens the month archive with the account filter: the dashboard's
   `xAccounts`, then its `bilibiliAccounts`.
4. **Videos** — the projection's shelf joined to the dashboard's `videos` by
   ID, each group in the projection's order, leaving out an ID without a
   record: the lead (marked Featured when `leadIsFeatured`, otherwise Latest
   Work), then Coming Up (reservations), Works, Stream Archives and Shorts. A
   card shows the cover, the title in the content language, a status chip from
   `view.phase` (live, upcoming, started, cancelled) or else the
   `view.formCode` chip, the tag, availability when not everyone can watch
   (members, private, removed), the JST time (scheduled start, else
   publication) and buttons for the video's page and its `alternates`. Shorts
   are vertical cards in a row that scrolls sideways. Pull to refresh reloads
   the dashboard. Past Videos opens the month archive with the category filter
   (`game`, `talk`, `song`, `other`).
5. **More** — Works, Journey, LINE BLOG archive, Settings and About. About
   states that the app is an unofficial fan project and links the web board
   and the `kano-navi` repository.

Both month archives read their month index (`/api/videos/months`,
`/api/posts/months`) and show one Japan month at a time, newest first, from
its first to its last date, 20 items per page; the next page is read when the
list reaches its end. A filter's counts come from the page's `categoryCounts`
or `accountCounts`, which count the whole month whatever the filter (keys are
lowercase handles); All is their sum.

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
