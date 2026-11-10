import SwiftUI

/// A small capsule with a label, the shared look of the state, members and
/// sale chips.
struct ComponentChip: View {
    let title: LocalizedStringResource
    let systemImage: String?
    let tint: Color

    var body: some View {
        Group {
            if let systemImage {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: systemImage)
                }
            } else {
                Text(title)
            }
        }
        .font(.caption.weight(.semibold))
        .labelStyle(ChipLabelStyle())
        .foregroundStyle(tint)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(tint.opacity(0.14), in: .capsule)
    }
}

/// A label with a tight gap between its icon and title, for chips.
private struct ChipLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
            configuration.title
        }
    }
}
