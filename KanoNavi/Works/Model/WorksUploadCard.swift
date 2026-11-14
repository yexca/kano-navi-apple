import Foundation
import KanoNaviCore

/// An upload as the Works entry shows it: one of the collection's, joined
/// with its stored cover, or a stored video newer than the collection.
nonisolated struct WorksUploadCard: Equatable, Identifiable, Sendable {
    /// Where the card comes from, so a collection upload and a newer video
    /// with the same ID stay apart.
    enum Origin: Equatable, Sendable {
        case collection
        case recent
    }

    /// The page a tap opens, and its platform when the app names it.
    struct WatchPage: Equatable, Sendable {
        let url: URL
        let platform: VideoPlatform?
    }

    let origin: Origin
    /// The upload ID, or a newer video's platform ID.
    let sourceID: String
    /// The song as the collection writes it, or a newer video's title.
    let title: String
    /// A newer video's title language and translations; `nil` for the
    /// collection's songs, which show as written.
    let sourceLanguage: String?
    let translations: Translations?
    /// The Japan date it came out; `nil` for a newer video without a time.
    let date: JapanDate?
    let cover: WorksUploadCover?
    /// The page a tap opens; `nil` when nothing is left to watch.
    let watch: WatchPage?

    var id: String {
        switch origin {
        case .collection: "collection." + sourceID
        case .recent: "recent." + sourceID
        }
    }

    /// A collection upload. A tap opens its first watch page, in the web
    /// board's order, that the stored data does not mark as removed or
    /// private.
    init(item: WorksUploadItem) {
        origin = .collection
        sourceID = item.id
        title = item.entry.song
        sourceLanguage = nil
        translations = nil
        date = item.entry.date
        cover = item.cover
        watch = item.links.first { $0.isGone == false }.map {
            WatchPage(url: $0.link.url, platform: $0.link.platform)
        }
    }

    /// A stored video newer than the collection. A tap opens its own page.
    init(recent video: WorksRecentUpload) {
        origin = .recent
        sourceID = video.id
        title = video.title
        sourceLanguage = video.sourceLanguage
        translations = video.translations
        date = video.publishedAt.map(JapanDate.date(from:))
        cover = video.cover
        watch = WatchPage(url: video.url, platform: VideoPlatform(rawValue: video.source.rawValue))
    }

    /// Every upload newest first: the stored videos newer than the
    /// collection, then the collection's uploads joined with their stored
    /// covers. Either read may have no value yet; the other still gives
    /// its cards.
    static func newestFirst(
        list: WorksUploadListResponse?, stored: WorksUploadsResponse?
    ) -> [WorksUploadCard] {
        let recent = (stored?.recent ?? []).map(WorksUploadCard.init(recent:))
        guard let list else { return recent }
        let items = WorksYearGroup.groups(
            of: WorksUploadCatalog(list: list, stored: stored).items, order: .newestFirst, date: \.entry.date
        ).flatMap(\.items)
        return recent + items.map(WorksUploadCard.init(item:))
    }
}
