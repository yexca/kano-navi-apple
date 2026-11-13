import Foundation
import KanoNaviCore

/// One upload of the collection joined, by upload ID, with what the service
/// has stored for it: a cover and its videos. Without stored data the upload
/// still shows from the list alone.
nonisolated struct WorksUploadItem: Equatable, Identifiable, Sendable {
    let entry: WorksUploadEntry
    /// The stored cover, when the join has one.
    let cover: WorksUploadCover?
    /// The watch pages built from the entry's platform IDs.
    let links: [WorksUploadLink]
    /// Every watch page of the upload is a stored video that is removed or
    /// private, so nothing is left to watch. A page the service stores
    /// nothing about, such as one on niconico, may still be there, and an
    /// upload with one is never gone: only its removed pages are marked.
    let isGone: Bool
    /// The first stored length in seconds.
    let lengthSeconds: Int?

    var id: String { entry.id }

    init(entry: WorksUploadEntry, state: WorksUploadState? = nil) {
        self.entry = entry
        cover = state?.cover
        let videos = state?.videos ?? []
        let gone = Set(videos.filter(Self.isGone).map { StoredVideoKey(source: $0.source, id: $0.id) })
        let links = WorksUploadLink.links(of: entry.videoIDs) { link in
            gone.contains(StoredVideoKey(platform: link.platform, id: link.id))
        }
        self.links = links
        isGone = links.isEmpty == false && links.allSatisfy(\.isGone)
        lengthSeconds = videos.lazy.compactMap(\.durationSeconds).first { $0 > 0 }
    }

    /// Whether only channel members can watch one of its videos.
    var hasMembersOnlyVideo: Bool {
        entry.youtubeMembers.isEmpty == false
    }

    /// Whether the upload answers a search: every word of `query` is found
    /// in its song, original artist, collaborators, albums, a compilation's
    /// songs or its Bilibili title, whatever the case, accents or width.
    func matches(query: String) -> Bool {
        let words = query.split(whereSeparator: \.isWhitespace)
        guard words.isEmpty == false else { return true }
        let fields =
            [entry.song, entry.originalArtist, entry.with, entry.bilibiliTitle] + entry.albums + entry.tracks
        return words.allSatisfy { word in
            fields.contains { field in
                field.range(of: word, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive])
                    != nil
            }
        }
    }

    /// Whether nobody can watch a stored video any more.
    private static func isGone(_ video: WorksUploadVideo) -> Bool {
        video.availability == .removed || video.availability == .private
    }
}

/// A stored video's platform and ID, for matching it with a watch page.
private nonisolated struct StoredVideoKey: Hashable {
    let source: String
    let id: String

    init(source: WorksVideoSource, id: String) {
        self.source = source.rawValue
        self.id = id
    }

    init(platform: VideoPlatform, id: String) {
        source = platform.rawValue
        self.id = id
    }
}
