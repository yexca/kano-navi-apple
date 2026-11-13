import SwiftUI

/// Marks a text as a machine translation: a bar beside it for the eye, and
/// "Machine translation" read before it for VoiceOver.
struct LineBlogTranslationMark<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.leading, 12)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.tint.opacity(0.5))
                    .frame(width: 3)
            }
            .accessibilityValue(Text(.LineBlog.machineTranslation))
    }
}
