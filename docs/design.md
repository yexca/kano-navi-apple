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
| `KanoNavi`                      | App                      | Scenes, tabs, screens, settings, local notifications                     |
| `KanoNaviWidgets`               | Widget extension         | Calendar widgets and their timeline provider                             |
| `KanoNaviKit` → `KanoNaviCore`  | Local Swift package lib  | API models, client, SSE revision streaming, caching, refresh scheduling, notification planning, Japan time, content language, display-code labels |
| `KanoNaviKit` → `KanoNaviComponents` | Local Swift package lib | SwiftUI pieces shared by the app and widgets: state chips, platform marks, time labels, event rows |
| `KanoNaviTests`                 | Unit tests               | App-level tests (Swift Testing)                                          |
| `KanoNaviUITests`               | UI tests                 | Launch and navigation smoke tests (XCTest)                               |

The package lives in `Packages/KanoNaviKit` with the Swift Testing targets
`KanoNaviCoreTests` and `KanoNaviComponentsTests`. It depends on nothing
outside the Apple SDKs. `KanoNaviCore` does not import SwiftUI;
`KanoNaviComponents` depends on `KanoNaviCore`.

Folders inside `KanoNavi/` follow features: `App/`, `Now/`, `Schedule/`,
`Videos/`, `Posts/`, `Journey/`, `Works/`, `LineBlog/`, `More/`,
`Notifications/`, `Shared/`. The app icon in `Resources/Assets.xcassets` is
the web board's avatar (`public/assets/kano-avatar.jpg` in `kano-navi`)
scaled to 1024 px.

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
  response. Open strings (such as `typeCode`, a milestone `kind` or a store
  `platform`) stay strings with a label table and a neutral fallback. A LINE
  BLOG block or inline of an unknown `type` decodes as an unknown case and the
  rest of the article still shows.
- Timestamps decode as ISO 8601 with and without fractional seconds. Japan
  dates (`YYYY-MM-DD`) decode into a `JapanDate` value, not `Date`.
- A Journey milestone `date` keeps its stored precision (`YYYY`, `YYYY-MM` or
  `YYYY-MM-DD`, matching `datePrecision`) in a `JourneyDate`; it is never
  widened to a guessed day, and `dateEnd` is a `JapanDate`.
- The archive reads (Journey, Works, LINE BLOG) give text as
  `{"ja", "zh-CN", "en"}` objects with `null` for a missing language. The app
  shows the content language when it has text (an empty string counts as
  missing), otherwise English, then Japanese, then Chinese; LINE BLOG text,
  written in Japanese, falls back to Japanese first. Release titles, names
  and upload fields are plain strings shown as written.
- Relative media URLs (`/media/...`) resolve against the API base URL.
  Third-party addresses (provenance such as `sourceUrl`, `sourcePage`,
  `archiveUrl`, `watchUrl`, link `href`s, and external pages on X, YouTube
  and Bilibili) are never resolved against the service or fetched; they are
  only opened for the user with `openURL`. Watch pages for Works platform IDs
  are built in the app, as the web board builds them.
- `/api/health`'s `lastSync.message` is not displayed; only `status` is.

Endpoints the app uses: `/api/dashboard?days=7`, `/api/dashboard/events`,
`/api/dashboard/revision`, `/api/calendar`, `/api/posts`, `/api/posts/months`,
`/api/videos`, `/api/videos/months`, `/api/works`, `/api/works/upload-list`,
`/api/works/uploads`, `/api/journey`, `/api/lineblog`,
`/api/lineblog/posts/{id}`, `/api/lineblog/posts/{id}/comments`,
`/api/calendar.ics` (as a subscription link only). The Journey, Works and
LINE BLOG reads carry no `revision`; they revalidate through their ETag
alone.

## Networking, Caching and Refresh

