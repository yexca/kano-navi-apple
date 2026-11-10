import KanoNaviCore
import SwiftUI
import WidgetKit

/// A red dot and the word "Live", so the state never relies on color alone.
struct LiveBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.red)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            Text(DisplayCodeLabels.eventState(.live))
                .fontWeight(.semibold)
        }
        .widgetAccentable()
    }
}
