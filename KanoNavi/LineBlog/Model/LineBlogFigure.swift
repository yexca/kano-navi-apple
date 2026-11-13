import Foundation

/// One picture of a row of figures.
nonisolated enum LineBlogFigure: Hashable, Sendable {
    /// An archived picture, which opens in the viewer.
    case picture(LineBlogPicture)
    /// A picture the archive never captured.
    case uncaptured(LineBlogUncapturedPicture)
}
