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
/// - On macOS a trackpad swipe, the arrow keys or the buttons at the sides
///   turn the page, a pinch or a double click zooms, and Esc or Close
///   closes; a drag does not close it.
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
    /// Whether the viewer is being pulled down to close.
    @State private var isPulled = false
    @State private var height: CGFloat = 0
    @FocusState private var isFocused: Bool

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
        .scrollDisabled(isZoomed || isPulled)
        .ignoresSafeArea()
        .modifier(
            MediaViewerDismissGesture(
                isEnabled: Self.closesOnDrag && isZoomed == false, isActive: $isPulled, close: close)
        )
        .overlay(alignment: .top) {
            MediaViewerTopBar(position: (index ?? 0) + 1, count: items.count, close: close)
                .barOpacity(barsOpacity)
        }
        .overlay {
            #if os(macOS)
                if items.count > 1, let index {
                    MediaViewerPageButtons(
                        hasPrevious: index > 0, hasNext: index < items.count - 1, turn: turnPage
                    )
                    .barOpacity(barsOpacity)
                }
            #endif
        }
        .overlay(alignment: .bottom) {
            if let index {
                MediaViewerCaptionBar(maxHeight: height * 0.4) {
                    caption(items[index])
                }
                .barOpacity(barsOpacity)
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            height = newHeight
        }
        .environment(\.colorScheme, .dark)
        .presentationBackground(.clear)
        .accessibilityAction(.escape, close)
        #if os(macOS)
            .focusable()
            .focusEffectDisabled()
            .focused($isFocused)
            .onKeyPress(.leftArrow) {
                turnPage(by: -1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                turnPage(by: 1)
                return .handled
            }
            .onAppear {
                isFocused = true
            }
        #endif
    }

    /// A Mac has no pull-down gesture for a sheet, and a drag there pans a
    /// zoomed picture or does nothing.
    private static var closesOnDrag: Bool {
        #if os(iOS)
            true
        #else
            false
        #endif
    }

    /// The bars stay for VoiceOver, which cannot tap the picture to bring
    /// them back, and hide while the viewer is pulled down.
    private var barsOpacity: Double {
        (showsBars || isVoiceOverOn) && isPulled == false ? 1 : 0
    }

    /// Shows the picture `step` places away, unless the picture is zoomed,
    /// as a swipe does.
    private func turnPage(by step: Int) {
        guard isZoomed == false, let index = items.firstIndex(where: { $0.id == currentID }) else { return }
        let target = index + step
        guard items.indices.contains(target) else { return }
        withAnimation(.snappy(duration: 0.3)) {
            currentID = items[target].id
        }
    }

    private func toggleBars() {
        showsBars.toggle()
    }

    private func close() {
        dismiss()
    }
}

extension View {
    /// Fades a bar of the viewer in and out. The animation covers the
    /// opacity alone, so it never takes over the pages' own motion, such as
    /// a pull springing back.
    fileprivate func barOpacity(_ opacity: Double) -> some View {
        animation(.easeInOut(duration: 0.2)) { $0.opacity(opacity) }
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
