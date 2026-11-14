import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Foreground snapshots plan timed reminders from a fresh calendar read and
/// only advance the baseline, never posting immediate alerts.
@MainActor
struct ForegroundReminderTests {
    private struct Harness {
        let controller: NotificationController
        let center: MockUserNotificationCenterClient
        let transport: StubNotificationTransport
    }

    /// A controller with notifications already on, so no preference sync runs
    /// alongside the test.
    private func makeHarness(
        cache: MemoryResponseCache = MemoryResponseCache(),
        handler: @escaping @Sendable (URLRequest) throws -> TransportResponse
    ) throws -> Harness {
        let suiteName = "com.yexca.kanonavi.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        let preferencesStore = NotificationPreferencesStore(defaults: defaults)
        preferencesStore.save(NotificationPreferences(isEnabled: true))

        let transport = StubNotificationTransport(handler: handler)
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: cache
        )
        let center = MockUserNotificationCenterClient(status: .authorized)
        let controller = NotificationController(
            client: client,
            calendar: CalendarReader(client: client),
            stateStore: MemoryNotificationStateStore(),
            preferencesStore: preferencesStore,
            center: center,
            backgroundScheduler: MockBackgroundRefreshScheduler(),
            defaults: defaults
        )
        return Harness(controller: controller, center: center, transport: transport)
    }

    private static func calendarResponder(_ calendar: Data)
        -> @Sendable (URLRequest) throws ->
        TransportResponse
    {
        { _ in TransportResponse(data: calendar, statusCode: 200) }
    }

    private func reminderIDs(_ center: MockUserNotificationCenterClient) async -> [String] {
        await center.pendingRequestIdentifiers().filter { $0.hasPrefix("kanonavi.reminder.") }
    }

    private let streamStart = Date().addingTimeInterval(2 * 60 * 60)

    @Test func snapshotAfterCacheFilledSchedulesReminderForEntryOnlyFreshReadHas() async throws {
        let emptyCalendar = try NotificationFixtures.calendarPageData()
        let harness = try makeHarness(handler: Self.calendarResponder(emptyCalendar))

        await harness.controller.observeForegroundSnapshot(try NotificationFixtures.dashboard(revision: 1))
        #expect(await reminderIDs(harness.center).isEmpty)

        let addedCalendar = try NotificationFixtures.calendarPageData(events: [
            NotificationFixtures.streamJSON(id: "added-stream", startsAt: streamStart)
        ])
        await harness.transport.setHandler(Self.calendarResponder(addedCalendar))
        await harness.controller.observeForegroundSnapshot(try NotificationFixtures.dashboard(revision: 2))

        #expect(await reminderIDs(harness.center) == ["kanonavi.reminder.event.added-stream.tenMinutes"])
    }

    @Test func offlineReadFallsBackToCachedCalendar() async throws {
        let cache = MemoryResponseCache()
        let calendar = try NotificationFixtures.calendarPageData(events: [
            NotificationFixtures.streamJSON(id: "cached-stream", startsAt: streamStart)
        ])
        let online = try makeHarness(cache: cache, handler: Self.calendarResponder(calendar))
        await online.controller.observeForegroundSnapshot(try NotificationFixtures.dashboard(revision: 1))

        let offline = try makeHarness(cache: cache) { _ in throw URLError(.notConnectedToInternet) }
        await offline.controller.observeForegroundSnapshot(try NotificationFixtures.dashboard(revision: 1))

        #expect(await offline.transport.requestCount(pathContaining: "/calendar") == 1)
        #expect(await reminderIDs(offline.center) == ["kanonavi.reminder.event.cached-stream.tenMinutes"])
    }

    @Test func concurrentSnapshotsShareOneCalendarRead() async throws {
        let calendar = try NotificationFixtures.calendarPageData(events: [
            NotificationFixtures.streamJSON(id: "shared-stream", startsAt: streamStart)
        ])
        let harness = try makeHarness(handler: Self.calendarResponder(calendar))
        let dashboard = try NotificationFixtures.dashboard(revision: 1)
        let controller = harness.controller

        // `Task.immediate` runs each call up to its first suspension right
        // away, so the second snapshot arrives while the first read is open.
        let first = Task.immediate { await controller.observeForegroundSnapshot(dashboard) }
        let second = Task.immediate { await controller.observeForegroundSnapshot(dashboard) }
        await first.value
        await second.value

        #expect(await harness.transport.requestCount(pathContaining: "/calendar") == 1)
        #expect(await reminderIDs(harness.center) == ["kanonavi.reminder.event.shared-stream.tenMinutes"])
    }

    @Test func foregroundEvaluationNeverPostsImmediateAlerts() async throws {
        let emptyCalendar = try NotificationFixtures.calendarPageData()
        let harness = try makeHarness(handler: Self.calendarResponder(emptyCalendar))
        await harness.controller.observeForegroundSnapshot(try NotificationFixtures.dashboard(revision: 1))

        let addedCalendar = try NotificationFixtures.calendarPageData(events: [
            NotificationFixtures.streamJSON(id: "new-stream", startsAt: streamStart)
        ])
        await harness.transport.setHandler(Self.calendarResponder(addedCalendar))
        let withPost = try NotificationFixtures.dashboard(
            posts: [NotificationFixtures.freshPostJSON(id: "fresh-post")],
            revision: 2
        )
        await harness.controller.observeForegroundSnapshot(withPost)

        let payloads = await harness.center.addedPayloads
        #expect(payloads.map(\.id) == ["kanonavi.reminder.event.new-stream.tenMinutes"])
        #expect(payloads.allSatisfy { $0.triggerDate != nil })
    }
}
