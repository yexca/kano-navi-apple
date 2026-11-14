import KanoNaviCore

/// A Japan date and the entries the widgets list under it.
nonisolated struct WidgetDay: Equatable, Identifiable, Sendable {
    var date: JapanDate
    var items: [WidgetItem]

    var id: JapanDate { date }
}
