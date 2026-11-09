import Foundation

public struct CachedResponse: Codable, Equatable, Sendable {
    public var body: Data
    public var etag: String?
    public var fetchedAt: Date
    public init(body: Data, etag: String?, fetchedAt: Date) {
        self.body = body
        self.etag = etag
        self.fetchedAt = fetchedAt
    }
}
