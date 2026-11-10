import Foundation
import KanoNaviCore

/// Reads the video archive's month index and pages, falling back to the copy
/// cached on this device when the service cannot be read.
nonisolated enum VideoArchiveSource {
    /// Videos per archive page.
    static let pageSize = 20

    static func months(client: APIClient) -> ArchiveModel<Video>.MonthsLoader {
        { ArchiveMonthIndex(try await client.readResult(VideosMonthsRequest())) }
    }

    static func page(client: APIClient) -> ArchiveModel<Video>.PageLoader {
        { query in
            let result = try await client.readResult(request(for: query))
            return ArchivePage(
                items: result.value.items, page: result.value.page, hasNext: result.value.hasNext,
                total: result.value.total, counts: result.value.categoryCounts ?? [:],
                isFromCache: result.isFromCache, fetchedAt: result.fetchedAt)
        }
    }

    /// The request for one page of a month, narrowed to a category.
    static func request(for query: ArchiveQuery) -> VideosRequest {
        VideosRequest(
            from: query.month.first, to: query.month.last, page: query.page, pageSize: pageSize,
            category: query.filter)
    }
}
