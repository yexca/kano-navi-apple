# Notifications

Local notifications and scheduled reminders run entirely on device through
`UNUserNotificationCenter` (`KanoNavi/Notifications/` and
`KanoNaviCore/Notifications/`) with no remote push server, device tokens, or App
Group, keeping unsigned and ad-hoc builds functional.

Authorization is requested only when the user enables **Allow Notifications**
in **More → Settings → Notifications**, never at launch.

## Baseline and Backfill Guard

`FileNotificationStateStore` persists seen post IDs, video IDs, event
snapshots, and live broadcast IDs in Application Support
(`MemoryNotificationStateStore` in tests). `NotificationPlanner` evaluates diffs
deterministically without importing UIKit or `UserNotifications`. Recording the
initial snapshot or re-enabling notifications seeds the baseline without
posting banners. Subsequent checks ignore posts and non-reservation videos
published more than 24 hours earlier so archive backfills never flood alerts.

## Immediate Alerts

Evaluated during background refresh runs (reading `/api/dashboard?days=7` and
the 14-day calendar range) and suppressed while a scene is active so foreground
browsing advances the baseline silently:

- **Live Now:** A scheduled entry entering `live` or an unannounced Bilibili
  `liveNow` stream.
- **Posts:** Individual toggles for Kano's own X posts, Bilibili posts, and
  promoted related-account posts (`view.promoted`).
- **Videos:** Individual toggles for Works (`work`), Shorts (`short`), and
  Stream Archives (`archive`, off by default). Reservations (`reservation`) are
  skipped because they map to schedule entries.
- **Schedule Updates:** Newly added entries, cancellations, and time changes,
  filtered by category (`stream`/`member`, `event`, `release`, `sale`) and an
  optional **Confirmed Entries Only** toggle.
- **Members-only:** Global toggle controlling members-only streams, videos, and
  reminders (on by default).

Each thread (`live`, `posts`, `videos`, `schedule`) posts at most three banners
per evaluation; four or more updates send the two newest plus a summary banner.

## Background Refresh

- **iOS / iPadOS:** `BackgroundRefreshScheduler` registers and schedules a
  `BGAppRefreshTask` (`<bundle-id>.refresh`) at least 15 minutes ahead.
- **macOS:** `SystemBackgroundRefreshScheduler` queues an
  `NSBackgroundActivityScheduler` task running roughly every 15–22 minutes
  while the app is open (with or without a visible window). macOS always reports
  background refresh as available, so the system-setting warning appears only
  on iOS/iPadOS.

Each run queues the next task on completion.

## Timed Reminders

`UNCalendarNotificationTrigger` requests (capped at the 48 nearest future
triggers) are rebuilt from the 14-day calendar window whenever notifications are
enabled and a new dashboard snapshot arrives, on foreground entry, and on
background entry (before scheduling the next refresh). Cached calendar pages
stand in while the fetch runs or if it fails; concurrent reads for one
dashboard revision coalesce, and results older than the latest snapshot are
discarded.

- **Streams and events:** Off, at start, 10 minutes before, or 30 minutes
  before (`startsAt` in JST, skipping cancelled or past entries).
- **Merchandise sales:** Sale opening (`sale_start`) and closing (`sale_end`:
  off, 1, 6, or 24 hours before). Date-only sale occurrences fire relative to
  `09:00 JST` on that Japan date.
- Notification titles follow the interface language and item titles follow the
  content language; changing either rebuilds pending reminders.

## Debugging

`NotificationController.performBackgroundRefresh()` logs revision, immediate
alert count, and scheduled reminder count through `os.Logger` (bundle ID
subsystem, `notifications` category). Debug builds expose **Run Background Check
(Debug)** in notification settings, executing a background check roughly five
seconds after the app enters the background (or closes its window on macOS). On
iOS, a real `BGAppRefreshTask` can also be simulated from LLDB after leaving the
app:

```text
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.yexca.kanonavi.refresh"]
```

## Deep Links

`NotificationRoute` and `AppRouter` handle `kanonavi://` URLs:

- `kanonavi://now`
- `kanonavi://posts`
- `kanonavi://videos`
- `kanonavi://event/<id>`
- `kanonavi://schedule?date=<YYYY-MM-DD>`
- `kanonavi://settings/notifications`

On iOS cold launches, `AppDelegate` extracts launch URL contexts or tapped
notification `routeURL` payloads during scene configuration so the first frame
opens directly on the target tab and focus; `AppRouter` deduplicates the
subsequent SwiftUI `onOpenURL` delivery once and clears that guard when leaving
the foreground.

## Related Docs

- [API and caching](api-and-caching.md)
- [Widgets](widgets.md)
- [Targets and platforms](targets-and-platforms.md)
