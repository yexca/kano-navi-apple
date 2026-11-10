import SwiftUI

/// A secondary link button: bordered and small, with its icon. At
/// accessibility text sizes it uses the regular size and drops the icon, so
/// the title wraps between words instead of truncating or breaking inside one.
struct CompactLinkButtonStyle: PrimitiveButtonStyle {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func makeBody(configuration: Configuration) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            Button(role: configuration.role, action: configuration.trigger) {
                configuration.label
                    .labelStyle(.titleOnly)
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
