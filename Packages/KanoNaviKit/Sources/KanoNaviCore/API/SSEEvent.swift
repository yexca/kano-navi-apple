import Foundation

/// One event decoded from a `text/event-stream` response.
public struct SSEEvent: Equatable, Sendable {
    public var event: String?
    public var data: String?
    public var id: String?
    public var retryMilliseconds: Int?

    public init(
        event: String? = nil,
        data: String? = nil,
        id: String? = nil,
        retryMilliseconds: Int? = nil
    ) {
        self.event = event
        self.data = data
        self.id = id
        self.retryMilliseconds = retryMilliseconds
    }
}
