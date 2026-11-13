import Foundation
import KanoNaviCore

/// A synthetic one-document read on a reserved domain, for the document
/// model tests.
nonisolated enum DocumentFixtures {
    /// The document's decoded form.
    struct Note: APIResponse, Equatable {
        var title: String
    }

    /// The read of the document.
    struct NoteRequest: APIRequest {
        typealias Response = Note
        let path = "/api/note"
        let queryItems: [URLQueryItem] = []
        func validate() throws {}
    }

    static let baseURL = URL(string: "https://example.com")!
    static let cachedAt = Date(timeIntervalSince1970: 1_794_000_000)

    static func body(_ title: String) -> Data {
        Data(#"{"title":"\#(title)"}"#.utf8)
    }

    /// A cache already holding the document titled `title`, read at
    /// `cachedAt`.
    static func cache(holding title: String) -> SingleDocumentCache {
        SingleDocumentCache(
            holding: CachedResponse(body: body(title), etag: "W/\"1\"", fetchedAt: cachedAt))
    }
}
