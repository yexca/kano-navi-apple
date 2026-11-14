import SwiftUI

/// The Home Screen widgets' background: cream fading to a faint pink, or
/// deep plum fading to a lighter plum in dark appearance. The system removes
/// it on tinted and clear Home Screens.
struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.widgetBackgroundTop, .widgetBackgroundBottom], startPoint: .top, endPoint: .bottom)
    }
}
