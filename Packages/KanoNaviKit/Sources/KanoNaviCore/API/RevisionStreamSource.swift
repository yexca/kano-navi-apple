import Foundation

/// Opens a stream of dashboard revision numbers.
public protocol RevisionStreamSource: Sendable {
    func connect() -> AsyncThrowingStream<RevisionStreamMessage, any Error>
}
