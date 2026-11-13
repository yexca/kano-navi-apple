import Foundation

/// Testable boundary around `UNUserNotificationCenter` using Sendable values.
nonisolated protocol UserNotificationCenterClient: Sendable {
    func authorizationState() async -> NotificationAuthorizationState
    func requestAuthorization() async throws -> Bool
    func add(_ payload: LocalNotificationPayload) async throws
    func pendingRequestIdentifiers() async -> [String]
    func removePendingRequests(withIdentifiers identifiers: [String])
}
