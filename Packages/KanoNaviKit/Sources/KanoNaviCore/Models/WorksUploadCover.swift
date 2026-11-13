import Foundation

/// A ready cached cover: a same-host `/media/<id>?v=<sha256>` address resolved
/// against the API base URL.
public struct WorksUploadCover: Codable, Equatable, Sendable {
    public var url: URL
    /// `nil` when the cache does not know the size.
    public var width: Int?
    public var height: Int?
}
