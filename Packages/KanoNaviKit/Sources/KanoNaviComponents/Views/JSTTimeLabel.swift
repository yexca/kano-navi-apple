import KanoNaviCore
import SwiftUI

/// An entry's start in Japan time, labelled JST, such as `21:00 JST`.
///
/// A date-only entry has no time: it shows its date when `includesDate` is
/// set, and nothing otherwise. Formatting follows the view's `\.locale`; see
/// ``JSTTimeFormat``. Safe in widgets.
public struct JSTTimeLabel: View {
    private let startsAt: Date?
    private let startsOn: JapanDate
    private let timePrecision: String
    private let includesDate: Bool
    @Environment(\.locale) private var locale

    /// Creates a label from an entry's start fields.
    public init(startsAt: Date?, startsOn: JapanDate, timePrecision: String, includesDate: Bool = false) {
        self.startsAt = startsAt
        self.startsOn = startsOn
        self.timePrecision = timePrecision
        self.includesDate = includesDate
    }

    /// Creates a label for one calendar entry, such as a sale's opening.
    public init(entry: CalendarEntryView, includesDate: Bool = false) {
        self.init(
            startsAt: entry.startsAt, startsOn: entry.startsOn, timePrecision: entry.timePrecision,
            includesDate: includesDate)
    }

    /// Creates a label for an event's own start.
    public init(event: ScheduleEvent, includesDate: Bool = false) {
        self.init(
            startsAt: event.startsAt, startsOn: event.startsOn, timePrecision: event.timePrecision,
            includesDate: includesDate)
    }

    public var body: some View {
        if let text = JSTTimeFormat.entry(
            startsAt: startsAt, startsOn: startsOn, timePrecision: timePrecision,
            includesDate: includesDate, locale: locale)
        {
            Text(text)
                .monospacedDigit()
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        JSTTimeLabel(
            startsAt: Date(timeIntervalSince1970: 1_794_484_800),
            startsOn: JapanDate(year: 2026, month: 11, day: 12), timePrecision: "exact")
        JSTTimeLabel(
            startsAt: Date(timeIntervalSince1970: 1_794_484_800),
            startsOn: JapanDate(year: 2026, month: 11, day: 12), timePrecision: "exact", includesDate: true)
        JSTTimeLabel(
            startsAt: nil, startsOn: JapanDate(year: 2026, month: 11, day: 12), timePrecision: "date",
            includesDate: true)
    }
}
