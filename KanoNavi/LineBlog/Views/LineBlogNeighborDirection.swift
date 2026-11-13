import SwiftUI

/// Which neighbour of an article a button leads to.
nonisolated enum LineBlogNeighborDirection: Sendable {
    /// The article published before this one (the blog's 前の記事).
    case older
    /// The article published after this one (the blog's 次の記事).
    case newer

    var label: LocalizedStringResource {
        switch self {
        case .older: .LineBlog.older
        case .newer: .LineBlog.newer
        }
    }

    var systemImage: String {
        switch self {
        case .older: "chevron.backward"
        case .newer: "chevron.forward"
        }
    }
}
