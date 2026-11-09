# KanoNaviKit

`KanoNaviCore` is the Foundation-only data layer used by the app and widget.
`APIClient` sends typed `APIRequest` values to the configured HTTPS service,
revalidates cached responses with ETags, and maps failures to `APIError`.

The model types mirror the public API: `Dashboard`, `ScheduleEvent`, `Video`,
`Post`, `CalendarPage`, archive pages/month indexes, `HealthResponse`,
`RevisionResponse`, and `WorksUploadsResponse`. `DashboardProjection` and the
record `view` values are required for a current dashboard response; an absent
projection or a version other than 1 is incompatible.

`FileResponseCache` stores raw bodies, ETags, and fetch times. Inject
`MemoryResponseCache` or another `ResponseCache` in tests. `CalendarReader`
loads all pages, merges them in server order, builds the widget range, and
returns a Monday-first six-week month grid.

`JapanDate` represents a Tokyo calendar date, while `JapanTime` supplies Tokyo
`Date.FormatStyle` values. `ContentLanguageResolver` resolves translated copy
for `.system`, English, Japanese, or Simplified Chinese and preserves Japanese
source wording. `DisplayCodeLabels` returns `LocalizedStringResource` values
backed by the package String Catalog.

`DashboardStore` is `@MainActor @Observable`. Call `start()` for an active
scene, `stop()` when it leaves the foreground, and `refresh()` for pull to
refresh. Its `snapshot`, `phase`, `fetchedAt`, and `isIncompatible` properties
let screens retain stale data while showing a failure state.
