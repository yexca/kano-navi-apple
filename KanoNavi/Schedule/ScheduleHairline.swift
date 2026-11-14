import SwiftUI

/// A one-pixel separator line, as between the weeks of a month.
struct ScheduleHairline: View {
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Rectangle()
            .fill(.separator)
            .frame(height: 1 / displayScale)
            .accessibilityHidden(true)
    }
}
