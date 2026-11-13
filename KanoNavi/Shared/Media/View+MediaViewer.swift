import SwiftUI

extension View {
    /// Presents the full-screen image viewer over `items` while `item` is
    /// set, opening on that item; closing the viewer sets it back to `nil`.
    /// See `MediaViewer` for what the viewer does and what `caption` should
    /// hold.
    ///
    /// - Parameters:
    ///   - item: The picture to open on, usually set by a thumbnail's button.
    ///   - items: Every picture the viewer pages through, in order.
    ///   - source: The image file of a picture.
    ///   - label: What VoiceOver reads for a picture.
    ///   - caption: The area under a picture: title, credit, provenance link.
    func mediaViewer<Item: Identifiable, Caption: View>(
        item: Binding<Item?>, in items: [Item], source: @escaping (Item) -> MediaImageSource,
        label: @escaping (Item) -> Text, @ViewBuilder caption: @escaping (Item) -> Caption
    ) -> some View {
        fullScreenCover(item: item) { start in
            MediaViewer(items: items, startingAt: start.id, source: source, label: label, caption: caption)
        }
    }
}
