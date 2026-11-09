import Foundation

public protocol RefreshClock: Sendable {
    var now: Date { get }
    func sleep(for duration: Duration) async throws
}

public struct SystemRefreshClock: RefreshClock {
    public init() {}
    public var now: Date { Date() }
    public func sleep(for duration: Duration) async throws { try await Task.sleep(for: duration) }
}
