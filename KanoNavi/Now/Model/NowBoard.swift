import Foundation
import KanoNaviCore

/// Everything the Now tab shows, read from one dashboard snapshot at one
/// instant. The projection decides; this only joins records by ID. Coming Up
/// reads its entries from the calendar; see ``NowComingUp``.
struct NowBoard: Equatable {
    var profile: NowProfile
    var spotlight: NowSpotlight?
    var liveBroadcast: NowLiveBroadcast?
    /// The dashboard's events, for Coming Up's recently ended entries.
    var events: [ScheduleEvent]
    var sales: [NowSale]
    var latestVideo: NowVideo?
    var freshness: NowFreshness

    init(dashboard: Dashboard, now: Date) {
        profile = NowProfile(dashboard: dashboard)
        let spotlight = NowSpotlight(dashboard: dashboard)
        self.spotlight = spotlight
        liveBroadcast = NowLiveBroadcast(dashboard: dashboard, spotlight: spotlight)
        events = dashboard.events
        sales = NowSale.sales(in: dashboard)
        latestVideo = NowVideo.latest(in: dashboard, besides: spotlight)
        freshness = NowFreshness(meta: dashboard.meta, now: now)
    }
}
