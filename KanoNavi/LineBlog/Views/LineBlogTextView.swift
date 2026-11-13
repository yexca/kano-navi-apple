import SwiftUI

/// A piece of an article's running text: selectable, with tappable links
/// and its pictographs on the line at text size.
struct LineBlogTextView: View {
    let text: LineBlogRichText
    let style: LineBlogTextStyle
    let pictographs: LineBlogPictographStore

    /// A pictograph is a little taller than the letters, like an emoji,
    /// and stays inside the line so lines with and without one are evenly
    /// spaced.
    @ScaledMetric(relativeTo: .body) private var originalGlyph: CGFloat = 19
    @ScaledMetric(relativeTo: .callout) private var translationGlyph: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var lineSpacing: CGFloat = 5

    var body: some View {
        // Text without pictographs does not read the store, so it is not
        // drawn again when pictographs arrive.
        let hasPictographs = text.pictographSources.isEmpty == false
        LineBlogTextBuilder.text(
            text, images: hasPictographs ? pictographs.images : [:],
            unavailable: hasPictographs ? pictographs.unavailable : [],
            glyphHeight: style == .original ? originalGlyph : translationGlyph
        )
        .font(style == .original ? .body : .callout)
        .foregroundStyle(style == .original ? .primary : .secondary)
        .lineSpacing(lineSpacing)
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Pictographs without a description alone leave nothing to read.
        .accessibilityHidden(text.plainText.allSatisfy(\.isWhitespace))
    }
}
