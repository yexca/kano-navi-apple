import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NotificationControllerTests {
    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "com.yexca.kanonavi.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    private func calendarPageData(events: [[String: Any]] = []) throws -> Data {
        let object: [String: Any] = [
            "events": events,
            "scheduleImages": [],
            "adjacent": ["previous": NSNull(), "next": NSNull()],
            "dayCounts": [:],
            "total": events.count,
            "page": 1,
            "pageSize": 100,
            "totalPages": 1,
            "hasNext": false,
            "revision": 1,
        ]
        return try JSONSerialization.data(withJSONObject: object)
    }

    private func dashboardData(posts: [[String: Any]] = [], revision: Int) throws -> Data {
        let object: [String: Any] = [
            "profile": [
                "displayName": "Synthetic",
                "romanizedName": "Synthetic",
                "bio": "",
                "xUrl": "https://example.com/x",
                "youtubeUrl": "https://example.com/youtube",
            ],
            "projection": [
                "version": 1,
                "focus": ["eventIds": [], "videoIds": []],
                "spotlight": NSNull(),
                "sales": [],
                "shelf": [
                    "leadIsFeatured": false,
                    "reservations": [],
                    "works": [],
                    "archives": [],
                    "shorts": [],
                ],
            ],
            "summary": [:],
            "posts": posts,
            "events": [],
            "videos": [],
            "timeline": [],
            "resources": [],
            "assets": [],
            "scheduleImages": [],
            "meta": [
                "postWindowDays": 7,
                "xAccounts": ["kano_synthetic"],
                "revision": revision,
            ],
        ]
        return try JSONSerialization.data(withJSONObject: object)
    }

    @Test func deniedPermissionKeepsMasterSwitchDisabled() async throws {
        let defaults = try makeDefaults()
        let center = MockUserNotificationCenterClient(status: .notDetermined, grantOnRequest: false)
        let scheduler = MockBackgroundRefreshScheduler()
        let emptyCalendar = try calendarPageData()
        let transport = StubNotificationTransport { _ in
            TransportResponse(data: emptyCalendar, statusCode: 200)
        }
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
        let controller = NotificationController(
            client: client,
            calendar: CalendarReader(client: client),
            stateStore: MemoryNotificationStateStore(),
            preferencesStore: NotificationPreferencesStore(defaults: defaults),
            center: center,
            backgroundScheduler: scheduler,
            defaults: defaults
        )

        await controller.setMasterEnabled(true)

        #expect(await center.requestAuthorizationCount == 1)
        #expect(controller.authorizationState == .denied)
        #expect(controller.preferences.isEnabled == false)
    }

    @Test func backgroundRefreshDeliversDiffNotificationAfterBaselineSeed() async throws {
        let defaults = try makeDefaults()
        let center = MockUserNotificationCenterClient(status: .authorized)
        let scheduler = MockBackgroundRefreshScheduler()
        let stateStore = MemoryNotificationStateStore()

        let initialDashboardData = try dashboardData(revision: 1)
        let calendarData = try calendarPageData()

        let transport = StubNotificationTransport { request in
            let path = request.url?.path ?? ""
            if path.contains("/calendar") {
                return TransportResponse(data: calendarData, statusCode: 200)
            }
            return TransportResponse(data: initialDashboardData, statusCode: 200)
        }
        let client = try APIClient(
            baseURL: try #require(URL(string: "https://api.example.com")),
            transport: transport,
            cache: MemoryResponseCache()
        )
        let controller = NotificationController(
            client: client,
            calendar: CalendarReader(client: client),
            stateStore: stateStore,
            preferencesStore: NotificationPreferencesStore(defaults: defaults),
            center: center,
            backgroundScheduler: scheduler,
            defaults: defaults
        )

        await controller.setMasterEnabled(true)

        // First background pass establishes cold-start baseline silently.
        await controller.performBackgroundRefresh()
        #expect((await center.addedPayloads).isEmpty)

        // Second background pass finds a fresh X post and delivers one local notification.
        let postJSON: [String: Any] = [
            "id": "fresh-post-1",
            "source": "x",
            "accountHandle": "kano_synthetic",
            "publishedAt": Date().ISO8601Format(),
            "text": "New announcement!",
            "url": "https://example.com/post/1",
            "media": [],
            "mediaStatus": "none",
        ]
        let secondData = try dashboardData(posts: [postJSON], revision: 2)

        await transport.setHandler { request in
            let path = request.url?.path ?? ""
            if path.contains("/calendar") {
                return TransportResponse(data: calendarData, statusCode: 200)
            }
            return TransportResponse(data: secondData, statusCode: 200)
        }

        await controller.performBackgroundRefresh()
        let delivered = await center.addedPayloads
        #expect(delivered.map(\.id) == ["kanonavi.post.fresh-post-1"])
        #expect(scheduler.scheduledCount >= 2)
    }
}
