import Foundation

/// A video of an article: a file on the service's media route, a YouTube
/// video with a downloaded copy, or a YouTube video the archive only links.
nonisolated struct LineBlogVideoEmbed: Hashable, Sendable {
    /// The same-host file to play, or `nil` without a downloaded copy.
    let file: URL?
    /// The still shown before playing.
    let cover: MediaImageSource?
    /// The video's page on YouTube (provenance), opened on request.
    let watchURL: URL?
    /// The archived capture of that page (provenance).
    let archiveURL: URL?
}
