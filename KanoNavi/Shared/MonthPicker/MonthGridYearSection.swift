import SwiftUI

/// One year of the month grid: the year as a heading over its twelve months,
/// four to a row, or two at accessibility text sizes. Each month is laid out
/// at once and identified by its key, so the grid can scroll to it.
struct MonthGridYearSection: View {
    let year: MonthGridYear
    let selection: ArchiveMonthKey?
    let unit: MonthPickerUnit
    let choose: (ArchiveMonthKey) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(year.year, format: .number.grouping(.never))
                .font(.title3.bold())
                .accessibilityAddTraits(.isHeader)

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(rows, id: \.first?.id) { row in
                    GridRow {
                        ForEach(row) { cell in
                            MonthGridCellButton(cell: cell, isSelected: cell.month == selection, unit: unit) {
                                choose(cell.month)
                            }
                            .id(cell.month)
                        }
                    }
                }
            }
        }
    }

    /// The months in rows of four, or two at accessibility text sizes.
    private var rows: [[MonthGridCell]] {
        let count = dynamicTypeSize.isAccessibilitySize ? 2 : 4
        return stride(from: 0, to: year.months.count, by: count).map {
            Array(year.months[$0..<min($0 + count, year.months.count)])
        }
    }
}
