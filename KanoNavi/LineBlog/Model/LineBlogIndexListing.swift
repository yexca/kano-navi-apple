import Foundation
import KanoNaviCore

/// The archive's articles grouped by the Japan month they were published
/// in, and those months by year, in the order the service lists them
/// (newest first).
nonisolated struct LineBlogIndexListing: Equatable, Sendable {
    /// One Japan month with its articles.
    struct Month: Identifiable, Equatable, Sendable {
        let key: ArchiveMonthKey
        let posts: [LineBlogPostSummary]

        var id: String { key.rawValue }
    }

    /// One year with its months.
    struct Year: Identifiable, Equatable, Sendable {
        let year: Int
        let months: [Month]

        var id: Int { year }
        /// The number of articles in the year.
        var total: Int { months.reduce(0) { $0 + $1.posts.count } }
    }

    let months: [Month]
    let years: [Year]

    init(posts: [LineBlogPostSummary]) {
        var order: [ArchiveMonthKey] = []
        var grouped: [ArchiveMonthKey: [LineBlogPostSummary]] = [:]
        for post in posts {
            let key = ArchiveMonthKey(containing: JapanDate.date(from: post.published))
            if grouped[key] == nil {
                order.append(key)
            }
            grouped[key, default: []].append(post)
        }
        let months = order.map { Month(key: $0, posts: grouped[$0] ?? []) }
        self.months = months

        var years: [Year] = []
        for month in months {
            let year = month.key.first.year
            if let index = years.firstIndex(where: { $0.year == year }) {
                years[index] = Year(year: year, months: years[index].months + [month])
            } else {
                years.append(Year(year: year, months: [month]))
            }
        }
        self.years = years
    }
}
