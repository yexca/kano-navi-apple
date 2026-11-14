/// One month of a month picker: its items, and whether it can be chosen. A
/// month without items, or one after the current Japan month, cannot.
nonisolated struct MonthGridCell: Equatable, Identifiable, Sendable {
    var month: ArchiveMonthKey
    var count: Int
    var isEnabled: Bool

    var id: String { month.rawValue }
}
