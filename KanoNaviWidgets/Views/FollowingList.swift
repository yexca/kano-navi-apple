import KanoNaviCore
import SwiftUI

/// The medium widget's right column: the entries after its lead entry, and
/// whether the data is cached.
struct FollowingList: View {
    let items: [WidgetItem]
    let schedule: WidgetSchedule
    let now: Date
    let today: JapanDate

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if items.isEmpty {
                Text(.widgetNothingElse)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ForEach(items) { item in
                Link(destination: item.url) {
                    FollowingRow(item: item, now: now, today: today)
                }
            }
            Spacer(minLength: 0)
            FreshnessLabel(schedule: schedule)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
