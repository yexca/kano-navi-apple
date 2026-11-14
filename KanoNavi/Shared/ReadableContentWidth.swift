import SwiftUI

/// Keeps the content of a `ScrollView` or `List` in a centred column no
/// wider than a comfortable line of text, by adding equal safe-area padding
/// on both sides when the container is wider than that column. In a
/// narrower container, such as an iPhone or a slim iPad window, it adds
/// nothing.
///
/// Safe-area padding, unlike content margins, adds to the insets a list or
/// scroll view already has in the same way for both, including the sidebar's
/// inset beside it, so the column is centred in the area left to the
/// content. Backgrounds and pull to refresh still span the whole container.
/// The column grows with the text size, as UIKit's readable content guide
/// does, so large text gets more room per line instead of more lines.
struct ReadableContentWidth: ViewModifier {
    /// The widest the content column gets at the default text size,
    /// including the list's or screen's own side margins.
    @ScaledMetric(relativeTo: .body) private var maximumWidth: CGFloat = 672

    @State private var containerWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.horizontal, padding)
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.width
            } action: { width in
                containerWidth = width
            }
    }

    /// The padding on each side that centres the column.
    private var padding: CGFloat {
        max(0, ((containerWidth - maximumWidth) / 2).rounded(.down))
    }
}
