import KanoNaviCore
import SwiftUI

/// The inline Lock Screen widget: one line with the next entry's time and
/// title, or "Live" and the live entry's title.
struct InlineUpcomingView: View {
    let entry: UpcomingEntry

    @Environment(\.locale) private var locale

    var body: some View {
        switch entry.content {
        case .unavailable:
            Text(.widgetUnavailableTitle)
        case .schedule(let schedule):
            if let item = schedule.next(at: entry.date) {
                Text(.widgetInlineEntry(lead(for: item), item.title))
            } else {
                Text(.widgetNothingScheduled)
            }
        }
    }

    private func lead(for item: WidgetItem) -> String {
        if item.isLive(at: entry.date) {
            return WidgetFormat.string(DisplayCodeLabels.eventState(.live), locale: locale)
        }
        guard let startsAt = item.startsAt else {
            return WidgetFormat.day(item.day, locale: locale)
        }
        let time = WidgetFormat.timeJST(startsAt, locale: locale)
        guard item.day != entry.today else { return time }
        return WidgetFormat.weekday(item.day, locale: locale) + " " + time
    }
}
