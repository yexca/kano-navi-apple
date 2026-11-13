import Foundation

/// A piece of a paragraph or quote as the reader lays it out: running text,
/// or a row of pictures between the text.
nonisolated enum LineBlogSegment: Hashable, Sendable {
    case text(LineBlogRichText)
    case figures([LineBlogFigure])
}
