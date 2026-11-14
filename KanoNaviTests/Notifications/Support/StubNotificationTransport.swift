import Foundation
import KanoNaviCore

actor StubNotificationTransport: APITransport {
    private var handler: @Sendable (URLRequest) throws -> TransportResponse
    private(set) var requestedPaths: [String] = []

    init(handler: @escaping @Sendable (URLRequest) throws -> TransportResponse) {
        self.handler = handler
    }

    func setHandler(_ handler: @escaping @Sendable (URLRequest) throws -> TransportResponse) {
        self.handler = handler
    }

    func requestCount(pathContaining fragment: String) -> Int {
        requestedPaths.filter { $0.contains(fragment) }.count
    }

    func send(_ request: URLRequest) async throws -> TransportResponse {
        requestedPaths.append(request.url?.path ?? "")
        return try handler(request)
    }
}
