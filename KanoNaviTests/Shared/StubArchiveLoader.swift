import Foundation
import KanoNaviCore

@testable import KanoNavi

/// Answers archive reads from queues of results: one for the month index and
/// one per page query. The last result of a queue repeats; a query without
/// results is offline.
actor StubArchiveLoader<Item: Sendable> {
    private var monthResults: [Result<ArchiveMonthIndex, APIError>]
    private var pageResults: [ArchiveQuery: [Result<ArchivePage<Item>, APIError>]]
    private(set) var pageRequests: [ArchiveQuery] = []

    init(
        months: [Result<ArchiveMonthIndex, APIError>],
        pages: [ArchiveQuery: [Result<ArchivePage<Item>, APIError>]] = [:]
    ) {
        monthResults = months
        pageResults = pages
    }

    func months() throws -> ArchiveMonthIndex {
        try next(&monthResults)
    }

    func page(_ query: ArchiveQuery) throws -> ArchivePage<Item> {
        pageRequests.append(query)
        var queue = pageResults[query] ?? []
        defer { pageResults[query] = queue }
        return try next(&queue)
    }

    func setPage(_ query: ArchiveQuery, _ results: [Result<ArchivePage<Item>, APIError>]) {
        pageResults[query] = results
    }

    private func next<Value>(_ queue: inout [Result<Value, APIError>]) throws -> Value {
        guard let first = queue.first else { throw APIError.offline }
        if queue.count > 1 {
            queue.removeFirst()
        }
        return try first.get()
    }
}
