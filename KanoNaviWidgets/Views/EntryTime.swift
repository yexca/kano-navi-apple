import SwiftUI

/// An entry's Japan time, "All day" for a date-only entry, or the live badge.
struct EntryTime: View {
    let item: WidgetItem
    let now: Date
    /// Whether to add "JST"; lists that label the zone once leave it out.
    var labelsZone = false

    @Environment(\.locale) private var locale

    var body: some View {
        if item.isLive(at: now) {
            LiveBadge()
        } else if let startsAt = item.startsAt {
            Text(
                labelsZone
                    ? WidgetFormat.timeJST(startsAt, locale: locale)
                    : WidgetFormat.time(startsAt, locale: locale)
            )
            .monospacedDigit()
        } else {
            Text(.widgetAllDay)
        }
    }
}
