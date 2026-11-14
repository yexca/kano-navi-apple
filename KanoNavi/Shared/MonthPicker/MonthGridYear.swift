/// One year of a month picker and its twelve months, January first.
nonisolated struct MonthGridYear: Equatable, Identifiable, Sendable {
    var year: Int
    var months: [MonthGridCell]

    var id: Int { year }
}
