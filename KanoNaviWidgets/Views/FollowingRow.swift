import KanoNaviCore
import SwiftUI

/// One entry in the medium widget's right column: its day, time and marks
/// over its title. When the marks do not fit beside the day, they follow the
/// title instead, which then gives way first.
struct FollowingRow: View {
    let item: WidgetItem
    let now: Date
    let today: JapanDate

    var body: some View {
        ViewThatFits(in: .horizontal) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    when
                    EntryMarks(item: item)
                }
                title
            }
            VStack(alignment: .leading, spacing: 1) {
                when
                HStack(spacing: 4) {
                    EntryTitle(item: item)
                        .font(.footnote.weight(.semibold))
                    EntryMarks(item: item)
                }
            }
        }
        .lineLimit(1)
    }

    private var when: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            DayLabel(date: max(item.day, today), today: today, isCompact: true)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            EntryTime(item: item, now: now)
                .font(.caption.weight(.bold))
                .berryForeground()
        }
    }

    /// The title under the marks, which takes the room that is left rather
    /// than setting the row's width.
    private var title: some View {
        EntryTitle(item: item)
            .font(.footnote.weight(.semibold))
            .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
