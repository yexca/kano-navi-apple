import KanoNaviCore

/// A Japan date and the entries the widgets list under it.
nonisolated struct WidgetDay: Equatable, Identifiable, Sendable {
    var date: JapanDate
    var items: [WidgetItem]
    /// Entries left out for lack of room.
    var hiddenCount = 0

    var id: JapanDate { date }
}
