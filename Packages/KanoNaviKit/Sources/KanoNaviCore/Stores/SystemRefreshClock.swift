import Foundation

public struct SystemRefreshClock: RefreshClock {
    public init() {}
    public var now: Date { Date() }
    public func sleep(for duration: Duration) async throws { try await Task.sleep(for: duration) }
}
