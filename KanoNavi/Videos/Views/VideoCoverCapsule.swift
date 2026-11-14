import SwiftUI

/// A small label over a video's cover, such as its length or "Live": white
/// on a dark or colored capsule.
struct VideoCoverCapsule: View {
    let text: Text
    var systemImage: String?
    var background: Color = .black.opacity(0.75)
    /// Capitals, as a live badge is drawn.
    var isUppercased = false

    var body: some View {
        HStack(spacing: 3) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            text
                .textCase(isUppercased ? .uppercase : nil)
        }
        .font(.caption.weight(.semibold))
        .monospacedDigit()
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(background, in: .capsule)
    }
}
