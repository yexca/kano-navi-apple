import Foundation
import KanoNaviCore

extension WorksRecentUpload {
    /// The title with its translations, shown in the content language as
    /// the Videos tab shows a video's.
    var contentTitle: NowContentText {
        NowContentText(title, sourceLanguage: sourceLanguage, translations: translations)
    }

    /// The video's own page first, then its alternates on other platforms.
    var pageLinks: [NowLink] {
        let own = NowLink.page(on: EventPlatform(videoSource: source.rawValue), url: url)
        let others = alternates.map { NowLink.page(on: EventPlatform(videoSource: $0.source), url: $0.url) }
        return [own] + others.filter { $0.url != url }
    }
}
