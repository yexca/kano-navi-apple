# Board and Timelines

The app uses a sidebar-adaptable `TabView` in two presentations:

- **Tab bar** (iPhone, iPad's bar at the top, compact iPad windows): **Now**,
  **Schedule**, **Posts**, **Videos**, and **More**.
- **Sidebar** (macOS, and iPad when the bar at the top turns into one): the
  first four tabs, then More's screens as tabs of their own in two sections,
  **Archive** (**Journey**, **Works**, **LINE BLOG**) and **App**
  (**Settings**, **About**). More is not listed. On macOS the sidebar has only
  **Archive**: Settings and About open in windows of their own (see
  [Targets and platforms](targets-and-platforms.md)).

`AppRouter` follows the presentation the tabs report through `tabBarPlacement`
and builds the tab list from it. When an iPad switches presentations, a
selected tab the new one does not list moves to the same screen: a sidebar tab
to More opened at that screen, and More to the sidebar tab of the screen it
shows (**Journey** while it shows its list). Only that root screen carries
over. Deep links and cross-tab buttons select tabs uniformly; the notification
settings link opens Settings ▸ Notifications in either presentation, waiting
for the first report when it arrives before the first frame. On macOS it opens
the Settings window on its **Notifications** pane instead.

On wide iPad and Mac windows, reading-focused views (`Now`, `Posts`, `Videos`,
entry details, `Journey` timeline/milestones, `Works` releases/participation,
`LINE BLOG` reader/comments, `Settings`, `Notifications`, and `About`) center
their content using
`readableContentWidth()` (672 pt base width, scaling with text size). List
indexes (`More`, `Works`, `LINE BLOG` index), grids, `Schedule` months, and
`MediaViewer` span the full width and adapt to free resizing and orientation
changes.

## Now

Top-to-bottom layout (below any failure banner):

- **Profile card:** 128 pt cropped banner (top third in view, or soft fill),
  84 pt round avatar overlapping halfway in a ring of the card background (or
  neutral circle), the tagline (`Virtual Artist · ミリプロ SONA`) as a small
  kicker, display name, small uppercase romanized name, the catchphrase
  (`みんなの毎日を、まほろばに。`), one row of links, and one row of counts.
  Tagline and catchphrase are untranslated app copy set in Hiragino Sans
  (`Font.japanese`, scaled with their text styles) in every language, since
  the system font gives Japanese text Chinese glyphs under Simplified Chinese.
  Links list an X logo + `@handle` for each X account in
  `resources` (`x.com/<handle>` or `twitter.com`, falling back to `xUrl`), then
  YouTube (`youtubeUrl`) and Bilibili (first `bilibili.com` resource) as round
  logo-only buttons with VoiceOver platform names (the profile card is the
  deliberate exception to the logo-and-name link rule in
  [Design](../development/design.md)). Narrow cards try tighter spacing, cap
  link text at extra-large then large sizes, and scale handles before wrapping
  only at accessibility text sizes. Counts show `summary.counts` as symbol +
  number buttons: `upcomingEvents` opens **Schedule** on today, `posts` (over
  `meta.postWindowDays`) opens **Posts**, and `videos` (the API's seven-day
  window) opens **Videos**; each carries its full phrase, such as "34 posts in
  3 days", as VoiceOver label and pointer tooltip. The row is omitted without
  `summary.counts` and wraps at accessibility text sizes. The banner and
  the avatar open the [image viewer](media-and-viewer.md#image-viewer) over
  both (banner first), captioned with the display name and **Banner** or
  **Avatar**, which VoiceOver also reads for each; VoiceOver reads the
  display name once as a heading.
- **Spotlight ticket and Bilibili live:** Shows `projection.spotlight` (live,
  next with countdown and links, or latest video); its cover opens the image
  viewer captioned with its title. Bilibili `liveNow` renders its own card
  when not in the spotlight.
- **Coming Up:** Lists up to five entries across today and the next 13 Japan
  days via `CalendarReader`, omitting the spotlight's event (matched by
  `eventId` or shared stream/video URLs) and all sale entries (shown in **On
  Sale**). Entries are grouped under **Today**, **Tomorrow**, or weekday +
  date; empty days are omitted. Today's started entries remain for three hours
  after `endsAt` (or `startsAt` when `endsAt` is absent). Ends with **See Full
  Schedule**; when nothing is scheduled in two weeks, shows "Nothing scheduled
  in the next two weeks", a calendar subscription control, and up to two
  recently ended clock-timed dashboard entries (one per event) under
  **Recently**.
- **EventTicketRow:** Shared ticket row showing the large JST time ("About …"
  or "Time TBA"), relative phrase (clock phrase on today's date or within 12
  hours, otherwise Japan days), title in the content language, and one metadata
  line (platform, type, tag, members, sale marks). Live rows turn red with
  `● Live` and end time; done rows dim; cancelled rows strike through and show
  their state. Tapping opens the entry in **Schedule**.
- **On Sale:** Projection sales with opening and closing JST times.
- **Freshness footer:** One line showing the status summary (warnings,
  running, failed, or not read for a day; the freshness header when healthy),
  turning orange with a warning symbol when the last run failed or any source
  is over a day old. Tapping opens a detail sheet with per-source read times
  and device check time.
- **Navigation subtitle:** "Updated" with the last collection run's JST time,
  adding its Japan day when the run is before today; blank while the run's time
  is unknown or too far ahead of the device clock.

Pull to refresh reloads the dashboard and Coming Up's range; Coming Up also
reloads whenever a new dashboard snapshot arrives.

## Schedule

Monday-first Japan-date months modeled after iOS Calendar:

- **Fixed header:** Active month name (`November 2026`, or `Nov 2026` at
  accessibility sizes) stays pinned as a large-style header without collapsing
  into the navigation bar. The bar holds **Today** (leading) and the mode and
  calendar subscription menus (trailing; `webcal://` to `/api/calendar.ics` in
  the interface language, plus HTTPS share).
- **Modes:** Menu lists **Compact**, **Stacked**, **Details**, divider, and
  **List** (default), persisted in `AppSettings.scheduleModeKey`. Months draw
  edge-to-edge with only their own days, hairline top rules per week segment,
  gray weekend numerals, and tinted today numerals.
  - **List:** Pins the active month, weekday row, and up to three tag-color
    segments per day capsule (dimmed when all entries are done or cancelled)
    above a pull-to-refresh day list. Vertical dragging translates the active
    and neighboring months smoothly clipped to the month area; crossing one
    third of the month height (with momentum on release) commits the adjacent
    month and animates the four-to-six-week height change (Reduce Motion
    cross-fades). Every day exposes VoiceOver Previous/Next Month actions. Day
    rows omit repeated `JST` suffixes in favor of one "Times in JST" caption
    when timed entries exist; untimed entries sort first, then by start time in
    server order.
  - **Compact / Stacked / Details:** Vertically scrolling months under the
    pinned month title and weekday row, reading the visible month plus two
    months on each side. Cells render dots (Compact), bars (Stacked), or
    tinted single-line titles (Details) with `+n` overflow without truncating
    `+n`. Tapping a day opens it in **List**. Accessibility text sizes fold
    Stacked and Details into dots.
- **Mode transitions and drawing:** List and grid share one underlying day cell
  layout so numerals resize and move in place over a 0.4 s spring (cross-fade
  under Reduce Motion; instant for deep links). `ScheduleMonthDays` indexes
  entries off the main actor; value equality excluding action closures limits
  redraws to changed days or loaded months.
- **Colors and entries:** Colors derive from `view.typeCode` in `ScheduleTag`
  (`KanoNaviComponents`) and stay ≥ 4.5:1 on Details tints and widget
  backgrounds. Day entries come from `view.calendarEntries`. Tapping opens a
  detail sheet showing title, JST time, state, type/tag, platforms/links,
  **Confirmed** (when `provenance == "manual"` or `manualLocked` is set) vs.
  **Auto-detected**, sale window, and announcement link. Deep links select
  List for the target date and open the entry sheet when an event ID is given.

## Posts

Reverse-chronological timeline of all posts from `/api/posts` (`until` cursor,
50 posts per page), grouped by Japan month with a dynamic navigation subtitle
naming the topmost visible month:

- **Cards:** Grouped inset style with account avatar (resolved from
  `accountAvatars` then dashboard entries, falling back to profile avatar for
  own posts or handle initial / person symbol for promoted posts), `@handle` or
  `Bilibili` (never mid), JST time, top-right X logo or Bilibili logo/name
  link, content-language text with **Show Original**, up to four ready images
  with `+N`, nested quoted posts (including deleted/withheld placeholders with
  links), and **Agency Post** chip when promoted.
- **Images:** A photo opens the image viewer over its post's ready images, or
  its quote's, captioned with its `alt` and an **Open Post** link (platform
  logo). A media item of `kind` `video` or `gif` is the still of something
  that plays only on X: its tile carries a round play mark or a GIF tag and
  opens the post (or the quoted post) through `openURL`, and in the viewer
  its caption offers **Play Video on X** or **Play GIF on X**. The `+N` tile
  always opens the viewer, which reaches the images it hides. An unknown
  `kind` shows as a photo. VoiceOver reads `alt` (after "Video" or "GIF" for
  a still) or the kind, with a hint saying what the tile does.
