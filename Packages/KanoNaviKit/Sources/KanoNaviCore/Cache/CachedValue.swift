import Foundation

/// A decoded cached response and when it was fetched from the service.
struct CachedValue<Value: Sendable>: Sendable {
    let value: Value
    let fetchedAt: Date
}
