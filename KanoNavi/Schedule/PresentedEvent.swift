import KanoNaviCore

/// The event whose detail sheet is open.
struct PresentedEvent: Identifiable {
    let event: ScheduleEvent
    var id: String { event.id }
}
