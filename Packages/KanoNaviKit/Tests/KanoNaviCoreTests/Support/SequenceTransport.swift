import Foundation

@testable import KanoNaviCore

actor SequenceTransport: APITransport {
    private var responses: [Result<TransportResponse, Error>]
    private(set) var requests: [URLRequest] = []

    init(_ responses: [Result<TransportResponse, Error>]) {
        self.responses = responses
    }

    func send(_ request: URLRequest) async throws -> TransportResponse {
        requests.append(request)
        guard responses.isEmpty == false else {
            throw URLError(.notConnectedToInternet)
        }
        return try responses.removeFirst().get()
    }

    func requestCount() -> Int {
        requests.count
    }
}
