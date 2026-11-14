import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One entry of the List mode's selected day: a thin bar in the entry's tag
/// color, as in the grids, beside its ``EventRow``.
struct ScheduleDayEntryRow: View {
    let item: ScheduleDayEntry
    let contentLanguage: ContentLanguage

    @ScaledMetric(relativeTo: .body) private var barWidth = 4.0

    var body: some View {
        HStack(spacing: 10) {
            Capsule()
                .fill(ScheduleTag(event: item.event).color)
                .opacity(item.event.isFadedInSchedule ? ScheduleTag.fadedOpacity : 1)
                .frame(width: barWidth)
                .accessibilityHidden(true)
            EventRow(event: item.event, entry: item.entry, contentLanguage: contentLanguage)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
