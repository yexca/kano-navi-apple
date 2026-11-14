import KanoNaviCore
import SwiftUI

/// A month's short name above the column of its first day, as in Calendar,
/// in the tint for the current month. It may run past that column; a hidden
/// copy gives the row its height.
struct ScheduleGridMonthLabel: View {
    let month: JapanDate
    let isCurrentMonth: Bool

    @Environment(\.locale) private var locale

    var body: some View {
        let firstColumn = month.mondayFirstColumn
        label
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .leading) {
                                if column == firstColumn {
                                    label
                                        .foregroundStyle(
                                            isCurrentMonth ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                                }
                            }
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: month.monthTitle(locale: locale)))
            .accessibilityAddTraits(.isHeader)
    }

    private var label: some View {
        Text(verbatim: month.shortMonthTitle(locale: locale))
            .font(.title3.weight(.bold))
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 6)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }
}
