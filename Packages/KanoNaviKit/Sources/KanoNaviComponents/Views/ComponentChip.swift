import SwiftUI

/// A small capsule with a label, the shared look of the state, members and
/// sale chips.
///
/// Screens use it for other labels in the same look, such as a video's form,
/// tag or availability: pass a label from `DisplayCodeLabels`, an optional SF
/// Symbol and a tint (`.secondary` for a neutral code). Safe in widgets.
public struct ComponentChip: View {
    let title: LocalizedStringResource
    let systemImage: String?
    let tint: Color

    /// Creates a chip with a title, an optional SF Symbol drawn before it and
    /// the tint of its text and background.
    public init(title: LocalizedStringResource, systemImage: String? = nil, tint: Color) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
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
