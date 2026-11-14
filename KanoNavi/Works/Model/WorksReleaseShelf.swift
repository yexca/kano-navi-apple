import KanoNaviCore

/// The personal releases as the Releases screen browses them: by Japan year,
/// narrowed to a format, newest or oldest first.
nonisolated struct WorksReleaseShelf: Equatable, Sendable {
    /// The formats with a choice of their own, in the order shown.
    static let filter = WorksCodeFilter(known: ["album", "single", "ep", "doujin"])

    /// The releases in the collection's order, oldest first.
    let releases: [WorksRelease]

    /// The filter's choices: all releases, then each format that has any.
    var options: [ArchiveFilterOption] {
        let all = ArchiveFilterOption(code: nil, label: .localized(.Works.filterAll), count: releases.count)
        let formats = Self.filter.counts(of: releases.map(\.format.rawValue)).map { entry in
            ArchiveFilterOption(
                code: entry.code, label: .localized(WorksCodeLabels.formatFilter(entry.code)),
                count: entry.count)
        }
        return [all] + formats
    }

    /// The releases of `format` (`nil` for all) by year, in `order`.
    func groups(format: String?, order: WorksOrder) -> [WorksYearGroup<WorksRelease>] {
        let shown = releases.filter { Self.filter.matches($0.format.rawValue, selection: format) }
        return WorksYearGroup.groups(of: shown, order: order, date: \.date)
    }
}
