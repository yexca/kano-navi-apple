import SwiftUI

/// Builds the one `Text` a piece of running text is drawn as.
///
/// A paragraph is a single `Text`, so the system's text layout wraps it,
/// selects it and reads it as one piece, and long Japanese text with many
/// pictographs costs one layout. Text runs are attributed strings, whose
/// links the system makes tappable and lists for VoiceOver, underlined so
/// they are not marked by colour alone; a pictograph is an image run
/// between them, scaled to the text's size and lowered onto its line the
/// way an emoji sits.
enum LineBlogTextBuilder {
    /// How far below the baseline a pictograph reaches, as a share of its
    /// height: about an emoji's descent.
    private static let descent: CGFloat = 0.2

    /// - Parameters:
    ///   - images: The pictographs decoded so far, by file address.
    ///   - unavailable: The pictograph files that cannot be shown.
    ///   - glyphHeight: The height of a pictograph, in points, at the
    ///     current text size.
    static func text(
        _ rich: LineBlogRichText, images: [URL: CGImage], unavailable: Set<URL>, glyphHeight: CGFloat
    ) -> Text {
        var pieces: [Text] = []
        var pending = AttributedString()

        func flush() {
            guard pending.characters.isEmpty == false else { return }
            pieces.append(Text(pending))
            pending = AttributedString()
        }

        for run in rich.runs {
            switch run {
            case .text(let string, let link):
                pending += attributed(string, link: link)
            case .pictograph(let pictograph, let link):
                if let url = pictograph.source?.url, let image = images[url], image.height > 0 {
                    flush()
                    if let link {
                        pieces.append(linkedGlyph(image, link: link))
                    } else {
                        pieces.append(glyph(image, alt: pictograph.alt, height: glyphHeight))
                    }
                } else if let url = pictograph.source?.url, unavailable.contains(url) == false {
                    // Still loading: a full-width space holds its place.
                    pending += attributed("\u{3000}", link: link)
                } else if let alt = pictograph.alt, alt.isEmpty == false {
                    pending += attributed("〔\(alt)〕", link: link)
                }
            }
        }
        flush()
        return joined(pieces)
    }

    private static func attributed(_ string: String, link: LineBlogLinkTarget?) -> AttributedString {
        var part = AttributedString(string)
        if let link {
            part.link = link.url
            part.underlineStyle = .single
        }
        return part
    }

    private static func glyph(_ image: CGImage, alt: String?, height: CGFloat) -> Text {
        let scale = CGFloat(image.height) / max(height, 1)
        let picture =
            if let alt, alt.isEmpty == false {
                Image(image, scale: scale, label: Text(verbatim: alt))
            } else {
                Image(decorative: image, scale: scale)
            }
        return Text(picture.interpolation(.high)).baselineOffset(-height * descent)
    }

    /// A pictograph inside a link. An image run cannot carry a link, so the
    /// run is a linked full-width space, which the system makes tappable
    /// like any linked text, and `LineBlogLinkedPictographRenderer` draws
    /// the pictograph over it. It is one character wide, a little smaller
    /// than a pictograph outside a link.
    private static func linkedGlyph(_ image: CGImage, link: LineBlogLinkTarget) -> Text {
        Text(attributed("\u{3000}", link: link))
            .customAttribute(LineBlogLinkedPictographAttribute(image: image))
    }

    /// The pieces as one text. The interpolation is built by hand, so the
    /// pieces stay in one flat text however many there are, and no format
    /// string is extracted for translation.
    private static func joined(_ pieces: [Text]) -> Text {
        guard pieces.count > 1 else { return pieces.first ?? Text(verbatim: "") }
        var interpolation = LocalizedStringKey.StringInterpolation(
            literalCapacity: 0, interpolationCount: pieces.count)
        for piece in pieces {
            interpolation.appendInterpolation(piece)
        }
        return Text(LocalizedStringKey(stringInterpolation: interpolation))
    }
}
