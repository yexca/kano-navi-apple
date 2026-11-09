import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct URLSessionTransport: APITransport {
    public var session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> TransportResponse {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        var headers: [String: String] = [:]
        for (key, value) in http.allHeaderFields {
            if let key = key as? String {
                headers[key.lowercased()] = String(describing: value)
            }
        }
        return TransportResponse(data: data, statusCode: http.statusCode, headers: headers)
    }
}
