import SwiftUI

/// A comment's rating: the old form's stars or face, with the value in
/// figures beside them, read by VoiceOver as one sentence.
struct LineBlogRatingView: View {
    let rating: LineBlogRatingDisplay

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if rating.glyphs.isEmpty == false {
                Text(verbatim: rating.glyphs)
                    .foregroundStyle(.orange)
            }
            Text(verbatim: rating.figures)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .font(.footnote)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(rating.label))
    }
}
