import SwiftUI
import WidgetKit

/// A faint Berry fill behind content. Outside full color it fills with the
/// primary style at the same opacity. The fill stays out of the accented
/// group, which the system draws opaque.
struct BerryTint<Background: Shape>: ViewModifier {
    let opacity: Double
    let shape: Background

    @Environment(\.widgetRenderingMode) private var renderingMode

    func body(content: Content) -> some View {
        content.background {
            shape
                .fill((renderingMode == .fullColor ? Color.berry : Color.primary).opacity(opacity))
        }
    }
}

extension View {
    /// Fills `shape` behind the view with Berry at `opacity`; see ``BerryTint``.
    func berryTint(_ opacity: Double, in shape: some Shape) -> some View {
        modifier(BerryTint(opacity: opacity, shape: shape))
    }
}
