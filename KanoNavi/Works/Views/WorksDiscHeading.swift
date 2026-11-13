import KanoNaviCore
import SwiftUI

/// The heading of one disc in a track list: its number and, when the record
/// says, what the disc is.
struct WorksDiscHeading: View {
    let number: Int
    let label: LocalizedText?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: "opticaldisc")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text(.Works.discNumber(number))
            if let label {
                WorksText(label)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline.weight(.semibold))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
