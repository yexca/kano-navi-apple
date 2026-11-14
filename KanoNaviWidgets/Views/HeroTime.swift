import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A lead entry's time, large and in its tag color: "Ends" and when a live entry
/// ends, the next entry's Japan time, each with "JST", or "All day".
struct HeroTime: View {
    let item: WidgetItem
    let now: Date
    var alignment: HorizontalAlignment = .leading

    @Environment(\.locale) private var locale

    var body: some View {
        if item.isLive(at: now) {
            if let endsAt = item.endsAt {
                block(
                    label: .widgetEnds, time: Text(JSTTimeFormat.clockTime(endsAt, locale: locale)),
                    isTime: true)
            }
        } else if let startsAt = item.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: item.timePrecision)
        {
            block(time: Text(JSTTimeFormat.clockTime(startsAt, locale: locale)), isTime: true)
        } else {
            block(time: Text(.widgetAllDay), isTime: false)
        }
    }

    /// The label beside the time where it fits, else above it.
    private func block(label: LocalizedStringResource? = nil, time: Text, isTime: Bool) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                if let label {
                    labelText(label)
                }
                timeLine(time, isTime: isTime)
            }
            VStack(alignment: alignment, spacing: 0) {
                if let label {
                    labelText(label)
                }
                timeLine(time, isTime: isTime)
                    // The time scales down rather than truncating.
                    .minimumScaleFactor(0.5)
            }
        }
        .lineLimit(1)
        .accessibilityElement(children: .combine)
    }

    private func labelText(_ label: LocalizedStringResource) -> some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)
    }

    private func timeLine(_ time: Text, isTime: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            time
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .tagForeground(item)
                .layoutPriority(1)
            if isTime {
                Text(.widgetJST)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
