import KanoNaviComponents
import SwiftUI
import UIKit

/// A day's entries as one dot each in its tag color, faded when done or
/// cancelled, with "+n" past `capacity`. A cell too narrow for that row
/// drops dots before it would cut "+n" short.
struct ScheduleDayDots: View {
    let marks: [ScheduleDayMark]
    let capacity: Int
    var availableWidth: CGFloat? = nil

    @ScaledMetric(relativeTo: .caption2) private var dotSize = 6.0

    var body: some View {
        let fitted = Self.fittingCapacity(
            entryCount: marks.count, maxCapacity: capacity, availableWidth: availableWidth, dotSize: dotSize)
        let shape = ScheduleMode.marks(forEntryCount: marks.count, capacity: fitted)
        HStack(spacing: 2) {
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

    /// Picks the largest capacity up to `maxCapacity` whose dots and "+n" fit
    /// within `availableWidth`, dropping dots before "+n" can truncate.
    nonisolated static func fittingCapacity(
        entryCount: Int, maxCapacity: Int, availableWidth: CGFloat?, dotSize: CGFloat
    ) -> Int {
        let limit = max(maxCapacity, 1)
        guard entryCount > 1, let availableWidth, availableWidth > 0 else { return limit }
        let font = UIFont.systemFont(ofSize: 11.0 * (dotSize / 6.0), weight: .medium)
        let spacing: CGFloat = 2.0
        for candidate in (1...limit).reversed() {
            let shape = ScheduleMode.marks(forEntryCount: entryCount, capacity: candidate)
            let dotsWidth = CGFloat(shape.shown) * dotSize + CGFloat(max(shape.shown - 1, 0)) * spacing
            let width: CGFloat
            if shape.more > 0 {
                let moreWidth = ("+\(shape.more)" as NSString).size(withAttributes: [.font: font]).width + 1.0
                let gap = shape.shown > 0 ? spacing : 0
                width = dotsWidth + gap + moreWidth
            } else {
                width = dotsWidth
            }
            if width <= availableWidth {
                return candidate
            }
        }
        return 1
    }
}
