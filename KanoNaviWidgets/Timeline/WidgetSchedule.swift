import Foundation
import KanoNaviCore

/// The calendar range the widgets show, flattened into entries.
///
/// The server decides each event's state; the schedule only orders entries
/// and, for a moment in the timeline, says which have passed.
nonisolated struct WidgetSchedule: Equatable, Sendable {
    /// Entries ordered by Japan date, date-only entries first, then by time.
    var items: [WidgetItem]
    /// When the data was read from the service; `nil` when unknown.
    var fetchedAt: Date?
    /// Whether the last read failed and this is the cached result.
    var isStale: Bool
    /// The service's next time-dependent change.
    var nextTransitionAt: Date?

    init(items: [WidgetItem], fetchedAt: Date?, isStale: Bool, nextTransitionAt: Date?) {
        self.items = Self.ordered(items)
        self.fetchedAt = fetchedAt
        self.isStale = isStale
        self.nextTransitionAt = nextTransitionAt
    }

    /// Builds the schedule from a calendar read, resolving titles for the
    /// content language.
    init(result: WidgetCalendarResult, language: ContentLanguage, interfaceLocale: Locale) {
        let items = result.events.flatMap { event -> [WidgetItem] in
            guard let view = event.view else { return [] }
            let title = ContentLanguageResolver.resolve(
                original: event.title, sourceLanguage: event.sourceLanguage,
                translations: event.translations, preference: language,
                interfaceLocale: interfaceLocale
            ).text
            return view.calendarEntries.enumerated().map { index, entry in
                WidgetItem(
                    id: event.id + "#" + String(index), eventID: event.id, title: title,
                    day: entry.startsOn, startsAt: entry.startsAt, timePrecision: entry.timePrecision,
                    endsAt: entry.saleMark == nil ? event.endsAt : nil, saleMark: entry.saleMark,
                    state: view.state, typeCode: view.typeCode)
            }
        }
        self.init(
            items: items, fetchedAt: result.fetchedAt, isStale: result.isStale,
            nextTransitionAt: result.nextTransitionAt)
    }

    /// Live entries first, then the ones still ahead, in order.
    func current(at now: Date) -> [WidgetItem] {
        let live = items.filter { $0.isLive(at: now) }
        let ahead = items.filter { $0.isLive(at: now) == false && $0.isPast(at: now) == false }
        return live + ahead
    }

    /// The entry a single-entry widget shows: live, or the next one that is
    /// not cancelled.
    func next(at now: Date) -> WidgetItem? {
        current(at: now).first { $0.isCancelled == false }
    }

    /// Current entries grouped by Japan day, within `lineBudget` lines, where
    /// each day heading takes one line and each entry `itemLines`.
    func upcomingDays(at now: Date, lineBudget: Int, itemLines: Int = 1) -> [WidgetDay] {
        let today = JapanDate.date(from: now)
        var days: [WidgetDay] = []
        var remaining = lineBudget
        for item in current(at: now) {
            let date = max(item.day, today)
            if days.last?.date != date {
                guard remaining >= 1 + itemLines else { break }
                days.append(WidgetDay(date: date, items: []))
                remaining -= 1
            }
            guard remaining >= itemLines else { break }
            days[days.count - 1].items.append(item)
            remaining -= itemLines
        }
        return days
    }

    /// The seven Japan days from today, each with its current entries, within
    /// `lineBudget` lines. Every day takes at least one line; days with
    /// entries take one line per entry, earlier days first. Entries that do
    /// not fit are counted in `hiddenCount`.
    func week(at now: Date, lineBudget: Int) -> [WidgetDay] {
        let today = JapanDate.date(from: now)
        let current = current(at: now)
        let days = (0..<7).map { offset in
            let date = today.addingDays(offset)
            return WidgetDay(date: date, items: current.filter { max($0.day, today) == date })
        }
        var spare = lineBudget - days.count
        return days.map { day in
            var day = day
            let extra = max(0, min(day.items.count - 1, spare))
            spare -= extra
            let shown = day.items.isEmpty ? 0 : extra + 1
            day.hiddenCount = day.items.count - shown
            day.items = Array(day.items.prefix(shown))
            return day
        }
    }

    /// The instants after `now` at which an entry starts, ends or changes
    /// day, in order and without duplicates.
    func transitionDates(after now: Date) -> [Date] {
        Set(items.flatMap(\.transitionDates)).filter { $0 > now }.sorted()
    }

    private static func ordered(_ items: [WidgetItem]) -> [WidgetItem] {
        items.enumerated().sorted { lhs, rhs in
            let left = lhs.element
            let right = rhs.element
            if left.day != right.day { return left.day < right.day }
            switch (left.startsAt, right.startsAt) {
            case (nil, .some): return true
            case (.some, nil): return false
            case (.some(let leftStart), .some(let rightStart)) where leftStart != rightStart:
                return leftStart < rightStart
            default: return lhs.offset < rhs.offset
            }
        }
        .map(\.element)
    }
}
