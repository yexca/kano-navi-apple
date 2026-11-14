import Foundation
import KanoNaviCore

/// One post of an archive page, with the page's account avatars, which its
/// avatar resolves from.
nonisolated struct PostArchiveEntry: Equatable, Sendable {
    var post: Post
    /// The page's `accountAvatars`, `nil` when the response leaves it out.
    var accountAvatars: [String: URL?]?
}
