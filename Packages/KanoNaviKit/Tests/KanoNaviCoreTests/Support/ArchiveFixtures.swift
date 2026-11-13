import Foundation
import Testing

@testable import KanoNaviCore

/// Synthetic archive fixtures and a client that serves them by request path.
enum ArchiveFixtures {
    static let baseURL = URL(string: "https://api.example.com")!

    static func data(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        try JSONDecoder.kanoNavi().decode(type, from: Data(json.utf8))
    }

    /// A client answering each path in `routes` with its fixture and anything
    /// else with 404 `{"error":"not_found"}`.
    static func client(
        _ routes: [String: String], cache: any ResponseCache = MemoryResponseCache()
    ) throws -> APIClient {
        var bodies = [String: Data]()
        for (path, name) in routes {
            bodies[path] = try data(name)
        }
        let served = bodies
        return try APIClient(
            baseURL: baseURL,
            transport: ClosureTransport { request in
                guard let path = request.url?.path, let body = served[path] else {
                    return TransportResponse(data: Data(#"{"error":"not_found"}"#.utf8), statusCode: 404)
                }
                return TransportResponse(data: body, statusCode: 200, headers: ["ETag": #"W/"fixture""#])
            },
            cache: cache
        )
    }
}
