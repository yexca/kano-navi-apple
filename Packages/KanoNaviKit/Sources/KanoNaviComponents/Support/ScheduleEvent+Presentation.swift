import Foundation
import KanoNaviCore

/// Presentation facts the components read from an event. They translate the
/// server's codes; none re-derives a decision the server makes.
nonisolated extension ScheduleEvent {
    /// The state the server decided for this entry. A record without a
    /// `view` (an incompatible response) reads as an unknown state.
    public var displayState: EventState {
        view?.state ?? .unknown("")
    }

    /// Whether the entry is for channel members only.
    public var isMembersOnly: Bool {
        view?.typeCode == "member"
    }

    /// Whether the board's maintainer confirmed the entry. Other entries were
    /// detected automatically from a post or a schedule image.
    public var isConfirmed: Bool {
        provenance == "manual" || manualLocked
    }

    /// Whether the entry was cancelled, so its title is struck through.
    public var isCancelled: Bool {
        displayState == .cancelled
    }

    /// The days this entry occupies in the calendar, as the server lists them.
    /// A sale has one entry for its opening and one for its close. A record
    /// without a `view` falls back to its own start.
    public var displayCalendarEntries: [CalendarEntryView] {
        if let entries = view?.calendarEntries, entries.isEmpty == false {
            return entries
        }
        return [CalendarEntryView(startsOn: startsOn, startsAt: startsAt, timePrecision: timePrecision)]
    }

    /// The title in the content language, with its translation details.
    public func resolvedTitle(preference: ContentLanguage, interfaceLocale: Locale) -> ResolvedContentText {
        ContentLanguageResolver.resolve(
            original: title, sourceLanguage: sourceLanguage, translations: translations,
            preference: preference, interfaceLocale: interfaceLocale)
    }
}
