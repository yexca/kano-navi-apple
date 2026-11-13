import SwiftUI

/// The heading of one year in a Works list, with how many items it has.
struct WorksYearHeader: View {
    let year: Int
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: String(year))
                .font(.title2.bold())
                .monospacedDigit()
            Spacer()
            Text(count, format: .number)
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(.Works.yearWithCount(String(year), count)))
        .accessibilityAddTraits(.isHeader)
    }
}
