# Archives

The **Journey**, **Works**, and **LINE BLOG** archive screens open from the
**More** tab and load whole documents via `DocumentModel`
(`KanoNavi/Shared/Document/`).

## Journey

Reads `/api/journey` into a segmented **Timeline** and **Gallery** under a
pinned horizontal row of identity chips (`safeAreaBar` with hard scroll edge):

- **Identity filter and footer:** Shows **All** plus each branch with its
  portrait (or person symbol in its tone ring), name, and item count. Tapping
  the active chip returns to **All**. Both views close with the verified-through
  date and an info button presenting the hand-curation and image-rights notices.
- **Timeline:** Oldest-first milestones grouped by Japan year (navigation
  subtitle tracks the topmost year and filtered count). Markers carry kind
  symbols on branch-toned lines; dates preserve `JourneyDate` precision plus
  `dateEnd` and `dateNote`. Highlights show filled markers, tinted cards, and
  "Key milestone". Rows display up to three detail lines and up to three
  thumbnails (`+N`).
- **Milestone page:** Full date, whole detail text, sized images opening the
  viewer, **Source and Links** (or "Third-party stream archive"), and **View in
  Works** when `releaseId` is present (invoking `journeyOpenRelease` from the
  More stack environment). Missing milestones after a reload show "Milestone
  Not Found".
- **Gallery:** Deduplicates images in timeline order (milestone images, release
  covers, gallery-only images) with a category filter (artwork, models,
  merchandise, video frames, covers, and fallback categories). Square
  thumbnails crop around `focus` and mark cancelled release covers.
- **Viewer captions, codes, and tones:** Captions include marks (Release
  cancelled, Third-party file), title, cover caption, labelled `dateKind` (or
  "Date unverified"), creator/scan credits, publisher credit, source/video/stream
  links, and a **Details** sheet for `sourceKind`, frame time, and provenance
  note. `Journey.xcstrings` localizes codes with neutral fallbacks and omits
  unknown notes. `JourneyColors.xcassets` (`honey`, `leaf`, `berry`,
  `lavender`, `sky`) maintains ≥ 4.5:1 contrast across backgrounds, 14% tags,
  and 8% highlight rows.

## Works

Entry screen reads `/api/works`, `/api/works/upload-list`, and
`/api/works/uploads` once per visit and shares them down the stack. Upload reads
enrich the view without blocking or blanking the base collection when they
fail:

- **Entry:** Displays year span, counts for **Own Releases**, **Featured On**,
  and **Uploads**, a toolbar info sheet (coverage date and rights notice),
  **Latest Uploads** (four newest cards: `recent` videos then collection
  uploads), and **On This Day** (past releases, featured works, and uploads
  matching today's Japan month and day; February 29 works appear on February 28
  in non-leap years).
- **Own Releases:** Year-grouped cover grid (rows at accessibility sizes) with
  a pinned format filter (`All`, `Album`, `Single`, `EP`, `Doujin`, `Other`) and
  sort toggle (newest/oldest first).
- **Release (`WorksReleaseScreen(releaseID:)`):** Independently loads `/api/works`
  so Journey links push directly, showing "Release Not Found" with **Try Again**
  only after a fresh read completes. Shows covers, metadata, shared disc track
  lists with watch links from `listen`, disc photos, edition sections (folding
  track lists and disc photos unless different from shared), store bonuses, and
  streaming/download stores with Hi-Res marks. All release images share one
  deduplicated viewer list with linked contributor credits.
- **Featured On:** Participation works by year ("Work Not Found" if absent),
  showing metadata, Kano's participated tracks and credits, folded full track
  list when longer, and source link.
- **Uploads:** Joins `/api/works/upload-list` with `/api/works/uploads` by
  upload ID; pinned kind filter, search (song, original artist, collaborators,
  albums, compilation songs, Bilibili title), optional Bilibili title display
  when content language is Chinese, platform watch links (`niconico`, `YouTube`,
  members-only `YouTube`, `Bilibili`), unavailability marks (marking a row "No
  Longer Watchable" only when every listed watch page is stored as removed or
  private), and a **Newer Uploads** header for `recent` items. Failed
  `/api/works/uploads` leaves the list intact with a one-line notice.

## LINE BLOG

Recovered 2015–2019 LINE BLOG archive across three `DocumentModel` screens:

- **Article list (`/api/lineblog`):** Newest-first articles grouped by Japan
  month with counts, a **Jump to Month** year/month menu, and an info sheet
  with original blog link, recovery context, and rights notice.
- **Reader (`/api/lineblog/posts/{id}`):** Renders title, JST timestamp, and
  blocks whole (non-lazy stack for accurate scroll metrics, 640 pt max column)
  while loading inline images lazily as they enter view:
  - *Paragraphs and pictographs:* Selectable text with underlined links
    (`articleId` pushes in-app; `http`/`https` opens outside) and inline
    Dynamic-Type-scaled pictographs (`emoji`) preloaded up front with `alt`
    fallback (retried once after 2 s on transient failure). Paragraphs holding a
    linked pictograph use a text renderer overlay and disable text selection so
    the pictograph remains tappable.
  - *Pictures:* Standalone figures (capped at 520 pt height) or two-column
    square grids opening `MediaViewer` across all archived article pictures
    with `alt`, recovery codes, and source/link URLs. Unavailable or uncaptured
    pictures keep original addresses without opening the viewer.
  - *Quotes, rules, link cards, and videos:* Link cards push `articleId` or open
    outside alongside archived capture links. Embedded videos with archived
    copies play inline via AVKit (same-host stream, sound enabled even with
    ring switch off, pausing when scrolled off-screen or when another video
    starts, deactivating the audio session off the main actor 0.4 s after
    playback ends on iOS). Checks system VP9/AV1 decoding support (VP9
    available from iOS 26.2) and displays "Can't play this video" when
    unsupported, keeping YouTube and archive capture links below.
  - *Translations and navigation:* Shows translated title and per-paragraph
    machine translations in English or Chinese with a toolbar toggle whenever
    any translation exists in that language. Closes with archived comment count,
    in-place **Older Article** / **Newer Article** swaps (`previousId` /
    `nextId`), and **Sources** links. Invalid or missing IDs show "Article Not
    Found" before requesting non-numeric paths.
- **Comments (`/api/lineblog/posts/{id}/comments`):** Newest-first selectable
  comments with number, writer name, JST timestamp, and star/face ratings (or
  "No Archived Comments").

## Related Docs

- [API and caching](api-and-caching.md)
- [Media and viewer](media-and-viewer.md)
- [Language](language.md)
