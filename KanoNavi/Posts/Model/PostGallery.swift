import Foundation

/// The images of one post or one quote, which the viewer pages through,
/// with the page they come from: where a video or GIF plays, and the link
/// under each image in the viewer.
struct PostGallery: Equatable {
    var images: [PostImage]
    /// The post or the quoted post on its platform.
    var url: URL
    var isBilibili: Bool
}
