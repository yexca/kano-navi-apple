import SwiftUI
import WidgetKit

/// Draws content in Berry, the widgets' accent, and puts it in the accented
/// group. Outside full color, where the system draws by opacity, it uses the
/// primary style so accented text stays as legible as the rest.
struct BerryForeground: ViewModifier {
    @Environment(\.widgetRenderingMode) private var renderingMode

    func body(content: Content) -> some View {
        content
            .foregroundStyle(renderingMode == .fullColor ? Color.berry : Color.primary)
            .widgetAccentable()
    }
}

extension View {
    /// Draws the view in the widgets' accent; see ``BerryForeground``.
    func berryForeground() -> some View {
        modifier(BerryForeground())
    }
}
