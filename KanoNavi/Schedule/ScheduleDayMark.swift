import Foundation
import KanoNaviComponents
import KanoNaviCore

/// What a calendar cell draws for one entry, as plain values, so a cell is
/// redrawn only when what it shows changes.
nonisolated struct ScheduleDayMark: Identifiable, Equatable, Sendable {
    let id: String
    let tag: ScheduleTag
    /// Done or cancelled, so the mark fades.
    let isFaded: Bool
    let isCancelled: Bool
    /// The title in the content language, for the Details grid; empty
    /// elsewhere.
    let title: String

    init(_ item: ScheduleDayEntry, title: String = "") {
        id = item.id
        tag = ScheduleTag(event: item.event)
        isFaded = item.event.isFadedInSchedule
        isCancelled = item.event.isCancelled
        self.title = title
    }

    /// The marks of each day of a loaded month; days without entries are
    /// left out. With a content language, each mark carries its title in
    /// that language.
    static func marks(
        of days: ScheduleMonthDays?, weeks: [[JapanDate?]], titlesIn language: ContentLanguage? = nil,
        locale: Locale = .current
    ) -> [JapanDate: [ScheduleDayMark]] {
        guard let days else { return [:] }
        var marks: [JapanDate: [ScheduleDayMark]] = [:]
        for date in weeks.joined().compactMap(\.self) {
            let entries = days.entries(on: date)
            guard entries.isEmpty == false else { continue }
            marks[date] = entries.map { item in
                let title =
                    language.map {
                        item.event.resolvedTitle(preference: $0, interfaceLocale: locale).text
                    } ?? ""
                return ScheduleDayMark(item, title: title)
            }
        }
        return marks
    }
}
