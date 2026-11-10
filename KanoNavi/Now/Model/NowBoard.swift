import Foundation
import KanoNaviCore

/// Everything the Now tab shows, read from one dashboard snapshot at one
/// instant. The projection decides; this only joins records by ID and picks
/// the Japan dates.
struct NowBoard: Equatable {
    var spotlight: NowSpotlight?
    var liveBroadcast: NowLiveBroadcast?
    var today: JapanDate
    var todayEntries: [NowEntry]
    var tomorrow: JapanDate
    var tomorrowEntries: [NowEntry]
    var sales: [NowSale]
    var latestVideo: NowVideo?
    var freshness: NowFreshness

    init(dashboard: Dashboard, now: Date) {
        let spotlight = NowSpotlight(dashboard: dashboard)
        self.spotlight = spotlight
        liveBroadcast = NowLiveBroadcast(dashboard: dashboard, spotlight: spotlight)
        today = JapanDate.today(at: now)
        todayEntries = NowEntry.entries(on: today, in: dashboard.events)
        tomorrow = today.addingDays(1)
        tomorrowEntries = NowEntry.entries(on: tomorrow, in: dashboard.events)
        sales = NowSale.sales(in: dashboard)
        latestVideo = NowVideo.latest(in: dashboard, besides: spotlight)
        freshness = NowFreshness(meta: dashboard.meta, now: now)
    }
}
