import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One day of a month in every mode, as in Calendar: a hairline above, its
/// number (gray on weekends, in the tint for today) and its entries.
///
/// - List: a larger number, a filled circle when selected (the tint for
///   today, else the primary color), and a capsule split into the tag colors
///   of its entries.
/// - Compact, Stacked and Details: a smaller number in a fixed-height cell,
///   and its entries as dots, bars or one-line titles, with "+n" past what
///   fits.
///
/// The same cell serves every mode, so switching modes resizes its number
/// and height in place while only the active mode's marks cross-fade. It
/// takes plain values and compares equal without its action, so it is redrawn
/// only when what it shows changes.
struct ScheduleDayCell: View, Equatable {
    let date: JapanDate
    let isToday: Bool
    let isSelected: Bool
    let marks: [ScheduleDayMark]
    let style: ScheduleMode
    /// Content width of the cell in `.compact`, used to drop dots before "+n"
    /// truncates; `nil` in other modes so width changes do not redraw them.
    var dotWidth: CGFloat? = nil
    let action: () -> Void

    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var listCircleSize = 30.0
    @ScaledMetric(relativeTo: .subheadline) private var gridCircleSize = 28.0
    @ScaledMetric(relativeTo: .subheadline) private var compactHeight = 62.0
    @ScaledMetric(relativeTo: .subheadline) private var tallHeight = 92.0
    @ScaledMetric(relativeTo: .caption2) private var barHeight = 6.0

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date && lhs.isToday == rhs.isToday && lhs.isSelected == rhs.isSelected
            && lhs.marks == rhs.marks && lhs.style == rhs.style && lhs.dotWidth == rhs.dotWidth
    }

    /// The grids' number size against List's: subheadline to title 3.
    private static let gridNumberScale = 0.75

    private var isList: Bool { style == .list }
    private var showsSelection: Bool { isList && isSelected }

    var body: some View {
        let circle = isList ? listCircleSize : gridCircleSize
        Button(action: action) {
            VStack(spacing: isList ? 3 : 4) {
                // One font in every mode, scaled down in the grids, so the
                // number shrinks or grows in place as modes switch.
                Text(date.day, format: .number)
                    .font(.title3.weight(isList || isToday ? .semibold : .regular))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(numberStyle)
                    .scaleEffect(isList ? 1 : Self.gridNumberScale)
                    .frame(width: circle, height: circle)
                    .background {
                        Circle()
                            .fill(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                            .opacity(showsSelection ? 1 : 0)
                    }
                marksView
            }
            .frame(maxWidth: .infinity, minHeight: fixedHeight, maxHeight: fixedHeight, alignment: .top)
            .padding(.horizontal, 3)
            .padding(.top, 4)
            .padding(.bottom, isList ? 3 : 4)
            .overlay(alignment: .top) {
                ScheduleHairline()
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(marks.isEmpty ? Text(verbatim: "") : Text(.Schedule.dayEntryCount(marks.count)))
        .accessibilityAddTraits(showsSelection ? .isSelected : [])
    }

    private var fixedHeight: CGFloat? {
        switch style {
        case .list: nil
        case .compact: compactHeight
        case .stacked, .details: tallHeight
        }
    }

    private var numberStyle: AnyShapeStyle {
        if showsSelection {
            isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.background)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else if date.isWeekend {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.primary)
        }
    }

    /// Draws only the current mode's marks, cross-fading when modes switch,
    /// instead of keeping all four modes' view trees alive in every cell.
    @ViewBuilder
    private var marksView: some View {
        ZStack(alignment: .top) {
            switch style {
            case .list:
                ScheduleDayCapsule(segments: marks.isEmpty ? [] : ScheduleDaySegments.segments(of: marks))
                    .transition(.opacity)
            case .compact:
                if marks.isEmpty == false {
                    ScheduleDayDots(
                        marks: marks, capacity: ScheduleMode.compact.markCapacity, availableWidth: dotWidth
                    )
                    .transition(.opacity)
                }
            case .stacked:
                if marks.isEmpty == false {
                    let shape = ScheduleMode.stacked.marks(forEntryCount: marks.count)
                    VStack(spacing: 3) {
                        ForEach(marks.prefix(shape.shown)) { mark in
                            Capsule()
                                .fill(mark.tag.color.opacity(mark.isFaded ? ScheduleTag.fadedOpacity : 1))
                                .frame(height: barHeight)
                        }
                        more(shape.more)
                    }
                    .transition(.opacity)
                }
            case .details:
                if marks.isEmpty == false {
                    let shape = ScheduleMode.details.marks(forEntryCount: marks.count)
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(marks.prefix(shape.shown)) { mark in
                            ScheduleGridEntryTitle(mark: mark)
                        }
                        more(shape.more)
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: isList ? nil : .infinity, alignment: .top)
        .clipped()
    }

    @ViewBuilder
    private func more(_ count: Int) -> some View {
        if count > 0 {
            Text(.Schedule.moreEntries(count))
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var accessibilityLabel: Text {
        let title = date.accessibilityTitle(locale: locale)
        return isToday ? Text(.Schedule.todayAccessibility(title)) : Text(verbatim: title)
    }
}
