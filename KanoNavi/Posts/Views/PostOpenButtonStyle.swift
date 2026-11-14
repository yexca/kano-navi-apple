import SwiftUI

/// The small tinted capsule a post's open button draws in the header's
/// trailing corner. The capsule stays small, but the button answers taps
/// across at least 44 by 44 points.
struct PostOpenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.tint.opacity(0.15), in: .capsule)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
            .contentShape(.rect)
    }
}

extension ButtonStyle where Self == PostOpenButtonStyle {
    /// A post's open button: a small tinted capsule with a 44-point hit area.
    static var postOpen: PostOpenButtonStyle { PostOpenButtonStyle() }
}
