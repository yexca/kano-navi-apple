import Foundation
import KanoNaviCore

/// Reads the video timeline's month index and pages, falling back to the copy
/// cached on this device when the service cannot be read.
nonisolated enum VideoTimelineSource {
    /// Videos per timeline page, the most the API serves, so a filter that
    /// matches few videos needs fewer reads.
    static let pageSize = 50

    static func months(client: APIClient) -> VideoTimelineModel.MonthsLoader {
        { ArchiveMonthIndex(try await client.readResult(VideosMonthsRequest())) }
    }

    static func page(client: APIClient) -> VideoTimelineModel.PageLoader {
        { query in
            page(from: try await client.readResult(request(for: query)))
        }
    }

    /// The newest page as cached on this device, read at once, so the
    /// timeline is on screen from its first frame; `nil` when none is cached.
    static func cachedFirstPage(client: APIClient) -> ArchivePage<Video>? {
        client.cachedResultImmediately(request(for: VideoTimelineQuery(start: nil, page: 1))).map(page(from:))
    }

    private static func page(from result: ReadResult<VideoArchivePage>) -> ArchivePage<Video> {
        ArchivePage(
            items: result.value.items, page: result.value.page, hasNext: result.value.hasNext,
            total: result.value.total, counts: result.value.categoryCounts ?? [:],
            isFromCache: result.isFromCache, fetchedAt: result.fetchedAt)
    }

    /// The request for one timeline page: every dated video, or those dated
    /// on or before the start month's last Japan date.
    static func request(for query: VideoTimelineQuery) -> VideosRequest {
        VideosRequest(until: query.start?.last, page: query.page, pageSize: pageSize)
    }
}
