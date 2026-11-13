import SwiftUI

/// The sticky header of one year on the timeline, with its milestone count:
/// side by side, or the count under the year at accessibility text sizes.
struct JourneyYearHeader: View {
    let year: Int
    let count: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        layout {
            Text(verbatim: String(year))
                .font(.title2.bold())
                .monospacedDigit()
            Spacer(minLength: 8)
                .frame(maxHeight: 0)
            Text(.Journey.milestoneCount(count))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