- `APIClient` is a `Sendable` value built from the base URL and a
  `URLSession`. Requests send `If-None-Match` with the cached ETag; a 304
  keeps the cached body. Errors are typed (`offline`, `http(status)`,
  `decoding`, `incompatible`).
- The last good dashboard and calendar pages are stored as raw JSON plus ETag
  in the caches directory, so launch shows them at once and then revalidates.
- While a scene is active, the dashboard store:
  - opens an SSE connection to `/api/dashboard/events` (`text/event-stream`),
    waits a random 0–3 second jitter when a pushed revision differs from the
    current snapshot before reloading, and falls back to polling
    `/api/dashboard/revision` every 30 seconds after three consecutive stream
    errors or an HTTP 503 (retrying the stream after five minutes, or
    `Retry-After` when longer); without a stream source it polls
    `/api/dashboard/revision` every 30 seconds;
  - reloads at `projection.nextTransitionAt`, when a time-dependent decision
    changes without a stored revision;
  - revalidates once a minute through the ETag;
  - reloads on foreground and on pull to refresh.
- Streaming and polling stop when the scene goes to the background. When local
  notifications are enabled, the app schedules a `BGAppRefreshTask`
  (`<bundle-id>.refresh`) to check the dashboard and 14-day calendar in the
  background; the widgets refresh on their own timeline.
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
   quote says so and still links to it) and a link to the post: the X
   logo alone, or the Bilibili logo and name.
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
5. **More** — Journey, Works and the LINE BLOG archive, each described
   below, then Settings and About. Settings is three rows without
   explanations: Notifications with its status, a Content Language menu, and
   App Language, which opens the system's per-app language setting. About
   says in one line that the app is an unofficial fan project, links the web
   board and the `kano-navi` repository, lists the models the app was built
   with (Claude Opus 5.5, Gemini 4 Carbon, Claude Fable 5.2) and shows the
   version.

Both month archives read their month index (`/api/videos/months`,
`/api/posts/months`) and show one Japan month at a time, newest first, from
its first to its last date, 20 items per page; the next page is read when the
list reaches its end. A filter's counts come from the page's `categoryCounts`
or `accountCounts`, which count the whole month whatever the filter (keys are
lowercase handles); All is their sum.

Delivery order: Now, Schedule, widgets, Settings and About first; Videos and
Posts next; Works, Journey and LINE BLOG last.

### Journey

Kano's public milestones and their images, from `/api/journey`, read as one
document through `DocumentModel` (saved-copy and failure notices, pull to
refresh). A segmented switch in the toolbar, one symbol per mode, flips
between the timeline and the gallery. Both start with one horizontally
scrolling row of equal-height identity chips (All, then each branch with its
portrait, name and its milestone or image count, which VoiceOver reads as
words), which filter both views. A branch without a portrait shows a person
symbol in its tone's ring instead; the selected chip is outlined and its
portrait carries a check mark. Tapping the selected chip shows all again.
Both end with one line, the date the data was checked through, whose info
button opens the hand-curation note and the image rights notice.

- **Timeline.** Milestones read oldest first, as the story runs, under a
  sticky header per year with its count; within a year they keep the API's
  order. A row shows a marker with the kind's symbol on a line in the
  branch's tone, the date at its stored precision (a year, `Sep` or `Sep 7`
  within the year; a `dateEnd` as a range; the `dateNote` after it), the
  branch's name, the kind, the title and up to three lines of detail in the
  content language, and up to three cropped thumbnails with "+N". A
  highlight has a filled marker, a larger title, a tinted card and "Key
  milestone".
- **Milestone page.** A row opens the full date with its year, the whole
  detail, every image at its own shape (tall ones capped) with what it shows,
  its date and its source link, then Source and Links: the source page by its
  site, or "Third-party stream archive" when there is none, and the further
  links by their worded labels. An image opens the
  viewer over the milestone's images. A milestone with a `releaseId` offers
  View in Works, which pushes that release's Works screen onto the More
  tab's stack: the Journey calls `journeyOpenRelease` from the environment,
  which the More tab sets, and shows no button where nothing sets it.
