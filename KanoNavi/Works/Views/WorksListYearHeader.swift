import SwiftUI

/// The header of one year's section in a Works list, with its item count.
struct WorksListYearHeader: View {
    let year: Int
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: String(year))
            Spacer()
            Text(count, format: .number)
        }
        .monospacedDigit()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(.Works.yearWithCount(String(year), count)))
    }
}
