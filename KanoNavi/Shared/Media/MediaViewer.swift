import SwiftUI

/// A full-screen viewer that pages through pictures.
///
/// Present it with `mediaViewer(item:in:source:label:caption:)`:
///
///     @State private var opened: JourneyPicture?
///
///     grid
///         .mediaViewer(item: $opened, in: pictures) { picture in
///             MediaImageSource(url: picture.url, width: picture.width, height: picture.height)
///         } label: { picture in
///             Text(picture.title)
///         } caption: { picture in
///             VStack(alignment: .leading) {
///                 Text(picture.title).font(.headline)
///                 Link(destination: picture.sourcePage) { Text(.Journey.source) }
///             }
///         }
///
/// - Swipe sideways to turn the page; pinch or double tap to zoom and drag
///   to move the picture while zoomed; drag down, tap Close or use the
///   VoiceOver escape gesture to close. A tap hides and shows the bars.
/// - Each page loads the copy that fits the screen and shows a smaller copy
///   already in memory, such as the thumbnail, meanwhile. A missing file
///   says so; the caption stays, so keep the provenance link in it.
/// - The viewer is always dark, so `caption` is drawn in the dark
///   appearance: use semantic styles (`.primary`, `.secondary`) in it. A
///   caption taller than two fifths of the screen scrolls.
/// - `label` is what VoiceOver reads for the picture.
struct MediaViewer<Item: Identifiable, Caption: View>: View {
    private let items: [Item]
    private let source: (Item) -> MediaImageSource
    private let label: (Item) -> Text
    private let caption: (Item) -> Caption

    @State private var currentID: Item.ID?
    @State private var showsBars = true
    @State private var isZoomed = false
    @State private var drag = MediaViewerDismissDrag()
    @State private var height: CGFloat = 0

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverOn

    /// A viewer over `items` that opens on the item with the ID `start`.
    init(
        items: [Item], startingAt start: Item.ID, source: @escaping (Item) -> MediaImageSource,
        label: @escaping (Item) -> Text, @ViewBuilder caption: @escaping (Item) -> Caption
    ) {
        self.items = items
        self.source = source
        self.label = label
        self.caption = caption
        _currentID = State(initialValue: start)
    }

    var body: some View {
        let index = items.firstIndex { $0.id == currentID }
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items) { item in
                    MediaViewerPage(
                        source: source(item), label: label(item), isZoomed: $isZoomed, tap: toggleBars
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentID)
        .scrollIndicators(.hidden)
        .scrollDisabled(isZoomed || drag.isActive)
        .ignoresSafeArea()
        .offset(y: drag.translation)
        .simultaneousGesture(dismissDrag, isEnabled: isZoomed == false)
        .background {
            Color.black
                .opacity(1 - 0.6 * drag.progress)
                .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            MediaViewerTopBar(position: (index ?? 0) + 1, count: items.count, close: close)
                .opacity(barsOpacity)
        }
        .overlay(alignment: .bottom) {
            if let index {
                MediaViewerCaptionBar(maxHeight: height * 0.4) {
                    caption(items[index])
                }
                .opacity(barsOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: barsOpacity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            height = newHeight
        }
        .environment(\.colorScheme, .dark)
        .presentationBackground(.clear)
        .accessibilityAction(.escape, close)
    }

    /// The bars stay for VoiceOver, which cannot tap the picture to bring
    /// them back, and hide while the viewer is pulled down.
    private var barsOpacity: Double {
        (showsBars || isVoiceOverOn) && drag.isActive == false ? 1 : 0
    }

    private var dismissDrag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                drag.update(translation: value.translation)
            }
            .onEnded { value in
                if drag.closes(predicted: value.predictedEndTranslation) {
                    close()
                } else {
                    withAnimation(.snappy(duration: 0.3)) {
                        drag = MediaViewerDismissDrag()
                    }
                }
            }
    }

    private func toggleBars() {
        showsBars.toggle()
    }

    private func close() {
        dismiss()
    }
}

#Preview {
    let items = (1...3).map { number in
        MediaViewerPreviewItem(
            id: number, url: URL(string: "https://example.com/media/journey/\(number).jpg")!)
    }
    MediaViewer(items: items, startingAt: 2) { item in
        MediaImageSource(url: item.url, width: 800, height: 1200)
    } label: { item in
        Text(verbatim: "Picture \(item.id)")
    } caption: { item in
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: "Picture \(item.id)")
                .font(.headline)
            Text(verbatim: "Credit line")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .environment(\.mediaImageLoader, MediaImageLoader { _ in throw MediaImageError.unavailable })
}
