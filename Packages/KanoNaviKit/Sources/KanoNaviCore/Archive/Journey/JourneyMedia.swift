import Foundation

/// One image of the Journey timeline or gallery. Every field is present; a
/// field that does not apply to the item's `origin` is `nil`.
public struct JourneyMedia: Codable, Equatable, Sendable, Identifiable {
    public var origin: JourneyMediaOrigin
    /// Stable image code; a release cover's is `<releaseId>/<name>`.
    public var id: String
    /// The same-host file (`/media/journey/…` or `/media/works/…`), resolved
    /// against the API base URL.
    public var url: URL
    public var width: Int
    public var height: Int
    public var mimeType: String
    /// The branch IDs whose gallery lists the image.
    public var branches: [String]
    public var category: JourneyMediaCategory
    public var title: LocalizedText
    /// The Japan date the image is dated by, or `nil` when unknown.
    public var date: JapanDate?
    public var dateKind: JourneyMediaDateKind
    public var sourceKind: JourneyMediaSourceKind
    /// Code of the provenance note to show, such as `cover` or `artwork`.
    public var note: String?
    /// A CSS `object-position` (such as `50% 0%`) that anchors a cropped thumbnail.
    public var focus: String?
    /// The credit line the publisher requests, shown as written.
    public var credit: String?
    /// Who made the picture, as written.
    public var creator: String?
    /// `HH:MM:SS` of a video frame.
    public var frameTime: String?
    /// The page the image comes from (provenance).
    public var sourcePage: URL?
    /// The original third-party file address (provenance, never loaded).
    public var sourceURL: URL?
    /// The original stream at the frame of a third-party archive frame (provenance).
    public var originalStream: URL?
    /// The Works release of a cover.
    public var releaseID: String?
    /// Whether every edition of the cover's release was withdrawn.
    public var cancelled: Bool?
    /// A release cover as a Works image, with its caption, credit and third-party mark.
    public var cover: WorksImage?

    enum CodingKeys: String, CodingKey {
        case origin, id, url, width, height, mimeType, branches, category, title, date, dateKind,
            sourceKind, note, focus, credit, creator, frameTime, sourcePage
        case sourceURL = "sourceUrl"
        case originalStream
        case releaseID = "releaseId"
        case cancelled, cover
    }

    func resolvingMedia(against baseURL: URL) -> JourneyMedia {
        var value = self
        value.url = resolveKanoMediaURL(url, against: baseURL) ?? url
        value.cover = cover?.resolvingMedia(against: baseURL)
        return value
    }
}
