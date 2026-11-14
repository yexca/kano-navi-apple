import Foundation
import KanoNaviCore

/// The Coming Up section at one instant: the next entries of the next two
/// weeks grouped by Japan day, or, when there are none, the entries that
/// ended most recently.
///
/// - Upcoming entries come from the calendar range of today and the 13 days
///   after it (Japan dates), one per calendar entry, so a sale is listed at
///   its opening and at its close. An entry is coming up when it is live,
///   on a later day, date-only today, or today and not yet started. An entry
///   of today that has started stays for ``endedGrace`` after it ends (its
///   start when it has no end time), so a stream that just finished is still
///   there, dimmed. Entries the screen shows elsewhere are left out: the
///   spotlight's event (``ShownAbove``) and every sale entry, opening and
///   close, which On Sale lists. The first ``limit`` of the rest are shown;
///   days without entries do not appear.
/// - Recent entries come from the dashboard's events: the entries that are
///   done and have a clock time, latest end first, one per event, at most
///   ``recentLimit``. They are listed only when nothing is coming up.
struct NowComingUp: Equatable {
    struct Day: Equatable, Identifiable {
        var date: JapanDate
        var entries: [NowEntry]

        var id: JapanDate { date }
    }

    /// The number of upcoming entries shown.
    static let limit = 5
    /// The number of Japan days read, today included.
    static let dayCount = 14
    /// How long an entry of today stays listed after it ends.
    static let endedGrace: TimeInterval = 3 * 60 * 60
    /// The number of recent entries shown when nothing is coming up.
    static let recentLimit = 2

    /// The spotlight's event, which Coming Up leaves out: its ID, and the
    /// addresses of the spotlight's video, which an event of the same stream
    /// links to.
    struct ShownAbove: Equatable {
        var eventIDs: Set<String> = []
        var videoURLs: Set<URL> = []

        func contains(_ event: ScheduleEvent) -> Bool {
            if eventIDs.contains(event.id) {
                return true
            }
            let addresses =
                [event.url, event.liveURL].compactMap(\.self) + (event.links ?? []).compactMap(\.url)
            return addresses.contains { videoURLs.contains($0) }
        }
    }

    var today: JapanDate
    var days: [Day]
    /// The most recently ended entries; empty unless nothing at all is coming
    /// up.
    var recent: [NowEntry]
    /// Whether something is coming up but all of it is in the spotlight or
    /// On Sale, so there is nothing to list and nothing to call empty.
    var isAllShownAbove: Bool

    init(
        calendarEvents: [ScheduleEvent], dashboardEvents: [ScheduleEvent],
        shownAbove: ShownAbove = ShownAbove(),
        now: Date
    ) {
        let today = JapanDate.today(at: now)
        self.today = today
        let comingUp = NowEntry.entries(in: calendarEvents)
            .filter { Self.isComingUp($0, today: today, now: now) }
        let upcoming = comingUp.filter { Self.isListed($0, shownAbove: shownAbove) }.prefix(Self.limit)
        var days: [Day] = []
        for entry in upcoming {
            if days.last?.date == entry.date {
                days[days.count - 1].entries.append(entry)
            } else {
                days.append(Day(date: entry.date, entries: [entry]))
            }
        }
        self.days = days
        isAllShownAbove = days.isEmpty && comingUp.isEmpty == false
        recent = comingUp.isEmpty ? Self.recent(in: dashboardEvents, now: now) : []
    }

    /// Whether an entry that is coming up is listed: not a sale's, which On
    /// Sale lists, and not the spotlight's event.
    static func isListed(_ entry: NowEntry, shownAbove: ShownAbove) -> Bool {
        guard entry.calendarEntry.saleMark == nil, entry.event.view?.typeCode != "sale" else { return false }
        return shownAbove.contains(entry.event) == false
    }

    /// Whether an entry belongs in Coming Up at `now`.
    static func isComingUp(_ entry: NowEntry, today: JapanDate, now: Date) -> Bool {
        if entry.state == .live, entry.calendarEntry.saleMark == nil {
            return true
        }
        guard entry.date >= today, entry.date < today.addingDays(dayCount) else { return false }
        guard entry.date == today, let startsAt = entry.startsAt, startsAt < now else { return true }
        let endedAt = entry.endedAt ?? startsAt
        return now.timeIntervalSince(endedAt) <= endedGrace
    }

    /// The entries that ended most recently before `now`, latest first, one
    /// per event.
    static func recent(in events: [ScheduleEvent], now: Date) -> [NowEntry] {
        var seen = Set<String>()
        return NowEntry.entries(in: events)
            .filter { entry in
                guard entry.state == .done, entry.calendarEntry.saleMark == nil,
                    let endedAt = entry.endedAt
                else { return false }
                return endedAt <= now
            }
            .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
            .filter { seen.insert($0.eventID).inserted }
            .prefix(recentLimit)
            .map(\.self)
    }
}
