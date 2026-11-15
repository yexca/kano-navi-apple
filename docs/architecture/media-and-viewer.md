# Media and Viewer

All service-hosted images—Now profile banners, avatars, video covers, post
images, Journey artwork, Works covers, and LINE BLOG pictures—use the shared
loader and viewer in `KanoNavi/Shared/Media/`.

## Images

`MediaImage` renders a file from a `MediaImageSource` (an absolute URL resolved
against `API_BASE_URL` and, when known, the original pixel dimensions).

- **Shape.** A fitted image reserves the width offered and the height implied by
  its original aspect ratio before loading so lists do not jump; without known
  dimensions it holds a 3:2 box until decoded. A cropped image fills its
  container frame and aligns around a focus point (`UnitPoint(objectPosition:)`
  for Journey's CSS-style `focus`).
- **Copy selection.** `MediaImageVariant` selects the smallest server `w`
  variant from `kano-navi`'s
  [Resized Copies](https://github.com/yexca/kano-navi/blob/main/docs/architecture/media-cache.md#resized-copies)
  that covers the rendered pixel width (points × display scale; scaled width
  for cropped views) without exceeding the original's width. When original
  width is unknown or no variant qualifies, it requests the original without
  `w`. Because video covers omit pixel dimensions in the API, the video timeline
  treats them as 1920 × 1080 and requests the covering `w` variant (the server
  falls back to the original if smaller).
- **Loading and caching.** `MediaImageLoader` is an actor injected via the
  environment. It fetches through a dedicated `URLSession` backed by a 512 MB
  disk `URLCache` in the caches directory (archive assets are immutable and
  served from disk without revalidation once fetched), decodes off the main
  actor with ImageIO to the target size, and retains decoded images in a 128 MB
  LRU memory cache (`MediaImageMemoryCache`) that clears on memory warnings.
  Concurrent views requesting the same URL and size share one fetch and decode;
  in-flight work cancels when all waiting views disappear.
- **First-frame rendering.** When a view resolves its size, it checks the memory
  cache synchronously on the main actor to draw hits in the same frame. Launch
  screens (Now, Posts, Videos) set `\.mediaImageDecodesCachedFilesAtOnce` to
  decode disk-cached files synchronously; archive screens (Journey, Works, LINE
  BLOG) do not, fading in newly loaded images over a sized placeholder.
- **States.** Missing server files (`404 media_not_found`) and non-image bodies
  display "Image unavailable"; failed fetches display a **Try Again** button.
  Both keep the screen's provenance link beside the image.
- **Accessibility.** Images provide an explicit label or are marked decorative
  and hidden from VoiceOver; unavailable and failed states populate the
  accessibility value.

## Image Viewer

`mediaViewer(item:in:source:label:caption:)` presents `MediaViewer` full
screen (or as a large 1000 × 720 sheet on macOS) over a list of images, opening
at the selected item.

- **Gestures and controls.** Swiping sideways changes pages; pinch or double
  tap/click zooms, and dragging pans while zoomed without paging or dismissing.
  Close button, downward drag (iOS/iPadOS), `Esc` (macOS), and the VoiceOver
  escape gesture dismiss the viewer. Tapping toggles chrome visibility (bars
  remain visible under VoiceOver). On macOS, trackpad swipes, Left/Right Arrow
  keys, and Previous/Next chrome buttons turn pages.
- **Progressive loading.** Each page requests the `w` variant matching the
  viewer's screen width while displaying any smaller in-memory copy (such as the
  list thumbnail) as an immediate placeholder.
- **Captions.** The presenting screen supplies the caption below each image
  (title, credit, provenance link). The viewer always uses a dark appearance,
  and captions exceeding two fifths of the viewport scroll independently so the
  image remains visible at accessibility text sizes.

## Related Docs

- [API and caching](api-and-caching.md)
- [Board and timelines](board-and-timelines.md)
- [Archives](archives.md)
