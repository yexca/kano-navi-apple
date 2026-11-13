import SwiftUI

/// The way into one area of the collection, with how many items it holds.
/// At accessibility text sizes the icon is left out and the count sits
/// under the title, so the words have the row's width.
struct WorksAreaRow: View {
    let destination: WorksDestination
    let title: LocalizedStringResource
    let detail: LocalizedStringResource
    let systemImage: String
    let count: Int
    /// Names the row for UI tests.
    let identifier: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationLink(value: destination) {
            VStack(alignment: .leading) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                        Text(count, format: .number)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Text(detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                            Text(detail)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: systemImage)
                    }
                    .badge(count)
                }
            }
        }
        .accessibilityIdentifier("works.area." + identifier)
    }
}