- **Controls:** Leading **Filter** menu (**All**, dashboard `xAccounts`,
  `bilibiliAccounts` with `accountCounts` totals; unknown/unfollowed accounts
  fall back to **All**) and trailing **Month** picker over `/api/posts/months`.
- **Consistency:** Appending pages deduplicates offset shifts; revision changes
  or mismatched page revisions reload loaded pages atomically while anchoring
  the topmost visible post (or inserting above at the very top).

## Videos

Reverse-chronological timeline of dated videos from `/api/videos` (`until`
cursor, 50 videos per page), led on the newest view by an **On Air** section
for `live` / `started` items ahead of scheduled reservations:

- **Cards:** Plain list (16 pt spacing), 16:9 cover (12 pt corners, requesting
  the matching width copy) with lower-trailing status or duration,
  lower-leading `Shorts` badge, upper-leading availability mark, platform
  circle, semibold title in content language (with translate glyph when
  translated), and secondary metadata line. Context menu previews the cover
  and lists alternate platforms, translation toggle, Copy Link, and Share;
  VoiceOver consolidates each card with custom actions.
- **Filters:** Leading **Kind** (`All`, `Streams`, `Videos`, `Shorts`) and
  **Platform** (`All`, `YouTube`, `Bilibili`) menus apply on-device and fetch
  additional pages until at least ten items match or the timeline ends.
  Trailing **Month** picker queries `/api/videos/months`.

