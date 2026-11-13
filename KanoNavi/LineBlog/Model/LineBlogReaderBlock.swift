import Foundation

/// One block of an article as the reader lays it out.
nonisolated struct LineBlogReaderBlock: Identifiable, Hashable, Sendable {
    /// What the block is.
    enum Content: Hashable, Sendable {
        case paragraph(LineBlogReaderParagraph)
        case quote([LineBlogSegment])
        case rule
        case video(LineBlogVideoEmbed)
        case card(LineBlogLinkCard)
    }

    /// The block's position in the article's `blocks`, from 0.
    let id: Int
    let content: Content
}
