import Foundation
import KanoNaviCore

/// Reads the post archive's month index and pages, falling back to the copy
/// cached on this device when the service cannot be read.
nonisolated enum PostArchiveSource {
    /// Posts per archive page.
    static let pageSize = 20

    static func months(client: APIClient) -> ArchiveModel<PostArchiveEntry>.MonthsLoader {
        { ArchiveMonthIndex(try await client.readResult(PostsMonthsRequest())) }
    }

    static func page(client: APIClient) -> ArchiveModel<PostArchiveEntry>.PageLoader {
        { query in
            let result = try await client.readResult(request(for: query))
            let avatars = result.value.accountAvatars
            return ArchivePage(
                items: result.value.items.map { PostArchiveEntry(post: $0, accountAvatars: avatars) },
                page: result.value.page, hasNext: result.value.hasNext,
                total: result.value.total, counts: result.value.accountCounts ?? [:],
                isFromCache: result.isFromCache, fetchedAt: result.fetchedAt)
        }
    }

    /// The request for one page of a month, narrowed to an account.
    static func request(for query: ArchiveQuery) -> PostsRequest {
        PostsRequest(
            from: query.month.first, to: query.month.last, page: query.page, pageSize: pageSize,
            account: query.filter)
    }
}
