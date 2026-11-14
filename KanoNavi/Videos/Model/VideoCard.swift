import Foundation
import KanoNaviCore

/// One video as the Videos tab shows it, from a shelf or an archive page.
struct VideoCard: Equatable, Identifiable {
    var id: String
    var title: NowContentText
    /// The cover, resolved against the API base URL.
    var thumbnailURL: URL?
    /// The scheduled start, or the publication without one.
    var time: Date?
    var status: VideoStatusMark?
    /// The form chip, shown when the video has no status mark.
    var formCode: VideoFormCode?
    /// The video's tag code, such as `game`, `talk`, `song` or `video`.
    var tag: String?
    var availability: VideoAvailabilityMark?
    /// The video's own page first, then its alternates on other platforms.
    var links: [NowLink]
    /// Whether the video is a Short, drawn as a vertical card.
    var isShort: Bool
    /// The shelf filter's kind for the video's form.
    var kind: VideoShelfKind
    var durationSeconds: Int?

    init(video: Video) {
        id = video.id
        title = NowContentText(
            video.title, sourceLanguage: video.sourceLanguage, translations: video.translations)
        thumbnailURL = video.thumbnailURL
        time = video.scheduledAt ?? video.publishedAt
        status = VideoStatusMark(video: video)
        formCode = video.view?.formCode
        tag = video.tag
        availability = VideoAvailabilityMark(video.availability)
        let own = NowLink.page(
            on: EventPlatform(videoSource: video.source), url: video.url, isLive: status == .live)
        let alternates = (video.alternates ?? []).map { alternate in
            NowLink.page(on: EventPlatform(videoSource: alternate.source), url: alternate.url)
        }
        links = [own] + alternates.filter { $0.url != video.url }
        isShort = video.view?.formCode == .short || video.isShort == true
        kind = VideoShelfKind(video: video)
        durationSeconds = video.durationSeconds
    }

    /// The form to show: none while a status mark says more.
    var shownFormCode: VideoFormCode? {
        status == nil ? formCode : nil
    }

    /// Whether the video, or one of its alternates, is on a platform.
    func isOn(_ platform: VideoShelfPlatform) -> Bool {
        links.contains { $0.destination == .platform(platform.platform) }
    }

    /// The card with its first link to a platform moved to the front, so the
    /// card opens that page; unchanged when it has none.
    func leading(with platform: VideoShelfPlatform) -> VideoCard {
        guard let index = links.firstIndex(where: { $0.destination == .platform(platform.platform) }) else {
            return self
        }
        var card = self
        card.links.insert(card.links.remove(at: index), at: 0)
        return card
    }

    /// The length as the platforms show it, such as `4:49` or `2:01:05`, or
    /// `nil` when it is unknown.
    var lengthText: String? {
        guard let durationSeconds, durationSeconds > 0 else { return nil }
        let duration = Duration.seconds(durationSeconds)
        let pattern: Duration.TimeFormatStyle.Pattern =
            durationSeconds >= 3600 ? .hourMinuteSecond : .minuteSecond
        return duration.formatted(.time(pattern: pattern))
    }
}
