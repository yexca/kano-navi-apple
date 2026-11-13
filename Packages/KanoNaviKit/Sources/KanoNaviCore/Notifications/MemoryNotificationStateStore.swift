import Foundation

/// In-memory notification baseline store for tests and previews.
public actor MemoryNotificationStateStore: NotificationStateStore {
    private var baseline: NotificationBaseline?

    public init(baseline: NotificationBaseline? = nil) {
        self.baseline = baseline
    }

    public func load() async -> NotificationBaseline? {
        baseline
    }

    public func save(_ baseline: NotificationBaseline) async {
        self.baseline = baseline
    }

    public func clear() async {
        baseline = nil
    }
}
