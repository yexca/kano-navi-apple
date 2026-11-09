import KanoNaviCore

/// What the Schedule tab should show after a deep link.
enum ScheduleFocus: Equatable {
    /// One entry, by its public event ID.
    case event(id: String)
    /// One Japan date.
    case date(JapanDate)
}
