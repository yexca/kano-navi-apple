import Foundation

@testable import KanoNavi

actor MockUserNotificationCenterClient: UserNotificationCenterClient {
    var status: NotificationAuthorizationState
    var grantOnRequest: Bool
    private(set) var requestAuthorizationCount = 0
    private(set) var addedPayloads: [LocalNotificationPayload] = []

    init(
        status: NotificationAuthorizationState = .authorized,
        grantOnRequest: Bool = true
    ) {
        self.status = status
        self.grantOnRequest = grantOnRequest
    }

    func setStatus(_ newStatus: NotificationAuthorizationState) {
        status = newStatus
    }

    func authorizationState() async -> NotificationAuthorizationState {
        status
    }

    func requestAuthorization() async throws -> Bool {
        requestAuthorizationCount += 1
        status = grantOnRequest ? .authorized : .denied
        return grantOnRequest
    }

    func add(_ payload: LocalNotificationPayload) async throws {
        addedPayloads.removeAll { $0.id == payload.id }
        addedPayloads.append(payload)
    }

    func pendingRequestIdentifiers() async -> [String] {
        addedPayloads.filter { $0.triggerDate != nil }.map(\.id)
    }

    nonisolated func removePendingRequests(withIdentifiers identifiers: [String]) {
        let targets = Set(identifiers)
        Task {
            await removeStored(targets)
        }
    }

    private func removeStored(_ targets: Set<String>) {
        addedPayloads.removeAll { targets.contains($0.id) }
    }
}
