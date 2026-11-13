import Foundation

/// A LINE BLOG picture or video file.
public struct LineBlogMedia: Codable, Equatable, Sendable {
    /// The same-host file (`/media/lineblog/<name>`), resolved against the API base URL.
    public var url: URL
    /// The displayed width of an image; `nil` for a video, which is sized from its stream.
    public var width: Int?
    /// The displayed height of an image; `nil` for a video.
    public var height: Int?
    /// `image/jpeg`, `image/png` or `video/mp4`.
    public var mimeType: String

    public var isVideo: Bool { mimeType.lowercased().hasPrefix("video/") }

    func resolvingMedia(against baseURL: URL) -> LineBlogMedia {
        var value = self
        value.url = resolveKanoMediaURL(url, against: baseURL) ?? url
        return value
    }
}
