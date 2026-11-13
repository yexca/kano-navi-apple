import Foundation

/// A framing error while reading a `text/event-stream` body.
public enum SSEDecoderError: Error, Equatable, Sendable {
    /// A single line or accumulated event data exceeded the byte limit.
    case bufferLimitExceeded
}
