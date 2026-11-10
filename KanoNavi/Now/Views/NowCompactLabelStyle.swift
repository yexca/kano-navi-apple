import SwiftUI

/// An icon and title with a tight gap, for chips.
struct NowCompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .accessibilityHidden(true)
            configuration.title
        }
    }
}
