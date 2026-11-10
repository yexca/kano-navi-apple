import Foundation
import KanoNaviCore

/// One ready image of a post or a quote, served by the Kano Navi service.
struct PostImage: Equatable, Identifiable {
    var id: String
    var url: URL
    var width: Int?
    var height: Int?
    var alt: String?

    /// The ready media with a URL, in their order. Media still being cached
    /// or failed are left out.
    static func ready(_ media: [MediaItem]) -> [PostImage] {
        media.enumerated().compactMap { index, item in
            guard item.status == "ready", let url = item.url else { return nil }
            return PostImage(
                id: item.id ?? "\(index)-\(url.absoluteString)", url: url, width: item.width,
                height: item.height, alt: item.alt)
        }
    }

    /// A post's ready images: its `media`, or for a record with only the
    /// older single `mediaUrl`, that image when it is ready.
    static func ready(in post: Post) -> [PostImage] {
        if post.media.isEmpty == false {
            return ready(post.media)
        }
        guard post.mediaStatus == "ready", let url = post.mediaURL else { return [] }
        return [PostImage(id: url.absoluteString, url: url)]
    }

    /// Width over height, kept between tall and wide bounds so one image
    /// never takes the whole screen. `nil` when the size is unknown.
    var aspectRatio: CGFloat? {
        guard let width, let height, width > 0, height > 0 else { return nil }
        return min(max(CGFloat(width) / CGFloat(height), 0.75), 2)
    }
}
