import KanoNaviComponents
import SwiftUI

/// The small capsule under a day of the List mode's month, as in Calendar:
/// split into a segment per tag of the day's entries (see
/// ``ScheduleDaySegments``), and empty for a day without entries.
struct ScheduleDayCapsule: View {
    let segments: [ScheduleDaySegments.Segment]

    @ScaledMetric(relativeTo: .caption2) private var segmentWidth = 7.0
    @ScaledMetric(relativeTo: .caption2) private var height = 4.0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments.enumerated(), id: \.offset) { _, segment in
                Rectangle()
                    .fill(segment.tag.color.opacity(segment.isFaded ? ScheduleTag.fadedOpacity : 1))
                    .frame(width: segmentWidth)
            }
        }
        .frame(height: height)
        .clipShape(.capsule)
        .accessibilityHidden(true)
    }
}
