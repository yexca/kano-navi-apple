import Foundation

/// A Works cover, disc photo, bonus image or cutout; also a Journey release
/// cover's `cover`.
public struct WorksImage: Codable, Equatable, Sendable {
    /// The same-host file (`/media/works/<name>`), resolved against the API base URL.
    public var url: URL
    public var width: Int
    public var height: Int
    public var mimeType: String
    public var caption: LocalizedText?
    /// The page the file was taken from (provenance, never loaded).
    public var sourceURL: URL?
    /// The site named instead of a page, as written.
    public var sourceLabel: String?
    /// Who scanned or photographed it, or `nil` for a file from a person's own copy.
    public var credit: WorksImageCredit?
    /// Whether the file is a store's, database's or collector's copy of the
    /// artwork rather than the publisher's file; `nil` for a cutout.
    public var thirdParty: Bool?

    enum CodingKeys: String, CodingKey {
        case url, width, height, mimeType, caption
        case sourceURL = "sourceUrl"
        case sourceLabel, credit, thirdParty
    }

    func resolvingMedia(against baseURL: URL) -> WorksImage {
        var value = self
        value.url = resolveKanoMediaURL(url, against: baseURL) ?? url
        return value
    }
}

/// The credit a Works image's publisher or contributor requests.
public struct WorksImageCredit: Codable, Equatable, Sendable {
    public var role: WorksImageCreditRole
    public var name: String?
    /// The contributor's page (provenance).
    public var url: URL?
}
