import Foundation
import KanoNaviCore

/// An unannounced Bilibili broadcast from the dashboard's `liveNow`, shown on
/// its own card when the spotlight does not already show it.
struct NowLiveBroadcast: Equatable {
    var platform: EventPlatform
    var title: String
    var url: URL
    var startedAt: Date

    init?(dashboard: Dashboard, spotlight: NowSpotlight?) {
        guard let live = dashboard.liveNow, spotlight?.mode != .liveNow else { return nil }
        platform = live.platform
        title = live.title
        url = live.url
        startedAt = live.startedAt
    }
}
