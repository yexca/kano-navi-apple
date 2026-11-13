import Foundation

/// One run of an article's running text.
nonisolated enum LineBlogTextRun: Hashable, Sendable {
    /// Text, with `\n` for a line break, and the link around it.
    case text(String, link: LineBlogLinkTarget?)
    /// A pictograph on the text's line, and the link around it.
    case pictograph(LineBlogPictograph, link: LineBlogLinkTarget?)
}
