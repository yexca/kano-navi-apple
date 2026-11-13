import SwiftUI

/// The sticky header of one year on the timeline, with its milestone count.
struct JourneyYearHeader: View {
    let year: Int
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: String(year))
                .font(.title2.bold())
                .monospacedDigit()
            Spacer()
            Text(.Journey.milestoneCount(count))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
