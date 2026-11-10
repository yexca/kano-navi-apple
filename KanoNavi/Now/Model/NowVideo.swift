import Foundation
import KanoNaviCore

/// The latest video card.
struct NowVideo: Equatable, Identifiable {
    var id: String
    var title: NowContentText
    var publishedAt: Date?
    var thumbnailURL: URL?
    var url: URL
    var formCode: VideoFormCode?
    var platform: EventPlatform

    init(video: Video) {
        id = video.id
        title = NowContentText(
            video.title, sourceLanguage: video.sourceLanguage, translations: video.translations)
        publishedAt = video.publishedAt ?? video.scheduledAt
        thumbnailURL = video.thumbnailURL
        url = video.url
        formCode = video.view?.formCode
        platform = EventPlatform(videoSource: video.source)
    }

    /// The spotlight's companion video, else the summary's latest video,
    /// unless the spotlight already shows it.
    static func latest(in dashboard: Dashboard, besides spotlight: NowSpotlight?) -> NowVideo? {
        let companion = dashboard.projection?.spotlight?.companionVideoID.flatMap { dashboard.video(id: $0) }
        guard let video = companion ?? dashboard.summary.latestVideo, video.id != spotlight?.videoID else {
            return nil
        }
        return NowVideo(video: video)
    }
}
