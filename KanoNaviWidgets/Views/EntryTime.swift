import KanoNaviComponents
import SwiftUI
import WidgetKit

/// An entry's Japan time, "All day" for an entry without a clock time, or
/// the live indicator.
struct EntryTime: View {
    let item: WidgetItem
    let now: Date
    /// Whether to add "JST"; lists that label the zone once leave it out.
    var labelsZone = false

    @Environment(\.locale) private var locale

    var body: some View {
        if item.isLive(at: now) {
            LiveIndicator()
                .widgetAccentable()
        } else if let startsAt = item.startsAt,
            JSTTimeFormat.showsTime(startsAt: startsAt, timePrecision: item.timePrecision)
        {
            if labelsZone {
                JSTTimeLabel(startsAt: startsAt, startsOn: item.day, timePrecision: item.timePrecision)
            } else {
                Text(JSTTimeFormat.clockTime(startsAt, locale: locale))
                    .monospacedDigit()
            }
        } else {
            Text(.widgetAllDay)
        }
    }
}
