import KanoNaviComponents
import SwiftUI

/// A day's entries as one dot each in its tag color, faded when done or
/// cancelled, with "+n" past `capacity`. A cell too narrow for that row
/// drops dots before it would cut "+n" short.
struct ScheduleDayDots: View {
    let marks: [ScheduleDayMark]
    let capacity: Int

    @ScaledMetric(relativeTo: .caption2) private var dotSize = 6.0

    var body: some View {
        ViewThatFits(in: .horizontal) {
            ForEach((1...max(capacity, 1)).reversed(), id: \.self) { capacity in
                row(capacity: capacity)
            }
        }
    }

    private func row(capacity: Int) -> some View {
        let shape = ScheduleMode.marks(forEntryCount: marks.count, capacity: capacity)
        return HStack(spacing: 2) {
            ForEach(marks.prefix(shape.shown)) { mark in
                Circle()
                    .fill(mark.tag.color.opacity(mark.isFaded ? ScheduleTag.fadedOpacity : 1))
                    .frame(width: dotSize, height: dotSize)
            }
            if shape.more > 0 {
                Text(.Schedule.moreEntries(shape.more))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }
}
