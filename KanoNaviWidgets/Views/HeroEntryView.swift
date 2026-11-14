import KanoNaviCore
import SwiftUI

/// The live or next entry laid out to fill a column: its state, title and
/// marks at the top and its time at the bottom.
struct HeroEntryView: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate
    /// The schedule whose freshness to mark, or `nil` when the widget marks
    /// it elsewhere.
    var freshness: WidgetSchedule?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HeroStatusRow(item: item, now: now, today: today, freshness: freshness)
            EntryTitle(item: item, lineLimit: dynamicTypeSize.isAccessibilitySize ? 2 : 3)
                .font(.headline)
                .minimumScaleFactor(0.75)
            EntryMarks(item: item)
            Spacer(minLength: 0)
            HeroTime(item: item, now: now)
                // Already display-sized; it stops growing so the title keeps
                // its lines and the label stays beside the time.
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
