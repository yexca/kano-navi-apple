import Foundation
import KanoNaviCore

/// Answers requests from a queue of canned results, failing as offline once
/// the queue is empty.
actor StubTransport: APITransport {
    private var responses: [Result<TransportResponse, URLError>]

    init(_ responses: [Result<TransportResponse, URLError>]) {
        self.responses = responses
    }

    func send(_ request: URLRequest) async throws -> TransportResponse {
        guard responses.isEmpty == false else { throw URLError(.notConnectedToInternet) }
        return try responses.removeFirst().get()
    }
}
