# KanoNaviKit

`KanoNaviCore` is the Foundation-only data layer used by the app and widget.
`APIClient` sends typed `APIRequest` values to the configured HTTPS service,
revalidates cached responses with ETags, and maps failures to `APIError`.

The model types mirror the public API: `Dashboard`, `ScheduleEvent`, `Video`,
`Post`, `CalendarPage`, archive pages/month indexes, `HealthResponse`,
`RevisionResponse`, and `WorksUploadsResponse`. `DashboardProjection` and the
record `view` values are required for a current dashboard response; an absent
projection or a version other than 1 is incompatible.

The archive reads have their own requests and responses: `JourneyRequest` →
`JourneyResponse`, `WorksRequest` → `WorksResponse`, `WorksUploadListRequest` →
`WorksUploadListResponse` (joined with `WorksUploadsResponse` by upload ID),
`LineBlogIndexRequest` → `LineBlogIndexResponse`, `LineBlogPostRequest(id:)` →
`LineBlogPostResponse` and `LineBlogCommentsRequest(articleID:)` →
`LineBlogCommentsResponse`, with matching `APIClient` methods (`journey()`,
`works()`, `worksUploadList()`, `lineBlog()`, `lineBlogPost(id:)`,
`lineBlogComments(articleID:)`). An article ID that is not an article number
fails validation with `RequestValidationError.invalidArticleID` before
anything is sent. Localized archive text is a `LocalizedText`;
`resolved(for:fallback:)` returns a `LocalizedTextResolution` with the text and
the language it is in, falling back in `LocalizedText.defaultFallback` order
(English, Japanese, Chinese) or `japaneseOriginalFallback` for LINE BLOG.
`JourneyDate` keeps a milestone date's precision. LINE BLOG articles are
`LineBlogBlock` and `LineBlogInline` enums whose unknown types decode as
`.unknown(type:)`. `PlatformVideoIDs.links` builds niconico, YouTube and
Bilibili watch pages from a track's `listen` or an upload's IDs. Media `url`s
resolve against the API base URL; provenance addresses stay as the API gives
them.

`FileResponseCache` stores raw bodies, ETags, and fetch times as one JSON file
per request, which a later launch reads back for ETag revalidation and offline
fallback; an unreadable file is removed. Inject `MemoryResponseCache` or
another `ResponseCache` in tests.

`CalendarReader` loads all pages of a range, merges them in server order,
builds the widget range, and returns a Monday-first six-week month grid. When
the service cannot be read and every page of the range is cached, it returns
the cached pages and says so: `readResult(from:to:)` returns a
`CalendarReadResult` with `isFromCache` and `fetchedAt` (the end of a fresh
read, or the oldest cached page's fetch time), and `month(containing:)` and
`widgetRange(today:now:)` carry the same facts as `isStale` and `fetchedAt` in
`ScheduleMonthResult` and `WidgetCalendarResult`. `cachedResult(from:to:)`
returns the cached range without asking the service, or `nil` when a page is
missing, for a screen to show while its first read runs. `read(from:to:)` returns
the page alone. With nothing cached, the service's error is thrown.
`APIClient.readResult(_:)` reads any one request the same way and returns a
`ReadResult` with the value, `isFromCache` and `fetchedAt`; cancellation and an
invalid request are never answered from the cache.

`JapanDate` represents a Tokyo calendar date, while `JapanTime` supplies Tokyo
`Date.FormatStyle` values. `ContentLanguageResolver` resolves translated copy
for `.system`, English, Japanese, or Simplified Chinese and preserves Japanese
source wording. `DisplayCodeLabels` returns `LocalizedStringResource` values
backed by the package String Catalog.

`DashboardStore` is `@MainActor @Observable`. Call `start()` for an active
scene, `stop()` when it leaves the foreground, and `refresh()` for pull to
refresh. Its `snapshot`, `phase`, `fetchedAt`, `source`, and `isIncompatible`
properties let screens retain stale data while showing a failure state.
`source` is `.cache` for the snapshot read from the cache at launch and
`.network` after a successful refresh; a failed refresh leaves it unchanged, so
`.cache` with a `.failed` phase means the cached snapshot could not be
refreshed.

`KanoNaviComponents` holds the SwiftUI pieces the app and the widgets share:
`EventRow`, `EventTicketRow` (an entry as a ticket: a stub with the large JST
time and a relative phrase from `EventTicketTiming`, read at an instant the
container passes, beside the title and one line of marks), `EventChips`, `EventStateBadge`, `LiveIndicator`, `MembersChip`,
`SaleChip`, `PlatformMark`, `TranslationMark` and `JSTTimeLabel`, the
`ComponentChip` capsule they share (for other labels in the same look, such as
a video's form, tag or availability) and the wrapping `FlowLayout`, plus
`JSTTimeFormat` for Japan-time text and presentation facts on `ScheduleEvent`
(`displayState`, `isMembersOnly`, `isConfirmed`, `displayCalendarEntries`,
`resolvedTitle`). They have no interactive controls, UIKit or navigation, so
they render in WidgetKit; the container decides what a tap does. Code labels
come from `DisplayCodeLabels`; the few words the components add live in the
module's own String Catalog.
