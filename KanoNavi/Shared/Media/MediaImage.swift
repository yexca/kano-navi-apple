import SwiftUI

/// An image from the service's media route (`/media/journey/…`,
/// `/media/works/…`, `/media/lineblog/…`).
///
///     MediaImage(MediaImageSource(url: cover.url, width: cover.width, height: cover.height),
///                label: Text(cover.caption))
///
///     MediaImage(decorative: source, contentMode: .fill, anchor: UnitPoint(objectPosition: focus) ?? .center)
///         .aspectRatio(1, contentMode: .fit)
///         .clipShape(.rect(cornerRadius: 8))
///
/// - **Shape.** With `.fit` (the default) the view takes the width it is
///   offered and the height the source's pixel size gives, before the file
///   arrives, so a list does not jump. Without a known size it holds a 3:2
///   box until the file is read. With `.fill` it fills the frame the caller
///   gives it and crops, keeping `anchor` in view as CSS `object-position`
///   does.
/// - **Copy.** It asks for the smallest copy the media route offers that
///   covers the pixels drawn, decodes it to that size off the main actor,
///   and shows a smaller copy already in memory meanwhile. An image already
///   in memory is drawn in the same frame as its box; with
///   `\.mediaImageDecodesCachedFilesAtOnce`, so is one the disk cache holds.
///   One that has to load fades in over a placeholder of its final size.
/// - **States.** A file the server does not have (404 `media_not_found`) or
///   cannot be read draws "Image unavailable"; a failed fetch draws a Try
///   Again button. The caller adds the provenance link beside it.
/// - **Accessibility.** Pass `label` for an image that carries meaning, or
///   use `init(decorative:)` to hide it from VoiceOver.
struct MediaImage: View {
    private let source: MediaImageSource
    private let label: Text?
    private let mode: MediaImageRequest.Mode
    private let anchor: UnitPoint

    @Environment(\.mediaImageLoader) private var loader
    @Environment(\.mediaImageDecodesCachedFilesAtOnce) private var decodesCachedFilesAtOnce
    @Environment(\.displayScale) private var displayScale
    @State private var size = CGSize.zero
    @State private var phase = MediaImagePhase.loading
    @State private var attempt = 0

    /// The box held for a fitted image whose shape is not known yet.
    private static let placeholderAspectRatio: CGFloat = 3 / 2

    /// An image VoiceOver reads as `label`.
    init(
        _ source: MediaImageSource, label: Text, contentMode: ContentMode = .fit, anchor: UnitPoint = .center
    ) {
        self.source = source
        self.label = label
        mode = contentMode == .fit ? .fit : .fill
        self.anchor = anchor
    }

    /// An image VoiceOver skips, such as a cover beside its own title.
    init(decorative source: MediaImageSource, contentMode: ContentMode = .fit, anchor: UnitPoint = .center) {
        self.source = source
        label = nil
        mode = contentMode == .fit ? .fit : .fill
        self.anchor = anchor
    }

    var body: some View {
        box
            .overlay {
                MediaImagePicture(image: phase.image, mode: mode, anchor: anchor)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(label ?? Text(verbatim: ""))
                    .accessibilityValue(statusText)
                    .accessibilityAddTraits(.isImage)
                    .accessibilityHidden(label == nil)
            }
            .overlay {
                MediaImageStatus(phase: phase, retry: retry)
            }
            .clipped()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                size = newSize
                showCachedImage()
            }
            .onChange(of: source) {
                phase = .loading
                showCachedImage()
            }
            .task(id: MediaImageLoadID(request: request, attempt: attempt)) {
                await load()
            }
    }

    /// The space the image is drawn in: the picture's own shape when
    /// fitted, the whole frame the caller gives when filling. (An
    /// `aspectRatio` without a ratio would hold the fill box to a square.)
    @ViewBuilder private var box: some View {
        if mode == .fit {
            Color.clear.aspectRatio(aspectRatio, contentMode: .fit)
        } else {
            Color.clear
        }
    }

    /// Width over height of the box a fitted image holds.
    private var aspectRatio: CGFloat {
        if let known = source.aspectRatio {
            return known
        }
        if let image = phase.image, image.height > 0 {
            return CGFloat(image.width) / CGFloat(image.height)
        }
        return Self.placeholderAspectRatio
    }

    /// The load for the size on screen, or `nil` before layout.
    private var request: MediaImageRequest? {
        guard size.width > 0, size.height > 0 else { return nil }
        return MediaImageRequest(source: source, size: size, displayScale: displayScale, mode: mode)
    }

    private var statusText: Text {
        switch phase {
        case .unavailable: Text(.Media.imageUnavailable)
        case .failed: Text(.Media.imageFailed)
        case .loading, .loaded: Text(verbatim: "")
        }
    }

    /// Shows the image for the size on screen at once when it is cached, so
    /// it is drawn in the same frame as its box: from memory always, and
    /// decoded from the disk cache when the screen asks for that and nothing
    /// is drawn yet.
    private func showCachedImage() {
        guard let request,
            let image = loader.cachedImage(
                for: request, decodingFromDisk: decodesCachedFilesAtOnce && phase.image == nil)
        else {
            return
        }
        phase = .loaded(image)
    }

    private func load() async {
        guard let request else { return }
        if let image = loader.memory.image(for: request) {
            phase = .loaded(image)
            return
        }
        if phase.image == nil, let smaller = loader.memory.largestImage(of: source.url) {
            phase = .loaded(smaller)
        }
        do {
            let image = try await loader.image(for: request)
            withAnimation(.easeOut(duration: 0.15)) {
                phase = .loaded(image)
            }
        } catch MediaImageError.unavailable {
            phase = .unavailable
        } catch is MediaImageError {
            phase = .failed
        } catch {
            // Cancelled: the view went away or its size changed.
        }
    }

    private func retry() {
        phase = .loading
        attempt += 1
    }
}

#Preview("Fit, loading box") {
    let source = MediaImageSource(
        url: URL(string: "https://example.com/media/journey/preview.jpg")!, width: 800, height: 1200)
    ScrollView {
        MediaImage(source, label: Text(verbatim: "Key visual"))
            .padding()
    }
    .environment(\.mediaImageLoader, MediaImageLoader { _ in throw MediaImageError.failed })
}

#Preview("Fill, unavailable") {
    let source = MediaImageSource(url: URL(string: "https://example.com/media/works/missing.jpg")!)
    MediaImage(decorative: source, contentMode: .fill, anchor: .top)
        .frame(width: 160, height: 160)
        .clipShape(.rect(cornerRadius: 8))
        .environment(\.mediaImageLoader, MediaImageLoader { _ in throw MediaImageError.unavailable })
}
