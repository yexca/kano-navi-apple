import Foundation

/// Persists the notification diff baseline across launches and background refreshes.
public protocol NotificationStateStore: Sendable {
    func load() async -> NotificationBaseline?
    func save(_ baseline: NotificationBaseline) async
    func clear() async
}
