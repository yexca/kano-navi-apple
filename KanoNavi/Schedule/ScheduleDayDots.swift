import KanoNaviComponents
import SwiftUI

/// A day's entries as one dot each in its tag color, faded when done or
/// cancelled, with "+n" past `capacity`. A cell too narrow for that row
/// drops dots before it would cut "+n" short. Muted dots, for the days of
/// the months around the one on screen, are all gray.
struct ScheduleDayDots: View {
    let entries: [ScheduleDayEntry]
    let capacity: Int
    var isMuted = false

    @ScaledMetric(relativeTo: .caption2) private var dotSize = 6.0

    var body: some View {
        ViewThatFits(in: .horizontal) {
            ForEach((1...max(capacity, 1)).reversed(), id: \.self) { capacity in
                row(capacity: capacity)
            }
        }
    }

    private func row(capacity: Int) -> some View {
        let marks = ScheduleMode.marks(forEntryCount: entries.count, capacity: capacity)
        return HStack(spacing: 2) {
            ForEach(entries.prefix(marks.shown)) { item in
                Circle()
                    .fill(color(of: item))
                    .frame(width: dotSize, height: dotSize)
            }
            if marks.more > 0 {
                Text(.Schedule.moreEntries(marks.more))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isMuted ? .tertiary : .secondary)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }

    private func color(of item: ScheduleDayEntry) -> AnyShapeStyle {
        if isMuted {
            return AnyShapeStyle(.tertiary)
        }
        return AnyShapeStyle(
            ScheduleTag(event: item.event).color
                .opacity(item.event.isFadedInSchedule ? ScheduleTag.fadedOpacity : 1))
    }
}
