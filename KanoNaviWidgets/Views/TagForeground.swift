import KanoNaviComponents
import SwiftUI
import WidgetKit

/// Draws an entry's time in its tag's color, as the app's calendar does, and
/// puts it in the accented group. A done or cancelled entry's color fades.
/// Outside full color, where the system draws by opacity, it uses the
/// primary style so the time stays as legible as the rest; the title and
/// marks still say what the entry is.
struct TagForeground: ViewModifier {
    let item: WidgetItem

    @Environment(\.widgetRenderingMode) private var renderingMode

    func body(content: Content) -> some View {
        content
            .foregroundStyle(renderingMode == .fullColor ? color : Color.primary)
            .widgetAccentable()
    }

    private var color: Color {
        item.tag.color.opacity(ScheduleTag.isFaded(item.state) ? ScheduleTag.fadedOpacity : 1)
    }
}

extension View {
    /// Draws the view in the entry's tag color; see ``TagForeground``.
    func tagForeground(_ item: WidgetItem) -> some View {
        modifier(TagForeground(item: item))
    }
}
