import SwiftUI

/// An archived picture of an article in its row.
///
/// - It is fetched once it scrolls into view: the reader lays an article
///   out whole, so otherwise every picture of a long article would load
///   when it opens. A box of the picture's shape holds its place until
///   then, so nothing moves when the file arrives.
/// - Once it has loaded it is a button that opens it in the viewer.
/// - A picture the server does not have says so, and one whose fetch
///   failed offers Try Again; neither opens the viewer. VoiceOver reads
///   the state as the picture's value and reaches the button.
struct LineBlogFigurePicture: View {
    let picture: LineBlogPicture
    /// A square, cropped thumbnail instead of the whole picture.
    let isThumbnail: Bool
    let open: (LineBlogPicture) -> Void

    @State private var load = LineBlogPictureLoad()
    @State private var hasBeenSeen = false
    @State private var size = CGSize.zero
    @State private var attempt = 0
    @Environment(\.mediaImageLoader) private var loader
    @Environment(\.displayScale) private var displayScale

    /// The shape `MediaImage` holds for a picture of unknown size.
    private static let unknownAspectRatio: CGFloat = 3 / 2

    var body: some View {
        content
            .clipShape(.rect(cornerRadius: 8))
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                size = newSize
            }
            .onScrollVisibilityChange(threshold: 0.01) { isVisible in
                if isVisible {
                    hasBeenSeen = true
                }
            }
            .task(id: MediaImageLoadID(request: request, attempt: attempt)) {
                guard let request else { return }
                await load.load(request, with: loader)
            }
    }

    @ViewBuilder private var content: some View {
        switch load.phase {
        case .loaded:
            Button(action: openPicture) {
                if isThumbnail {
                    MediaImage(decorative: picture.source, contentMode: .fill)
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    MediaImage(decorative: picture.source)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(LineBlogPictureLabel.text(for: picture))
            .accessibilityAddTraits(.isImage)
            .accessibilityHint(Text(.LineBlog.openPictureHint))
        case .waiting:
            placeholder(value: nil)
        case .unavailable:
            placeholder(value: .Media.imageUnavailable)
                .overlay {
                    MediaImageStatusMark(symbol: "photo.badge.exclamationmark", text: .Media.imageUnavailable)
                        // The picture's accessibility value already says it.
                        .accessibilityHidden(true)
                }
        case .failed:
            placeholder(value: .Media.imageFailed)
                .accessibilitySortPriority(1)
                .overlay {
                    Button(action: retry) {
                        MediaImageStatusMark(symbol: "arrow.clockwise", text: .Media.imageRetry)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(.Media.imageRetry))
                }
                // The picture and its state are read before the button.
                .accessibilityElement(children: .contain)
        }
    }

    /// The box that holds the picture's place, read by VoiceOver as the
    /// picture with its state.
    private func placeholder(value: LocalizedStringResource?) -> some View {
        Rectangle()
            .fill(.fill.tertiary)
            .aspectRatio(
                isThumbnail ? 1 : picture.source.aspectRatio ?? Self.unknownAspectRatio, contentMode: .fit
            )
            .accessibilityElement()
            .accessibilityLabel(LineBlogPictureLabel.text(for: picture))
            .accessibilityValue(value.map { Text($0) } ?? Text(verbatim: ""))
            .accessibilityAddTraits(.isImage)
    }

    /// The load for the size on screen, the same one the picture's
    /// `MediaImage` asks for, so the file is fetched and decoded once.
    /// `nil` before the picture has been seen and laid out.
    private var request: MediaImageRequest? {
        guard hasBeenSeen, size.width > 0, size.height > 0 else { return nil }
        return MediaImageRequest(
            source: picture.source, size: size, displayScale: displayScale, mode: isThumbnail ? .fill : .fit)
    }

    private func openPicture() {
        open(picture)
    }

    private func retry() {
        attempt += 1
    }
}
