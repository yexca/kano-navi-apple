import Foundation

/// A response read from the service, or from the cache when the service could
/// not be read, with when it was fetched.
public struct ReadResult<Value: Sendable>: Sendable {
    /// The decoded response.
    public var value: Value
    /// `true` when the service could not be read and `value` is the cached
    /// response.
    public var isFromCache: Bool
    /// When `value` was fetched from the service: the end of the read for a
    /// fresh response, or the cached response's fetch time.
    public var fetchedAt: Date

    public init(value: Value, isFromCache: Bool, fetchedAt: Date) {
        self.value = value
        self.isFromCache = isFromCache
        self.fetchedAt = fetchedAt
    }
}

extension ReadResult: Equatable where Value: Equatable {}
