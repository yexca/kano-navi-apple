# Board and Timelines

The app uses a sidebar-adaptable `TabView` with five tabs: **Now**,
**Schedule**, **Posts**, **Videos**, and **More**. On iPhone they appear as a
tab bar, on macOS as a sidebar, and on iPadOS as an adaptable top bar or
sidebar; deep links and cross-tab buttons select tabs uniformly across all
three.

On wide iPad and Mac windows, reading-focused views (`Now`, `Posts`, `Videos`,
entry details, `Journey` timeline/milestones, `Works` releases/participation,
and `LINE BLOG` reader/comments) center their content using
`readableContentWidth()` (672 pt base width, scaling with text size). List
indexes (`More`, `Works`, `LINE BLOG` index), grids, `Schedule` months, and
`MediaViewer` span the full width and adapt to free resizing and orientation
changes.

## Now

Top-to-bottom layout (below any failure banner):

- **Profile card:** 128 pt cropped banner (top third in view, or soft fill),
  84 pt round avatar overlapping halfway in a ring of the card background (or
  neutral circle), display name, small uppercase romanized name, and one row of
  links. Links list an X logo + `@handle` for each X account in `resources`
  (`x.com/<handle>` or `twitter.com`, falling back to `xUrl`), then YouTube
  (`youtubeUrl`) and Bilibili (first `bilibili.com` resource) as round logo-only
  buttons with VoiceOver platform names (the profile card is the deliberate
  exception to the logo-and-name link rule in [Design](../development/design.md)).
  Narrow cards try tighter spacing, cap link text at extra-large then large
  sizes, and scale handles before wrapping only at accessibility text sizes.
  Images are decorative; VoiceOver reads the display name once as a heading.
- **Spotlight ticket and Bilibili live:** Shows `projection.spotlight` (live,
  next with countdown and links, or latest video). Bilibili `liveNow` renders
  its own card when not in the spotlight.
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
- **Freshness footer:** One line showing last collection time and status
  summary, turning orange with a warning symbol when the last run failed or any
  source is over a day old. Tapping opens a detail sheet with per-source read
  times and device check time.

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

## More

Pushes **Journey**, **Works**, and **LINE BLOG** onto the More tab's
`NavigationStack`, followed by **Settings** (Notifications status, Content
Language menu, system App Language / Language & Region link) and **About**
(unofficial project statement, links to web board and `kano-navi` repository,
`AboutCredits.models` list, and app version).

## Related Docs

- [API and caching](api-and-caching.md)
- [Archives](archives.md)
- [Media and viewer](media-and-viewer.md)
- [Design and interaction](../development/design.md)
