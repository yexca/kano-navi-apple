import SwiftUI

/// A small label over its value in the viewer's caption, read as one.
struct JourneyCaptionFact: View {
    let label: LocalizedStringResource
    let value: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            value
                .font(.subheadline)
        }
        .accessibilityElement(children: .combine)
    }
}
