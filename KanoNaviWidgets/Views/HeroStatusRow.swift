import KanoNaviCore
import SwiftUI

/// The top row of a lead entry: its state capsule, when it starts at the
/// trailing edge, and optionally a cached-data icon.
struct HeroStatusRow: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate
    /// The schedule whose freshness to mark, or `nil` when the widget marks
    /// it elsewhere.
    var freshness: WidgetSchedule?

    var body: some View {
        HStack(spacing: 4) {
            StatusCapsule(isLive: item.isLive(at: now))
            Spacer(minLength: 2)
            if item.isLive(at: now) == false {
                EntryWhen(item: item, now: now, today: today)
            }
            if let freshness {
                FreshnessLabel(schedule: freshness, iconOnly: true)
            }
        }
        .lineLimit(1)
        // A short row of labels; it stops growing so the title keeps room.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
