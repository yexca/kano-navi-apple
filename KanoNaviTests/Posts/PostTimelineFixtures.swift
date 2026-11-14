import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Synthetic post timeline pages for the timeline model tests.
enum PostTimelineFixtures {
    static func query(
        _ start: ArchiveMonthKey? = nil, account: String? = nil, page: Int = 1
    ) -> PostTimelineQuery {
        PostTimelineQuery(start: start, account: account, page: page)
    }

    /// A page of posts, newest first. An ID starting with `N` is published in
    /// November 2026, any other in October.
    static func page(
        _ ids: [String], page: Int = 1, hasNext: Bool = false, revision: Int = 1,
        handle: String = "kano_example", counts: [String: Int] = ["kano_example": 3, "_sub": 2],
        accountAvatars: [String: URL?]? = nil, isFromCache: Bool = false
    ) throws -> ArchivePage<PostTimelineEntry> {
        let entries = try ids.map { id in
            var json = PostFixtures.json(id: id, handle: handle)
            json["publishedAt"] = id.hasPrefix("N") ? "2026-11-09T10:00:00Z" : "2026-10-09T10:00:00Z"
            return PostTimelineEntry(post: try PostFixtures.post(json), accountAvatars: accountAvatars)
        }
        return ArchivePage(
            items: entries, page: page, hasNext: hasNext, total: ids.count, counts: counts,
            isFromCache: isFromCache,
            fetchedAt: isFromCache ? ArchiveFixtures.cachedAt : ArchiveFixtures.fetchedAt, revision: revision)
    }
}
