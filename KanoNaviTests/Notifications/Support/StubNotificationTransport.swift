import Foundation
import KanoNaviCore

actor StubNotificationTransport: APITransport {
    private var handler: @Sendable (URLRequest) throws -> TransportResponse

    init(handler: @escaping @Sendable (URLRequest) throws -> TransportResponse) {
        self.handler = handler
    }

    func setHandler(_ handler: @escaping @Sendable (URLRequest) throws -> TransportResponse) {
        self.handler = handler
    }

    func send(_ request: URLRequest) async throws -> TransportResponse {
        try handler(request)
    }
}
