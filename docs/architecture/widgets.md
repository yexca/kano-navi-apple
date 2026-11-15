# Widgets

`KanoNaviWidgets` provides the calendar widgets on iPhone, iPad, and macOS.

## Widget Families and Layouts

- **Upcoming** (`systemSmall`, `systemMedium`, `systemLarge`, and
  `systemExtraLarge` on iPadOS and macOS) leads with the active live entry, or
  the next non-cancelled upcoming entry:
  - **Small:** State capsule (`● Live` on red or `Next`), countdown for today
    or Japan day for later entries, title (up to three lines), and large JST
    time (or `Ends` and end time while live).
  - **Medium:** Lead entry plus a divider and up to three following entries with
    day, time, and title.
  - **Large:** Header with avatar, "This Week", and JST date range; seven-day
    Japan strip starting today (today filled, up to three tag-colored dots per
    day); lead entry card; and remaining entries grouped under compact day
    headings fitting available height.
  - **Extra Large:** Wide header and seven-day strip above a two-column split
    pairing the lead card with the remaining weekly entries.
  - **Accessibility text sizes:** Medium, Large, and Extra Large switch to a
    day-grouped list with time above title under an "Upcoming" header. Lead
    time and state rows cap scaling at large text sizes to preserve title
    space.
- **Lock Screen** (`accessoryRectangular`, `accessoryInline`) on iOS and iPadOS
  shows the next entry and its JST time; rectangular layout caps text scaling
  at `xxxLarge` to keep three fixed lines readable.

## Visual Style and Shared Views

- Home Screen widgets use the Berry accent (`#DC4560` light, `#FF7088` dark)
  for capsules and today's marker, cream-to-pink or plum gradients, rounded
  system typography, and tag-colored entry times matching `ScheduleTag` (dimmed
  when done or cancelled).
- Accented/tinted rendering removes the background, switches colors to primary
  style, and collapses the week strip to one dot per day while keeping titles
  and status marks legible.
- Shared views (`KanoNaviComponents`) render JST times, dates, and live state;
  compact one-word sale, members, and cancellation capsules remain
  widget-specific to preserve title space in single-line rows.
- Unavailable, empty, and cached states each fit in one short line; cached
  snapshots show a cloud mark and `As of <JST time>` (mark alone in small and
  rectangular layouts).

## Timeline Provider, Caching, and Deep Links

- `UpcomingProvider` queries `/api/calendar` directly via `CalendarReader` for
  today through 13 Japan days ahead using the widget extension's own cache
  directory, requiring no App Group. Failed reads fall back to cached pages
  marked stale (`isStale`).
- Timeline entries regenerate at each entry start time and sale open/close
  boundary, requesting reload at the next transition or within 30 minutes,
  whichever comes first.
- `UpcomingConfigurationIntent` (`AppIntentConfiguration`) provides an
  independent **Content Language** parameter because widgets do not share
  `AppSettings` across an App Group.
- Tapping an entry opens `kanonavi://event/<id>`; tapping a day in the strip
  opens `kanonavi://schedule?date=<YYYY-MM-DD>`; tapping elsewhere opens
  today's date in **Schedule**.

## Related Docs

- [Board and timelines](board-and-timelines.md)
- [Notifications](notifications.md)
- [Targets and platforms](targets-and-platforms.md)
