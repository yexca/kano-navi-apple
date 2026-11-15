/// A choice made in the month grid: a month, or `nil` for Newest.
/// ``MonthPickerButton`` applies it once the grid has closed.
struct MonthPickerChoice: Equatable {
    var month: ArchiveMonthKey?
}
