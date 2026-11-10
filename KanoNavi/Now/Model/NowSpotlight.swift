import Foundation
import KanoNaviCore

/// The ticket at the top of the Now tab: what is live, what is next, or the
/// latest video, as `projection.spotlight` decides.
struct NowSpotlight: Equatable {
    enum Mode: Equatable {
        /// An unannounced Bilibili broadcast (`liveNow`).
        case liveNow
        /// The next or current stream or entry.
        case next
        /// The latest video, when nothing is next.
        case latest
    }

    var mode: Mode
    var isLive: Bool
    var showsMembersChip: Bool
    var title: NowContentText
    /// The start (or publish) time; `nil` for a date-only entry.
    var startsAt: Date?
    /// The Japan date of a date-only entry.
    var startsOn: JapanDate?
    var timePrecision: String?
    var thumbnailURL: URL?
    var links: [NowLink]
    var eventID: String?
    var videoID: String?
}

extension NowSpotlight {
    /// Joins `projection.spotlight` to the snapshot's records by ID. Returns
    /// `nil` when the projection names no ticket or its records are missing.
    init?(dashboard: Dashboard) {
        guard let spotlight = dashboard.projection?.spotlight else { return nil }

        if spotlight.liveNow, let live = dashboard.liveNow {
            self.init(
                mode: .liveNow,
                isLive: true,
                showsMembersChip: spotlight.membersChip,
                title: NowContentText(live.title),
                startsAt: live.startedAt,
                startsOn: nil,
                timePrecision: nil,
                thumbnailURL: nil,
                links: [.page(on: live.platform, url: live.url, isLive: true)],
                eventID: nil,
                videoID: nil
            )
            return
        }

        let video = spotlight.videoID.flatMap { dashboard.video(id: $0) }
        let event = spotlight.eventID.flatMap { dashboard.event(id: $0) }

        if spotlight.mode == .latest, let latest = video ?? dashboard.summary.latestVideo {
            self.init(
                mode: .latest,
                isLive: spotlight.isLive,
                showsMembersChip: false,
                title: NowContentText(
                    latest.title, sourceLanguage: latest.sourceLanguage, translations: latest.translations),
                startsAt: latest.publishedAt ?? latest.scheduledAt,
                startsOn: nil,
                timePrecision: nil,
                thumbnailURL: latest.thumbnailURL,
                links: Self.links(video: latest, event: nil, isLive: spotlight.isLive),
                eventID: nil,
                videoID: latest.id
            )
            return
        }

        if let video {
            self.init(
                mode: .next,
                isLive: spotlight.isLive,
                showsMembersChip: spotlight.membersChip,
                title: NowContentText(
                    video.title, sourceLanguage: video.sourceLanguage, translations: video.translations),
                startsAt: video.scheduledAt ?? event?.startsAt,
                startsOn: nil,
                timePrecision: event?.timePrecision,
                thumbnailURL: video.thumbnailURL,
                links: Self.links(video: video, event: event, isLive: spotlight.isLive),
                eventID: event?.id,
                videoID: video.id
            )
        } else if let event {
            self.init(
                mode: .next,
                isLive: spotlight.isLive,
                showsMembersChip: spotlight.membersChip,
                title: NowContentText(
                    event.title, sourceLanguage: event.sourceLanguage, translations: event.translations),
                startsAt: event.startsAt,
                startsOn: event.startsAt == nil ? event.startsOn : nil,
                timePrecision: event.timePrecision,
                thumbnailURL: nil,
                links: Self.links(event: event),
                eventID: event.id,
                videoID: nil
            )
        } else {
            return nil
        }
    }

    /// A video's own link and its alternates, then the entry's links on
    /// platforms the video has no copy on, such as a simulcast's Bilibili room.
    private static func links(video: Video, event: ScheduleEvent?, isLive: Bool) -> [NowLink] {
        var result = [
            NowLink.page(on: EventPlatform(videoSource: video.source), url: video.url, isLive: isLive)
        ]
        for alternate in video.alternates ?? [] {
            result.append(.page(on: EventPlatform(videoSource: alternate.source), url: alternate.url))
        }
        guard let event else { return unique(result) }
        let covered = Set([video.source] + (video.alternates ?? []).map(\.source))
        for link in event.links ?? [] where covered.contains(link.platform.rawValue) == false {
            guard let url = link.url else { continue }
            result.append(.page(on: link.platform, url: url, isLive: link.liveStatus == .live))
        }
        return unique(result)
    }

    /// An entry's platform links in API order, then its announcement when no
    /// platform link is that page.
    static func links(event: ScheduleEvent) -> [NowLink] {
        var result: [NowLink] = []
        for link in event.links ?? [] {
            guard let url = link.url else { continue }
            result.append(.page(on: link.platform, url: url, isLive: link.liveStatus == .live))
        }
        if let url = event.liveURL {
            result.append(.page(on: .bilibili, url: url, isLive: event.liveStatus == .live))
        }
        if let url = event.url, result.contains(where: { $0.url == url }) == false {
            result.append(NowLink(destination: .announcement, url: url, isLive: false))
        }
        return unique(result)
    }

    private static func unique(_ links: [NowLink]) -> [NowLink] {
        var seen = Set<URL>()
        return links.filter { seen.insert($0.url).inserted }
    }
}

extension Dashboard {
    /// The snapshot's video with this ID, including the summary's videos.
    func video(id: String) -> Video? {
        videos.first { $0.id == id }
            ?? [summary.nextStream, summary.latestVideo].compactMap(\.self).first { $0.id == id }
    }

    /// The snapshot's event with this ID, including the summary's next event.
    func event(id: String) -> ScheduleEvent? {
        events.first { $0.id == id } ?? summary.nextEvent.flatMap { $0.id == id ? $0 : nil }
    }
}
