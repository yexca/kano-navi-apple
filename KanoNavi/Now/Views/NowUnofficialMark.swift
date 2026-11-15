import SwiftUI

/// "Unofficial" in a thin Berry capsule, as the web board marks its name,
/// so the app is never taken for an official one.
struct NowUnofficialMark: View {
    var body: some View {
        Text(.Now.unofficialMark)
            .font(.caption2.bold())
            .foregroundStyle(.berry)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay {
                Capsule()
                    .strokeBorder(.berry.opacity(0.45), lineWidth: 1)
            }
            .fixedSize()
    }
}
