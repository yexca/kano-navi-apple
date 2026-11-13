import Foundation
import KanoNaviCore

/// Answers the document read from a queue of replies; the last one repeats.
/// With `gate` set, a request waits for the gate before it is answered.
actor StubDocumentService {
    enum Reply: Sendable {
        case document(String)
        case status(Int)
        case offline
    }

    private var replies: [Reply]
    private let gate: TestGate?
    /// Opens when the first request has arrived.
    let arrived = TestGate()
    private(set) var requestCount = 0

    init(_ replies: Reply..., gate: TestGate? = nil) {
        self.replies = replies
        self.gate = gate
    }

    /// A client whose requests this service answers.
    nonisolated func client(cache: SingleDocumentCache = SingleDocumentCache()) throws -> APIClient {
        try APIClient(
            baseURL: DocumentFixtures.baseURL,
            transport: ClosureTransport { request in try await self.send(request) }, cache: cache)
    }

    private func send(_ request: URLRequest) async throws -> TransportResponse {
        requestCount += 1
        await arrived.open()
        try await gate?.wait()
        let reply = replies.count > 1 ? replies.removeFirst() : replies[0]
        switch reply {
        case .document(let title):
            return TransportResponse(
                data: DocumentFixtures.body(title), statusCode: 200, headers: ["etag": "W/\"\(title)\""])
        case .status(let status):
            return TransportResponse(data: Data(#"{"error":"not_found"}"#.utf8), statusCode: status)
        case .offline:
            throw URLError(.notConnectedToInternet)
        }
    }
}
