import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One entry of the List mode's selected day, as in Calendar: a bar in its
/// tag color, its title, a quiet line with its notable state and type, and
/// its start over its end in Japan time on the trailing side, or "All Day".
/// A done entry fades. At accessibility text sizes the time moves under
/// the title. VoiceOver reads the title, state, type and time range in JST.
struct ScheduleDayEntryRow: View {
    let row: ScheduleDayRowModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var barWidth = 4.0

    var body: some View {
        let stacks = dynamicTypeSize.isAccessibilitySize
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: barWidth / 2)
                .fill(row.tag.color.opacity(row.isFaded ? ScheduleTag.fadedOpacity : 1))
                .frame(width: barWidth)
                .accessibilityHidden(true)
            let layout =
                stacks
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 8))
            layout {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: row.title)
                        .font(.body.weight(.semibold))
                        .strikethrough(row.isCancelled)
                        .lineLimit(stacks ? nil : 2)
                    detail
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                time(alignment: stacks ? .leading : .trailing)
            }
        }
        .padding(.vertical, 2)
        .fixedSize(horizontal: false, vertical: true)
        .opacity(row.isFaded ? 0.6 : 1)
        .accessibilityElement(children: .combine)
    }

    /// The notable state, then the type, in small secondary text.
    private var detail: some View {
        HStack(spacing: 4) {
            switch row.status {
            case .live:
                Circle()
                    .fill(.red)
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
                Text(DisplayCodeLabels.eventState(.live))
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                separator
            case .sale(let mark):
                Text(DisplayCodeLabels.saleMark(mark))
                separator
            case .state(let state):
                Text(DisplayCodeLabels.eventState(state))
                    .foregroundStyle(state == .cancelled ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
                separator
            case nil:
                EmptyView()
            }
            Text(DisplayCodeLabels.eventType(row.typeCode))
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var separator: some View {
        Text(verbatim: "·")
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func time(alignment: HorizontalAlignment) -> some View {
        switch row.time {
        case .allDay:
            Text(.Schedule.allDay)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .clock(let start, let end):
            VStack(alignment: alignment, spacing: 2) {
                Text(verbatim: start)
                    .foregroundStyle(.primary)
                if let end {
                    Text(verbatim: end)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .monospacedDigit()
            .lineLimit(1)
            .fixedSize()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                end.map { Text(.Schedule.rowTimeRange(start, $0)) } ?? Text(.Schedule.rowTime(start)))
        }
    }
}
