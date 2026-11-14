import Foundation
import KanoNaviCore

/// Reads the post timeline's month index and pages, falling back to the copy
/// cached on this device when the service cannot be read.
nonisolated enum PostTimelineSource {
    /// Posts per timeline page, the most the API serves.
    static let pageSize = 50

    static func months(client: APIClient) -> PostTimelineModel.MonthsLoader {
        { ArchiveMonthIndex(try await client.readResult(PostsMonthsRequest())) }
    }

    static func page(client: APIClient) -> PostTimelineModel.PageLoader {
        { query in
            page(from: try await client.readResult(request(for: query)))
        }
    }

    /// The newest page of every account as cached on this device, read at
    /// once, so the timeline is on screen from its first frame; `nil` when
    /// none is cached.
    static func cachedFirstPage(client: APIClient) -> ArchivePage<PostTimelineEntry>? {
        client.cachedResultImmediately(request(for: PostTimelineKey().page(1))).map(page(from:))
    }

    private static func page(from result: ReadResult<PostArchivePage>) -> ArchivePage<PostTimelineEntry> {
        let avatars = result.value.accountAvatars
        return ArchivePage(
            items: result.value.items.map { PostTimelineEntry(post: $0, accountAvatars: avatars) },
            page: result.value.page, hasNext: result.value.hasNext, total: result.value.total,
            counts: result.value.accountCounts ?? [:], isFromCache: result.isFromCache,
            fetchedAt: result.fetchedAt, revision: result.value.revision)
    }

    /// The request for one timeline page: every post, or those published on
    /// or before the start month's last Japan date, narrowed to an account.
    static func request(for query: PostTimelineQuery) -> PostsRequest {
        PostsRequest(until: query.start?.last, page: query.page, pageSize: pageSize, account: query.account)
    }
}