- **Gallery.** Every image once: each milestone's images in timeline order
  (catalogued images, then release covers), then the gallery-only images; an
  image listed again keeps its first place. A branch shows the images that
  list it in `branches`. The image-type filter (artwork, models,
  merchandise, video frames, covers, then any new category) counts the
  chosen identity's images. Thumbnails are squares cropped around `focus`; a
  cancelled release's cover carries a mark. A thumbnail opens the viewer over
  the filtered images.
- **A milestone that is gone.** When a reload no longer lists the
  milestone whose page is open, the page says "Milestone Not Found" in one
  line.
- **Viewer caption.** What the image shows, with Release cancelled and
  Third-party file marks; the title (a cover's caption under it); the date
  labelled with what it is (`dateKind`), or "Date unverified"; the recorded
  creator and a cover's scan or photo credit; the publisher's credit line as
  written; and the links to the source page, the file or the video at that
  moment, and the original stream. The links stay when the file is
  unavailable. Details opens who published the file (`sourceKind`), the frame
  time and the provenance note over the viewer, as a sheet on iPhone.
- **Codes.** Kinds, link labels, categories, date kinds, source kinds,
  notes and cover credit roles are worded in `Journey.xcstrings`, after the
  web board's wording. An unknown kind reads "Milestone", an unknown link
  "Related page", an unknown category "Other images", an unknown date kind
  "Date" and an unknown source kind "Other source"; an unknown note is left
  out, since a note is a sentence about one image.
- **Tones.** `honey`, `leaf`, `berry`, `lavender` and `sky` are colours in
  `JourneyColors.xcassets` with light and dark values; the light ones are
  darker than the web board's. Tone text (dates, branch tags, "Key
  milestone") reaches at least 4.5:1 in both appearances on the system
  background, on a branch tag's 14% tint, on a highlighted row's 8% tint
  and on a tag inside a highlighted row. An unknown tone is the secondary
  colour. A tone always accompanies the branch's name.

### Works

Opens from More. The entry reads `/api/works`, `/api/works/upload-list` and
`/api/works/uploads` once each and shares them with the screens it opens, so
moving between them reads nothing again. Each read loads on appear and on
pull to refresh. The collection is the entry's document; the two upload
reads only add to it, so while they run or after they fail the entry shows
without what they add, and Uploads says why when it opens.

- **Entry.** The years the collection spans, the three ways in with their
  counts (Own Releases, Featured On, Uploads), then two sections. The
  toolbar's info button opens a sheet with the date the collection covers
  works through and the rights notice.
  - Latest Uploads: the ten newest uploads as cover cards in a row that
    scrolls sideways, each with its cover, title and Japan date. The videos
    newer than the collection (`recent`) lead, titled in the content
    language; the collection's uploads follow, newest first, with their
    stored covers. A card opens its watch page in the browser: a newer
    video's own page, or a collection upload's first page in the order of
    its watch buttons that is not removed or private. A card with no such
    page does nothing. The Uploads row above is the way to the full list.
  - On This Day: personal releases, participation works and uploads whose
    Japan month and day are today's in Asia/Tokyo, from past years, newest
    first, each with a small cover and "N years ago". A release or work
    opens its page, an upload its watch page as a card does. A work dated
    February 29 shows on February 28 in years without that day, and on
    February 29 alone in leap years. The section is left out when nothing
    matches.
- **Own Releases.** Covers in a grid by Japan year, newest first, with a
  format filter (All, Album, Single, EP, Doujin, and Other for a format the
  app does not name) and its counts in one row that scrolls sideways and
  keeps the selected format in view. A card shows the first cover, the
  title, the date and marks for format, digital, unit and cancelled
  (struck through); a release without a cover draws a disc mark. A toolbar
  menu switches to oldest first. At accessibility text sizes the grid
  becomes rows.
- **Release.** `WorksReleaseScreen(releaseID:)` loads the Works document
  itself, so any screen can push it, and says Release Not Found for an ID
  the collection does not hold, with Try Again: only once the read has
  ended, since the cached copy may be older than the link, and with the
  notice when that read failed. It shows the first cover large and the
  others as a strip, title, date and marks, label and catalog number, the
  tracks every edition shares by disc (credits, note, and watch links from
  `listen`), disc photos, then a section per edition, store bonuses and the
  streaming and download stores with a Hi-Res mark.
  - An edition shows what the record states for it: catalog number, price,
    format, packaging, its own date, JAN, its covers, what is in the
    package with pictures, and its store bonuses and stores. Its track list
    shows, folded, only when it differs from the shared one, and its disc
    photos only when they differ from the release's.
  - Every image opens the shared viewer over all of the release's
    pictures; a file several places show is one picture. The caption gives
    the image's caption (the title without one), the requested credit
    linked to the contributor's page, whether the file is the publisher's
    or a third party's, and the source page as a link or the site's name.
- **Featured On.** The participation works by year with cover, date, role
  and form chips and the unit; an ID the collection does not hold says
  Work Not Found, as a release does. A work shows its cover, label, event and
  catalog number as written (an empty one is left out), the tracks Kano
  took part in with her further credits, the full track list folded below
  when it holds more than those, and a link to the page the record follows.
- **Uploads.** The upload list joined with `/api/works/uploads` by upload
  ID, by year, newest first, with a kind filter and its counts in one row
  that scrolls sideways, as on Own Releases, and a search
  over song, original artist, collaborators, albums, a compilation's songs
  and the Bilibili title. A row shows the song, the original artist and
  collaborators, date and kind, the albums that include the recording, a
  compilation's songs folded, and a watch button per platform in the order
  niconico, YouTube, members-only YouTube (marked), Bilibili. With Chinese
  as the content language it also shows the upload's title on Bilibili.
  - Stored data adds the cover and the length, which VoiceOver reads with
    the row. A watch page whose stored video is removed or private says
    Unavailable in its button and keeps its link. The row carries a No
    Longer Watchable mark only when every one of its watch pages is such a
    video: a page the service stores nothing about, such as one on
    niconico, may still be there. Rows keep room for covers only when one
    of the rows shown, after the search and the kind filter, has a cover.
  - A search that finds nothing shows the system's no-results view; a kind
    or a collection without uploads says so in its own words.
  - Above the list, Newer Uploads shows `recent` (three until expanded)
    with titles in the content language, JST time and platform links, under
    one footer line with the date they follow and `recentTotal`.
  - The list is the screen's document. When only `/api/works/uploads`
    fails, the list stays and a one-line notice says covers and newer
    uploads could not be loaded or updated, or are the saved copy, with Try
    Again.
- Codes (formats, roles, forms, credits, upload kinds, store platforms,
  image credit roles, the reason a newer upload is listed) are worded in
  `Works.xcstrings`; an unknown code gets a neutral label. Dates are Japan
  dates shown with their year.

### LINE BLOG

Opens from More: the archive of Kano's LINE BLOG, recovered from web archive
captures after the service closed. It has three screens, each one
[single document](#single-documents) with its saved-copy and failure
notices and pull to refresh.

- **Article list** (`/api/lineblog`). The articles in the service's order,
  newest first, under their Japan month with its count. The toolbar's info
  button opens a sheet that says what the archive is and how its comments
  were kept, links the blog's original address and carries the rights
  notice. A row shows the first picture, the title in the
  content language (the Japanese original when that language has none), the
  JST time and the number of archived comments. The toolbar's Jump to Month
  menu lists the years and, inside each, its months with their counts, and
  scrolls the list there.
- **Reader** (`/api/lineblog/posts/{id}`). The title as written, the JST
  time, then the blocks in reading order in a column no wider than 640
  points. The article is laid out whole, not in a lazy stack, so every
  block has its real height from the start; a picture is fetched once it
  scrolls into view, with a box of its shape holding its place until then:
  - A paragraph is one selectable text. Links inside it are underlined,
    tappable and listed for VoiceOver: a link with an `articleId` pushes
    that article, an `http` or `https` address opens outside, and any other
    address is plain text. A pictograph (`emoji`) is an image run of the
    text, scaled with Dynamic Type to sit inside the line; the article's
    pictographs are loaded up front and a full-width space holds each place
    meanwhile. A file the server does not have is replaced by its `alt`; a
    fetch that merely failed is tried once more after two seconds before
    its `alt` is shown, and pull to refresh tries every missing one again.
    A pictograph inside a link is a linked full-width space with the
    picture drawn over it by a text renderer, so it stays tappable when it
    is all the link holds; a paragraph with one is not selectable, because
    selectable text is not drawn through a renderer.
  - Pictures that stand between text split the paragraph into text and
    rows of figures. One picture is drawn whole, no wider than the blog
    showed it and at most 520 points tall; several share a two-column grid
    of square thumbnails. A picture opens the [image viewer](#image-viewer),
    which pages through all of the article's archived pictures and captions
    each with its `alt`, its recovery note and links to where its file was
    recovered from and to the page it linked. A `recovery` code is worded
    under the row (stand-in, from the embedded tweet, or a neutral note for
    an unknown code), each in a few words. A picture is a button only once
    it has loaded: one the server does not have says "Image unavailable"
    and one whose fetch failed offers Try Again, neither opens the viewer,
    and VoiceOver reads the state as the picture's value and reaches the
    button. A picture the archive never captured says "Picture not
    archived" and links its original address.
  - A quote is set off with a bar, a rule is a divider, and a link card
    shows its picture, title, summary and host: a card with an `articleId`
    pushes that article, any other opens outside, and its archived capture
    is a link under it.
  - A video shows its cover with a play button when the archive holds a
    copy. Play opens the same-host file with AVKit, sizes the player from
    the stream and plays in place, with sound even when the ring switch is
    off; it pauses when scrolled out of view, and a copy still opening
    then does not start. One video plays at a time: starting one pauses the
    one that plays, also when it is resumed from the player's own controls.
    When none plays any more, the audio session is deactivated off the main
    actor after 0.4 seconds, notifying other apps so interrupted music
    carries on; the `playback` category stays for the next video. A copy
    that cannot be opened says "Can't play this video". Without a copy the
    cover stands alone over "Video not archived". The YouTube page and its archived capture are links under
    the video and are never loaded. The app asks the system for its VP9
    decoder, which exists from iOS 26.2; a VP9 or AV1 copy on a system
    that cannot decode it shows the cannot-be-played note.
  - Translations follow the content language. Japanese shows none. Chinese
    or English shows that language's translation after each paragraph, with
    a bar beside it and "Machine translation" as its VoiceOver value, the
    translated title under the title, and a Machine Translation mark under
    the time. The toolbar's Show Translation switch turns them off for the
    article on screen. The switch and the mark appear whenever
    the article has anything in that language, a translated title alone
    included, and neither appears when it has nothing. A translation is
    text: pictures in it are left out.
  - The article ends with the link to its comments and their count, which
    the article states (a copy cached before the service counted them takes
    it from the article list; an article known to have none says "No
    archived comments"), Older Article and Newer Article with the
    neighbour's title (`previousId` is older, `nextId` newer), which swap
    the article in place so Back returns to where the reader was opened,
    and under Sources the original address and archived capture.
  - An article number the archive does not have (404, or a number that is
    not an article number) shows Article Not Found.
- **Comments** (`/api/lineblog/posts/{id}/comments`). Under their count,
  each comment shows its number, the name its writer gave, the JST time,
  its rating and its text as written, selectable, newest first. A
  rating is the old form's stars or face with the value in figures beside
  it (`4/5`), read by VoiceOver as one sentence; an unknown kind shows the
  figures alone. An article without comments says No Archived Comments.

## Notifications and Reminders

Notifications run on device through `UNUserNotificationCenter` without remote
push tokens or an App Group, so unsigned builds keep working. Notification
permission is requested only when the user turns on **Allow Notifications** in
**More → Settings → Notifications**, never at launch.

- **Baseline and backfill guard.** `FileNotificationStateStore` saves seen post
  IDs, video IDs, event snapshots and live broadcast IDs in Application
  Support. Recording the first snapshot (or turning notifications back on)
  seeds this baseline without posting banners. Later evaluations ignore posts
  and non-reservation videos published more than 48 hours before the check, so
  archive backfills do not alert.
- **Immediate alerts.** Evaluated during `BGAppRefreshTask` runs (which read
  `/api/dashboard?days=7` and the 14-day calendar window) and kept silent while
  a scene is active so foreground browsing only advances the baseline:
  - *Live Now*: a scheduled entry entering `live`, or an unannounced Bilibili
    `liveNow` stream.
  - *Posts*: three switches — Kano's own X posts, Bilibili posts, and promoted
    related-account posts (`view.promoted`).
  - *Videos*: Works (`work`), Shorts (`short`), and Stream Archives (`archive`,
    off by default). Reservation videos (`reservation`) are skipped because the
    service derives schedule entries from them.
  - *Schedule Updates*: newly added entries and cancellations or time changes,
    filtered by category (`stream`/`member`, `event`, `release`, `sale`) and an
    optional **Confirmed Entries Only** switch.
  - *Members-only*: one switch controls whether members-only streams, videos
    and reminders are included (on by default).
  - Up to three banners are posted per thread (`live`, `posts`, `videos`,
    `schedule`); four or more updates in one thread send the newest two plus a
    summary banner.
- **Timed reminders.** `UNCalendarNotificationTrigger` requests are rebuilt
  from the 14-day calendar window (up to 48 nearest future triggers):
  - *Streams and events*: off, at start, 10 minutes before, or 30 minutes
    before (`startsAt` in JST, skipping cancelled or past entries).
  - *Merchandise sales*: sale opening (`sale_start`) and sale closing
    (`sale_end`: off, 1 hour, 6 hours, or 24 hours before). Date-only sale
    occurrences fire relative to `09:00 JST` on that Japan date.
  - Titles follow the interface language and item text follows the content
    language; changing either rebuilds pending reminder text.
- **Deep links.** Tapping a notification or widget opens a `kanonavi://` URL
  routed by `AppRouter`: `kanonavi://now`, `kanonavi://posts`,
  `kanonavi://videos`, `kanonavi://event/<id>`,
  `kanonavi://schedule?date=<YYYY-MM-DD>`, and
  `kanonavi://settings/notifications`.

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
- YouTube, X and Bilibili are marked by their monochrome logos, custom
  symbols made from Simple Icons that tint and scale like SF Symbols; other
  platforms and sites use a symbol.
- Live state uses a red dot and the word "Live" (never color alone). Members
  entries carry a members chip. Cancelled and suspected cancellations are
  struck through or marked, with their state in words.
- No official logos or branding, and no artwork beyond the app icon, which is
  the web board's avatar. Media from the API is shown as the API serves it.
- Every screen works at the largest accessibility text size; rows wrap rather
  than truncate important times.

## Local Integration

`Tools/local-backend/` runs the latest local `kano-navi` checkout with
synthetic data behind a local HTTPS endpoint, and `Config/Local.xcconfig`
(git-ignored, optional) points `API_BASE_URL` at it. See
[Tools/local-backend/README.md](../Tools/local-backend/README.md).
