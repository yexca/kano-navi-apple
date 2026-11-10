import KanoNaviCore
import SwiftUI

/// Marks an entry for channel members only, shown when
/// `event.isMembersOnly` is true. Safe in widgets.
public struct MembersChip: View {
    /// Creates the chip.
    public init() {}

    public var body: some View {
        ComponentChip(
            title: DisplayCodeLabels.eventType("member"), systemImage: "person.crop.circle.badge.checkmark",
            tint: .indigo)
    }
}

#Preview {
    MembersChip()
}
