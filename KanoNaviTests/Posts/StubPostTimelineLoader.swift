import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Answers post timeline reads from queues of results: one for the month
/// index and one per page query. The last result of a queue repeats; a query
/// without results is offline. A page may wait on a gate first.
actor StubPostTimelineLoader {
    private var monthResults: [Result<ArchiveMonthIndex, APIError>]
    private var pageResults: [PostTimelineQuery: [Result<ArchivePage<PostTimelineEntry>, APIError>]]
    private var gates: [PostTimelineQuery: TestGate] = [:]
    private(set) var pageRequests: [PostTimelineQuery] = []
    private(set) var monthRequests = 0

    init(
        months: [Result<ArchiveMonthIndex, APIError>] = [],
        pages: [PostTimelineQuery: [Result<ArchivePage<PostTimelineEntry>, APIError>]] = [:]
    ) {
        monthResults = months
        pageResults = pages
    }

    func months() throws -> ArchiveMonthIndex {
        monthRequests += 1
        return try next(&monthResults)
    }

    func page(_ query: PostTimelineQuery) async throws -> ArchivePage<PostTimelineEntry> {
        pageRequests.append(query)
        if let gate = gates[query] {
            try await gate.wait()
        }
        var queue = pageResults[query] ?? []
        defer { pageResults[query] = queue }
        return try next(&queue)
    }

    func setPage(_ query: PostTimelineQuery, _ results: [Result<ArchivePage<PostTimelineEntry>, APIError>]) {
        pageResults[query] = results
    }

    func hold(_ query: PostTimelineQuery, until gate: TestGate) {
        gates[query] = gate
    }

    func clearRequests() {
        pageRequests = []
    }

    private func next<Value>(_ queue: inout [Result<Value, APIError>]) throws -> Value {
        guard let first = queue.first else { throw APIError.offline }
        if queue.count > 1 {
            queue.removeFirst()
        }
        return try first.get()
    }
}
