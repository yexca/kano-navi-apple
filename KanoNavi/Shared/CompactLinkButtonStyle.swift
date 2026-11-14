import SwiftUI

/// A secondary link button: bordered and small, with its icon. At
/// accessibility text sizes it uses the regular size and keeps the icon, which
/// is often a platform's logo that a short name such as "X" needs; the title
/// wraps between words beside it.
struct CompactLinkButtonStyle: PrimitiveButtonStyle {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func makeBody(configuration: Configuration) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            Button(role: configuration.role, action: configuration.trigger) {
                configuration.label
                    .labelStyle(.titleAndIcon)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.bordered)
        } else {
            Button(role: configuration.role, action: configuration.trigger) {
                configuration.label
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}

extension PrimitiveButtonStyle where Self == CompactLinkButtonStyle {
    /// A small bordered link button that stays readable at accessibility
    /// text sizes.
    static var compactLink: CompactLinkButtonStyle { CompactLinkButtonStyle() }
}
