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
    /// What the spotlight shows, which Coming Up leaves out.
    var shownAbove: NowComingUp.ShownAbove
    var freshness: NowFreshness

    init(dashboard: Dashboard, now: Date) {
        profile = NowProfile(dashboard: dashboard)
        let spotlight = NowSpotlight(dashboard: dashboard)
        self.spotlight = spotlight
        liveBroadcast = NowLiveBroadcast(dashboard: dashboard, spotlight: spotlight)
        events = dashboard.events
        sales = NowSale.sales(in: dashboard)
        shownAbove = Self.shownAbove(spotlight, in: dashboard)
        freshness = NowFreshness(meta: dashboard.meta, now: now)
    }

    /// The spotlight's event ID and its video's addresses, the video's own and
    /// its copies on other platforms.
    static func shownAbove(_ spotlight: NowSpotlight?, in dashboard: Dashboard) -> NowComingUp.ShownAbove {
        guard let spotlight else { return NowComingUp.ShownAbove() }
        let video = spotlight.videoID.flatMap { dashboard.video(id: $0) }
        let addresses = video.map { [$0.url] + ($0.alternates ?? []).map(\.url) } ?? []
        return NowComingUp.ShownAbove(
            eventIDs: Set([spotlight.eventID].compactMap(\.self)), videoURLs: Set(addresses))
    }
}
