import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Answers video timeline reads from queues of results: one for the month
/// index and one per page query. The last result of a queue repeats; a query
/// without results is offline. A page may wait on a gate first.
actor StubVideoTimelineLoader {
    private var monthResults: [Result<ArchiveMonthIndex, APIError>]
    private var pageResults: [VideoTimelineQuery: [Result<ArchivePage<Video>, APIError>]]
    private var gates: [VideoTimelineQuery: TestGate] = [:]
    private(set) var pageRequests: [VideoTimelineQuery] = []

    init(
        months: [Result<ArchiveMonthIndex, APIError>] = [],
        pages: [VideoTimelineQuery: [Result<ArchivePage<Video>, APIError>]] = [:]
    ) {
        monthResults = months
        pageResults = pages
    }

    func months() throws -> ArchiveMonthIndex {
        try next(&monthResults)
    }

    func page(_ query: VideoTimelineQuery) async throws -> ArchivePage<Video> {
        pageRequests.append(query)
        if let gate = gates[query] {
            try await gate.wait()
        }
        var queue = pageResults[query] ?? []
        defer { pageResults[query] = queue }
        return try next(&queue)
    }

    func setPage(_ query: VideoTimelineQuery, _ results: [Result<ArchivePage<Video>, APIError>]) {
        pageResults[query] = results
    }

    func hold(_ query: VideoTimelineQuery, until gate: TestGate) {
        gates[query] = gate
    }

    private func next<Value>(_ queue: inout [Result<Value, APIError>]) throws -> Value {
        guard let first = queue.first else { throw APIError.offline }
        if queue.count > 1 {
            queue.removeFirst()
        }
        return try first.get()
    }
}