## Month Picker

Shared by **Posts** and **Videos** (`KanoNavi/Shared/MonthPicker/`): sheet on
iPhone, popover on iPad/Mac. Leads with **Newest**, followed by years from the
current Japan year down to the oldest indexed month in a four-column grid (two
columns at accessibility text sizes). Active months display item counts and
allow selection; empty or future months stay dimmed.

## More and Sidebar Tabs

In the tab bar, **More** lists **Journey**, **Works**, and **LINE BLOG**, then
**Settings** and **About**, and pushes each onto its `NavigationStack`. In the
sidebar each of these screens is a tab whose own `NavigationStack` shows it at
the root. Both presentations draw the same screens (`MoreDestinationScreen`),
so a Journey milestone's **View in Works** pushes the release onto the stack it
is in.

- **Settings:** Notifications status, Content Language menu, the system App
  Language / Language & Region link, and a one-line footer telling the two
  languages apart.
- **About:** A centered header with the app icon (`AboutIcon`, a 72 pt copy of
  the app icon), the app name, the version, and the unofficial project
  statement; a link to the web board; links to the app's source
  (`kano-navi-apple`), the service's source (`kano-navi`), and the app's
  license (GNU AGPL v3.0, `AGPL-3.0`); and a footnote naming the
  `AboutCredits.models`.

Settings, Notifications, and About are `Form`s in the grouped style on every
platform, so a Mac window shows the same rounded groups as iPhone and iPad
instead of the Mac's default two-column form.

## Related Docs

- [API and caching](api-and-caching.md)
- [Archives](archives.md)
- [Media and viewer](media-and-viewer.md)
- [Design and interaction](../development/design.md)
