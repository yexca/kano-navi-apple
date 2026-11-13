import Foundation

/// Semantic payload of a future calendar-triggered local reminder.
public enum ScheduledReminderKind: Equatable, Sendable {
    case eventStart(event: ScheduleEvent, lead: EventReminderLead, startsAt: Date)
    case saleOpens(event: ScheduleEvent, date: JapanDate, instant: Date, hasClockTime: Bool)
    case saleCloses(
        event: ScheduleEvent,
        lead: SaleCloseReminderLead,
        date: JapanDate,
        instant: Date,
        hasClockTime: Bool
    )
}
